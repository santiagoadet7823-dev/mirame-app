# 01 · Arquitectura

---

## 1. La regla que ordena todo

```
Widget ─watch()→ Repositorio ─watch()→ Drift (SQLite)   ← única fuente de verdad de la UI
                      │
                      └─write()→ Drift + fila en `outbox`
                                        │
                                   SyncEngine ─push→ Supabase
                                        └───── pull ──┘
```

**La UI nunca espera a la red.** Si una pantalla muestra un spinner mientras consulta Supabase,
está mal escrita: tiene que leer de Drift, que responde en microsegundos y funciona en modo avión.

Consecuencia práctica: ningún widget importa `supabase_flutter`. Si aparece ese import fuera de
`data/remote/` y `features/auth/`, es un bug.

---

## 2. Capas

```
lib/
├── main.dart
│     bootstrap: carga config, abre Drift, inicializa Supabase y Firebase,
│     arranca el SyncEngine, monta el router.
│
├── core/
│   ├── config/app_config.dart     valores por --dart-define, sin secretos en el repo
│   ├── theme/                     tokens · app_theme · shadows · motion
│   ├── result.dart                Result<T> — errores tipados, sin excepciones sueltas
│   ├── audit.dart                 interceptor de acceso cross-tenant
│   └── extensions/                fechas, formato de moneda, strings
│
├── domain/                        ← SIN dependencias de Flutter ni de paquetes
│   ├── entities/                  Appointment · Client · Transaction · StockItem · Service …
│   ├── rules/                     proyección, recordatorios, cierre de caja, stats, solapamientos
│   └── value_objects/             Money, TenantId, Phone
│
├── data/
│   ├── local/                     Drift: tables.dart · database.dart · daos/
│   ├── remote/                    supabase_client.dart · mappers/
│   ├── sync/                      sync_engine.dart · outbox.dart · conflict.dart · cursor.dart
│   └── repositories/              uno por entidad — la ÚNICA puerta entre features y datos
│
├── features/
│   ├── auth/                      splash · login · pending · blocked · expired
│   ├── shell/                     AppShell · nav · header · panel de notificaciones
│   ├── dashboard/ agenda/ crm/ caja/ stock/ stats/ settings/
│   └── admin/                     tenants · licencias · usuarios · auditoría
│
└── shared/widgets/                Chip · Pill · Sheet · Toggle · EmptyState · Fab · KpiCard · Avatar
```

### Por qué `domain/` no depende de nada

Las reglas de negocio del legacy son la parte que más duele si se rompe: la proyección del mes, el
margen, el cierre de caja, los recordatorios de retoque, el cálculo del donut. Aisladas en
`domain/` se testean con `dart test` puro, sin emulador, en milisegundos. Son las únicas pruebas
que este proyecto **necesita** tener.

---

## 3. Stack

| Necesidad | Elección | Por qué |
|---|---|---|
| State | **Riverpod** | Funciona igual en móvil y web, testeable, sin el boilerplate de eventos de BLoC |
| Router | **go_router** | La PWA necesita URLs reales. El legacy no tenía rutas: `nav()` solo togglea `.active`, así que en web no se puede compartir un link ni volver con el botón atrás |
| Base local | **Drift** | SQL tipado, `watch()` reactivo, migraciones versionadas, corre en web vía WASM |
| Backend | **supabase_flutter** | Auth + Postgres + Realtime + Storage en un cliente |
| HTTP / descargas | **dio** | Progreso de descarga para el updater del APK |
| Push | **firebase_messaging** | Lo único que Supabase no cubre |
| Notif. locales | **flutter_local_notifications** | Recordatorios sin servidor |
| Iconos | **flutter_svg** | Los 12 SVG Feather del original |
| Fechas / formato | **intl** | `es_AR`, separador de miles con punto |
| Versión instalada | **package_info_plus** | El updater compara contra `min_version` |
| Red | **connectivity_plus** | Dispara el drenaje del outbox |
| WhatsApp | **url_launcher** | `wa.me` — el canal hacia las clientas se mantiene |
| Export CSV | **share_plus** | Compartir el archivo generado |
| Auto-update APK | **plugin propio (Kotlin)** | Ningún paquete de pub implementa la instalación silenciosa de Android 12+ |

Charts: **ninguna librería**. El donut y las barras se dibujan con `CustomPainter`. El original los
hace con SVG y CSS a mano y pesan cero; meter `fl_chart` para replicar un donut de 110 px sería
cambiar peso por nada.

---

## 4. Rutas

```
/                       → splash / redirect según sesión
/login
/pendiente
/bloqueado
/vencido
/app                    → shell con las 5 pestañas
   /app/inicio
   /app/agenda
   /app/clientas
   /app/clientas/:id
   /app/caja
   /app/stock
   /app/stats           ← no es pestaña: se llega desde la quick action del dashboard
   /app/ajustes         ← no es pestaña: se llega desde el engranaje del header
/admin                  → solo superadmin
   /admin/tenants
   /admin/tenants/:id
   /admin/usuarios
   /admin/auditoria
```

Las guardas viven en `redirect` de `go_router` y consultan el `SessionController`. Detalle en
`04-AUTH-Y-ROLES.md`.

---

## 5. Configuración sin secretos en el repo

```dart
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
}
```

```bash
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=eyJ...
```

En local se usa un `--dart-define-from-file=env.json` (ignorado por git). En CI vienen de secrets.

La **anon key es pública por diseño** — va horneada en el bundle web y en el APK, y no pasa nada:
la seguridad la dan las RLS. La que **nunca** puede tocar el cliente es la **service-role key**;
esa vive solo en secrets de GitHub Actions y en las Edge Functions.

---

## 6. Manejo de errores

```dart
sealed class Result<T> {}
class Ok<T> extends Result<T> { final T value; }
class Err<T> extends Result<T> { final AppError error; }
```

Los repositorios devuelven `Result`, no lanzan. La UI decide qué mostrar. El equivalente del
`toast()` del legacy es un `AppSnackbar` con el mismo lenguaje visual.

Errores de red **no son errores**: en una app local-first, quedarse sin señal es un estado normal.
Se refleja en un indicador de "pendiente de sincronizar", no en un mensaje de error.

---

## 7. Tests

| Qué | Cómo | Prioridad |
|---|---|---|
| `domain/rules/` | `dart test` puro | **Alta** — es lo que rompe silenciosamente |
| Motor de sync | tests de integración con Drift en memoria | **Alta** — sobre todo el caso de los deltas de stock |
| Repositorios | Drift en memoria + fake de Supabase | Media |
| Widgets | `flutter_test` de los componentes de `shared/widgets/` | Baja |
| RLS | queries manuales en el SQL Editor (`03-BACKEND-SUPABASE.md` §10) | **Alta** |

No se persigue cobertura. Se testea lo que, si se rompe, entrega números equivocados a alguien que
está cobrando plata con ellos.
