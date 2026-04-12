# Location Picker + Daily Creation Limits — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an explicit map-based location picker to event/mission creation forms, and enforce a daily limit of 2 events + 2 missions per user per UTC day, with disabled buttons in the create hub.

**Architecture:** Backend gets a new `GET /profile/me/creation-limits` query + enforcement checks in both create handlers. Mobile gets a `LocationPickerPage` route, updated create forms that await the picker result, a `CreateHubBloc` that fetches limits on init, and an updated `CreateHubPage` that disables options when limits are reached.

**Tech Stack:** .NET 9 Minimal API + EF Core (backend) · Flutter + BLoC + flutter_map + latlong2 (mobile) · bloc_test + mocktail (Flutter tests)

---

## File map

| File | Action |
|------|--------|
| `backend/src/Api/Features/Profile/GetCreationLimitsQuery.cs` | Create |
| `backend/src/Api/Features/Profile/ProfileEndpoints.cs` | Add endpoint |
| `backend/src/Api/Features/Events/CreateEventCommand.cs` | Add limit check |
| `backend/src/Api/Features/Events/EventEndpoints.cs` | Add try/catch on POST / |
| `backend/src/Api/Features/Missions/CreateMissionCommand.cs` | Add limit check |
| `backend/src/Api/Features/Missions/MissionEndpoints.cs` | Add try/catch on POST / |
| `mobile/lib/shared/models/creation_limits_model.dart` | Create |
| `mobile/lib/features/profile/data/i_profile_repository.dart` | Add `getCreationLimits()` |
| `mobile/lib/features/profile/data/profile_repository.dart` | Implement `getCreationLimits()` |
| `mobile/lib/features/events/bloc/create_hub_bloc.dart` | Create |
| `mobile/test/features/events/create_hub_bloc_test.dart` | Create |
| `mobile/lib/features/events/pages/create_hub_page.dart` | Integrate `CreateHubBloc` |
| `mobile/lib/features/map/pages/location_picker_page.dart` | Create |
| `mobile/lib/app.dart` | Add route + fix CreateHubPage/CreateMissionPage builders |
| `mobile/lib/features/events/bloc/create_event_bloc.dart` | Add lat/lng to `CreateEventSubmitted` |
| `mobile/lib/features/events/pages/create_event_page.dart` | Add location field |
| `mobile/lib/features/missions/pages/create_mission_page.dart` | Add location field, remove locationService |

---

## Task 1: Backend — `GetCreationLimitsQuery` and endpoint

**Files:**
- Create: `backend/src/Api/Features/Profile/GetCreationLimitsQuery.cs`
- Modify: `backend/src/Api/Features/Profile/ProfileEndpoints.cs`

- [ ] **Step 1: Create `GetCreationLimitsQuery.cs`**

```csharp
// backend/src/Api/Features/Profile/GetCreationLimitsQuery.cs
using Infrastructure.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Profile;

public record GetCreationLimitsQuery(Guid UserId) : IRequest<CreationLimitsResponse>;

public record CreationLimitsResponse(int EventsToday, int MissionsToday, int DailyLimit);

public class GetCreationLimitsQueryHandler(AppDbContext db)
    : IRequestHandler<GetCreationLimitsQuery, CreationLimitsResponse>
{
    private const int DailyLimit = 2;

    public async Task<CreationLimitsResponse> Handle(
        GetCreationLimitsQuery request, CancellationToken ct)
    {
        var todayUtc = new DateTimeOffset(DateTimeOffset.UtcNow.Date, TimeSpan.Zero);

        var eventsToday = await db.Events.CountAsync(
            e => e.CreatorId == request.UserId && e.CreatedAt >= todayUtc, ct);

        var missionsToday = await db.Missions.CountAsync(
            m => m.CreatorId == request.UserId && m.CreatedAt >= todayUtc, ct);

        return new CreationLimitsResponse(eventsToday, missionsToday, DailyLimit);
    }
}
```

- [ ] **Step 2: Add endpoint in `ProfileEndpoints.cs`**

Insert after the `group.MapGet("/me/missions", ...)` block, before `return app;`:

```csharp
group.MapGet("/me/creation-limits", async (ClaimsPrincipal principal, ISender mediator) =>
{
    var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
    var result = await mediator.Send(new GetCreationLimitsQuery(userId));
    return Results.Ok(result);
});
```

- [ ] **Step 3: Verify the backend builds**

```bash
dotnet build backend/src/Api
```
Expected: Build succeeded, 0 errors.

- [ ] **Step 4: Commit**

```bash
git add backend/src/Api/Features/Profile/GetCreationLimitsQuery.cs \
        backend/src/Api/Features/Profile/ProfileEndpoints.cs
git commit -m "feat(backend): add GET /profile/me/creation-limits endpoint"
```

---

## Task 2: Backend — Enforce daily limit in event creation

**Files:**
- Modify: `backend/src/Api/Features/Events/CreateEventCommand.cs`
- Modify: `backend/src/Api/Features/Events/EventEndpoints.cs`

- [ ] **Step 1: Add limit check at the top of `CreateEventCommandHandler.Handle`**

In `CreateEventCommand.cs`, replace the `Handle` method body — insert these lines right after the opening brace of `Handle`, before any existing logic:

```csharp
public async Task<EventResponse> Handle(CreateEventCommand request, CancellationToken ct)
{
    var todayUtc = new DateTimeOffset(DateTimeOffset.UtcNow.Date, TimeSpan.Zero);
    var eventsToday = await db.Events.CountAsync(
        e => e.CreatorId == request.CreatorId && e.CreatedAt >= todayUtc, ct);
    if (eventsToday >= 2)
        throw new InvalidOperationException("Daily event creation limit reached");

    var req = request.Request;
    // ... rest of the existing body unchanged ...
```

The full method after the edit:

