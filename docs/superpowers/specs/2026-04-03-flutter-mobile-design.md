# Flutter Mobile — Diseño de Implementación
**Fecha:** 2026-04-03  
**Proyecto:** App de Eventos Situacionistas  
**Stack:** Flutter 3.x · BLoC · GoRouter · Dio · SignalR  
**Basado en:** MOBILE_SPEC.md + backend ASP.NET Core 9 implementado

---

## 1. Contexto

La app móvil es la interfaz principal de una capa invisible sobre la ciudad. No es una red social. Permite crear y participar en eventos efímeros, explorar la ciudad en modo deriva (instrucciones generadas por IA) y completar misiones con pistas encadenadas.

El backend está implementado en ASP.NET Core 9 con Vertical Slice Architecture. Todos los endpoints están disponibles. Base URL: `https://api.situationist.app`.

---

## 2. Arquitectura de capas

```
UI (Pages + Widgets)
        ↓ eventos/estados
    BLoC (flutter_bloc)
        ↓ llamadas async
   Repository (interfaz abstracta + impl concreta)
        ↓ HTTP / SignalR
  ApiClient (Dio + interceptors) / SignalRService
        ↓
   Backend ASP.NET Core 9
```

### Repositorios por feature

| Repositorio | Interfaz | Operaciones |
|---|---|---|
| `AuthRepository` | `IAuthRepository` | login, logout, getMe |
| `EventsRepository` | `IEventsRepository` | nearby, detail, create, generate, participate, cancel |
| `DerivaRepository` | `IDerivaRepository` | start, nextInstruction, complete, abandon |
| `MissionsRepository` | `IMissionsRepository` | nearby, detail, start, submitAnswer, hint, progress |
| `ProfileRepository` | `IProfileRepository` | profile, activityLog (cursor pagination) |

Cada BLoC recibe la interfaz abstracta por constructor. Los tests inyectan mocks con `mocktail`.

### SignalR

`SignalRService` (singleton en core) expone un `Stream<SignalREvent>`. El `MapBloc` se suscribe y reacciona a `EventExpired` / `EventFull`. La conexión se autentica via query param `access_token` y usa reconexión automática.

---

## 3. Estructura de carpetas

```
mobile/
├── lib/
│   ├── main.dart
│   ├── app.dart                        # MaterialApp + ThemeData + GoRouter
│   ├── core/
│   │   ├── auth/
│   │   │   ├── auth_service.dart       # JWT: lectura, escritura, expiración
│   │   │   └── auth_guard.dart         # GoRouter redirect
│   │   ├── network/
│   │   │   ├── api_client.dart         # Dio + AuthInterceptor
│   │   │   └── api_exception.dart      # Mapeado de errores HTTP
│   │   ├── location/
│   │   │   └── location_service.dart   # geolocator wrapper
│   │   ├── realtime/
│   │   │   └── signalr_service.dart    # HubConnection + streams
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   └── widgets/
│   │       ├── mono_text.dart
│   │       ├── void_button.dart
│   │       ├── typewriter_text.dart
│   │       ├── glitch_text.dart
│   │       └── scanlines_overlay.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── bloc/auth_bloc.dart
│   │   │   ├── data/
│   │   │   │   ├── i_auth_repository.dart
│   │   │   │   └── auth_repository.dart
│   │   │   ├── pages/login_page.dart
│   │   │   └── pages/splash_page.dart
│   │   ├── map/
│   │   │   ├── bloc/map_bloc.dart
│   │   │   ├── pages/map_page.dart
│   │   │   └── widgets/event_detail_sheet.dart
│   │   ├── events/
│   │   │   ├── bloc/events_bloc.dart
│   │   │   ├── data/
│   │   │   │   ├── i_events_repository.dart
│   │   │   │   └── events_repository.dart
│   │   │   └── pages/create_event_page.dart
│   │   ├── deriva/
│   │   │   ├── bloc/deriva_bloc.dart
│   │   │   ├── data/
│   │   │   │   ├── i_deriva_repository.dart
│   │   │   │   └── deriva_repository.dart
│   │   │   ├── pages/deriva_home_page.dart
│   │   │   └── pages/deriva_active_page.dart
│   │   ├── missions/
│   │   │   ├── bloc/missions_bloc.dart
│   │   │   ├── data/
│   │   │   │   ├── i_missions_repository.dart
│   │   │   │   └── missions_repository.dart
│   │   │   ├── pages/missions_page.dart
│   │   │   ├── pages/mission_detail_page.dart
│   │   │   └── pages/mission_active_page.dart
│   │   └── profile/
│   │       ├── bloc/profile_bloc.dart
│   │       ├── data/
│   │       │   ├── i_profile_repository.dart
│   │       │   └── profile_repository.dart
│   │       └── pages/profile_page.dart
│   └── shared/
│       ├── models/
│       │   ├── event_model.dart
│       │   ├── deriva_session_model.dart
│       │   ├── clue_model.dart
│       │   ├── mission_model.dart
│       │   ├── mission_progress_model.dart
│       │   └── profile_model.dart
│       └── extensions/
│           └── datetime_extensions.dart
└── test/
    ├── features/auth/auth_bloc_test.dart
    ├── features/events/events_bloc_test.dart
    ├── features/deriva/deriva_bloc_test.dart
    └── features/missions/missions_bloc_test.dart
```

