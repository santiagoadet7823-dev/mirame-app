# 04 · Auth, roles y tenancy

> **Acá arranca el desarrollo.** Es la Fase 2 y bloquea todo lo demás.

---

## 1. Decisión: Supabase Auth, no Firebase Auth

El legacy usa **Firebase Auth** (Google Sign-In) + una whitelist manual en Firestore
(`users/{uid}` con `status: pending | approved | blocked`).

Se migra a **Supabase Auth**. Motivos:

- Las RLS de Postgres necesitan `auth.uid()` **de Supabase**. Con Firebase Auth habría que emitir
  y validar un JWT custom, o mantener un mapeo de UIDs — trabajo permanente y frágil.
- Sostener dos proveedores de identidad para el mismo usuario es la fuente de bugs número uno en
  este tipo de migración: sesiones que caducan a destiempo, un lado logueado y el otro no.
- Supabase Auth ya trae el Google OAuth resuelto en móvil y web.

**Firebase se queda solo para FCM** (push). El proyecto `mirame-lash-studio-41ba9` ya existe y se
reutiliza tal cual.

Lo que se pierde: los usuarios actuales tienen que volver a loguearse una vez. Como hoy es
prácticamente una sola usuaria, el costo es nulo.

---

## 2. Flujo completo

```
arranque
   │
   ├─ ¿hay sesión de Supabase persistida?
   │     no → /login  (botón de Google, mismo diseño que hoy)
   │     sí ↓
   │
   ├─ ¿hay red?
   │     no → entrar con el perfil y las membresías cacheados en Drift
   │           (gracia de licencia: 7 días desde el último chequeo exitoso)
   │     sí ↓
   │
   ├─ cargar profile + tenant_members  →  guardar en Drift
   │
   ├─ profile.plataforma_rol == 'superadmin'
   │     → /admin  (y puede "entrar como" cualquier tenant)
   │
   ├─ sin membresías aprobadas ni pendientes
   │     → /pendiente  (se auto-inserta como 'pending' y avisa por WhatsApp)
   │
   ├─ membresía en estado 'pending'
   │     → /pendiente
   │
   ├─ membresía en estado 'blocked'
   │     → /bloqueado
   │
   ├─ tenant suspendido / cancelado / licencia vencida
   │     → /vencido  ("Venció el DD/MM/AAAA")
   │
   └─ aprobada + licencia vigente
         → /app  con el tenant activo
```

Es el mismo árbol que `authCheckFirestore()` del legacy, con dos agregados: el nivel de
plataforma (superadmin) y el de licencia por tenant.

---

## 3. Offline-first en el gate de acceso

El legacy ya hacía lo correcto y hay que conservarlo: **sin red, se entra igual**. Una dueña que
abre la app en el salón sin señal tiene que poder ver la agenda del día.

Reglas:

- La sesión de Supabase se persiste local (`persistSession: true`) y sobrevive al reinicio.
- `profile` y `tenant_members` se cachean en Drift en cada login exitoso.
- La verificación de licencia tiene **7 días de gracia** desde el último chequeo exitoso. Después
  de eso, sin poder validar, la app pasa a `/vencido`. Es un compromiso: sin gracia, un fin de
  semana sin señal deja a la dueña afuera; sin límite, una licencia impaga nunca se corta.
- El estado de gracia se muestra sutilmente (no un cartel alarmante) para que no sorprenda.

---

## 4. Roles

### 4.1 Plataforma

`profiles.plataforma_rol = 'superadmin'` — dos personas: el dueño del producto y el revendedor.

**Se siembra solo por SQL** (`sql/05_seed_superadmins.sql`). No hay pantalla que lo otorgue, y la
policy de `profiles` bloquea la auto-promoción. Es a propósito.

### 4.2 Tenant

`tenant_members.rol`:

| Rol | Puede |
|---|---|
| `owner` | Todo dentro del salón, incluido invitar y aprobar usuarios y editar los datos del salón |
| `admin` | Igual que owner, sin borrar el tenant |
| `profesional` | Agenda, clientas, caja, stock. Sin ajustes del salón ni gestión de usuarios |
| `lectura` | Solo ver |