```csharp
public async Task<EventResponse> Handle(CreateEventCommand request, CancellationToken ct)
{
    var todayUtc = new DateTimeOffset(DateTimeOffset.UtcNow.Date, TimeSpan.Zero);
    var eventsToday = await db.Events.CountAsync(
        e => e.CreatorId == request.CreatorId && e.CreatedAt >= todayUtc, ct);
    if (eventsToday >= 2)
        throw new InvalidOperationException("Daily event creation limit reached");

    var req = request.Request;

    var actionType = Enum.Parse<ActionType>(req.ActionType, ignoreCase: true);
    var interventionLevel = Enum.Parse<InterventionLevel>(req.InterventionLevel, ignoreCase: true);
    var visibility = Enum.Parse<EventVisibility>(req.Visibility, ignoreCase: true);

    var location = new Point(req.Longitude, req.Latitude) { SRID = 4326 };
    var now = DateTimeOffset.UtcNow;

    var evt = new Event
    {
        Id = Guid.NewGuid(),
        CreatorId = request.CreatorId,
        Title = req.Title,
        Description = req.Description,
        ActionType = actionType,
        InterventionLevel = interventionLevel,
        Location = location,
        RadiusMeters = req.RadiusMeters,
        Visibility = visibility,
        MaxParticipants = req.MaxParticipants,
        StartsAt = req.StartsAt,
        ExpiresAt = req.StartsAt.AddMinutes(req.DurationMinutes),
        Status = EventStatus.Active,
        CreatedAt = now
    };

    db.Events.Add(evt);
    await db.SaveChangesAsync(ct);

    var geohash6 = GeoHash.Encode(req.Latitude, req.Longitude, 6);
    await cache.RemoveAsync($"events:nearby:{geohash6}");

    return EventHelpers.MapToResponse(evt, 0);
}
```

- [ ] **Step 2: Add try/catch to `POST /events` in `EventEndpoints.cs`**

Replace the existing `group.MapPost("/", ...)` handler (currently no try/catch) with:

```csharp
group.MapPost("/", async (CreateEventRequest req, ClaimsPrincipal principal, ISender mediator) =>
{
    var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
    try
    {
        var result = await mediator.Send(new CreateEventCommand(userId, req));
        return Results.Created($"/events/{result.Id}", result);
    }
    catch (InvalidOperationException ex)
    {
        return Results.Conflict(new { error = ex.Message });
    }
});
```

- [ ] **Step 3: Build**

```bash
dotnet build backend/src/Api
```
Expected: Build succeeded, 0 errors.

- [ ] **Step 4: Commit**

```bash
git add backend/src/Api/Features/Events/CreateEventCommand.cs \
        backend/src/Api/Features/Events/EventEndpoints.cs
git commit -m "feat(backend): enforce daily event creation limit (max 2 per UTC day)"
```

---

## Task 3: Backend — Enforce daily limit in mission creation

**Files:**
- Modify: `backend/src/Api/Features/Missions/CreateMissionCommand.cs`
- Modify: `backend/src/Api/Features/Missions/MissionEndpoints.cs`

- [ ] **Step 1: Add limit check at the top of `CreateMissionCommandHandler.Handle`**

Full `Handle` method after the edit:

```csharp
public async Task<MissionSummaryResponse> Handle(CreateMissionCommand request, CancellationToken ct)
{
    var todayUtc = new DateTimeOffset(DateTimeOffset.UtcNow.Date, TimeSpan.Zero);
    var missionsToday = await db.Missions.CountAsync(
        m => m.CreatorId == request.CreatorId && m.CreatedAt >= todayUtc, ct);
    if (missionsToday >= 2)
        throw new InvalidOperationException("Daily mission creation limit reached");

    var req = request.Request;
    var location = new Point(req.Longitude, req.Latitude) { SRID = 4326 };

    var mission = new Mission
    {
        Id = Guid.NewGuid(),
        CreatorId = request.CreatorId,
        Title = req.Title,
        Description = req.Description,
        Location = location,
        RadiusMeters = req.RadiusMeters,
        Status = MissionStatus.Active,
        CreatedAt = DateTimeOffset.UtcNow
    };

    foreach (var c in req.Clues)
    {
        Point? clueLocation = c.Latitude.HasValue && c.Longitude.HasValue
            ? new Point(c.Longitude.Value, c.Latitude.Value) { SRID = 4326 }
            : null;

        mission.Clues.Add(new Clue
        {
            Id = Guid.NewGuid(),
            MissionId = mission.Id,
            Order = c.Order,
            Type = Enum.Parse<ClueType>(c.Type, ignoreCase: true),
            Content = c.Content,
            Hint = c.Hint,
            AnswerHash = BCrypt.Net.BCrypt.HashPassword(c.Answer.Trim().ToLowerInvariant()),
            IsOptional = c.IsOptional,
            Location = clueLocation
        });
    }

    db.Missions.Add(mission);
    await db.SaveChangesAsync(ct);

    var geohash6 = GeoHash.Encode(req.Latitude, req.Longitude, 6);
    await cache.RemoveAsync($"missions:nearby:{geohash6}");

    return new MissionSummaryResponse(
        mission.Id, mission.Title, mission.Description,
        mission.Location.Y, mission.Location.X,
        mission.RadiusMeters, mission.Status.ToString(), mission.Clues.Count);
}
```

- [ ] **Step 2: Add try/catch to `POST /missions` in `MissionEndpoints.cs`**

Replace the existing `group.MapPost("/", ...)` handler (currently no try/catch) with:

```csharp
group.MapPost("/", async (CreateMissionRequest req, ClaimsPrincipal principal, ISender mediator) =>
{
    var userId = Guid.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
    try
    {
        var result = await mediator.Send(new CreateMissionCommand(userId, req));
        return Results.Created($"/missions/{result.Id}", result);
    }
    catch (InvalidOperationException ex)
    {
        return Results.Conflict(new { error = ex.Message });
    }
});
```

