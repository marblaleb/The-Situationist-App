# MOBILE_SPEC.md — App de Eventos Situacionistas
**Plataforma:** Flutter 3.x  
**Fecha:** 2026-04-03  
**Basado en:** BRD + Backend implementado (ASP.NET Core 9 · Vertical Slice)

---

## 1. Visión de la app móvil

La app es la interfaz principal de una capa invisible sobre la ciudad. No es una red social. No tiene feed. No tiene likes. Es una herramienta de intervención urbana: discreta, efímera, un poco inquietante.

La experiencia debe sentirse como si hubiera sido diseñada en 1997 por alguien que conocía el futuro pero decidió no explotarlo comercialmente.

---

## 2. Identidad estética: Minimalismo Vintage Internet

### 2.1 Filosofía visual

La UI combina **minimalismo extremo** con **estética vintage de internet temprano**: terminales, tipografías monoespaciadas, paletas desaturadas y referencias a la cultura web de los 90-00. No es retro decorativo — es funcional y austero, como un sistema que no pide permiso para existir.

**Referencias visuales:**
- Terminales UNIX / CRT phosphor screens
- Web brutalist (HTML sin estilos, pero elegante)
- Zines de arte urbano digitalizados
- Interfaces de software científico antiguo (topografía, sistemas de radar)
- Early Geocities pero curada — sin colores primarios saturados

### 2.2 Paleta de color

| Nombre | Hex | Uso |
|---|---|---|
| `bg-void` | `#0A0A0A` | Fondo principal |
| `bg-surface` | `#111111` | Cards, modales, paneles |
| `bg-elevated` | `#1A1A1A` | Input fields, overlays |
| `fg-primary` | `#E8E0D0` | Texto principal (marfil ligeramente cálido) |
| `fg-secondary` | `#6B6560` | Texto secundario, labels |
| `fg-muted` | `#3A3733` | Placeholders, bordes sutiles |
| `accent-phosphor` | `#C8F03C` | Acento principal (verde fósforo cálido) |
| `accent-amber` | `#E8A030` | Alertas, TTL, urgencia |
| `accent-void` | `#4040FF` | Links, acciones secundarias (azul eléctrico apagado) |
| `danger` | `#CC3333` | Errores, cancelar evento |
| `success` | `#3A8A3A` | Confirmaciones discretas |

**Regla:** Nunca usar más de 2 colores de acento en una misma pantalla. El fondo siempre domina.

### 2.3 Tipografía

| Rol | Fuente | Tamaño base | Uso |
|---|---|---|---|
| **Mono UI** | `JetBrains Mono` | 13sp | Etiquetas, metadatos, timestamps |
| **Mono Display** | `Space Mono` | 18sp+ | Títulos de pantalla, instrucciones Deriva |
| **Sans legible** | `Inter` | 14sp | Body text, descripciones largas |

```yaml
# pubspec.yaml — google_fonts
dependencies:
  google_fonts: ^6.2.1
```

**Reglas tipográficas:**
- Títulos en `Space Mono`, UPPERCASE, letter-spacing amplio (+0.08em)
- Todos los números, fechas y coordenadas en `JetBrains Mono`
- Sin negrita excesiva — usar `FontWeight.w300` / `w400` por defecto
- `FontWeight.w600` solo para datos críticos (TTL, estado de evento)

### 2.4 Geometría y espaciado

