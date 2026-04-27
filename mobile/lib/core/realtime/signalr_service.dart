import 'dart:async';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter/foundation.dart';
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
  static const _hubUrl =
      '${String.fromEnvironment('API_BASE_URL', defaultValue: 'https://the-situationist-app.onrender.com')}/hubs/events';

  final AuthService _authService;
  HubConnection? _connection;
  final _controller = StreamController<SignalREvent>.broadcast();
  String? _currentZone;

  SignalRService(this._authService);

  Stream<SignalREvent> get events => _controller.stream;

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  Future<void> connect() async {
    if (isConnected) return;

    debugPrint('[SignalR] connecting…');
    _connection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                await _authService.getToken() ?? '',
            requestTimeout: 30000,
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
      } catch (e, st) {
        debugPrint('[SignalR] ReceiveMessage parse error: $e\n$st');
      }
    });

    await _connection!.start();
    debugPrint('[SignalR] connected');
  }

  Future<void> joinZone(double lat, double lng) async {
    if (!isConnected) return;
    final geohash = GeoHasher().encode(lng, lat, precision: 5);
    if (geohash == _currentZone) return;
    _currentZone = geohash;
    await _connection!.invoke('JoinZone', args: [geohash]);
  }

  Future<void> joinEvent(String eventId) async {
    if (!isConnected) return;
    await _connection!.invoke('JoinEvent', args: [eventId]);
  }

  Future<void> leaveEvent(String eventId) async {
    if (!isConnected) return;
    await _connection!.invoke('LeaveEvent', args: [eventId]);
  }

  Future<void> sendMessage(String eventId, String content) async {
    if (!isConnected) return;
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
