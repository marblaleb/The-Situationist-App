import 'dart:async';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../auth/auth_service.dart';

sealed class SignalREvent {}

class EventExpiredSignal extends SignalREvent {
  final String eventId;
  EventExpiredSignal(this.eventId);
}

class EventFullSignal extends SignalREvent {
  final String eventId;
  EventFullSignal(this.eventId);
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

    await _connection!.start();
  }

  Future<void> joinZone(double lat, double lng) async {
    if (_connection?.state != HubConnectionState.Connected) return;
    final geohash = GeoHasher().encode(lng, lat, precision: 5);
    if (geohash == _currentZone) return;
    _currentZone = geohash;
    await _connection!.invoke('JoinZone', args: [geohash]);
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
