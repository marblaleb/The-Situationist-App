# Backend Spec — App de Eventos Situacionistas
**Fecha:** 2026-03-31  
**Alcance:** MVP + Modo Deriva, TTL de eventos, Modo Misiones  
**Stack:** .NET 9 · ASP.NET Core Minimal API · Vertical Slice Architecture · PostgreSQL + PostGIS · Redis · SignalR · Anthropic Claude API

---

## 1. Visión general

El backend expone una Web API construida con .NET 9 + Minimal API. La estructura interna sigue Vertical Slice Architecture: cada feature vive en `Features/{NombreFeature}/` y contiene sus propios comandos, queries, handlers y endpoint mapping. No hay controllers. MediatR desacopla los endpoints de la lógica.

### Capas

| Carpeta | Responsabilidad |
|---|---|
| `Api/` | Configuración HTTP, middleware, bootstrapping de features |
| `Features/` | Slices: Auth, Events, Deriva, Missions, Profile |
| `Infrastructure/` | EF Core + PostgreSQL/PostGIS, Redis, SignalR hub, cliente Anthropic, background workers |
| `Domain/` | Entidades y value objects compartidos (`GeoPoint`, `EventStatus`, etc.) |

### Decisión de geolocalización

Se usa **PostGIS**. La carga esperada de una app urbana con eventos efímeros implica consultas frecuentes de "eventos en radio X" desde múltiples clientes simultáneos. PostGIS con `ST_DWithin` e índice `GIST` es la elección correcta; el overhead de setup es bajo con EF Core + `NetTopologySuite`.

### Cross-cutting

- **Autenticación:** JWT Bearer (RS256) emitido tras callback OAuth; middleware valida en todas las rutas protegidas
- **Validación:** FluentValidation por comando/query
- **Errores:** `ProblemDetails` estándar (RFC 7807)
- **Rate limiting:** Middleware de .NET 9 (`RateLimiter`) en rutas de creación y generación IA

---

## 2. Slice: Auth

### Entidad

```
User
  Id              : Guid
  ExternalId      : string        // sub del provider OAuth
  Provider        : enum          // Google | Apple
  Email           : string
  CreatedAt       : DateTimeOffset
  LastSeenAt      : DateTimeOffset
```

### Flujo OAuth/OIDC

1. Cliente inicia login → redirige al provider (Google/Apple)
2. Provider devuelve `code` al callback del backend
3. Backend valida con el provider, obtiene `sub` + email
4. Si el usuario no existe → se crea; si existe → se actualiza `LastSeenAt`
5. Backend emite JWT firmado (RS256) con claims: `userId`, `email`, `provider`
6. JWT tiene TTL de 7 días; refresh mediante re-autenticación silenciosa en el cliente

### Endpoints

```
GET    /auth/login/{provider}     → redirige al provider (Google | Apple)
GET    /auth/callback/{provider}  → procesa code, emite JWT
GET    /auth/me                   → devuelve perfil básico del usuario autenticado
DELETE /auth/session              → invalida sesión (blacklist en Redis)
```

### Commands / Queries

- `HandleOAuthCallbackCommand` — crea o recupera usuario, devuelve JWT
- `GetCurrentUserQuery` — devuelve datos del usuario autenticado

### Reglas de negocio

- Un mismo email puede tener cuentas en distintos providers (se tratan como identidades separadas)
- No existe registro manual; solo OAuth
- JWT blacklist en Redis: `auth:blacklist:{jti}` con TTL igual al tiempo restante del token

---

## 3. Slice: Events

### Entidades

