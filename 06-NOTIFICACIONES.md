# 06 · Notificaciones

Dos canales, con una regla para elegir: **si no necesita servidor, es local.**

---

## 1. Notificaciones locales (`flutter_local_notifications`)

Para todo lo que la app puede calcular sola con los datos que ya tiene en Drift. No consumen
cuota, funcionan sin señal y no dependen de que FCM entregue.

| Aviso | Cuándo | Regla |
|---|---|---|
| Recordatorio de retoque | 10:00 | Regla del legacy: último turno `done` de la clienta + `retoque_dias` del servicio; se avisa si faltan entre −3 y +7 días |
| Turnos de mañana | 20:00 | Resumen: "Mañana tenés 4 turnos, el primero a las 9:00" |
| Cierre de caja | 21:00, si hubo movimientos | "Cerraste el día con $X" |
| Stock bajo | al abrir la app, máximo una vez por día | Productos con `cantidad <= minimo` |
| Cumpleaños de clienta | 9:00 | El legacy ya lo hace con un toast a los 1200 ms del arranque |

Se programan al abrir la app y tras cada sync, cancelando y reprogramando (no acumulando).

---

## 2. Push remoto (FCM)

Para lo que solo el servidor sabe. Firebase se usa **exclusivamente** para esto: la identidad y
los datos son de Supabase.

| Aviso | Destinatario | Origen |
|---|---|---|
| Licencia por vencer (7, 3, 1 día) | owner del tenant + revendedor | cron `chequear-vencimientos` |
| Tenant suspendido | owner | cron |
| Usuario nuevo pendiente de aprobación | owner y admins del tenant | trigger al insertar en `tenant_members` |
| Versión nueva disponible | toda la flota | manual desde el panel |
| Mensaje global | toda la flota | campo `app_config.mensaje_global` |

### Registro de tokens

Tabla `device_tokens (user_id, tenant_id, token, plataforma)`. El token se registra al loguearse y
se refresca con `onTokenRefresh`. Al cerrar sesión se borra el token de ese dispositivo — si no, la
persona que use el teléfono después recibe notificaciones ajenas.

### Envío

Edge Function `enviar-push`: recibe `{tenant_id | user_ids, titulo, cuerpo, data}`, busca los
tokens y hace el fan-out contra la API HTTP v1 de FCM con la service account.

Ojo con lo aprendido en la-union-app: si se invoca desde `pg_net`, el `timeout_milliseconds` es
obligatorio, o la llamada puede quedar colgada.

---

## 3. Configuración de Firebase

El proyecto `mirame-lash-studio-41ba9` ya existe (lo usa la app legacy para Auth). Se reutiliza
**solo para Messaging**:

1. Agregar una app Android con `applicationId = com.mirame.app`.
2. Descargar `google-services.json` → `app_flutter/android/app/`. **No se commitea** (va como
   secret en CI).
3. Registrar el SHA-1 del keystore de release.
4. Generar la service account key para las Edge Functions (secret de Supabase, nunca en el cliente).

En **web** el push requiere además una VAPID key y un `firebase-messaging-sw.js`. Es opcional: la
PWA puede vivir sin push, y las notificaciones locales cubren lo importante. Se deja para después.

---

## 4. Permisos

