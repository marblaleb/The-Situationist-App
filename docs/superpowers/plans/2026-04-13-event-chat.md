# Event Chat Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add real-time per-event chat via SignalR so users can message each other while participating in an event.

**Architecture:** A `ChatMessage` entity (EventId, SenderId, Content, SentAt) persists messages. `EventHub` gains three new methods (`JoinEvent`, `LeaveEvent`, `SendMessage`) that save to DB and broadcast `ReceiveMessage` to a SignalR group keyed by event ID. The Flutter side adds a `ChatBloc` that loads history via REST and receives live messages via the existing `SignalRService` stream. A new `EventChatPage` is accessed via a CHAT button added to `EventDetailSheet`.

**Tech Stack:** .NET 9 · ASP.NET Core SignalR · EF Core + PostgreSQL · MediatR · Flutter BLoC · `signalr_netcore`

---

## File Map

**Backend — create:**
- `backend/src/Domain/Entities/ChatMessage.cs` — entity
- `backend/src/Infrastructure/SignalR/ChatMessageDto.cs` — shared DTO (used by hub + REST handler)
- `backend/src/Api/Features/Chat/GetChatMessagesQuery.cs` — MediatR query + handler
- `backend/src/Api/Features/Chat/ChatEndpoints.cs` — minimal API endpoint

**Backend — modify:**
- `backend/src/Infrastructure/Persistence/AppDbContext.cs` — add `DbSet<ChatMessage>` + EF config
- `backend/src/Infrastructure/SignalR/EventHub.cs` — add `JoinEvent`, `LeaveEvent`, `SendMessage`
- `backend/src/Api/Program.cs` — register `MapChatEndpoints()`

**Flutter — create:**
- `mobile/lib/shared/models/chat_message_model.dart`
- `mobile/lib/features/chat/data/i_chat_repository.dart`
- `mobile/lib/features/chat/data/chat_repository.dart`
- `mobile/lib/features/chat/bloc/chat_bloc.dart`
- `mobile/lib/features/chat/pages/event_chat_page.dart`
- `mobile/test/features/chat/chat_bloc_test.dart`

**Flutter — modify:**
- `mobile/lib/core/realtime/signalr_service.dart` — add `ChatMessageSignal` + hub methods
- `mobile/lib/features/map/widgets/event_detail_sheet.dart` — add CHAT button
- `mobile/lib/app.dart` — add `/home/events/:id/chat` route

---

## Task 1: ChatMessage entity + DB migration

**Files:**
- Create: `backend/src/Domain/Entities/ChatMessage.cs`
- Modify: `backend/src/Infrastructure/Persistence/AppDbContext.cs`

- [ ] **Step 1: Create the entity**

Create `backend/src/Domain/Entities/ChatMessage.cs`:

```csharp
namespace Domain.Entities;

public class ChatMessage
{
    public Guid Id { get; set; }
    public Guid EventId { get; set; }
    public Guid SenderId { get; set; }
    public string Content { get; set; } = string.Empty;
    public DateTimeOffset SentAt { get; set; }

    public Event Event { get; set; } = null!;
    public User Sender { get; set; } = null!;
}
```

- [ ] **Step 2: Register in AppDbContext**

In `backend/src/Infrastructure/Persistence/AppDbContext.cs`, add `DbSet` after the existing sets and add EF config in `OnModelCreating`.

Add after `public DbSet<ActivityLog> ActivityLogs => Set<ActivityLog>();`:
```csharp
public DbSet<ChatMessage> ChatMessages => Set<ChatMessage>();
```

Add at the end of `OnModelCreating`, before the closing brace:
```csharp
// ChatMessage
modelBuilder.Entity<ChatMessage>(e =>
{
    e.HasKey(x => x.Id);
    e.HasIndex(x => new { x.EventId, x.SentAt });
    e.HasOne(x => x.Event).WithMany().HasForeignKey(x => x.EventId).OnDelete(DeleteBehavior.Cascade);
    e.HasOne(x => x.Sender).WithMany().HasForeignKey(x => x.SenderId).OnDelete(DeleteBehavior.Restrict);
});
```

- [ ] **Step 3: Generate migration**

Run from repo root (`C:\Users\elebr\OneDrive\Escritorio\Claude`):