Un mismo usuario puede pertenecer a varios tenants con roles distintos (útil para una profesional
que trabaja en dos salones).

### 4.3 El revendedor, en concreto

Es un `superadmin`, y según lo definido puede:

| Capacidad | Cómo se implementa |
|---|---|
| Crear salones | RPC `crear_tenant` → queda como `creado_por` |
| Suspender / reactivar | `update tenants set estado` |
| Gestionar usuarios de cada tenant | policy `members_manage` incluye `es_revendedor_de` |
| Ver datos de negocio de sus tenants | policy de `select` incluye `es_revendedor_de` |
| Facturación y licencias | RPC `renovar_licencia` + `licencia_pagos` |

**No puede escribir** datos de negocio ajenos (agenda, clientas, caja de otro salón). Ve para dar
soporte; no opera el salón de otro.

Y **toda lectura cross-tenant queda en `audit_log`**, visible para el propio salón. Ver
`03-BACKEND-SUPABASE.md` §5.

---

## 5. Modo "entrar como" (impersonar)

El superadmin puede abrir un tenant y ver la app tal como la ve el salón.

Requisitos no negociables:

1. Se registra en `audit_log` con `accion = 'impersonar'` **al entrar**, no al hacer cada cosa.
2. Mientras dura, hay un **banner persistente** arriba: "Viendo *Nombre del salón* como
   administrador de plataforma", con un botón de salir. No se puede olvidar en qué modo se está.
3. Todas las escrituras quedan deshabilitadas para el revendedor (las RLS ya lo garantizan; la UI
   además esconde los botones, para no ofrecer acciones que van a fallar).
4. El tenant activo se guarda en el `SessionController`, no en una variable global.

---

## 6. `SessionController` (Riverpod)

```dart
class SessionState {
  final User? user;
  final Profile? profile;
  final List<Membership> memberships;
  final Tenant? activeTenant;
  final LicenseStatus license;      // vigente | gracia | vencida | desconocida
  final bool impersonating;
  final AuthGate gate;              // splash | login | pending | blocked | expired | ready
}
```

Es el único lugar que decide el `gate`. El router lo lee; ninguna pantalla lo recalcula.

Al cambiar de tenant activo se invalidan los providers de datos, para que ninguna lista quede
mostrando filas del salón anterior.

---

## 7. Configuración de Google OAuth

**Web (PWA):** el flujo normal de Supabase con redirect a la URL de GitHub Pages.

**Nativo (APK):** `signInWithOAuth` con `redirectTo: 'com.mirame.app://auth'` y el intent-filter
correspondiente en el `AndroidManifest.xml` (dentro de `MainActivity`, que es `singleTop`; lo
captura `app_links`, dependencia de `supabase_flutter`).

> **No hace falta un OAuth client de tipo *Android* ni registrar el SHA-1 del keystore.** Ese
> requisito es del plugin `google_sign_in`, que usa el SDK nativo de Google. Acá el flujo es
> **web**: la app abre un Custom Tab contra el client de tipo *Web application* de Supabase, y
> vuelve por el deep link. Google nunca ve la firma del APK. Se aclara porque es un desvío fácil
> de tomar y cuesta una tarde.

### Los TRES lugares donde se cargan URLs (se confunden fácil)

Son campos distintos, en dos consolas distintas, con reglas distintas. Cargar solo uno hace que el
login falle con un `redirect_uri_mismatch` que no explica nada.

**1. Google Cloud Console → OAuth client ID (tipo *Web application*) → Authorized JavaScript origins**

De dónde sale la petición. **Sin ruta, sin wildcards, con el puerto exacto.**

```
http://localhost:8899
https://santiagoadet7823-dev.github.io
```

**2. Google Cloud Console → el mismo client → Authorized redirect URIs**

A dónde vuelve Google. Una sola, la de Supabase — nunca la de la app.

```
https://hanljsmsgvezuhmehqla.supabase.co/auth/v1/callback
```

**3. Supabase → Authentication → URL Configuration → Redirect URLs**

A dónde rebota Supabase después. **Acá sí se aceptan wildcards.**