```
Event
  Id                : Guid
  CreatorId         : Guid (FK User)
  Title             : string
  Description       : string
  ActionType        : enum         // Performativa | Social | Sensorial | Poética
  InterventionLevel : enum         // Bajo | Medio | Alto
  Location          : Point        // PostGIS geometry (lat/lng, SRID 4326)
  RadiusMeters      : int          // zona aproximada visible al usuario
  Visibility        : enum         // Public | ByProximity | HiddenUntilDiscovery
  MaxParticipants   : int?         // null = sin límite
  StartsAt          : DateTimeOffset
  ExpiresAt         : DateTimeOffset  // StartsAt + duración configurada (máx 60 min)
  Status            : enum         // Active | Full | Expired | Cancelled
  CreatedAt         : DateTimeOffset

Participation
  Id        : Guid
  EventId   : Guid (FK Event)
  UserId    : Guid (FK User)
  Role      : enum          // Participante | Observador
  JoinedAt  : DateTimeOffset
```

### Endpoints

```
POST   /events                    → crear evento (con o sin "Sorpréndeme")
GET    /events?lat&lng&radius     → eventos cercanos activos
GET    /events/{id}               → detalle (solo si visibilidad lo permite)
POST   /events/{id}/participate   → unirse como participante u observador
DELETE /events/{id}               → cancelar (solo creador)
POST   /events/generate           → generador IA ("Sorpréndeme"), devuelve sugerencia sin persistir
```

### Commands / Queries

- `CreateEventCommand` — valida reglas, modera contenido vía IA, persiste, encola job de expiración
- `GenerateEventSuggestionCommand` — llama Claude API, devuelve `EventDraft` (no persiste)
- `ParticipateInEventCommand` — valida cupo y estado, crea `Participation`, escribe entrada `EventParticipation` en `ActivityLog`, emite SignalR si se llena el cupo
- `GetNearbyEventsQuery` — `ST_DWithin` filtrado por visibilidad y estado `Active`
- `GetEventDetailQuery` — verifica visibilidad antes de devolver datos; `HiddenUntilDiscovery` requiere que el usuario esté dentro del radio

### Expiración (background worker)

`EventExpirationWorker` — hosted service que corre cada 30s:
1. Consulta eventos con `ExpiresAt <= now` y `Status = Active`
2. Marca estado como `Expired`
3. Invalida cache Redis de la zona (`events:nearby:{geohash6}`)
4. Emite `EventExpired(eventId)` en SignalR al grupo `zone:{geohash5}`

### Reglas de negocio

- Ubicación almacenada como `Point` (PostGIS, SRID 4326); al usuario se le devuelve solo el centroide del radio, nunca coordenadas exactas
- Duración máxima: 60 minutos (configurable en `appsettings`)
- Evento `HiddenUntilDiscovery`: solo aparece en `/events/{id}` cuando el usuario está dentro del radio
- Moderación IA: `CreateEventCommand` llama Claude API antes de persistir; contenido rechazado devuelve `422` con motivo
- Un usuario no puede participar como `Participante` en su propio evento

---

## 4. Slice: Deriva

### Entidades

```
DerivaSession
  Id          : Guid
  UserId      : Guid (FK User)
  Type        : enum            // Caótica | Poética | Social | Sensorial
  StartedAt   : DateTimeOffset
  EndedAt     : DateTimeOffset?
  Status      : enum            // Active | Completed | Abandoned

DerivaInstruction
  Id               : Guid
  SessionId        : Guid (FK DerivaSession)
  Content          : string        // instrucción generada por IA
  GeneratedAt      : DateTimeOffset
  ContextSnapshot  : jsonb         // hora, zona aproximada, tipo de deriva
```

### Endpoints

```
POST /deriva/sessions                          → iniciar sesión de deriva
GET  /deriva/sessions/{id}/next-instruction    → obtener siguiente instrucción
POST /deriva/sessions/{id}/complete            → finalizar sesión
POST /deriva/sessions/{id}/abandon             → abandonar sesión
```

### Commands / Queries