- **Android 13+** exige `POST_NOTIFICATIONS` en runtime.
- **No pedirlo al arrancar.** Se pide en contexto, la primera vez que la usuaria hace algo que se
  beneficia: al crear su primer turno, con una línea explicando qué va a recibir ("te aviso el día
  anterior"). Un permiso pedido en frío se rechaza y después no hay segunda oportunidad fácil.
- Si lo rechaza, la app funciona igual. Los recordatorios quedan visibles dentro de la app, en el
  panel de notificaciones que ya existe.

---

## 5. WhatsApp sigue siendo el canal hacia las clientas

Nada de esto reemplaza a WhatsApp. Las clientas del salón **no tienen la app**: el contacto con
ellas sigue siendo por `wa.me`, con los 5 generadores de mensajes del legacy portados tal cual
(turnos libres, catálogo de servicios, stock, promo, reactivación).

Las notificaciones de este documento son para **quien trabaja en el salón**, no para las clientas.

---

## 6. Estado de la implementación (2026-08-24)

| Pieza | Dónde | Estado |
|---|---|---|
| Reglas de qué avisar | `lib/domain/rules/avisos.dart` | ✅ con 13 tests |
| Motor local (canales, agenda, tap) | `lib/core/notificaciones/servicio_avisos.dart` | ✅ |
| Reprogramación con los datos vivos | `lib/features/shell/programador_avisos.dart` | ✅ |
| Pedido de permiso en contexto | `lib/core/notificaciones/pedir_permiso.dart` | ✅ tras guardar un turno |
| Tabla `device_tokens` + RPCs | `sql/07_notificaciones.sql` | ✅ aplicada |
| Cliente FCM | `lib/core/notificaciones/push.dart` | ✅ pero **inerte** sin `google-services.json` |
| Edge Function `enviar-push` | `supabase/functions/enviar-push/index.ts` | ✅ escrita, **sin desplegar** |
| Cron de vencimientos | — | ⬜ |

### Qué proyecto de Firebase se usa, y por qué

**`mirame-lash-studio-41ba9`** — el que la app legacy ya usa para Auth. Sus identificadores
(`apiKey`, `messagingSenderId 998613317742`, `projectId`) ya están a la vista en el `index.html`
público, así que no hay nada secreto en reutilizarlos.

**NO se usa `gestor-local-celulares`**, que es el de DisT-At (`com.launion.app`). Compartir
proyecto entre las dos flotas significa que un error de segmentación le manda a los repartidores
un aviso de retoque de pestañas. Son negocios distintos y quedan separados.

**No hay `google-services.json`.** La config va por Dart en `firebase_options.dart`, así no hay
archivo que commitear ni secret de CI que mantener. El único valor que se pasa aparte es el App ID
de Android, por `--dart-define=FIREBASE_ANDROID_APP_ID`, que en el workflow sale del secret del
mismo nombre.

### Lo que falta para que el push funcione de verdad

Tres pasos, y **solo el primero es imprescindible**:

1. **Registrar la app Android** (30 segundos, es lo único que no se puede hacer desde acá).
   Firebase Console → `mirame-lash-studio-41ba9` → ⚙️ → *Agregar app* → Android → package name
   `com.mirame.app` → **Registrar**. No hace falta bajar el archivo ni poner el SHA-1: el SHA-1 es
   para Google Sign-In nativo, y el login va por OAuth web de Supabase.
   Copiar el **App ID** (`1:998613317742:android:…`) y cargarlo como secret
   `FIREBASE_ANDROID_APP_ID` en GitHub.
   → Con esto los teléfonos ya registran su token en `device_tokens`.
2. Service account (⚙️ → Cuentas de servicio → Generar clave privada) como secret
   `FIREBASE_SERVICE_ACCOUNT` en Supabase. → Con esto se puede *enviar*.
3. `supabase functions deploy enviar-push`.

Hasta entonces `Push.disponible` es `false`, Ajustes lo muestra como *"No configurado"* y
**todo lo local sigue andando**: es la parte que la dueña usa todos los días.

Los tres canales de Android (`Agenda`, `Caja`, `Stock`) se crean al iniciar, así que se pueden
silenciar por separado desde los ajustes del sistema sin perder los otros.

---

## 7. Verificación

- [ ] El recordatorio de retoque se dispara con la misma regla que el legacy (−3 a +7 días).
- [ ] Rechazar el permiso de notificaciones no rompe nada.
- [ ] Cerrar sesión borra el token de ese dispositivo.
- [ ] Un aviso de licencia por vencer llega al owner y al revendedor, no a otros tenants.
- [ ] Las notificaciones locales se reprograman, no se duplican, tras varios arranques seguidos.