- **Sin border-radius** en elementos estructurales (cards, paneles). `borderRadius: 0`
- Border-radius `2px` máximo en chips pequeños y badges
- Bordes: `1px solid` en `fg-muted` (#3A3733)
- Grid de 8dp. Márgenes horizontales: 16dp. Padding interno cards: 16dp
- Separadores: líneas horizontales `1px` en `fg-muted`, nunca `Divider` con altura

### 2.5 Efectos y animaciones

| Efecto | Descripción | Cuándo usar |
|---|---|---|
| **Glitch text** | Desplazamiento de capas de color por frames, ~3 frames | Transición a pantalla Deriva activa |
| **Scanlines overlay** | Gradiente lineal horizontal semitransparente (opacity 0.04) | Fondo de pantallas inmersivas |
| **Typewriter** | Texto que aparece carácter a carácter, cursor parpadeante `_` | Instrucciones de Deriva, pistas de misiones |
| **Blink** | Opacity 0→1, período 800ms | Indicador "LIVE" en eventos activos |
| **Fade void** | Fade a negro completo en transiciones entre modos | Cambiar entre Mapa ↔ Deriva |
| **Noise grain** | Shader estático, opacity 0.03 | Overlay en pantalla home |

**Regla:** Las animaciones no son decorativas — señalan estado. Una pantalla en reposo no se mueve.

### 2.6 Iconografía

Sin iconos de Material Design. Usar:
- Caracteres Unicode tipográficos: `→`, `↗`, `⊕`, `⊗`, `◉`, `▸`, `⌀`, `≡`
- Líneas dibujadas en canvas (CustomPainter) para indicadores de estado
- Nunca `Icon(Icons.xxx)` en la UI visible al usuario

---

## 3. Arquitectura Flutter

### 3.1 Estructura de carpetas

```
mobile/
├── lib/
│   ├── main.dart
│   ├── app.dart                    # MaterialApp + theme + router
│   ├── core/
│   │   ├── auth/
│   │   │   ├── auth_service.dart   # Gestión de JWT, almacenamiento seguro
│   │   │   └── auth_guard.dart     # GoRouter redirect
│   │   ├── network/
│   │   │   ├── api_client.dart     # Dio + interceptors
│   │   │   └── api_exception.dart
│   │   ├── location/
│   │   │   └── location_service.dart  # geolocator wrapper
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_text_styles.dart
│   │   └── widgets/
│   │       ├── mono_text.dart      # Text con JetBrains Mono
│   │       ├── void_button.dart    # Botón sin relleno, borde 1px
│   │       ├── glitch_text.dart    # Efecto glitch
│   │       └── typewriter_text.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   ├── map/
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   ├── events/
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   ├── deriva/
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   ├── missions/
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   └── profile/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   └── shared/
│       ├── models/                 # DTOs deserializados
│       └── extensions/
├── test/
└── pubspec.yaml
```

### 3.2 Dependencias principales

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Estado
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # Navegación
  go_router: ^14.2.7

  # Red
  dio: ^5.7.0

  # Auth / Almacenamiento seguro
  flutter_secure_storage: ^9.2.2
  flutter_web_auth_2: ^4.0.0    # OAuth WebView

  # Geolocalización
  geolocator: ^12.0.0
  permission_handler: ^11.3.1

  # Mapas
  flutter_map: ^7.0.2           # Leaflet-based, sin Google Maps
  latlong2: ^0.9.1

  # SignalR
  signalr_netcore: ^1.3.5

  # Tipografías
  google_fonts: ^6.2.1

  # Utils
  intl: ^0.19.0
  freezed_annotation: ^2.4.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
  build_runner: ^2.4.12
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

---

## 4. Autenticación

### 4.1 Flujo completo OAuth → JWT

```
Usuario toca "ENTRAR CON GOOGLE"
  │
  ▼
flutter_web_auth_2.authenticate(
  url: GET /auth/login/google     ← backend redirige a Google
  callbackUrlScheme: "situationist"
)
  │
  ▼ Google autentica y redirige a:
  /auth/callback/google?code=XXXX
  │
  ▼ Backend responde con AuthResponse JSON
  │
  ▼ App extrae access_token
  │
  ▼ flutter_secure_storage.write("jwt", token)
  │
  ▼ App navega a /home
```

### 4.2 Endpoint de login

```
GET /auth/login/{provider}
```

El backend redirige al proveedor OAuth. La app abre esto en WebView y captura el callback.

```dart
// core/auth/auth_service.dart
Future<void> loginWithGoogle() async {
  const backendUrl = 'https://api.situationist.app';
  
  final result = await FlutterWebAuth2.authenticate(
    url: '$backendUrl/auth/login/google',
    callbackUrlScheme: 'situationist',
  );
  
  // El backend redirige al callback y devuelve JSON
  // Parsear el token de la URL o del body según implementación
  final uri = Uri.parse(result);
  final token = uri.queryParameters['access_token']
      ?? await _fetchTokenFromCallback(result);
  
  await _secureStorage.write(key: 'jwt', value: token);
  await _secureStorage.write(key: 'jwt_exp', value: _extractExp(token).toIso8601String());
}
```

### 4.3 Respuesta de autenticación

```
GET /auth/callback/google?code=AUTH_CODE
```

**Response 200:**
```json
{
  "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "expiresIn": 604800,
  "user": {
    "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "email": "usuario@gmail.com",
    "provider": "Google"
  }
}
```

### 4.4 Perfil del usuario autenticado

```
GET /auth/me
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "email": "usuario@gmail.com",
  "provider": "Google"
}
```

**Response 401:** Token expirado o en blacklist.

### 4.5 Cerrar sesión

```
DELETE /auth/session
Authorization: Bearer {token}
```

**Response 204:** Sin cuerpo. El token queda en blacklist en Redis.

```dart
Future<void> logout() async {
  await _apiClient.delete('/auth/session');
  await _secureStorage.deleteAll();
}
```

### 4.6 Interceptor Dio — JWT automático

```dart
// core/network/api_client.dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'jwt');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expirado — redirigir a login
      await _storage.deleteAll();
      // Emitir evento de logout al AuthBloc
    }
    handler.next(err);
  }
}
```

### 4.7 Modelo JWT (claims)

El JWT contiene:
- `sub` → `userId` (Guid)
- `email` → email del usuario
- `provider` → "Google" | "Apple"
- `jti` → ID único del token (usado para blacklist)
- `exp` → expiración (7 días desde emisión)

---

## 5. API — Endpoints detallados

Base URL: `https://api.situationist.app`  
Todos los endpoints excepto `/auth/login` y `/auth/callback` requieren `Authorization: Bearer {token}`.

---

### 5.1 Events

#### Listar eventos cercanos

```
GET /events?lat={lat}&lng={lng}&radius={metros}
Authorization: Bearer {token}
```

**Parámetros:**
| Param | Tipo | Ejemplo | Descripción |
|---|---|---|---|
| `lat` | double | `40.4168` | Latitud del usuario |
| `lng` | double | `-3.7038` | Longitud del usuario |
| `radius` | int | `1000` | Radio en metros (recomendado: 500–2000) |

**Response 200:**
```json
[
  {
    "id": "a1b2c3d4-0000-0000-0000-000000000001",
    "title": "Sonido de medianoche",
    "description": "Encuentra una superficie metálica y golpéala tres veces",
    "actionType": "Sensorial",
    "interventionLevel": "Bajo",
    "centroidLatitude": 40.4170,
    "centroidLongitude": -3.7035,
    "radiusMeters": 200,
    "visibility": "Public",
    "maxParticipants": 8,
    "startsAt": "2026-04-03T22:00:00+00:00",
    "expiresAt": "2026-04-03T22:45:00+00:00",
    "status": "Active",
    "participantCount": 3
  }
]
```

**Notas:**
- `centroidLatitude/Longitude` es el centro aproximado del radio. Nunca se devuelve la ubicación exacta.
- Eventos con `visibility: "HiddenUntilDiscovery"` no aparecen en este listado.
- Ordenar en cliente por `startsAt` o por `expiresAt` asc (más urgentes primero).

#### Detalle de evento

```
GET /events/{id}?lat={lat}&lng={lng}
Authorization: Bearer {token}
```

**Response 200:** Mismo esquema que un ítem del listado.  
**Response 404:** Evento no existe o no visible (HiddenUntilDiscovery sin proximidad).

#### Crear evento

```
POST /events
Authorization: Bearer {token}
Content-Type: application/json
```

**Request body:**
```json
{
  "title": "Espejo roto en el metro",
  "description": "Sitúate frente a cualquier reflejo y permanece inmóvil 90 segundos",
  "actionType": "Poetica",
  "interventionLevel": "Bajo",
  "latitude": 40.4168,
  "longitude": -3.7038,
  "radiusMeters": 300,
  "visibility": "ByProximity",
  "maxParticipants": null,
  "startsAt": "2026-04-03T21:00:00+00:00",
  "durationMinutes": 45
}
```

**Valores válidos:**
- `actionType`: `"Performativa"` | `"Social"` | `"Sensorial"` | `"Poetica"`
- `interventionLevel`: `"Bajo"` | `"Medio"` | `"Alto"`
- `visibility`: `"Public"` | `"ByProximity"` | `"HiddenUntilDiscovery"`
- `durationMinutes`: 1–60

**Response 201:**
```json
{
  "id": "a1b2c3d4-0000-0000-0000-000000000002",
  "title": "Espejo roto en el metro",
  "status": "Active",
  "expiresAt": "2026-04-03T21:45:00+00:00",
  ...
}
```

**Response 422:** Contenido rechazado por moderación IA.
```json
{
  "error": "Content rejected by moderation: contains potentially harmful instructions"
}
```

#### Generador IA — "Sorpréndeme"

```
POST /events/generate
Authorization: Bearer {token}
Content-Type: application/json
```

**Request body:**
```json
{
  "actionType": "Caotica",
  "interventionLevel": "Medio",
  "latitude": 40.4168,
  "longitude": -3.7038
}
```

**Response 200:** Sugerencia no persistida. El usuario decide si crearla.
```json
{
  "title": "El extraño del banco",
  "description": "Siéntate en el banco más cercano y sonríe a la primera persona que pase sin apartar la mirada durante 5 segundos",
  "actionType": "Social",
  "interventionLevel": "Medio"
}
```

#### Participar en evento

```
POST /events/{id}/participate
Authorization: Bearer {token}
Content-Type: application/json
```

**Request body:**
```json
{
  "role": "Participante"
}
```

**Valores válidos:** `"Participante"` | `"Observador"`

**Response 204:** Sin cuerpo. Participación registrada.  
**Response 409:** Evento lleno, ya participa, o evento no activo.
```json
{
  "error": "Event is full"
}
```

#### Cancelar evento (solo creador)

```
DELETE /events/{id}
Authorization: Bearer {token}
```

**Response 204:** Sin cuerpo.  
**Response 403:** No es el creador.

---

### 5.2 Deriva

#### Iniciar sesión de deriva

```
POST /deriva/sessions
Authorization: Bearer {token}
Content-Type: application/json
```

**Request body:**
```json
{
  "type": "Poetica",
  "latitude": 40.4168,
  "longitude": -3.7038,
  "language": "es"
}
```

**Valores válidos para `type`:** `"Caotica"` | `"Poetica"` | `"Social"` | `"Sensorial"`

**Response 201:**
```json
{
  "id": "b2c3d4e5-0000-0000-0000-000000000001",
  "type": "Poetica",
  "startedAt": "2026-04-03T21:30:00+00:00",
  "status": "Active",
  "firstInstruction": "Camina hacia el sonido más lejano que puedas escuchar ahora mismo. Cuando llegues, cierra los ojos durante treinta segundos."
}
```

**Response 409:** Ya existe una sesión activa.

#### Obtener siguiente instrucción

```
GET /deriva/sessions/{id}/next-instruction?lat={lat}&lng={lng}&lang={lang}
Authorization: Bearer {token}
```

**Parámetros:**
| Param | Tipo | Default | Descripción |
|---|---|---|---|
| `lat` | double | requerido | Posición actual |
| `lng` | double | requerido | Posición actual |
| `lang` | string | `"es"` | Idioma de la instrucción |

**Response 200:**
```json
{
  "instructionId": "c3d4e5f6-0000-0000-0000-000000000001",
  "content": "Detente frente al próximo edificio que tenga una puerta roja. Observa quién entra y quién sale durante dos minutos.",
  "generatedAt": "2026-04-03T21:35:00+00:00"
}
```

#### Completar sesión

```
POST /deriva/sessions/{id}/complete
Authorization: Bearer {token}
```

**Response 204:** Sin cuerpo. Registrado en huella situacionista.

#### Abandonar sesión

```
POST /deriva/sessions/{id}/abandon
Authorization: Bearer {token}
```

**Response 204:** Sin cuerpo. No se registra en historial.

---

### 5.3 Missions

#### Misiones cercanas

```
GET /missions?lat={lat}&lng={lng}&radius={metros}
Authorization: Bearer {token}
```

**Response 200:**
```json
[
  {
    "id": "d4e5f6a7-0000-0000-0000-000000000001",
    "title": "El mapa olvidado",
    "description": "Alguien dejó instrucciones ocultas en el barrio. Encuéntralas.",
    "latitude": 40.4170,
    "longitude": -3.7040,
    "radiusMeters": 500,
    "status": "Active",
    "clueCount": 4
  }
]
```

#### Detalle de misión

```
GET /missions/{id}
Authorization: Bearer {token}
```

**Response 200:** Incluye lista de pistas (sin hashes de respuesta, sin respuestas correctas):
```json
{
  "id": "d4e5f6a7-0000-0000-0000-000000000001",
  "title": "El mapa olvidado",
  "description": "Alguien dejó instrucciones ocultas en el barrio.",
  "latitude": 40.4170,
  "longitude": -3.7040,
  "radiusMeters": 500,
  "status": "Active",
  "clues": [
    {
      "id": "e5f6a7b8-0000-0000-0000-000000000001",
      "order": 1,
      "type": "Textual",
      "content": "El punto de inicio es donde el agua se detiene pero no desaparece",
      "hasHint": true,
      "isOptional": false,
      "latitude": null,
      "longitude": null
    }
  ]
}
```

#### Iniciar misión

```
POST /missions/{id}/start
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "progressId": "f6a7b8c9-0000-0000-0000-000000000001",
  "missionId": "d4e5f6a7-0000-0000-0000-000000000001",
  "status": "InProgress",
  "startedAt": "2026-04-03T21:00:00+00:00",
  "completedAt": null,
  "hintsUsed": 0,
  "currentClue": {
    "id": "e5f6a7b8-0000-0000-0000-000000000001",
    "order": 1,
    "type": "Textual",
    "content": "El punto de inicio es donde el agua se detiene pero no desaparece",
    "hasHint": true,
    "isOptional": false,
    "latitude": null,
    "longitude": null
  }
}
```

#### Enviar respuesta a pista

```
POST /missions/{id}/clues/{clueId}/submit
Authorization: Bearer {token}
Content-Type: application/json
```

**Request body:**
```json
{
  "answer": "fuente"
}
```

**Response 200 — Correcto, avanza:**
```json
{
  "correct": true,
  "missionCompleted": false,
  "nextClue": {
    "id": "a7b8c9d0-0000-0000-0000-000000000002",
    "order": 2,
    "type": "Sensorial",
    "content": "Desde la fuente, camina hacia el olor más intenso del barrio",
    "hasHint": false,
    "isOptional": false,
    "latitude": null,
    "longitude": null
  }
}
```

**Response 200 — Incorrecto:**
```json
{
  "correct": false,
  "missionCompleted": false,
  "nextClue": null
}
```

**Response 200 — Misión completada:**
```json
{
  "correct": true,
  "missionCompleted": true,
  "nextClue": null
}
```

#### Solicitar pista

```
POST /missions/{id}/clues/{clueId}/hint
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "hint": "Piensa en los espacios públicos del barrio donde el agua tiene presencia"
}
```

**Response 404:** La pista no tiene hint disponible.

#### Progreso de misión

```
GET /missions/{id}/progress
Authorization: Bearer {token}
```

**Response 200:** Mismo esquema que `/start`. Incluye `currentClue` actual.  
**Response 404:** No hay progreso activo para esta misión.

---

### 5.4 Profile

#### Huella situacionista

```
GET /profile/me
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "joinedAt": "2026-01-15T09:00:00+00:00",
  "situationistFootprint": {
    "eventsParticipated": 12,
    "derivasCompleted": 5,
    "missionsCompleted": 3
  }
}
```

#### Log de actividad (paginado)

```
GET /profile/me/activity?cursor={cursor}&pageSize={n}
Authorization: Bearer {token}
```

**Parámetros:**
| Param | Tipo | Default | Descripción |
|---|---|---|---|
| `cursor` | string? | null | Base64 del cursor. Omitir para primera página |
| `pageSize` | int | 20 | Máximo 100 |

**Response 200:**
```json
{
  "items": [
    {
      "id": "a1b2c3d4-0000-0000-0000-000000000010",
      "type": "EventParticipation",
      "referenceId": "a1b2c3d4-0000-0000-0000-000000000001",
      "occurredAt": "2026-04-02T22:45:00+00:00"
    },
    {
      "id": "a1b2c3d4-0000-0000-0000-000000000011",
      "type": "DerivaCompleted",
      "referenceId": "b2c3d4e5-0000-0000-0000-000000000001",
      "occurredAt": "2026-04-01T20:30:00+00:00"
    }
  ],
  "nextCursor": "MjAyNi0wNC0wMVQyMDozMDowMCswMDowMHxhMWIyYzNkNC0wMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMTE="
}
```

**Notas:**
- Pasar `nextCursor` como `cursor` en la siguiente request para paginar
- Si `nextCursor` es `null`, no hay más páginas

---

## 6. SignalR — Tiempo real

### 6.1 Conexión

```
wss://api.situationist.app/hubs/events?access_token={jwt}
```

La autenticación se pasa como query param (requerido por SignalR).

```dart
// core/network/signalr_service.dart
final connection = HubConnectionBuilder()
  .withUrl(
    '${ApiConfig.baseUrl}/hubs/events',
    HttpConnectionOptions(
      accessTokenFactory: () async => await _authService.getToken(),
    ),
  )
  .withAutomaticReconnect()
  .build();

await connection.start();

// Unirse a zona
await connection.invoke('JoinZone', args: [geohash5]);
```

### 6.2 Eventos recibidos del servidor

#### `EventExpired`
```dart
connection.on('EventExpired', (args) {
  final eventId = args?[0] as String;
  // Eliminar evento del mapa y de la lista local
  context.read<MapBloc>().add(EventExpiredEvent(eventId));
});
```

#### `EventFull`
```dart
connection.on('EventFull', (args) {
  final eventId = args?[0] as String;
  // Marcar evento como lleno en la UI
  context.read<MapBloc>().add(EventFullEvent(eventId));
});
```

### 6.3 Geohash para grupos de zona

La app calcula el geohash5 de la posición del usuario y se une al grupo:

```dart
import 'package:ngeohash/ngeohash.dart'; // o implementación manual

String geohash5 = GeoHash.encode(lat, lng, precision: 5);
await connection.invoke('JoinZone', args: [geohash5]);
```

---

## 7. Navegación

### 7.1 Estructura de rutas (GoRouter)

```
/                     → SplashPage (verificar JWT)
/login                → LoginPage
/home                 → ShellRoute (barra inferior)
  /home/map           → MapPage
  /home/deriva        → DerivaHomePage
  /home/missions      → MissionsPage
  /home/create        → CreateEventPage
/home/events/:id      → EventDetailPage
/home/deriva/active   → DerivaActivePage (inmersiva, sin nav)
/home/missions/:id    → MissionDetailPage
/home/missions/:id/active → MissionActivePage
/profile              → ProfilePage
```

### 7.2 Bottom navigation

4 destinos. Sin labels de texto — solo caracteres Unicode:

```
⌀  Mapa        →  /home/map
↺  Deriva      →  /home/deriva
◈  Misiones    →  /home/missions
⊕  Crear       →  /home/create
```

Indicador de pestaña activa: línea horizontal superior `2px` en `accent-phosphor`. Sin iconos rellenos ni fondos.

---

## 8. Pantallas principales

### 8.1 LoginPage

- Fondo `bg-void` puro
- Centro: caracteres ASCII formando un símbolo de ciudad esquemático (CustomPainter)
- Texto: `"SITUATIONIST"` en `Space Mono`, `14sp`, letter-spacing `0.3em`, `fg-secondary`
- Subtexto: `"intervención urbana / experiencia efímera"` en `JetBrains Mono`, `11sp`
- Botón: borde `1px fg-muted`, sin relleno, texto `"ENTRAR CON GOOGLE"` en `JetBrains Mono`
- Sin splash, sin onboarding

### 8.2 MapPage

- Mapa base: `flutter_map` con tiles oscuros (tile provider oscuro: Carto Dark Matter o similar)
- Eventos como marcadores: círculo `⌀{radiusMeters}m`, borde `1px accent-phosphor`, opacity 0.7
- Eventos `ByProximity`: borde punteado `1px fg-muted`
- Eventos a punto de expirar (< 10 min): borde `accent-amber` + efecto blink
- Tap en marcador: panel inferior (`DraggableScrollableSheet`) con detalle del evento
- Sin Google Maps. Sin attribution de estilo Material

### 8.3 EventDetailSheet

Panel inferior (aparece desde abajo, animación `Curves.easeOutExpo`, 300ms):

```
SONIDO DE MEDIANOCHE                    [ACTIVO ●]
─────────────────────────────────────────────────
Sensorial · Bajo · hasta 22:45

Encuentra una superficie metálica
y golpéala tres veces.

participantes: 03 / 08

[  PARTICIPAR  ]          [ OBSERVAR ]
```

- Timestamps en `JetBrains Mono`
- Contadores de participantes con padding de ceros: `03 / 08`
- Botones `VoidButton` (borde 1px, sin relleno)

### 8.4 DerivaHomePage

Selección de tipo de deriva:

```
MODO DERIVA
─────────────────────

  CAÓTICA      —  sin reglas, sin dirección
  POÉTICA      —  instrucciones contemplativas
  SOCIAL       —  interacción con desconocidos
  SENSORIAL    —  percepción aumentada

[  INICIAR  ]
```

Cada tipo seleccionado: `accent-phosphor` como indicador `▸` a la izquierda.

### 8.5 DerivaActivePage (inmersiva)

Pantalla completa. Sin bottom nav. Sin header.

```
[overlay scanlines, opacity 0.04]

                    22:34


  Detente frente al próximo edificio
  que tenga una puerta roja. Observa
  quién entra y quién sale durante
  dos minutos._

  ─────────────────────────────────

  [ siguiente instrucción ]

  [ completar ]   [ abandonar ]
```

- La instrucción aparece con efecto **typewriter** (carácter a carácter, `50ms` por carácter)
- Cursor parpadeante `_` al final hasta que se complete la escritura
- `[ siguiente instrucción ]` desactivado durante la animación de escritura
- Hora en esquina superior derecha en `JetBrains Mono`
- Transición de entrada: fade desde negro completo (500ms)

### 8.6 CreateEventPage

Formulario en dos pasos:

**Paso 1 — Generación**
```
CREAR EVENTO
─────────────────────

  tipo de acción
  > Poética

  nivel de intervención
  > Bajo

  [  SORPRÉNDEME  ]      ← llama a /events/generate

  o describe el evento manualmente:
  título _______________
  descripción __________

  [ SIGUIENTE → ]
```

**Paso 2 — Configuración**
```
DETALLES
─────────────────────

  visibilidad
  > Público

  duración
  > 30 min

  participantes máx.
  > sin límite

  [← VOLVER]     [PUBLICAR]
```

La ubicación se toma automáticamente de la posición actual. No hay mapa de selección.

### 8.7 MissionActivePage

Formato similar a `DerivaActivePage`:

```
pista 2 de 4
─────────────────────

  Desde la fuente, camina hacia el
  olor más intenso del barrio._

  [ solicitar pista ]    hints: 1

  respuesta: _______________

  [ ENVIAR ]
```

- Respuesta incorrecta: feedback sutil `→ incorrecto` en `fg-secondary`, sin modal
- Respuesta correcta: fade-out del texto, fade-in de la siguiente pista

### 8.8 ProfilePage

```
HUELLA SITUACIONISTA
─────────────────────────────────────

  desde: 2026-01-15

  eventos               12
  derivas completadas    5
  misiones completadas   3

─────────────────────────────────────

REGISTRO DE ACTIVIDAD

  2026-04-02 22:45   EventParticipation
  2026-04-01 20:30   DerivaCompleted
  2026-03-30 18:10   MissionCompleted
  ...

  [ cargar más ]
```

- Sin gráficas. Sin barras de progreso. Solo números y timestamps
- Scroll infinito con cursor-based pagination

---

## 9. Gestión de estado — BLoC

### 9.1 AuthBloc

```dart
// Estados
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState { final String message; }

// Eventos
abstract class AuthEvent {}
class AuthCheckRequested extends AuthEvent {}
class AuthLoginRequested extends AuthEvent { final String provider; }
class AuthLogoutRequested extends AuthEvent {}
```

### 9.2 EventsBloc

```dart
// Estados
abstract class EventsState {}
class EventsInitial extends EventsState {}
class EventsLoading extends EventsState {}
class EventsLoaded extends EventsState {
  final List<EventModel> events;
}
class EventsError extends EventsState { final String message; }

// Eventos
abstract class EventsEvent {}
class EventsNearbyRequested extends EventsEvent {
  final double lat, lng;
  final int radius;
}
class EventParticipateRequested extends EventsEvent {
  final String eventId;
  final String role;
}
class EventExpiredReceived extends EventsEvent { final String eventId; }
class EventFullReceived extends EventsEvent { final String eventId; }
```

### 9.3 DerivaBloc

```dart
// Estados
abstract class DerivaState {}
class DerivaIdle extends DerivaState {}
class DerivaStarting extends DerivaState {}
class DerivaActive extends DerivaState {
  final String sessionId;
  final String currentInstruction;
  final DerivaType type;
  final bool isWriting; // true durante typewriter animation
}
class DerivaCompleted extends DerivaState {}
class DerivaError extends DerivaState { final String message; }

// Eventos
abstract class DerivaEvent {}
class DerivaStartRequested extends DerivaEvent {
  final DerivaType type;
  final double lat, lng;
}
class DerivaNextInstructionRequested extends DerivaEvent {
  final double lat, lng;
}
class DerivaCompleteRequested extends DerivaEvent {}
class DerivaAbandonRequested extends DerivaEvent {}
```

### 9.4 MissionsBloc

```dart
abstract class MissionsEvent {}
class MissionsNearbyRequested extends MissionsEvent { final double lat, lng, radius; }
class MissionStartRequested extends MissionsEvent { final String missionId; }
class MissionAnswerSubmitted extends MissionsEvent {
  final String missionId, clueId, answer;
}
class MissionHintRequested extends MissionsEvent {
  final String missionId, clueId;
}
```

---

## 10. Modelos Dart

```dart
// shared/models/event_model.dart
@freezed
class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    required String title,
    required String description,
    required String actionType,
    required String interventionLevel,
    required double centroidLatitude,
    required double centroidLongitude,
    required int radiusMeters,
    required String visibility,
    int? maxParticipants,
    required DateTime startsAt,
    required DateTime expiresAt,
    required String status,
    required int participantCount,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
}

// shared/models/deriva_session_model.dart
@freezed
class DerivaSessionModel with _$DerivaSessionModel {
  const factory DerivaSessionModel({
    required String id,
    required String type,
    required DateTime startedAt,
    required String status,
    required String firstInstruction,
  }) = _DerivaSessionModel;

  factory DerivaSessionModel.fromJson(Map<String, dynamic> json) =>
      _$DerivaSessionModelFromJson(json);
}

// shared/models/clue_model.dart
@freezed
class ClueModel with _$ClueModel {
  const factory ClueModel({
    required String id,
    required int order,
    required String type,
    required String content,
    required bool hasHint,
    required bool isOptional,
    double? latitude,
    double? longitude,
  }) = _ClueModel;

  factory ClueModel.fromJson(Map<String, dynamic> json) =>
      _$ClueModelFromJson(json);
}

// shared/models/mission_progress_model.dart
@freezed
class MissionProgressModel with _$MissionProgressModel {
  const factory MissionProgressModel({
    required String progressId,
    required String missionId,
    required String status,
    required DateTime startedAt,
    DateTime? completedAt,
    required int hintsUsed,
    ClueModel? currentClue,
  }) = _MissionProgressModel;

  factory MissionProgressModel.fromJson(Map<String, dynamic> json) =>
      _$MissionProgressModelFromJson(json);
}

// shared/models/profile_model.dart
@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String userId,
    required DateTime joinedAt,
    required SituationistFootprint situationistFootprint,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}

@freezed
class SituationistFootprint with _$SituationistFootprint {
  const factory SituationistFootprint({
    required int eventsParticipated,
    required int derivasCompleted,
    required int missionsCompleted,
  }) = _SituationistFootprint;

  factory SituationistFootprint.fromJson(Map<String, dynamic> json) =>
      _$SituationistFootprintFromJson(json);
}
```

---

## 11. Theme Flutter

```dart
// core/theme/app_colors.dart
class AppColors {
  static const bgVoid    = Color(0xFF0A0A0A);
  static const bgSurface = Color(0xFF111111);
  static const bgElevated = Color(0xFF1A1A1A);
  static const fgPrimary  = Color(0xFFE8E0D0);
  static const fgSecondary = Color(0xFF6B6560);
  static const fgMuted    = Color(0xFF3A3733);
  static const phosphor   = Color(0xFFC8F03C);
  static const amber      = Color(0xFFE8A030);
  static const electricBlue = Color(0xFF4040FF);
  static const danger     = Color(0xFFCC3333);
}

// core/theme/app_theme.dart
ThemeData buildTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.bgVoid,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.bgSurface,
      primary: AppColors.phosphor,
      secondary: AppColors.amber,
      error: AppColors.danger,
    ),
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.spaceMono(
        color: AppColors.fgPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 4,
      ),
      bodyMedium: GoogleFonts.inter(
        color: AppColors.fgPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        height: 1.6,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        color: AppColors.fgSecondary,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.fgMuted,
      thickness: 1,
      space: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgElevated,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.fgMuted, width: 1),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.fgMuted, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.phosphor, width: 1),
      ),
      hintStyle: GoogleFonts.jetBrainsMono(
        color: AppColors.fgMuted,
        fontSize: 13,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgVoid,
      selectedItemColor: AppColors.phosphor,
      unselectedItemColor: AppColors.fgMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
```

---

## 12. Manejo de errores y edge cases

### 12.1 Códigos HTTP → UX

| Código | Causa | UX |
|---|---|---|
| `401` | Token inválido / expirado / en blacklist | Redirect silencioso a `/login` |
| `403` | No autorizado (ej: borrar evento ajeno) | Texto `→ acción no permitida` inline |
| `404` | Recurso no encontrado | Texto `→ no encontrado` inline |
| `409` | Conflicto (evento lleno, ya participa) | Texto descriptivo del error en panel |
| `422` | Moderación rechazó contenido | Mensaje de moderación, campo editable |
| `429` | Rate limit (generador IA) | `→ límite alcanzado. intenta más tarde` |
| `5xx` | Error servidor | `→ error de conexión. intenta de nuevo` |

Sin modales de error. Sin dialogs. El error aparece como texto en el lugar donde ocurrió la acción.

### 12.2 Sin conexión

- Cachear última lista de eventos en memoria (solo sesión actual)
- Mostrar `→ sin conexión` en top de pantalla, 1px borde `amber`
- Las acciones que requieren red quedan desactivadas visualmente (opacity 0.3)

### 12.3 GPS no disponible

- Solicitar permisos al iniciar app con `permission_handler`
- Si se rechaza: mapa centrado en ciudad por defecto, sin eventos cercanos
- Deriva e instrucciones funcionan sin coordenadas exactas (geohash aproximado)

### 12.4 Evento expirado durante uso

SignalR `EventExpired` → el evento desaparece del mapa inmediatamente con fade-out (300ms). Si el usuario tenía el detalle abierto, el panel muestra `→ este evento ha expirado`.

---

## 13. Testing

### 13.1 Estrategia

| Capa | Framework | Qué testear |
|---|---|---|
| BLoC | `bloc_test` + `mocktail` | Transiciones de estado, mapeo de eventos |
| Widgets | `flutter_test` | Renders correctos, interacciones |
| API client | `mocktail` + `dio_mock` | Serialización, manejo de errores HTTP |

### 13.2 Ejemplo — DerivaBloc test

```dart
blocTest<DerivaBloc, DerivaState>(
  'emite DerivaActive al iniciar sesión exitosamente',
  build: () {
    when(() => mockDerivaRepository.startSession(
      type: DerivaType.poetica,
      lat: any(named: 'lat'),
      lng: any(named: 'lng'),
    )).thenAnswer((_) async => mockSession);
    return DerivaBloc(repository: mockDerivaRepository);
  },
  act: (bloc) => bloc.add(DerivaStartRequested(
    type: DerivaType.poetica,
    lat: 40.4168,
    lng: -3.7038,
  )),
  expect: () => [
    isA<DerivaStarting>(),
    isA<DerivaActive>(),
  ],
);
```

---

## 14. Checklist de implementación

- [ ] Configurar `ThemeData` con paleta void/phosphor completa
- [ ] Implementar `AuthService` con `flutter_secure_storage` + `flutter_web_auth_2`
- [ ] Implementar `ApiClient` (Dio) con `AuthInterceptor` y manejo de 401
- [ ] `LocationService` con `geolocator` + permisos
- [ ] `SignalRService` con reconexión automática y gestión de grupos geohash
- [ ] Feature Auth: LoginPage + AuthBloc
- [ ] Feature Map: `flutter_map` + marcadores custom + EventDetailSheet
- [ ] Feature Events: CreateEventPage (2 pasos) + EventsBloc
- [ ] Feature Deriva: DerivaHomePage + DerivaActivePage (typewriter) + DerivaBloc
- [ ] Feature Missions: MissionsPage + MissionActivePage + MissionsBloc
- [ ] Feature Profile: ProfilePage + paginación cursor
- [ ] Widget `TypewriterText` con cursor parpadeante
- [ ] Widget `VoidButton` (borde 1px, sin relleno, letras uppercase mono)
- [ ] Widget `GlitchText` para transiciones
- [ ] Overlay scanlines para pantallas inmersivas
- [ ] Tests de BLoC para los 4 features principales
