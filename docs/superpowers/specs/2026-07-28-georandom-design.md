# Módulo A — GeoRandom: Generador de Puntos Geo-Random

**Fecha:** 2026-07-28
**Estado:** Aprobado para implementación
**Alcance:** Solo Módulo A (generador de puntos). El Módulo B (generador de rutas) es un spec separado y posterior, que probablemente consuma el punto generado acá como destino.

## Contexto

The Situationist App ya tiene infraestructura espacial: backend con PostGIS + NetTopologySuite (`geometry(Point,4326)` en `Event`, `Mission`, `Clue`), mobile con `flutter_map` (OpenStreetMap) + `geolocator` + `dart_geohash`. No existe integración con Overpass/OSM data, KDE, ni generación de puntos aleatorios. La feature `Deriva` existente es un mecanismo distinto (instrucciones de texto generadas por LLM, sin coordenadas ni waypoints) — GeoRandom no la reemplaza ni se solapa con ella.

## Objetivo

El usuario elige un radio de búsqueda R (500m–5km) y un tipo de punto (Atractor, Vacío, Anomalía). La app genera un único punto dentro de ese radio, alrededor de su ubicación GPS actual, calculado por densidad real de puntos de interés (POIs) de OpenStreetMap, y validado contra un filtro de seguridad básico. Es una herramienta standalone dentro de una nueva sección "Explorar" — no persiste nada, no crea Events ni Missions, no dispara ninguna navegación guiada todavía.

## Decisiones de alcance (explícitas, ya acordadas)

- **Standalone "Explorar"**, no integrado a creación de Event/Mission en esta iteración.
- **Efímero**: sin persistencia backend ni historial. Cálculo stateless por request.
- **KDE sobre densidad urbana real** (POIs de Overpass/OSM), no sobre ruido auto-referencial.
- **Filtro de seguridad básico**: tags OSM inequívocos (agua, militar, área protegida, edificios `access=private|no`). No es exhaustivo ni pretende cubrir "propiedad privada" en general.
- **Randomness**: CSPRNG local (.NET `RandomNumberGenerator`), sin dependencia de APIs de entropía cuántica externas.
- **Campo "intención" del spec original**: fuera de este MVP.
- **Vista de radar animada (FR-07)**: fuera de este MVP; loading state simple.
- **Disclaimer legal (NFR-03)**: diferido al Módulo B (no hay "iniciar ruta" todavía acá).
- **Rate limiting**: throttle por usuario vía Redis.
- **Permiso de GPS**: exigido explícitamente (no se usa el fallback silencioso a Madrid que tiene `LocationService` para otras features).

## Arquitectura

### Backend — `Api/Features/GeoRandom/` (vertical slice, mismo patrón que `Deriva`)

- `GeoRandomEndpoints.cs` — `MapGroup("/georandom").RequireAuthorization()`, único endpoint `POST /georandom/generate`.
- `GenerateGeoRandomPointCommand.cs` + `GenerateGeoRandomPointCommandValidator.cs` (FluentValidation, en el mismo archivo, patrón `StartDerivaSessionCommandValidator`) — handler MediatR que orquesta: obtener POIs+exclusiones (cache o Overpass) → correr KDE → elegir punto según tipo → validar filtro de seguridad → reintentar si falla → devolver resultado.
- `GeoRandomModels.cs` — DTOs de request/response.

### Infraestructura nueva

- `Infrastructure/Geo/IOverpassClient.cs` + `OverpassClient.cs` — `HttpClient` tipado (mismo patrón que `AnthropicClient`). **Actualizado durante implementación:** en vez de una sola query combinada, se hacen dos queries Overpass QL por celda (una para POIs — comercios, amenities, edificios, para densidad — y otra para polígonos de exclusión: `natural=water`, `landuse=military`, `leisure=nature_reserve`/`protected_area`, `building[access~"private|no"]`), priorizando claridad de parseo sobre un único round-trip. Ambas llamadas corren en paralelo (`Task.WhenAll`) para no duplicar la latencia. Limitación conocida: la query de exclusión solo matchea `way[...]`, no `relation[...]` — zonas protegidas mapeadas en OSM como multipolígono (relation) no se detectan. Aceptable dado que el filtro ya está definido como "básico, no exhaustivo".
- `Infrastructure/Geo/GeoRandomCacheService.cs` — usa `IRedisCacheService` existente. Clave por celda geohash de precisión 5 (~4.9km × 4.9km). El fetch a Overpass se ancla al **centro decodificado de la celda** (no al punto exacto del request), con radio 8.5km — cubre la celda entera (semidiagonal ~3.46km) más el R máximo de usuario (5km), garantizando que cualquier request dentro de esa celda quede cubierto por el mismo fetch cacheado. TTL de 7 días — los POIs no cambian con frecuencia.
- `Infrastructure/Geo/KdeCalculator.cs` — clase pura en C# (sin dependencias de infraestructura, 100% testeable con datos sintéticos). Recibe centro + R + POIs + exclusiones, devuelve el punto elegido según tipo.

