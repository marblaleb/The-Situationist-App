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