```bash
dotnet ef migrations add AddChatMessages \
  --project backend/src/Infrastructure \
  --startup-project backend/src/Api
```

Expected output: `Build started... Done. To undo this action, use 'ef migrations remove'`

A new file `backend/src/Infrastructure/Migrations/<timestamp>_AddChatMessages.cs` will be generated.

- [ ] **Step 4: Verify migration builds**

```bash
dotnet build backend/src/Infrastructure
```

Expected: `Build succeeded.`

- [ ] **Step 5: Commit**

```bash
git add backend/src/Domain/Entities/ChatMessage.cs \
        backend/src/Infrastructure/Persistence/AppDbContext.cs \
        backend/src/Infrastructure/Migrations/
git commit -m "feat: add ChatMessage entity and migration"
```

---

## Task 2: Chat REST endpoint

**Files:**
- Create: `backend/src/Infrastructure/SignalR/ChatMessageDto.cs`
- Create: `backend/src/Api/Features/Chat/GetChatMessagesQuery.cs`
- Create: `backend/src/Api/Features/Chat/ChatEndpoints.cs`
- Modify: `backend/src/Api/Program.cs`

- [ ] **Step 1: Create ChatMessageDto**

Create `backend/src/Infrastructure/SignalR/ChatMessageDto.cs`:

```csharp
namespace Infrastructure.SignalR;

public record ChatMessageDto(
    Guid Id,
    Guid EventId,
    Guid SenderId,
    string SenderEmail,
    string Content,
    DateTimeOffset SentAt);
```

This record lives in Infrastructure so both the hub and the REST handler can use it without a circular reference.

- [ ] **Step 2: Create the MediatR query**

Create `backend/src/Api/Features/Chat/GetChatMessagesQuery.cs`:

```csharp
using Infrastructure.Persistence;
using Infrastructure.SignalR;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Api.Features.Chat;

public record GetChatMessagesQuery(Guid EventId) : IRequest<List<ChatMessageDto>>;

public class GetChatMessagesQueryHandler(AppDbContext db)
    : IRequestHandler<GetChatMessagesQuery, List<ChatMessageDto>>
{
    public async Task<List<ChatMessageDto>> Handle(
        GetChatMessagesQuery request,
        CancellationToken ct)
    {
        var messages = await db.ChatMessages
            .Where(m => m.EventId == request.EventId)
            .Include(m => m.Sender)
            .OrderByDescending(m => m.SentAt)
            .Take(50)
            .Select(m => new ChatMessageDto(
                m.Id, m.EventId, m.SenderId,
                m.Sender.Email, m.Content, m.SentAt))
            .ToListAsync(ct);

        messages.Reverse(); // oldest first for display
        return messages;
    }
}
```

- [ ] **Step 3: Create the endpoint**

Create `backend/src/Api/Features/Chat/ChatEndpoints.cs`:

```csharp
using Infrastructure.SignalR;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace Api.Features.Chat;

public static class ChatEndpoints
{
    public static IEndpointRouteBuilder MapChatEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/events").RequireAuthorization();

        group.MapGet("/{id:guid}/messages", async (Guid id, ISender mediator) =>
        {
            var result = await mediator.Send(new GetChatMessagesQuery(id));
            return Results.Ok(result);
        });

        return app;
    }
}
```

- [ ] **Step 4: Register the endpoint in Program.cs**

In `backend/src/Api/Program.cs`, add the using at the top with the other feature usings:
```csharp
using Api.Features.Chat;
```

Add the endpoint registration after `app.MapProfileEndpoints();`:
```csharp
app.MapChatEndpoints();
```

- [ ] **Step 5: Build the API**

```bash
dotnet build backend/src/Api
```

Expected: `Build succeeded.`

- [ ] **Step 6: Commit**

```bash
git add backend/src/Infrastructure/SignalR/ChatMessageDto.cs \
        backend/src/Api/Features/Chat/GetChatMessagesQuery.cs \
        backend/src/Api/Features/Chat/ChatEndpoints.cs \
        backend/src/Api/Program.cs
git commit -m "feat: add GET /events/{id}/messages endpoint"
```

---

## Task 3: EventHub chat methods

**Files:**
- Modify: `backend/src/Infrastructure/SignalR/EventHub.cs`