- `StartDerivaSessionCommand` — crea sesión, genera primera instrucción llamando Claude API
- `GetNextDerivaInstructionCommand` — genera instrucción con contexto actualizado, persiste en `DerivaInstruction`
- `CompleteDerivaSessionCommand` — marca sesión como completada, registra en `ActivityLog`
- `AbandonDerivaSessionCommand` — marca como abandonada, no registra en `ActivityLog`

### Integración Claude API

El prompt incluye:
- Tipo de deriva (`Caótica`, `Poética`, `Social`, `Sensorial`)
- Hora del día (mañana / tarde / noche)
- Zona urbana aproximada: el servidor convierte las coordenadas GPS del cliente a un geohash de precisión 5 (~5km²) y lo incluye como descripción opaca; nunca se envían coordenadas exactas a la IA
- Instrucción previa (para evitar repetición)
- Idioma del usuario

La respuesta es una instrucción corta (1-3 frases), accionable e inmediata.  
Ejemplo: *"Detente frente al próximo edificio que tenga una puerta roja. Observa quién entra y quién sale durante dos minutos."*

### Reglas de negocio

- Solo puede haber una sesión `Active` por usuario a la vez
- Sin límite de instrucciones por sesión; el usuario avanza a su ritmo
- `ContextSnapshot` en `jsonb` para auditar/mejorar prompts sin migración de esquema
- El backend no bloquea consultas de eventos durante una deriva activa (responsabilidad del cliente)

---

## 5. Slice: Missions

### Entidades

```
Mission
  Id           : Guid
  CreatorId    : Guid (FK User)
  Title        : string
  Description  : string
  Location     : Point         // PostGIS — zona general de la misión
  RadiusMeters : int
  Status       : enum          // Draft | Active | Archived
  CreatedAt    : DateTimeOffset

Clue
  Id          : Guid
  MissionId   : Guid (FK Mission)
  Order       : int           // posición en la cadena
  Type        : enum          // Textual | Sensorial | Contextual
  Content     : string        // descripción de la pista
  Hint        : string?       // pista progresiva (opcional)
  AnswerHash  : string        // hash bcrypt de la respuesta correcta
  IsOptional  : bool          // si es false, obligatoria para completar la misión
  Location    : Point?        // coordenada específica de la pista (opcional)

MissionProgress
  Id            : Guid
  MissionId     : Guid (FK Mission)
  UserId        : Guid (FK User)
  CurrentClueId : Guid (FK Clue)
  StartedAt     : DateTimeOffset
  CompletedAt   : DateTimeOffset?
  Status        : enum        // InProgress | Completed | Abandoned
  HintsUsed     : int
```

### Endpoints

```
POST   /missions                               → crear misión con sus pistas
GET    /missions?lat&lng&radius                → misiones activas cercanas
GET    /missions/{id}                          → detalle (sin hashes de respuesta)
POST   /missions/{id}/start                    → iniciar misión (crea MissionProgress)
POST   /missions/{id}/clues/{clueId}/submit    → enviar respuesta a una pista
GET    /missions/{id}/progress                 → estado actual del progreso
POST   /missions/{id}/clues/{clueId}/hint      → solicitar pista progresiva
```

### Commands / Queries

- `CreateMissionCommand` — valida estructura, hashea respuestas con bcrypt, persiste misión + pistas
- `StartMissionCommand` — crea `MissionProgress` apuntando a la primera pista obligatoria
- `SubmitClueAnswerCommand` — compara respuesta con `AnswerHash`; si correcta avanza al siguiente clue obligatorio; si es el último completa la misión y registra en `ActivityLog`
- `RequestClueHintCommand` — devuelve `Hint` si existe, incrementa `HintsUsed`
- `GetNearbyMissionsQuery` — `ST_DWithin` sobre `Mission.Location`, solo estado `Active`
- `GetMissionProgressQuery` — devuelve estado + pista actual (sin revelar las siguientes ni los hashes)

### Reglas de negocio