- [ ] **Step 3: Build and run all backend unit tests**

```bash
dotnet build backend/src/Api && dotnet test backend/tests/UnitTests
```
Expected: Build succeeded, all tests pass.

- [ ] **Step 4: Commit**

```bash
git add backend/src/Api/Features/Missions/CreateMissionCommand.cs \
        backend/src/Api/Features/Missions/MissionEndpoints.cs
git commit -m "feat(backend): enforce daily mission creation limit (max 2 per UTC day)"
```

---

## Task 4: Mobile — `CreationLimitsModel` and repository method

**Files:**
- Create: `mobile/lib/shared/models/creation_limits_model.dart`
- Modify: `mobile/lib/features/profile/data/i_profile_repository.dart`
- Modify: `mobile/lib/features/profile/data/profile_repository.dart`

- [ ] **Step 1: Create `creation_limits_model.dart`**

```dart
// mobile/lib/shared/models/creation_limits_model.dart
class CreationLimitsModel {
  final int eventsToday;
  final int missionsToday;
  final int dailyLimit;

  const CreationLimitsModel({
    required this.eventsToday,
    required this.missionsToday,
    required this.dailyLimit,
  });

  factory CreationLimitsModel.fromJson(Map<String, dynamic> json) =>
      CreationLimitsModel(
        eventsToday: (json['eventsToday'] as num).toInt(),
        missionsToday: (json['missionsToday'] as num).toInt(),
        dailyLimit: (json['dailyLimit'] as num).toInt(),
      );
}
```

- [ ] **Step 2: Add `getCreationLimits()` to `IProfileRepository`**

Full file after the edit:

```dart
// mobile/lib/features/profile/data/i_profile_repository.dart
import '../../../shared/models/creation_limits_model.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/models/profile_model.dart';

abstract class IProfileRepository {
  Future<ProfileModel> getProfile();
  Future<ActivityLogPage> getActivityLog({String? cursor, int pageSize = 20});
  Future<List<EventModel>> getCreatedEvents();
  Future<List<MissionModel>> getCreatedMissions();
  Future<CreationLimitsModel> getCreationLimits();
}
```

- [ ] **Step 3: Implement `getCreationLimits()` in `ProfileRepository`**

Add this method to `ProfileRepository` (after `getCreatedMissions`):

```dart
@override
Future<CreationLimitsModel> getCreationLimits() async {
  final response =
      await _client.get<Map<String, dynamic>>('/profile/me/creation-limits');
  return CreationLimitsModel.fromJson(response.data!);
}
```

Also add the import at the top of `profile_repository.dart`:

```dart
import '../../../shared/models/creation_limits_model.dart';
```

- [ ] **Step 4: Verify Flutter analyzes cleanly**

```bash
cd mobile && flutter analyze --fatal-warnings
```
Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/shared/models/creation_limits_model.dart \
        mobile/lib/features/profile/data/i_profile_repository.dart \
        mobile/lib/features/profile/data/profile_repository.dart