- [ ] **Step 1: Add JoinEvent, LeaveEvent, SendMessage to the hub**

Replace the entire content of `backend/src/Infrastructure/SignalR/EventHub.cs` with:

```csharp
using Domain.Entities;
using Infrastructure.Persistence;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;

namespace Infrastructure.SignalR;

[Authorize]
public class EventHub(AppDbContext db) : Hub
{
    public async Task JoinZone(string geohash5)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"zone:{geohash5}");
    }

    public async Task LeaveZone(string geohash5)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"zone:{geohash5}");
    }

    public async Task JoinEvent(string eventId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"event:{eventId}");
    }

    public async Task LeaveEvent(string eventId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"event:{eventId}");
    }

    public async Task SendMessage(string eventId, string content)
    {
        var userIdStr = Context.User?.FindFirst("sub")?.Value;
        if (userIdStr is null || string.IsNullOrWhiteSpace(content)) return;

        var userId = Guid.Parse(userIdStr);
        var user = await db.Users.FindAsync(userId);
        if (user is null) return;

        var message = new ChatMessage
        {
            Id = Guid.NewGuid(),
            EventId = Guid.Parse(eventId),
            SenderId = userId,
            Content = content.Trim(),
            SentAt = DateTimeOffset.UtcNow,
        };

        db.ChatMessages.Add(message);
        await db.SaveChangesAsync();

        var dto = new ChatMessageDto(
            message.Id,
            message.EventId,
            userId,
            user.Email,
            message.Content,
            message.SentAt);

        await Clients.Group($"event:{eventId}").SendAsync("ReceiveMessage", dto);
    }
}
```

- [ ] **Step 2: Build Infrastructure**

```bash
dotnet build backend/src/Infrastructure
```

Expected: `Build succeeded.`

- [ ] **Step 3: Run existing backend tests to confirm nothing broke**

```bash
dotnet test backend/tests/UnitTests
```

Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
git add backend/src/Infrastructure/SignalR/EventHub.cs
git commit -m "feat: add JoinEvent, LeaveEvent, SendMessage to EventHub"
```

---

## Task 4: ChatMessageModel (Flutter)

**Files:**
- Create: `mobile/lib/shared/models/chat_message_model.dart`

- [ ] **Step 1: Create the model**

Create `mobile/lib/shared/models/chat_message_model.dart`:

```dart
class ChatMessageModel {
  final String id;
  final String eventId;
  final String senderId;
  final String senderEmail;
  final String content;
  final DateTime sentAt;

  const ChatMessageModel({
    required this.id,
    required this.eventId,
    required this.senderId,
    required this.senderEmail,
    required this.content,
    required this.sentAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      senderId: json['senderId'] as String,
      senderEmail: json['senderEmail'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String).toLocal(),
    );
  }

  String get senderHandle => senderEmail.split('@').first;
}
```

- [ ] **Step 2: Run tests to confirm nothing broke**

```bash
cd mobile && flutter test
```

Expected: all existing tests pass.

- [ ] **Step 3: Commit**

```bash
git add mobile/lib/shared/models/chat_message_model.dart
git commit -m "feat: add ChatMessageModel"
```

---

## Task 5: SignalRService chat methods

**Files:**
- Modify: `mobile/lib/core/realtime/signalr_service.dart`

The current sealed class has `EventExpiredSignal` and `EventFullSignal`. Add `ChatMessageSignal`. Add three new methods: `joinEvent`, `leaveEvent`, `sendMessage`. Subscribe to `ReceiveMessage` in `connect()`.

- [ ] **Step 1: Update signalr_service.dart**

Replace the entire content of `mobile/lib/core/realtime/signalr_service.dart` with:

```dart
import 'dart:async';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../auth/auth_service.dart';
import '../../shared/models/chat_message_model.dart';

sealed class SignalREvent {}

class EventExpiredSignal extends SignalREvent {
  final String eventId;
  EventExpiredSignal(this.eventId);
}

class EventFullSignal extends SignalREvent {
  final String eventId;
  EventFullSignal(this.eventId);
}

class ChatMessageSignal extends SignalREvent {
  final ChatMessageModel message;
  ChatMessageSignal(this.message);
}