- Las respuestas se hashean con bcrypt al crear; nunca se almacenan en texto plano
- La misión se completa al resolver todas las pistas con `IsOptional = false`
- Un usuario no puede iniciar su propia misión
- Máximo una instancia `InProgress` de la misma misión por usuario
- `Clue.Location` es opcional — las pistas pueden ser puramente textuales

---

## 6. Slice: Profile

### Entidad

```
ActivityLog
  Id           : Guid
  UserId       : Guid (FK User)
  Type         : enum          // EventParticipation | DerivaCompleted | MissionCompleted
  ReferenceId  : Guid          // Id del evento, sesión o misión
  OccurredAt   : DateTimeOffset
  Metadata     : jsonb         // zona, tipo de deriva, rol en evento, etc.
```

### Endpoints

```
GET /profile/me            → huella situacionista del usuario autenticado
GET /profile/me/activity   → log de actividad paginado (cursor-based)
```

### Queries

- `GetProfileQuery` — agrega conteos desde `ActivityLog` por tipo
- `GetActivityLogQuery` — entradas paginadas por `OccurredAt` desc; cursor basado en `OccurredAt + Id`

### Response de perfil

```json
{
  "userId": "...",
  "joinedAt": "...",
  "situationistFootprint": {
    "eventsParticipated": 12,
    "derivasCompleted": 5,
    "missionsCompleted": 3
  }
}
```

### Reglas de negocio

- El perfil es estrictamente privado; no hay endpoint público para ver el perfil de otro usuario
- `ActivityLog` es append-only; no se modifican ni eliminan entradas
- `Metadata` en `jsonb` permite enriquecer el historial sin migraciones futuras
- No hay ranking, puntuación ni comparación entre usuarios

---

## 7. Infraestructura transversal

### PostGIS + EF Core

- Paquetes: `NetTopologySuite` + `Npgsql.EntityFrameworkCore.PostgreSQL.NetTopologySuite`
- Todas las columnas `Point` usan SRID 4326 (WGS84)
- Índice `GIST` en `Event.Location` y `Mission.Location`
- Query pattern: `ST_DWithin(location, ST_MakePoint(lng, lat)::geography, radiusMeters)`

### Redis

| Clave | TTL | Invalidación |
|---|---|---|
| `auth:blacklist:{jti}` | Tiempo restante del token | — |
| `events:nearby:{geohash6}` | 30s | Al crear o expirar evento en la zona |
| `missions:nearby:{geohash6}` | 60s | Al crear o archivar misión en la zona |

### SignalR

- Hub único: `EventHub` en `/hubs/events`
- Al conectar, el cliente envía su posición y se une al grupo `zone:{geohash5}`
- Mensajes emitidos: `EventExpired(eventId)`, `EventFull(eventId)`
- Autenticación: JWT como query param `?access_token=` (requerido por SignalR)

### Cliente Anthropic

Interfaz `IAnthropicClient` con métodos:

```csharp
Task<EventDraft> GenerateEventSuggestionAsync(EventContext context);
Task<DerivaInstruction> GenerateDerivaInstructionAsync(DerivaContext context);
Task<ModerationResult> ModerateContentAsync(string content);
```

- Implementación en `Infrastructure/Ai/AnthropicClient.cs`
- Rate limiting: `RateLimiter` de .NET 9, política `SlidingWindow` (configurable)
- `ModerationResult` devuelve `{ IsAllowed: bool, Reason: string? }`

### Background Workers

- `EventExpirationWorker` (Hosted Service) — loop cada 30s; marca eventos expirados, invalida cache Redis, emite SignalR

### Configuración (`appsettings.json`)

```json
{
  "Events": {
    "MaxDurationMinutes": 60
  },
  "Ai": {
    "MaxRequestsPerMinute": 20
  },
  "SignalR": {
    "GeohashPrecision": 5
  },
  "Cache": {
    "NearbyEventsTtlSeconds": 30,
    "NearbyMissionsTtlSeconds": 60
  }
}
```
