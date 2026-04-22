# CLAUDE.md — App de Eventos Situacionistas

## Visión del proyecto

Aplicación para generar, descubrir y participar en experiencias urbanas efímeras inspiradas en la psicogeografía y el pensamiento situacionista. Los usuarios crean y viven eventos con tiempo de vida limitado, exploran la ciudad mediante el modo deriva y completan misiones con pistas encadenadas. El objetivo no es optimizar el consumo de eventos sino provocar exploración, interacción inesperada y ruptura de la rutina. No hay likes, seguidores ni comentarios públicos.

---

## Stack técnico

| Capa       | Tecnología                                      |
|------------|-------------------------------------------------|
| Backend    | .NET 9 · ASP.NET Core Web API                   |
| Arquitectura | Vertical Slice Architecture                   |
| ORM        | Entity Framework Core                           |
| Base de datos | PostgreSQL                                   |
| Caché      | Redis                                           |
| Tiempo real | SignalR                                        |
| Auth       | OAuth / OIDC (Google, Apple)                    |
| IA         | Anthropic Claude API                            |
| Frontend   | Angular 19 (web)                                |
| Mobile     | Flutter                                         |
| Cloud      | Azure                                           |
| Testing    | xUnit + FluentAssertions · Jest · flutter_test  |

---

## Estructura de carpetas

```
/
├── backend/
│   ├── src/
│   │   ├── Api/              # Endpoints, Middleware, configuración HTTP
│   │   ├── Features/         # Vertical slices (un folder por feature)
│   │   ├── Infrastructure/   # EF Core, Redis, SignalR, Anthropic client
│   │   └── Domain/           # Entidades y value objects compartidos
│   └── tests/
│       └── UnitTests/        # xUnit + FluentAssertions
├── frontend/
│   └── src/
│       └── app/
│           ├── features/     # Módulos por feature (lazy loaded)
│           ├── core/         # Auth, guards, interceptors
│           └── shared/       # Componentes y servicios reutilizables
└── mobile/
    ├── lib/
    │   ├── features/         # Feature-first structure
    │   ├── core/             # Auth, routing, theme
    │   └── shared/           # Widgets y utilidades comunes
    └── test/
```

---

## Convenciones

### Backend — Vertical Slice

- Cada feature vive en `Features/{NombreFeature}/` con sus propios comandos, queries, handlers y endpoints.
- Usar **MediatR** para commands/queries (CQRS ligero).
- Preferir **Minimal API** con `MapGroup` sobre Controllers.
- Migraciones EF Core en `Infrastructure/Migrations/`.
- Nunca colocar lógica de negocio en endpoints o middleware.

### Frontend — Angular 19

- **Standalone components** en todos los casos (sin NgModules).
- **Signals** para estado local; NgRx solo si el estado es complejo y compartido entre features.
- Lazy loading obligatorio por feature.
- Naming: `kebab-case` para archivos, `PascalCase` para clases y componentes.

### Mobile — Flutter

- **BLoC** como patrón de gestión de estado principal.
- Estructura feature-first: cada feature contiene sus propios blocs, pages y widgets.
- Usar Riverpod solo en casos puntuales donde BLoC sea excesivo.

---

## Errores cometidos — no repetir

### Flutter: `const` en subclases de `Equatable`

`Equatable` tiene un super constructor no-const. Ninguna subclase puede declarar un constructor `const`, aunque el compilador no lo avise hasta el momento de compilar.

```dart
// MAL — falla en runtime/compilación
class MapClusterSelected extends MapEvent {
  const MapClusterSelected(this.cluster); // Error: can't call non-const super
}

// BIEN
class MapClusterSelected extends MapEvent {
  MapClusterSelected(this.cluster);
}
```

Afecta a todos los eventos BLoC (`MapEvent`, `DerivaEvent`, etc.) y a los estados que extienden `Equatable`. Tampoco usar `const` en los call-sites si el constructor no es const.

---

### Flutter GoRouter: `go()` vs `push()` para formularios

`context.go('/ruta')` **reemplaza** toda la pila de navegación. Si la página de destino llama a `context.pop()` al terminar, no hay nada a lo que volver y la pantalla queda en blanco.

Para navegar a formularios (create-event, create-mission) que necesitan poder hacer pop al guardar, usar siempre `context.push()`.

```dart
// MAL — pantalla en blanco tras guardar
onTap: () => context.go('/home/create-event')

// BIEN
onTap: () => context.push('/home/create-event')
```

---

### GitHub Actions: secretos en condiciones `if:`

Los valores de `secrets.*` no pueden evaluarse directamente en expresiones `if:` de GitHub Actions. Hay que exponerlos como variable de entorno y evaluar en shell.

```yaml
# MAL
- if: secrets.MY_SECRET != ''

# BIEN
- id: check
  env:
    VALUE: ${{ secrets.MY_SECRET }}
  run: |
    if [ -n "$VALUE" ]; then echo "present=true" >> "$GITHUB_OUTPUT"
    else echo "present=false" >> "$GITHUB_OUTPUT"; fi
- if: steps.check.outputs.present == 'true'
```

---

### Flutter CI: `flutter analyze --fatal-infos`

El proyecto tiene hints de nivel `info` (prefer_const_constructors, etc.) que son normales y no bloquean la compilación. Usar `--fatal-infos` rompe el CI inmediatamente. Usar `--fatal-warnings` en su lugar.

```yaml
# MAL
run: flutter analyze --fatal-infos

# BIEN
run: flutter analyze --fatal-warnings
```

---

## Comandos útiles

```bash
# Backend
dotnet run --project backend/src/Api
dotnet ef migrations add <Nombre> --project backend/src/Infrastructure
dotnet ef database update --project backend/src/Infrastructure
dotnet test backend/tests/UnitTests

# Frontend
cd frontend && ng serve
cd frontend && ng test
cd frontend && ng build --configuration production

# Mobile
cd mobile && flutter run
cd mobile && flutter test
cd mobile && flutter build apk
```