class SignalRService {
  static const _hubUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.situationist.app',
  ) + '/hubs/events';

  final AuthService _authService;
  HubConnection? _connection;
  final _controller = StreamController<SignalREvent>.broadcast();
  String? _currentZone;

  SignalRService(this._authService);

  Stream<SignalREvent> get events => _controller.stream;

  Future<void> connect() async {
    _connection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                await _authService.getToken() ?? '',
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('EventExpired', (args) {
      final id = args?.firstOrNull as String?;
      if (id != null) _controller.add(EventExpiredSignal(id));
    });

    _connection!.on('EventFull', (args) {
      final id = args?.firstOrNull as String?;
      if (id != null) _controller.add(EventFullSignal(id));
    });

    _connection!.on('ReceiveMessage', (args) {
      final data = args?.firstOrNull;
      if (data == null) return;
      try {
        final msg = ChatMessageModel.fromJson(
            Map<String, dynamic>.from(data as Map));
        _controller.add(ChatMessageSignal(msg));
      } catch (_) {}
    });

    await _connection!.start();
  }

  Future<void> joinZone(double lat, double lng) async {
    if (_connection?.state != HubConnectionState.Connected) return;
    final geohash = GeoHasher().encode(lng, lat, precision: 5);
    if (geohash == _currentZone) return;
    _currentZone = geohash;
    await _connection!.invoke('JoinZone', args: [geohash]);
  }

  Future<void> joinEvent(String eventId) async {
    if (_connection?.state != HubConnectionState.Connected) return;
    await _connection!.invoke('JoinEvent', args: [eventId]);
  }

  Future<void> leaveEvent(String eventId) async {
    if (_connection?.state != HubConnectionState.Connected) return;
    await _connection!.invoke('LeaveEvent', args: [eventId]);
  }

  Future<void> sendMessage(String eventId, String content) async {
    if (_connection?.state != HubConnectionState.Connected) return;
    await _connection!.invoke('SendMessage', args: [eventId, content]);
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
    _currentZone = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
```

- [ ] **Step 2: Run tests**

```bash
cd mobile && flutter test
```

Expected: all existing tests pass.

- [ ] **Step 3: Commit**

```bash
git add mobile/lib/core/realtime/signalr_service.dart
git commit -m "feat: add ChatMessageSignal and chat hub methods to SignalRService"
```

---

## Task 6: IChatRepository + ChatRepository

**Files:**
- Create: `mobile/lib/features/chat/data/i_chat_repository.dart`
- Create: `mobile/lib/features/chat/data/chat_repository.dart`

- [ ] **Step 1: Create the interface**

Create `mobile/lib/features/chat/data/i_chat_repository.dart`:

```dart
import '../../../shared/models/chat_message_model.dart';

abstract class IChatRepository {
  Future<List<ChatMessageModel>> getMessages(String eventId);
}
```

- [ ] **Step 2: Create the implementation**

Create `mobile/lib/features/chat/data/chat_repository.dart`:

```dart
import '../../../core/network/api_client.dart';
import '../../../shared/models/chat_message_model.dart';
import 'i_chat_repository.dart';

class ChatRepository implements IChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  @override
  Future<List<ChatMessageModel>> getMessages(String eventId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/events/$eventId/messages',
    );
    return (response.data as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ChatMessageModel.fromJson)
        .toList();
  }
}
```

- [ ] **Step 3: Run tests**

```bash
cd mobile && flutter test
```

Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
git add mobile/lib/features/chat/data/i_chat_repository.dart \
        mobile/lib/features/chat/data/chat_repository.dart
git commit -m "feat: add IChatRepository and ChatRepository"
```

---

## Task 7: ChatBloc + tests

**Files:**
- Create: `mobile/lib/features/chat/bloc/chat_bloc.dart`
- Create: `mobile/test/features/chat/chat_bloc_test.dart`

- [ ] **Step 1: Write the failing tests first**

Create `mobile/test/features/chat/chat_bloc_test.dart`:

```dart
import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:situationist/features/chat/bloc/chat_bloc.dart';
import 'package:situationist/features/chat/data/i_chat_repository.dart';
import 'package:situationist/core/realtime/signalr_service.dart';
import 'package:situationist/shared/models/chat_message_model.dart';

class MockChatRepository extends Mock implements IChatRepository {}

class MockSignalRService extends Mock implements SignalRService {}

final _now = DateTime.now();

final _mockMsg = ChatMessageModel(
  id: 'msg-1',
  eventId: 'event-1',
  senderId: 'user-1',
  senderEmail: 'alice@test.com',
  content: 'hola',
  sentAt: _now,
);

void main() {
  late MockChatRepository repo;
  late MockSignalRService signalR;

  setUp(() {
    repo = MockChatRepository();
    signalR = MockSignalRService();
    when(() => signalR.events).thenAnswer((_) => const Stream.empty());
    when(() => signalR.joinEvent(any())).thenAnswer((_) async {});
    when(() => signalR.leaveEvent(any())).thenAnswer((_) async {});
    when(() => signalR.sendMessage(any(), any())).thenAnswer((_) async {});
  });

  group('ChatBloc', () {
    blocTest<ChatBloc, ChatState>(
      'emite ChatLoading luego ChatLoaded con historial al recibir ChatStarted',
      build: () {
        when(() => repo.getMessages('event-1'))
            .thenAnswer((_) async => [_mockMsg]);
        return ChatBloc(repository: repo, signalRService: signalR);
      },
      act: (bloc) => bloc.add(ChatStarted('event-1')),
      expect: () => [
        isA<ChatLoading>(),
        isA<ChatLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ChatLoaded;
        expect(state.messages, hasLength(1));
        expect(state.messages.first.content, 'hola');
        verify(() => signalR.joinEvent('event-1')).called(1);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'añade mensaje al estado al recibir ChatMessageReceived via SignalR',
      build: () {
        when(() => repo.getMessages('event-1'))
            .thenAnswer((_) async => [_mockMsg]);
        final controller = StreamController<SignalREvent>.broadcast();
        when(() => signalR.events).thenAnswer((_) => controller.stream);
        when(() => signalR.joinEvent(any())).thenAnswer((_) async {
          controller.add(ChatMessageSignal(ChatMessageModel(
            id: 'msg-2',
            eventId: 'event-1',
            senderId: 'user-2',
            senderEmail: 'bob@test.com',
            content: 'buenas',
            sentAt: _now,
          )));
        });
        return ChatBloc(repository: repo, signalRService: signalR);
      },
      act: (bloc) => bloc.add(ChatStarted('event-1')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<ChatLoading>(),
        isA<ChatLoaded>(),
        isA<ChatLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ChatLoaded;
        expect(state.messages, hasLength(2));
        expect(state.messages.last.content, 'buenas');
      },
    );

    blocTest<ChatBloc, ChatState>(
      'emite ChatError cuando falla la carga',
      build: () {
        when(() => repo.getMessages('event-1'))
            .thenThrow(Exception('network error'));
        return ChatBloc(repository: repo, signalRService: signalR);
      },
      act: (bloc) => bloc.add(ChatStarted('event-1')),
      expect: () => [
        isA<ChatLoading>(),
        isA<ChatError>(),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'llama sendMessage en SignalR al enviar ChatMessageSent',
      build: () {
        when(() => repo.getMessages('event-1'))
            .thenAnswer((_) async => []);
        return ChatBloc(repository: repo, signalRService: signalR);
      },
      seed: () => ChatLoaded(eventId: 'event-1', messages: []),
      act: (bloc) => bloc.add(ChatMessageSent('nuevo mensaje')),
      verify: (_) {
        verify(() => signalR.sendMessage('event-1', 'nuevo mensaje')).called(1);
      },
    );
  });
}
```

- [ ] **Step 2: Run failing tests to verify they fail**

```bash
cd mobile && flutter test test/features/chat/chat_bloc_test.dart
```

Expected: FAIL (ChatBloc does not exist yet).

- [ ] **Step 3: Implement ChatBloc**

Create `mobile/lib/features/chat/bloc/chat_bloc.dart`:

```dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/realtime/signalr_service.dart';
import '../../../shared/models/chat_message_model.dart';
import '../data/i_chat_repository.dart';

// Events
abstract class ChatEvent extends Equatable {}

class ChatStarted extends ChatEvent {
  final String eventId;
  ChatStarted(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class ChatMessageSent extends ChatEvent {
  final String content;
  ChatMessageSent(this.content);
  @override
  List<Object?> get props => [content];
}

class _ChatMessageReceived extends ChatEvent {
  final ChatMessageModel message;
  _ChatMessageReceived(this.message);
  @override
  List<Object?> get props => [message];
}

// States
abstract class ChatState extends Equatable {}

class ChatInitial extends ChatState {
  @override
  List<Object?> get props => [];
}

class ChatLoading extends ChatState {
  @override
  List<Object?> get props => [];
}

class ChatLoaded extends ChatState {
  final String eventId;
  final List<ChatMessageModel> messages;

  ChatLoaded({required this.eventId, required this.messages});

  @override
  List<Object?> get props => [eventId, messages];
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IChatRepository _repository;
  final SignalRService _signalRService;
  StreamSubscription<SignalREvent>? _signalRSub;

  ChatBloc({
    required IChatRepository repository,
    required SignalRService signalRService,
  })  : _repository = repository,
        _signalRService = signalRService,
        super(ChatInitial()) {
    on<ChatStarted>(_onStarted);
    on<ChatMessageSent>(_onSent);
    on<_ChatMessageReceived>(_onReceived);
  }

  Future<void> _onStarted(ChatStarted event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await _repository.getMessages(event.eventId);
      emit(ChatLoaded(eventId: event.eventId, messages: messages));
      // Subscribe before joining so messages emitted during join are not missed
      // (broadcast streams do not buffer for late subscribers).
      _signalRSub = _signalRService.events.listen((e) {
        if (e is ChatMessageSignal && e.message.eventId == event.eventId) {
          add(_ChatMessageReceived(e.message));
        }
      });
      await _signalRService.joinEvent(event.eventId);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;
    final loaded = state as ChatLoaded;
    await _signalRService.sendMessage(loaded.eventId, event.content);
  }

  void _onReceived(_ChatMessageReceived event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    final loaded = state as ChatLoaded;
    emit(ChatLoaded(
      eventId: loaded.eventId,
      messages: [...loaded.messages, event.message],
    ));
  }

  @override
  Future<void> close() async {
    await _signalRSub?.cancel();
    if (state is ChatLoaded) {
      await _signalRService.leaveEvent((state as ChatLoaded).eventId);
    }
    return super.close();
  }
}
```

- [ ] **Step 4: Run tests — expect pass**

```bash
cd mobile && flutter test test/features/chat/chat_bloc_test.dart
```

Expected: 4/4 PASS.

- [ ] **Step 5: Run all tests**

```bash
cd mobile && flutter test
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/features/chat/bloc/chat_bloc.dart \
        mobile/test/features/chat/chat_bloc_test.dart
git commit -m "feat: add ChatBloc with TDD tests"
```

---

## Task 8: EventChatPage

**Files:**
- Create: `mobile/lib/features/chat/pages/event_chat_page.dart`

- [ ] **Step 1: Create the page**

