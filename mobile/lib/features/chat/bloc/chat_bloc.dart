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