### Mobile — `mobile/lib/features/georandom/` (BLoC, feature-first)

Nueva sección "Explorar": selector de radio (slider 500m–5km) y tipo (Atractor/Vacío/Anomalía), botón "Generar", loading state simple, resultado pintado como marker sobre `flutter_map` (reutilizando lo existente en `features/map`). Requiere permiso de GPS explícito antes de generar — si no está otorgado, prompt bloqueante en vez de fallback silencioso.

### Flujo

Usuario elige R + tipo → mobile obtiene GPS actual (o pide permiso) → `POST /georandom/generate {lat, lng, radiusMeters, type}` → backend resuelve (cache hit rápido, o Overpass + KDE) → devuelve `{lat, lng}` → mobile pinta el punto en el mapa. Sin SignalR/tiempo real — no hace falta para este módulo.

## Algoritmo

**Muestreo de candidatos:** ~3.000 puntos con distribución uniforme por área dentro del círculo de radio R (ángulo uniforme + radio = `R·√(random)`, no radio lineal, para evitar amontonamiento en el centro).

**Kernel gaussiano (KDE real):** para cada candidato, `densidad(x) = Σ exp(-dist(x, poi)² / 2h²)`, sumando sobre POIs dentro de un radio de corte `3h`, obtenidos vía `STRtree` (NetTopologySuite, ya es dependencia del proyecto) para podar POIs lejanos sin recorrer todo el set. `h` (bandwidth) = 120m, constante configurable — escala de "manzana urbana", el nivel al que tiene sentido psicogeográfico hablar de denso/vacío.

**Selección según tipo**, sobre la distribución de densidades de los candidatos (media μ, desvío σ):
- **Atractor** → candidatos con densidad ≥ percentil 90, pick aleatorio ponderado entre ellos.
- **Vacío** → candidatos con densidad ≤ percentil 10, mismo mecanismo.
- **Anomalía** → el candidato con mayor `|z-score| = |densidad − μ| / σ` (más extremo en cualquier dirección).

**Validación de seguridad:** el candidato elegido se valida contra los polígonos de exclusión. Si falla, se descarta y se repite con el siguiente mejor candidato de esa categoría, hasta 10 intentos.

**Casos borde:**
- σ ≈ 0 (zona con tan poca señal de POIs que los candidatos son estadísticamente indistinguibles, típico en R chico en zona poco urbanizada) → fallback a pick uniforme random dentro de R para cualquier tipo, sin fallar.
- Se agotan los 10 reintentos sin candidato válido (zona casi enteramente excluida) → error `422`.

## Contrato de API

```
POST /georandom/generate
{ "lat": double, "lng": double, "radiusMeters": int, "type": "atractor" | "vacio" | "anomalia" }

200 OK
{ "lat": double, "lng": double, "type": "atractor", "generatedAt": "2026-07-28T18:32:00Z" }

400  radiusMeters fuera de [500, 5000] o type inválido
422  no se encontró candidato válido tras agotar reintentos (zona mayormente excluida)
429  throttle por usuario excedido (header Retry-After)
503  Overpass no disponible y sin cache para la zona — sin fallback inventado
```

## Manejo de errores

| Caso | Comportamiento |
|---|---|
| Overpass caído/timeout, sin cache | `503`, mensaje claro, sin inventar un punto sin datos reales |
| Permiso GPS denegado (mobile) | UI bloquea el flujo con prompt pidiendo el permiso explícitamente |
| σ ≈ 0 entre candidatos | Fallback a pick uniforme random dentro de R, sin fallar |
| 10 reintentos de re-muestreo agotados | `422` "no encontramos una zona válida con este radio, probá un radio mayor" |
| Throttle excedido | `429` + `Retry-After`. Límite: 1 request cada 4 segundos por usuario (Redis, key por `userId`) |

## Testing

- `KdeCalculatorTests` (xUnit puro, sin mocks de infra): con sets sintéticos de POIs — Atractor devuelve densidad ≥ P90, Vacío ≤ P10, Anomalía = mayor `|z-score|`; caso σ≈0 cae a random uniforme; punto en zona excluida se descarta y re-muestrea correctamente.
- `GenerateGeoRandomPointCommandValidatorTests` — radio fuera de rango, tipo inválido (mismo patrón que `StartDerivaSessionCommandValidatorTests`).
- `OverpassClientTests` — contra `HttpMessageHandler` mockeado (sin red real): parseo de la query QL construida y de la respuesta.
- Mobile: `GeoRandomBlocTest` — estados loading/success/error/rate-limited, mismo patrón que `DerivaBloc`.

## Explícitamente fuera de alcance

Módulo B (rutas), animación de radar (FR-07), persistencia/historial de puntos generados, disclaimer legal (NFR-03), campo "intención" (FR-01), entropía cuántica externa, integración con creación de Event/Mission, soporte offline (NFR-02 aplica a rutas activas del Módulo B, no a este módulo).