Create `mobile/lib/features/chat/pages/event_chat_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/realtime/signalr_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../shared/models/chat_message_model.dart';
import '../bloc/chat_bloc.dart';
import '../data/chat_repository.dart';

class EventChatPage extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final SignalRService signalRService;
  final ApiClient apiClient;

  const EventChatPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.signalRService,
    required this.apiClient,
  });

  @override
  State<EventChatPage> createState() => _EventChatPageState();
}

class _EventChatPageState extends State<EventChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc(
        repository: ChatRepository(widget.apiClient),
        signalRService: widget.signalRService,
      )..add(ChatStarted(widget.eventId)),
      child: Scaffold(
        backgroundColor: AppColors.bgVoid,
        appBar: AppBar(
          backgroundColor: AppColors.bgSurface,
          foregroundColor: AppColors.fgPrimary,
          title: Text(
            widget.eventTitle.toUpperCase(),
            style: AppTextStyles.monoDisplay.copyWith(fontSize: 12),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.fgMuted),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) _scrollToBottom();
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.phosphor),
                    );
                  }
                  if (state is ChatError) {
                    return Center(
                      child: MonoText(state.message,
                          color: AppColors.fgSecondary),
                    );
                  }
                  if (state is ChatLoaded) {
                    final authState = context.watch<AuthBloc>().state;
                    final myId = authState is AuthAuthenticated
                        ? authState.userId
                        : null;
                    if (state.messages.isEmpty) {
                      return const Center(
                        child: MonoText(
                          'sin mensajes aún',
                          color: AppColors.fgSecondary,
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: state.messages.length,
                      itemBuilder: (context, i) {
                        final msg = state.messages[i];
                        return _ChatBubble(
                          message: msg,
                          isMe: msg.senderId == myId,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Builder(
              builder: (ctx) => _ChatInput(
                controller: _textController,
                onSend: () {
                  final text = _textController.text.trim();
                  if (text.isEmpty) return;
                  ctx.read<ChatBloc>().add(ChatMessageSent(text));
                  _textController.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        isMe ? AppColors.phosphor.withAlpha(20) : AppColors.bgElevated;
    final handleColor =
        isMe ? AppColors.phosphor : AppColors.fgSecondary;
    final time =
        '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          border: Border.all(
            color: isMe ? AppColors.phosphor : AppColors.fgMuted,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            MonoText(
              message.senderHandle,
              color: handleColor,
              size: 10,
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                color: AppColors.fgPrimary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            MonoText(time, color: AppColors.fgSecondary, size: 9),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgSurface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.fgPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'mensaje...',
                hintStyle: TextStyle(
                    color: AppColors.fgSecondary, fontSize: 13),
                filled: true,
                fillColor: AppColors.bgElevated,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.fgMuted),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.phosphor),
                ),
              ),
              onSubmitted: (_) => onSend(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.phosphor),
              ),
              child: const Icon(Icons.send,
                  color: AppColors.phosphor, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run tests**

```bash
cd mobile && flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Commit**

```bash
git add mobile/lib/features/chat/pages/event_chat_page.dart
git commit -m "feat: add EventChatPage UI"
```

---

## Task 9: Wire routes + EventDetailSheet CHAT button

**Files:**
- Modify: `mobile/lib/app.dart`
- Modify: `mobile/lib/features/map/widgets/event_detail_sheet.dart`

- [ ] **Step 1: Add the chat route to app.dart**

In `mobile/lib/app.dart`, add the import at the top with the other feature imports:

```dart
import 'features/chat/pages/event_chat_page.dart';
```

Add the route inside `_router = GoRouter(...)`, after the existing `/home/events/:id` route:

```dart
GoRoute(
  path: '/home/events/:id/chat',
  builder: (_, state) => EventChatPage(
    eventId: state.pathParameters['id']!,
    eventTitle: state.extra as String? ?? '',
    signalRService: _signalRService,
    apiClient: _apiClient,
  ),
),
```

- [ ] **Step 2: Add CHAT button to EventDetailSheet**

In `mobile/lib/features/map/widgets/event_detail_sheet.dart`, after the `BlocBuilder<EventsBloc, EventsState>` block at the bottom of the `ListView` children (after the error state builder), add:

```dart
const SizedBox(height: 8),
VoidButton(
  label: 'CHAT',
  borderColor: AppColors.electricBlue,
  onPressed: () => context.push(
    '/home/events/${event.id}/chat',
    extra: event.title,
  ),
),
```

Also add the `go_router` import at the top of `event_detail_sheet.dart` if not already present:

```dart
import 'package:go_router/go_router.dart';
```

- [ ] **Step 3: Run tests**

```bash
cd mobile && flutter test
```

Expected: all tests pass.

- [ ] **Step 4: Analyze for warnings**

```bash
cd mobile && flutter analyze --fatal-warnings
```

Expected: no warnings.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/app.dart \
        mobile/lib/features/map/widgets/event_detail_sheet.dart
git commit -m "feat: wire EventChatPage route and add CHAT button to EventDetailSheet"
```

---

## How to test end-to-end

1. Rebuild the backend Docker image (needed because EventHub and migration changed):
   ```bash
   docker compose build api && docker compose up -d
   ```
   The migration runs automatically on startup.

2. Open the app in two browser tabs (or two devices). Log in on both.

3. Navigate to the map — seeded events appear (Madrid).

4. Tap an event → `EventDetailSheet` appears with the new **CHAT** button.

5. Open chat on both tabs. Send a message from one tab — it should appear on the other tab in real time via SignalR.

6. The message also persists: close and reopen chat — history loads from REST.
