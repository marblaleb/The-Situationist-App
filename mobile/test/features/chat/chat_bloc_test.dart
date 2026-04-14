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