---

## 4. Navegación (GoRouter)

```
/ (SplashPage — verifica JWT, redirige)
/login
/home (ShellRoute — bottom nav 4 tabs)
  /home/map
  /home/deriva
  /home/missions
  /home/create
/home/events/:id      (push sobre ShellRoute)
/home/deriva/active   (pantalla inmersiva, sin bottom nav)
/home/missions/:id
/home/missions/:id/active
/profile
```

**Bottom nav** — 4 destinos, solo caracteres Unicode, sin labels de texto:

```
⌀  /home/map
↺  /home/deriva
◈  /home/missions
⊕  /home/create
```

Indicador de tab activa: línea superior 2px `accent-phosphor`.

**AuthGuard:** redirect en `GoRouter.redirect`. Sin JWT → `/login`. Con JWT en splash → `/home/map`.

---

## 5. Autenticación — OAuth callback (opción B)

El flujo concreto dado que el backend devuelve JSON (no redirige a custom scheme):

```
1. flutter_web_auth_2.authenticate(
     url: '$baseUrl/auth/login/google',
     callbackUrlScheme: 'situationist'
   )
2. El WebView sigue el redirect a /auth/callback/google?code=XXX
3. La app captura la URL final de la respuesta del WebView
4. Hace GET a esa URL con Dio para obtener el AuthResponse JSON
5. Extrae accessToken, lo persiste en flutter_secure_storage
6. AuthBloc emite AuthAuthenticated
```

---

## 6. Decisiones técnicas adicionales

| Decisión | Elección | Razón |
|---|---|---|
| Geohash | `dart_geohash: ^1.0.2` | No incluido en spec original, necesario para `SignalR.JoinZone` |
| Error UX | Texto inline `→ {message}` | Sin modales/dialogs. Error aparece donde ocurre la acción |
| Estado global | Solo `AuthBloc` en la raíz | El resto son locales por pantalla |
| Sin conexión | `ConnectivityWrapper` en raíz | Banner 1px amber + acciones en opacity 0.3 |
| Iconos | Solo Unicode + CustomPainter | Nunca `Icon(Icons.xxx)` en UI visible |
| Border radius | 0 en estructurales, 2px max en chips | Estética minimalismo vintage |

---

## 7. Orden de implementación (feature vertical)

1. **Scaffolding inicial** — `flutter create`, `pubspec.yaml`, ThemeData, AppColors, AppTextStyles
2. **Core** — ApiClient (Dio + AuthInterceptor), LocationService, SignalRService, widgets compartidos (VoidButton, MonoText, TypewriterText, GlitchText, ScanlinesOverlay)
3. **Auth** — AuthRepository, AuthBloc, SplashPage, LoginPage
4. **Map + Events** — EventsRepository, EventsBloc, MapBloc, MapPage, EventDetailSheet, CreateEventPage
5. **Deriva** — DerivaRepository, DerivaBloc, DerivaHomePage, DerivaActivePage
6. **Missions** — MissionsRepository, MissionsBloc, MissionsPage, MissionDetailPage, MissionActivePage
7. **Profile** — ProfileRepository, ProfileBloc, ProfilePage (con paginación cursor)
8. **Tests** — BLoC tests para Auth, Events, Deriva, Missions

---

## 8. Testing

Un test de BLoC por feature. Se mockea la interfaz del repositorio con `mocktail`. Cubre transiciones de estado principales:

- `AuthBloc`: login exitoso → `AuthAuthenticated`, 401 → `AuthUnauthenticated`
- `EventsBloc`: nearby exitoso → `EventsLoaded`, `EventExpiredReceived` elimina evento de la lista
- `DerivaBloc`: start → `DerivaStarting` → `DerivaActive`, nextInstruction actualiza `currentInstruction`
- `MissionsBloc`: submitAnswer correcto → avanza pista, `missionCompleted: true` → estado completado

Sin tests de widget en esta fase.
