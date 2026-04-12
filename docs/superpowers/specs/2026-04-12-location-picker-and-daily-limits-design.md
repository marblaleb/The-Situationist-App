# Spec: Location Picker + Daily Creation Limits

**Date:** 2026-04-12  
**Status:** Approved

---

## Overview

Two features added to event and mission creation:

1. **Location picker** — instead of silently using GPS at submit time, the user explicitly picks a point on a map before creating an event or mission.
2. **Daily creation limits** — a user can create at most 2 events and 2 missions per UTC day. The create hub disables options when the limit is reached.

---

## Feature 1: Map Location Picker

### New page: `LocationPickerPage`

**File:** `mobile/lib/features/map/pages/location_picker_page.dart`

- Accepts `LatLng? initialLocation` (optional).
- On open: centers map on GPS position if available; otherwise uses a default center.
- Full-screen `flutter_map` (already a dependency).
- User taps anywhere on the map → pin marker moves to that point.
- Bottom bar shows live coordinates of the current pin.
- "CONFIRMAR UBICACIÓN" button → `context.pop(selectedLatLng)`.
- "CANCELAR" (or back) → `context.pop(null)`.

### New route

`/home/location-picker` added to `app.dart` outside the `StatefulShellRoute`. Builder passes `LocationPickerPage(initialLocation: null)`.

### Changes to `CreateEventPage`

- New `LatLng? _pickedLocation` state field.
- New tappable "UBICACIÓN" field rendered between DURACIÓN and the submit button.
  - Shows `"SIN UBICAR"` when null, or `"LAT X.XXXX / LNG X.XXXX"` when set.
  - On tap: `final result = await context.push<LatLng>('/home/location-picker'); if (result != null) setState(() => _pickedLocation = result);`
- CREAR EVENTO button disabled if `_pickedLocation == null`.
- `CreateEventSubmitted` event now carries `double latitude, double longitude` (passed from `_pickedLocation`).
- `locationService` is no longer passed to `CreateEventPage` (it was only needed for submit; generate still works via the BLoC).

> **Note:** `locationService` stays in `CreateEventBloc` because `_onGenerateRequested` still calls `_locationService.getCurrentPosition()` to provide geographic context to the AI suggestion endpoint.

### Changes to `CreateMissionPage`

- Same pattern: new `LatLng? _pickedLocation` field.
- New tappable "UBICACIÓN" field.
- `_submit()` uses `_pickedLocation!.latitude` / `_pickedLocation!.longitude` instead of calling `widget.locationService.getCurrentPosition()`.
- CREAR MISIÓN button disabled if `_pickedLocation == null`.
- `CreateMissionSubmitted` event carries `double latitude, double longitude`.

### Changes to BLoC events

**`create_event_bloc.dart`:**
- `CreateEventSubmitted` adds fields: `required double latitude, required double longitude`.
- `CreateEventBloc._onSubmitted` removes the `_locationService.getCurrentPosition()` call; uses `event.latitude` / `event.longitude` directly.

**`create_mission_bloc.dart`:**
- `CreateMissionSubmitted` adds fields: `required double latitude, required double longitude`.
- `CreateMissionBloc._onSubmitted` removes the `locationService` call; uses `event.latitude` / `event.longitude`.

---

## Feature 2: Daily Creation Limits

### Limit rule

- Maximum **2 events** and **2 missions** per user per **UTC day**.
- `DailyLimit = 2` (hardcoded constant, same for both resource types).
- The day boundary is UTC midnight (`CreatedAt >= today 00:00:00 UTC`).

### Backend — new query

**File:** `backend/src/Api/Features/Profile/GetCreationLimitsQuery.cs`

```
GetCreationLimitsQuery(Guid UserId) → CreationLimitsResponse
CreationLimitsResponse(int EventsToday, int MissionsToday, int DailyLimit)
```

Handler queries:
- `db.Events.Count(e => e.CreatorId == userId && e.CreatedAt >= todayUtc)`
- `db.Missions.Count(m => m.CreatorId == userId && m.CreatedAt >= todayUtc)`

`todayUtc = DateTimeOffset.UtcNow.Date` (midnight UTC).

### Backend — new endpoint

`ProfileEndpoints` adds:

```
GET /profile/me/creation-limits
→ 200 CreationLimitsResponse
```

### Backend — enforcement on create

**`CreateEventCommandHandler.Handle`:** at the top, before any insert:

```csharp
var todayUtc = DateTimeOffset.UtcNow.Date;
var eventsToday = await db.Events.CountAsync(e => e.CreatorId == request.CreatorId && e.CreatedAt >= todayUtc, ct);
if (eventsToday >= 2)
    throw new InvalidOperationException("Daily event creation limit reached");
```

**`CreateMissionCommandHandler.Handle`:** same pattern for missions.

### Backend — error handling in create endpoints

`EventEndpoints.MapPost("/")` and `MissionEndpoints.MapPost("/")` currently have no try/catch. Both add:

```csharp
catch (InvalidOperationException ex)
{
    return Results.Conflict(new { error = ex.Message });
}
```

### Mobile — model

**File:** `mobile/lib/shared/models/creation_limits_model.dart`

Plain Dart class (no freezed needed — read-only, no copyWith required):

```dart
class CreationLimitsModel {
  final int eventsToday;
  final int missionsToday;
  final int dailyLimit;
  // fromJson constructor
}
```

### Mobile — repository

`IProfileRepository` gains:

```dart
Future<CreationLimitsModel> getCreationLimits();
```

`ProfileRepository` implements it with `GET /profile/me/creation-limits`.

### Mobile — BLoC

**File:** `mobile/lib/features/events/bloc/create_hub_bloc.dart`

States:
- `CreateHubInitial`
- `CreateHubLoading`
- `CreateHubLoaded(CreationLimitsModel limits)`
- `CreateHubError(String message)`

Event: `CreateHubLimitsRequested` — fired in the BLoC constructor via `add(CreateHubLimitsRequested())`.

### Mobile — `CreateHubPage`

- Becomes a non-const constructor receiving `ApiClient apiClient`.
- Wraps content with `BlocProvider<CreateHubBloc>`.
- In `BlocBuilder`:
  - `CreateHubLoading` / `CreateHubInitial`: show skeleton or loading indicator.
  - `CreateHubLoaded`: render options. For each option, if `limits.eventsToday >= limits.dailyLimit` (events) or `limits.missionsToday >= limits.dailyLimit` (missions), the option is rendered disabled: `onTap: null`, border color `AppColors.fgMuted`, add a `MonoText("LÍMITE DIARIO ALCANZADO", color: AppColors.danger, size: 10)` line below subtitle.
  - `CreateHubError`: show error text with a retry button.
- `app.dart` changes builder for `/home/create` to `CreateHubPage(apiClient: _apiClient)`.

---

## Out of scope

- Configurable daily limit (hardcoded at 2).
- Per-timezone day boundaries.
- Admin override or limit increase.
- Showing time until reset.

---

## Files changed summary

| File | Change |
|------|--------|
| `mobile/lib/features/map/pages/location_picker_page.dart` | **New** |
| `mobile/lib/features/events/pages/create_event_page.dart` | Add location field + disable logic |
| `mobile/lib/features/missions/pages/create_mission_page.dart` | Add location field + disable logic |
| `mobile/lib/features/events/bloc/create_event_bloc.dart` | Add lat/lng to `CreateEventSubmitted` |
| `mobile/lib/features/missions/bloc/create_mission_bloc.dart` | Add lat/lng to `CreateMissionSubmitted` |
| `mobile/lib/app.dart` | Add `/home/location-picker` route; pass `apiClient` to `CreateHubPage` |
| `mobile/lib/shared/models/creation_limits_model.dart` | **New** |
| `mobile/lib/features/profile/data/i_profile_repository.dart` | Add `getCreationLimits()` |
| `mobile/lib/features/profile/data/profile_repository.dart` | Implement `getCreationLimits()` |
| `mobile/lib/features/events/bloc/create_hub_bloc.dart` | **New** |
| `mobile/lib/features/events/pages/create_hub_page.dart` | Integrate `CreateHubBloc`, disable options |
| `backend/src/Api/Features/Profile/GetCreationLimitsQuery.cs` | **New** |
| `backend/src/Api/Features/Profile/ProfileEndpoints.cs` | Add `GET /profile/me/creation-limits` |
| `backend/src/Api/Features/Events/CreateEventCommand.cs` | Add daily limit check |
| `backend/src/Api/Features/Missions/CreateMissionCommand.cs` | Add daily limit check |
| `backend/src/Api/Features/Events/EventEndpoints.cs` | Add try/catch on `POST /` |
| `backend/src/Api/Features/Missions/MissionEndpoints.cs` | Add try/catch on `POST /` |