git commit -m "feat(mobile): add CreationLimitsModel and ProfileRepository.getCreationLimits()"
```

---

## Task 5: Mobile — `CreateHubBloc` with tests

**Files:**
- Create: `mobile/lib/features/events/bloc/create_hub_bloc.dart`
- Create: `mobile/test/features/events/create_hub_bloc_test.dart`

- [ ] **Step 1: Write the failing test first**

```dart
// mobile/test/features/events/create_hub_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:situationist/features/events/bloc/create_hub_bloc.dart';
import 'package:situationist/features/profile/data/i_profile_repository.dart';
import 'package:situationist/shared/models/creation_limits_model.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late MockProfileRepository repo;

  setUp(() {
    repo = MockProfileRepository();
  });

  group('CreateHubBloc', () {
    blocTest<CreateHubBloc, CreateHubState>(
      'emite CreateHubLoaded con los límites al inicializarse',
      build: () {
        when(() => repo.getCreationLimits()).thenAnswer((_) async =>
            const CreationLimitsModel(
                eventsToday: 1, missionsToday: 0, dailyLimit: 2));
        return CreateHubBloc(repository: repo);
      },
      expect: () => [isA<CreateHubLoading>(), isA<CreateHubLoaded>()],
      verify: (bloc) {
        final state = bloc.state as CreateHubLoaded;
        expect(state.limits.eventsToday, 1);
        expect(state.limits.missionsToday, 0);
        expect(state.limits.dailyLimit, 2);
      },
    );

    blocTest<CreateHubBloc, CreateHubState>(
      'emite CreateHubError cuando falla la carga',
      build: () {
        when(() => repo.getCreationLimits())
            .thenThrow(Exception('network error'));
        return CreateHubBloc(repository: repo);
      },
      expect: () => [isA<CreateHubLoading>(), isA<CreateHubError>()],
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd mobile && flutter test test/features/events/create_hub_bloc_test.dart
```
Expected: FAIL — `CreateHubBloc` not defined.

- [ ] **Step 3: Create `create_hub_bloc.dart`**

```dart
// mobile/lib/features/events/bloc/create_hub_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../profile/data/i_profile_repository.dart';
import '../../../shared/models/creation_limits_model.dart';

// Events
abstract class CreateHubEvent extends Equatable {}

class CreateHubLimitsRequested extends CreateHubEvent {
  @override
  List<Object?> get props => [];
}

// States
abstract class CreateHubState extends Equatable {}

class CreateHubInitial extends CreateHubState {
  @override
  List<Object?> get props => [];
}

class CreateHubLoading extends CreateHubState {
  @override
  List<Object?> get props => [];
}

class CreateHubLoaded extends CreateHubState {
  final CreationLimitsModel limits;
  CreateHubLoaded(this.limits);

  @override
  List<Object?> get props => [limits];
}

class CreateHubError extends CreateHubState {
  final String message;
  CreateHubError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CreateHubBloc extends Bloc<CreateHubEvent, CreateHubState> {
  final IProfileRepository _repository;

  CreateHubBloc({required IProfileRepository repository})
      : _repository = repository,
        super(CreateHubInitial()) {
    on<CreateHubLimitsRequested>(_onLimitsRequested);
    add(CreateHubLimitsRequested());
  }

  Future<void> _onLimitsRequested(
    CreateHubLimitsRequested event,
    Emitter<CreateHubState> emit,
  ) async {
    emit(CreateHubLoading());
    try {
      final limits = await _repository.getCreationLimits();
      emit(CreateHubLoaded(limits));
    } catch (e) {
      emit(CreateHubError(e.toString()));
    }
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd mobile && flutter test test/features/events/create_hub_bloc_test.dart
```
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/events/bloc/create_hub_bloc.dart \
        mobile/test/features/events/create_hub_bloc_test.dart
git commit -m "feat(mobile): add CreateHubBloc with daily limit loading"
```

---

## Task 6: Mobile — Update `CreateHubPage`

**Files:**
- Modify: `mobile/lib/features/events/pages/create_hub_page.dart`

`CreateHubPage` needs to: accept `ApiClient`, create `CreateHubBloc`, show a loading state, disable options when the limit is reached, and display an error with a retry button.

- [ ] **Step 1: Rewrite `create_hub_page.dart`**

```dart
// mobile/lib/features/events/pages/create_hub_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../../profile/data/profile_repository.dart';
import '../bloc/create_hub_bloc.dart';

class CreateHubPage extends StatelessWidget {
  final ApiClient apiClient;

  const CreateHubPage({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateHubBloc(repository: ProfileRepository(apiClient)),
      child: const _CreateHubView(),
    );
  }
}

class _CreateHubView extends StatelessWidget {
  const _CreateHubView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CREAR', style: AppTextStyles.monoDisplay),
              const SizedBox(height: 4),
              Container(height: 1, color: AppColors.fgMuted),
              const SizedBox(height: 32),
              BlocBuilder<CreateHubBloc, CreateHubState>(
                builder: (context, state) {
                  if (state is CreateHubLoading || state is CreateHubInitial) {
                    return const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: AppColors.fgMuted,
                        ),
                      ),
                    );
                  }

                  if (state is CreateHubError) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MonoText(
                          'error al cargar límites',
                          color: AppColors.danger,
                          size: 11,
                        ),
                        const SizedBox(height: 12),
                        VoidButton(
                          label: 'REINTENTAR',
                          onPressed: () => context
                              .read<CreateHubBloc>()
                              .add(CreateHubLimitsRequested()),
                        ),
                      ],
                    );
                  }

                  final limits = (state as CreateHubLoaded).limits;
                  final eventsLimited =
                      limits.eventsToday >= limits.dailyLimit;
                  final missionsLimited =
                      limits.missionsToday >= limits.dailyLimit;

                  return Column(
                    children: [
                      _HubOption(
                        symbol: '⊕',
                        title: 'NUEVO EVENTO',
                        subtitle: 'Intervención efímera en el espacio urbano',
                        limitReached: eventsLimited,
                        onTap: eventsLimited
                            ? null
                            : () => context.push('/home/create-event'),
                      ),
                      const SizedBox(height: 20),
                      _HubOption(
                        symbol: '◈',
                        title: 'NUEVA MISIÓN',
                        subtitle:
                            'Secuencia de pistas para explorar el territorio',
                        limitReached: missionsLimited,
                        onTap: missionsLimited
                            ? null
                            : () => context.push('/home/create-mission'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubOption extends StatelessWidget {
  final String symbol;
  final String title;
  final String subtitle;
  final bool limitReached;
  final VoidCallback? onTap;

  const _HubOption({
    required this.symbol,
    required this.title,
    required this.subtitle,
    required this.limitReached,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: limitReached ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.fgMuted, width: 1),
          ),
          child: Row(
            children: [
              Text(
                symbol,
                style: AppTextStyles.monoDisplay.copyWith(
                  fontSize: 28,
                  color: limitReached
                      ? AppColors.fgMuted
                      : AppColors.phosphor,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MonoText(title, size: 14, letterSpacing: 2),
                    const SizedBox(height: 4),
                    MonoText(subtitle,
                        color: AppColors.fgSecondary, size: 11),
                    if (limitReached) ...[
                      const SizedBox(height: 6),
                      MonoText(
                        'LÍMITE DIARIO ALCANZADO',
                        color: AppColors.danger,
                        size: 10,
                        letterSpacing: 1,
                      ),
                    ],
                  ],
                ),
              ),
              if (!limitReached)
                MonoText('→', color: AppColors.phosphor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update the route builder in `app.dart`**

Find the line:
```dart
builder: (_, __) => const CreateHubPage(),
```
Replace with:
```dart
builder: (_, __) => CreateHubPage(apiClient: _apiClient),
```

- [ ] **Step 3: Run all Flutter tests**

```bash
cd mobile && flutter test
```
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add mobile/lib/features/events/pages/create_hub_page.dart \
        mobile/lib/app.dart
git commit -m "feat(mobile): CreateHubPage shows daily limits and disables options when reached"
```

---

## Task 7: Mobile — `LocationPickerPage`

**Files:**
- Create: `mobile/lib/features/map/pages/location_picker_page.dart`

- [ ] **Step 1: Create `location_picker_page.dart`**

```dart
// mobile/lib/features/map/pages/location_picker_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';

class LocationPickerPage extends StatefulWidget {
  final LocationService locationService;

  const LocationPickerPage({super.key, required this.locationService});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final _mapController = MapController();
  LatLng? _selected;

  static const _defaultCenter = LatLng(40.4168, -3.7038); // Madrid

  @override
  void initState() {
    super.initState();
    _centerOnGps();
  }

  Future<void> _centerOnGps() async {
    final (lat, lng) = await widget.locationService.getCurrentPosition();
    final pos = LatLng(lat, lng);
    if (mounted) {
      _mapController.move(pos, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 14,
                onTap: (_, point) => setState(() => _selected = point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.situationist.app',
                ),
                if (_selected != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selected!,
                        width: 36,
                        height: 36,
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.phosphor,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.bgVoid.withOpacity(0.88),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(null),
                      child: MonoText(
                        '← CANCELAR',
                        color: AppColors.fgSecondary,
                        size: 12,
                      ),
                    ),
                    const Spacer(),
                    MonoText(
                      'ELEGIR UBICACIÓN',
                      color: AppColors.fgPrimary,
                      size: 13,
                      letterSpacing: 2,
                    ),
                    const Spacer(),
                    const SizedBox(width: 80),
                  ],
                ),
              ),
            ),

            // Bottom bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.bgVoid.withOpacity(0.92),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selected != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MonoText(
                          'LAT ${_selected!.latitude.toStringAsFixed(5)}  '
                          'LNG ${_selected!.longitude.toStringAsFixed(5)}',
                          color: AppColors.fgSecondary,
                          size: 11,
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: MonoText(
                          'TOCA EL MAPA PARA FIJAR UN PUNTO',
                          color: AppColors.fgMuted,
                          size: 11,
                        ),
                      ),
                    VoidButton(
                      label: 'CONFIRMAR UBICACIÓN',
                      onPressed: _selected == null
                          ? null
                          : () => context.pop(_selected),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
cd mobile && flutter analyze --fatal-warnings
```
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add mobile/lib/features/map/pages/location_picker_page.dart
git commit -m "feat(mobile): add LocationPickerPage with flutter_map tap-to-pin"
```

---

## Task 8: Mobile — Register `/home/location-picker` route

**Files:**
- Modify: `mobile/lib/app.dart`

- [ ] **Step 1: Add route to `app.dart`**

In the `routes` list of `_router = GoRouter(...)`, add this route after the `/home/create-mission` route:

```dart
GoRoute(
  path: '/home/location-picker',
  builder: (_, __) => LocationPickerPage(
    locationService: _locationService,
  ),
),
```

Also add the import at the top of `app.dart`:
```dart
import 'features/map/pages/location_picker_page.dart';
```

- [ ] **Step 2: Verify**

```bash
cd mobile && flutter analyze --fatal-warnings
```
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add mobile/lib/app.dart
git commit -m "feat(mobile): register /home/location-picker route"
```

---

## Task 9: Mobile — Location picker in event creation

**Files:**
- Modify: `mobile/lib/features/events/bloc/create_event_bloc.dart`
- Modify: `mobile/lib/features/events/pages/create_event_page.dart`

`CreateEventSubmitted` currently has no lat/lng — the BLoC silently calls GPS. After this task, the page owns the location (from the picker) and passes it explicitly.

- [ ] **Step 1: Add `latitude`/`longitude` to `CreateEventSubmitted` and remove GPS call from BLoC**

Full `create_event_bloc.dart` after the edit:

```dart
// mobile/lib/features/events/bloc/create_event_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/location/location_service.dart';
import '../../../shared/models/event_model.dart';
import '../data/i_events_repository.dart';

// Events
abstract class CreateEventEvent extends Equatable {}

class CreateEventGenerateRequested extends CreateEventEvent {
  final String actionType;
  final String interventionLevel;

  CreateEventGenerateRequested({
    required this.actionType,
    required this.interventionLevel,
  });

  @override
  List<Object?> get props => [actionType, interventionLevel];
}

class CreateEventSubmitted extends CreateEventEvent {
  final String title;
  final String description;
  final String actionType;
  final String interventionLevel;
  final String visibility;
  final int durationMinutes;
  final double latitude;
  final double longitude;

  CreateEventSubmitted({
    required this.title,
    required this.description,
    required this.actionType,
    required this.interventionLevel,
    required this.visibility,
    required this.durationMinutes,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        actionType,
        interventionLevel,
        visibility,
        durationMinutes,
        latitude,
        longitude,
      ];
}

// States
abstract class CreateEventState extends Equatable {}

class CreateEventInitial extends CreateEventState {
  @override
  List<Object?> get props => [];
}

class CreateEventGenerating extends CreateEventState {
  @override
  List<Object?> get props => [];
}

class CreateEventSuggested extends CreateEventState {
  final GeneratedEventSuggestion suggestion;

  CreateEventSuggested(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

class CreateEventSubmitting extends CreateEventState {
  @override
  List<Object?> get props => [];
}

class CreateEventSuccess extends CreateEventState {
  final EventModel event;

  CreateEventSuccess(this.event);

  @override
  List<Object?> get props => [event];
}

class CreateEventError extends CreateEventState {
  final String message;

  CreateEventError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  final IEventsRepository _repository;
  final LocationService _locationService;

  CreateEventBloc({
    required IEventsRepository repository,
    required LocationService locationService,
  })  : _repository = repository,
        _locationService = locationService,
        super(CreateEventInitial()) {
    on<CreateEventGenerateRequested>(_onGenerateRequested);
    on<CreateEventSubmitted>(_onSubmitted);
  }

  Future<void> _onGenerateRequested(
    CreateEventGenerateRequested event,
    Emitter<CreateEventState> emit,
  ) async {
    emit(CreateEventGenerating());
    try {
      final (lat, lng) = await _locationService.getCurrentPosition();
      final suggestion = await _repository.generateEvent(
        GenerateEventRequest(
          actionType: event.actionType,
          interventionLevel: event.interventionLevel,
          latitude: lat,
          longitude: lng,
        ),
      );
      emit(CreateEventSuggested(suggestion));
    } catch (e) {
      emit(CreateEventError(e.toString()));
    }
  }

  Future<void> _onSubmitted(
    CreateEventSubmitted event,
    Emitter<CreateEventState> emit,
  ) async {
    emit(CreateEventSubmitting());
    try {
      final created = await _repository.createEvent(
        CreateEventRequest(
          title: event.title,
          description: event.description,
          actionType: event.actionType,
          interventionLevel: event.interventionLevel,
          latitude: event.latitude,
          longitude: event.longitude,
          radiusMeters: 200,
          visibility: event.visibility,
          startsAt: DateTime.now().toUtc(),
          durationMinutes: event.durationMinutes,
        ),
      );
      emit(CreateEventSuccess(created));
    } catch (e) {
      emit(CreateEventError(e.toString()));
    }
  }
}
```

- [ ] **Step 2: Add location picker field to `create_event_page.dart`**

The `_CreateEventViewState` needs:
1. A `LatLng? _pickedLocation` field.
2. A method `_openLocationPicker(BuildContext context)`.
3. A new "UBICACIÓN" `_Field` in the form.
4. The submit button disabled if `_pickedLocation == null`.
5. `latitude`/`longitude` passed in `CreateEventSubmitted`.

Add the import at the top:
```dart
import 'package:latlong2/latlong.dart';
```

Full `create_event_page.dart` after the edit (only the `_CreateEventViewState` class changes — `_Field`, `_Selector`, `_SuggestionCard` remain unchanged):

```dart
// mobile/lib/features/events/pages/create_event_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/event_model.dart';
import '../bloc/create_event_bloc.dart';
import '../data/events_repository.dart';

class CreateEventPage extends StatelessWidget {
  final LocationService locationService;
  final ApiClient apiClient;

  const CreateEventPage({
    super.key,
    required this.locationService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateEventBloc(
        repository: EventsRepository(apiClient),
        locationService: locationService,
      ),
      child: const _CreateEventView(),
    );
  }
}

class _CreateEventView extends StatefulWidget {
  const _CreateEventView();

  @override
  State<_CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<_CreateEventView> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _actionType = 'Performativa';
  String _interventionLevel = 'Bajo';
  String _visibility = 'Public';
  int _durationMinutes = 60;
  LatLng? _pickedLocation;

  static const _actionTypes = ['Performativa', 'Social', 'Sensorial', 'Poetica'];
  static const _interventionLevels = ['Bajo', 'Medio', 'Alto'];
  static const _visibilities = ['Public', 'Unlisted'];
  static const _durations = [30, 60, 120, 240];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final result = await context.push<LatLng>('/home/location-picker');
    if (result != null && mounted) {
      setState(() => _pickedLocation = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateEventBloc, CreateEventState>(
      listener: (context, state) {
        if (state is CreateEventSuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgVoid,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                MonoText(
                  'NUEVO EVENTO',
                  color: AppColors.fgPrimary,
                  size: 18,
                  letterSpacing: 4,
                ),
                const SizedBox(height: 4),
                Container(height: 1, color: AppColors.fgMuted),
                const SizedBox(height: 24),

                // Generate suggestion
                VoidButton(
                  label: state is CreateEventGenerating
                      ? 'GENERANDO...'
                      : '⚙ GENERAR SUGERENCIA IA',
                  onPressed: state is CreateEventGenerating
                      ? null
                      : () => context.read<CreateEventBloc>().add(
                            CreateEventGenerateRequested(
                              actionType: _actionType,
                              interventionLevel: _interventionLevel,
                            ),
                          ),
                ),

                if (state is CreateEventError) ...[
                  const SizedBox(height: 8),
                  MonoText(state.message, color: AppColors.danger, size: 11),
                ],

                if (state is CreateEventSuggested) ...[
                  const SizedBox(height: 12),
                  _SuggestionCard(
                    suggestion: state.suggestion,
                    onAccept: () {
                      _titleCtrl.text = state.suggestion.title;
                      _descCtrl.text = state.suggestion.description;
                      setState(() {
                        _actionType = state.suggestion.actionType;
                        _interventionLevel = state.suggestion.interventionLevel;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 24),
                _Field(
                    label: 'TÍTULO',
                    child: _textInput(_titleCtrl, 'nombre del evento')),
                const SizedBox(height: 16),
                _Field(
                  label: 'DESCRIPCIÓN',
                  child: _textInput(_descCtrl, 'descripción', maxLines: 4),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'TIPO',
                  child: _Selector(
                    options: _actionTypes,
                    selected: _actionType,
                    onSelect: (v) => setState(() => _actionType = v),
                  ),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'INTENSIDAD',
                  child: _Selector(
                    options: _interventionLevels,
                    selected: _interventionLevel,
                    onSelect: (v) => setState(() => _interventionLevel = v),
                  ),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'VISIBILIDAD',
                  child: _Selector(
                    options: _visibilities,
                    selected: _visibility,
                    onSelect: (v) => setState(() => _visibility = v),
                  ),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'DURACIÓN (MIN)',
                  child: _Selector(
                    options: _durations.map((d) => d.toString()).toList(),
                    selected: _durationMinutes.toString(),
                    onSelect: (v) =>
                        setState(() => _durationMinutes = int.parse(v)),
                  ),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'UBICACIÓN',
                  child: GestureDetector(
                    onTap: _openLocationPicker,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _pickedLocation != null
                              ? AppColors.phosphor
                              : AppColors.fgMuted,
                          width: 1,
                        ),
                      ),
                      child: MonoText(
                        _pickedLocation != null
                            ? 'LAT ${_pickedLocation!.latitude.toStringAsFixed(5)}'
                                '  LNG ${_pickedLocation!.longitude.toStringAsFixed(5)}'
                            : 'TOCA PARA ELEGIR EN EL MAPA →',
                        color: _pickedLocation != null
                            ? AppColors.phosphor
                            : AppColors.fgMuted,
                        size: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                VoidButton(
                  label: state is CreateEventSubmitting
                      ? 'CREANDO...'
                      : 'CREAR EVENTO',
                  onPressed: (state is CreateEventSubmitting ||
                          _pickedLocation == null)
                      ? null
                      : () {
                          if (_titleCtrl.text.isEmpty ||
                              _descCtrl.text.isEmpty) return;
                          context.read<CreateEventBloc>().add(
                                CreateEventSubmitted(
                                  title: _titleCtrl.text.trim(),
                                  description: _descCtrl.text.trim(),
                                  actionType: _actionType,
                                  interventionLevel: _interventionLevel,
                                  visibility: _visibility,
                                  durationMinutes: _durationMinutes,
                                  latitude: _pickedLocation!.latitude,
                                  longitude: _pickedLocation!.longitude,
                                ),
                              );
                        },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _textInput(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.fgMuted),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoText(label,
            color: AppColors.fgSecondary, size: 10, letterSpacing: 2),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _Selector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _Selector({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.phosphor.withOpacity(0.1)
                  : Colors.transparent,
              border: Border.all(
                color:
                    isSelected ? AppColors.phosphor : AppColors.fgMuted,
                width: 1,
              ),
            ),
            child: MonoText(
              opt.toUpperCase(),
              size: 11,
              color: isSelected ? AppColors.phosphor : AppColors.fgSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final GeneratedEventSuggestion suggestion;
  final VoidCallback onAccept;

  const _SuggestionCard({required this.suggestion, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppColors.phosphor.withOpacity(0.3), width: 1),
        color: AppColors.bgSurface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoText(suggestion.title.toUpperCase(),
              color: AppColors.phosphor, size: 12),
          const SizedBox(height: 6),
          Text(suggestion.description, style: AppTextStyles.body),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onAccept,
            child: MonoText(
              '→ USAR ESTA SUGERENCIA',
              color: AppColors.phosphor,
              size: 11,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Run all Flutter tests**

```bash
cd mobile && flutter test
```
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add mobile/lib/features/events/bloc/create_event_bloc.dart \
        mobile/lib/features/events/pages/create_event_page.dart
git commit -m "feat(mobile): add location picker to event creation form"
```

---

## Task 10: Mobile — Location picker in mission creation

**Files:**
- Modify: `mobile/lib/features/missions/pages/create_mission_page.dart`
- Modify: `mobile/lib/app.dart`

`CreateMissionBloc` already accepts `latitude`/`longitude` in `CreateMissionSubmitted`. The page currently calls `locationService.getCurrentPosition()` in `_submit()`. After this task the page uses `_pickedLocation` instead, and `locationService` is removed from the page entirely.

- [ ] **Step 1: Rewrite `create_mission_page.dart`**

Key changes vs the current file:
- Remove `LocationService locationService` from `CreateMissionPage` and `_CreateMissionView`.
- Add `LatLng? _pickedLocation` to `_CreateMissionViewState`.
- Add `_openLocationPicker()` method.
- Add "UBICACIÓN" `_Field` in the form (after RADIO, before the PISTAS section).
- Change `_submit()` to use `_pickedLocation` instead of calling GPS.
- Disable submit button if `_pickedLocation == null`.
- Add `import 'package:go_router/go_router.dart';` and `import 'package:latlong2/latlong.dart';`.

Full file:

```dart
// mobile/lib/features/missions/pages/create_mission_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/create_mission_bloc.dart';
import '../data/missions_repository.dart';

class CreateMissionPage extends StatelessWidget {
  final ApiClient apiClient;

  const CreateMissionPage({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateMissionBloc(repository: MissionsRepository(apiClient)),
      child: const _CreateMissionView(),
    );
  }
}

class _CreateMissionView extends StatefulWidget {
  const _CreateMissionView();

  @override
  State<_CreateMissionView> createState() => _CreateMissionViewState();
}

class _CreateMissionViewState extends State<_CreateMissionView> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _radiusMeters = 500;
  final List<_ClueEntry> _clues = [_ClueEntry()];
  LatLng? _pickedLocation;

  static const _radii = [100, 250, 500, 1000, 2000];
  static const _clueTypes = ['Textual', 'Sensorial', 'Contextual'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _clues) c.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final result = await context.push<LatLng>('/home/location-picker');
    if (result != null && mounted) {
      setState(() => _pickedLocation = result);
    }
  }

  void _submit() {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) return;
    if (_pickedLocation == null) return;
    if (_clues.any((c) =>
        c.contentCtrl.text.isEmpty || c.answerCtrl.text.isEmpty)) return;

    context.read<CreateMissionBloc>().add(CreateMissionSubmitted(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      latitude: _pickedLocation!.latitude,
      longitude: _pickedLocation!.longitude,
      radiusMeters: _radiusMeters,
      clues: _clues
          .map((c) => ClueFormData(
                type: c.selectedType,
                content: c.contentCtrl.text.trim(),
                answer: c.answerCtrl.text.trim(),
                hint: c.hintCtrl.text.trim(),
                isOptional: c.isOptional,
              ))
          .toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateMissionBloc, CreateMissionState>(
      listener: (context, state) {
        if (state is CreateMissionSuccess) context.pop();
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgVoid,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                MonoText('NUEVA MISIÓN',
                    color: AppColors.fgPrimary, size: 18, letterSpacing: 4),
                const SizedBox(height: 4),
                Container(height: 1, color: AppColors.fgMuted),
                const SizedBox(height: 24),
                _Field(
                    label: 'TÍTULO',
                    child: _textInput(_titleCtrl, 'nombre de la misión')),
                const SizedBox(height: 16),
                _Field(
                  label: 'DESCRIPCIÓN',
                  child: _textInput(_descCtrl, 'descripción de la misión',
                      maxLines: 3),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'RADIO (METROS)',
                  child: _Selector(
                    options: _radii.map((r) => r.toString()).toList(),
                    selected: _radiusMeters.toString(),
                    onSelect: (v) =>
                        setState(() => _radiusMeters = int.parse(v)),
                  ),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'UBICACIÓN',
                  child: GestureDetector(
                    onTap: _openLocationPicker,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _pickedLocation != null
                              ? AppColors.phosphor
                              : AppColors.fgMuted,
                          width: 1,
                        ),
                      ),
                      child: MonoText(
                        _pickedLocation != null
                            ? 'LAT ${_pickedLocation!.latitude.toStringAsFixed(5)}'
                                '  LNG ${_pickedLocation!.longitude.toStringAsFixed(5)}'
                            : 'TOCA PARA ELEGIR EN EL MAPA →',
                        color: _pickedLocation != null
                            ? AppColors.phosphor
                            : AppColors.fgMuted,
                        size: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(height: 1, color: AppColors.fgMuted),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PISTAS', style: AppTextStyles.monoDisplay),
                    GestureDetector(
                      onTap: () => setState(() => _clues.add(_ClueEntry())),
                      child: MonoText('+ AÑADIR',
                          color: AppColors.phosphor, size: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._clues.asMap().entries.map((entry) {
                  final i = entry.key;
                  final clue = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _ClueForm(
                      index: i,
                      entry: clue,
                      clueTypes: _clueTypes,
                      canRemove: _clues.length > 1,
                      onRemove: () => setState(() => _clues.removeAt(i)),
                      onChanged: () => setState(() {}),
                    ),
                  );
                }),
                if (state is CreateMissionError) ...[
                  const SizedBox(height: 8),
                  MonoText(state.message, color: AppColors.danger, size: 11),
                ],
                const SizedBox(height: 16),
                VoidButton(
                  label: state is CreateMissionSubmitting
                      ? 'CREANDO...'
                      : 'CREAR MISIÓN',
                  onPressed: (state is CreateMissionSubmitting ||
                          _pickedLocation == null)
                      ? null
                      : _submit,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _textInput(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.fgMuted),
      ),
    );
  }
}

// ── Clue form state ───────────────────────────────────────────────────────────

class _ClueEntry {
  final contentCtrl = TextEditingController();
  final answerCtrl = TextEditingController();
  final hintCtrl = TextEditingController();
  String selectedType = 'Textual';
  bool isOptional = false;

  void dispose() {
    contentCtrl.dispose();
    answerCtrl.dispose();
    hintCtrl.dispose();
  }
}

class _ClueForm extends StatelessWidget {
  final int index;
  final _ClueEntry entry;
  final List<String> clueTypes;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _ClueForm({
    required this.index,
    required this.entry,
    required this.clueTypes,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(border: Border.all(color: AppColors.fgMuted, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MonoText('PISTA ${index + 1}',
                  color: AppColors.fgSecondary, size: 10, letterSpacing: 2),
              if (canRemove)
                GestureDetector(
                  onTap: onRemove,
                  child:
                      MonoText('ELIMINAR', color: AppColors.danger, size: 10),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'TIPO',
            child: _Selector(
              options: clueTypes,
              selected: entry.selectedType,
              onSelect: (v) {
                entry.selectedType = v;
                onChanged();
              },
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'CONTENIDO',
            child: TextField(
              controller: entry.contentCtrl,
              maxLines: 2,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'descripción de la pista',
                hintStyle:
                    AppTextStyles.body.copyWith(color: AppColors.fgMuted),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'RESPUESTA',
            child: TextField(
              controller: entry.answerCtrl,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'respuesta correcta',
                hintStyle:
                    AppTextStyles.body.copyWith(color: AppColors.fgMuted),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'PISTA (OPCIONAL)',
            child: TextField(
              controller: entry.hintCtrl,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'ayuda para el jugador',
                hintStyle:
                    AppTextStyles.body.copyWith(color: AppColors.fgMuted),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              entry.isOptional = !entry.isOptional;
              onChanged();
            },
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: entry.isOptional
                          ? AppColors.phosphor
                          : AppColors.fgMuted,
                    ),
                    color: entry.isOptional
                        ? AppColors.phosphor.withOpacity(0.15)
                        : Colors.transparent,
                  ),
                ),
                const SizedBox(width: 8),
                MonoText('PISTA OPCIONAL',
                    color: AppColors.fgSecondary, size: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared local widgets ──────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoText(label,
            color: AppColors.fgSecondary, size: 10, letterSpacing: 2),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _Selector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _Selector(
      {required this.options,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.phosphor.withOpacity(0.1)
                  : Colors.transparent,
              border: Border.all(
                  color:
                      isSelected ? AppColors.phosphor : AppColors.fgMuted),
            ),
            child: MonoText(
              opt.toUpperCase(),
              size: 11,
              color:
                  isSelected ? AppColors.phosphor : AppColors.fgSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

- [ ] **Step 2: Update `app.dart` — fix `CreateMissionPage` builder**

Find:
```dart
GoRoute(
  path: '/home/create-mission',
  builder: (_, __) => CreateMissionPage(
    locationService: _locationService,
    apiClient: _apiClient,
  ),
),
```
Replace with:
```dart
GoRoute(
  path: '/home/create-mission',
  builder: (_, __) => CreateMissionPage(apiClient: _apiClient),
),
```

- [ ] **Step 3: Run all Flutter tests**

```bash
cd mobile && flutter test
```
Expected: All tests pass.

- [ ] **Step 4: Final analyze**

```bash
cd mobile && flutter analyze --fatal-warnings
```
Expected: No issues found.

- [ ] **Step 5: Rebuild the backend container to pick up all changes**

```bash
docker compose up api --build -d
```
Expected: Container rebuilt and started.

- [ ] **Step 6: Final commit**

```bash
git add mobile/lib/features/missions/pages/create_mission_page.dart \
        mobile/lib/app.dart
git commit -m "feat(mobile): add location picker to mission creation form"
```