```
http://localhost:*
com.mirame.app://auth
https://santiagoadet7823-dev.github.io/mirame-app/
```

> ⚠️ **Google no acepta `localhost:*`.** Como `flutter run -d chrome` elige un puerto aleatorio en
> cada corrida, hay que fijarlo o el login falla de forma intermitente y desconcertante:
>
> ```bash
> flutter run -d chrome --web-port=8899 --dart-define-from-file=env.json
> ```
>
> Es el puerto de `.claude/launch.json`. Si se cambia, hay que actualizarlo también en Google.

**Nativo (APK):** el flujo va por el navegador del sistema y vuelve por `com.mirame.app://auth`, así
que usa el mismo client web. Solo haría falta un OAuth client de tipo Android (con el SHA-1 del
keystore) si en el futuro se pasa a Google Sign-In nativo.

### Cómo verificar la configuración sin loguearse

Toda la config de OAuth se puede comprobar contra el servidor, sin credenciales:

```bash
B=https://hanljsmsgvezuhmehqla.supabase.co/auth/v1

# 1. ¿El provider está habilitado? Un 302 a accounts.google.com = sí.
curl -s -o /dev/null -w "%{http_code}
"   "$B/authorize?provider=google&redirect_to=http%3A%2F%2Flocalhost%3A8899"

# 2. ¿Qué client_id está usando realmente Supabase?
curl -s -D - -o /dev/null "$B/authorize?provider=google&redirect_to=http%3A%2F%2Flocalhost%3A8899"   | grep -i '^location:'

# 3. ¿Google acepta la config? Seguir la cadena: si termina en la pantalla de
#    login sin `redirect_uri_mismatch` ni `invalid_client`, está bien.
curl -s -L -A "Mozilla/5.0" -o /tmp/g.html -w "%{url_effective}
" "<la Location del paso 2>"
grep -o "redirect_uri_mismatch\|invalid_client\|Access blocked" /tmp/g.html
```

Dos cosas que este chequeo encontró en la puesta a punto real:

- El endpoint público `/settings` reportaba `external.google: null` **aunque el provider ya estaba
  habilitado**. Le creemos a `/authorize`, que ejecuta el flujo de verdad; `/settings` parece
  cachear.
- El `client_id` que Supabase enviaba **no era** el que se creyó configurar. En el proyecto de
  Google había varios clients (incluido el del backup a Drive del HTML viejo, que ya no se usa).
  El paso 2 de arriba es la forma rápida de saber cuál está realmente en uso.

**Magic link por email** queda habilitado como respaldo: si Google falla en un dispositivo, hay
una segunda puerta y no se pierde el acceso al salón.

---

## 8. Lo que se conserva del legacy

- **Acceso oculto al panel admin**: triple tap en el logo dentro de 600 ms, o `Ctrl+Shift+A` en
  teclado. Es un gesto que la dueña ya conoce; no hay razón para cambiarlo.
- **Pantalla de pendiente** con el botón de WhatsApp al administrador, mostrando el email del
  solicitante en un pill.
- **Pantalla de vencido** con la fecha exacta: "Venció el DD/MM/AAAA".
- El texto del footer del login: la nota sobre usuarias autorizadas, con el icono de candado.

---

## 9. Verificación de la Fase 2

- [ ] Login con Google funciona en la PWA.
- [ ] Login con Google funciona en el APK (deep link vuelve a la app).
- [ ] Usuario nuevo sin membresía → `/pendiente`, y aparece en `tenant_members` como `pending`.
- [ ] Aprobarlo desde el panel → entra a `/app` al reintentar.
- [ ] Bloquearlo → `/bloqueado`.
- [ ] Vencer la licencia del tenant a mano → `/vencido` con la fecha correcta.
- [ ] Modo avión con sesión previa → entra igual, con los datos cacheados.
- [ ] Modo avión más de 7 días sin validar → `/vencido`.
- [ ] Superadmin entra a `/admin`, "entra como" un tenant y ve el banner.
- [ ] La impersonación queda registrada en `audit_log`, y el owner del salón la puede ver.
- [ ] Cerrar sesión limpia la sesión, el cache local y vuelve a `/login`.
