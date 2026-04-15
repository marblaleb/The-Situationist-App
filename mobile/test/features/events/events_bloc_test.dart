import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:situationist/features/events/bloc/events_bloc.dart';
import 'package:situationist/features/events/data/i_events_repository.dart';
import 'package:situationist/shared/models/event_model.dart';

class MockEventsRepository extends Mock implements IEventsRepository {}

final _mockEvent = EventModel(
  id: 'e1',
  creatorId: 'user1',
  title: 'Test',
  description: 'Desc',
  actionType: 'Sensorial',
  interventionLevel: 'Bajo',
  centroidLatitude: 40.4168,
  centroidLongitude: -3.7038,
  radiusMeters: 200,
  visibility: 'Public',
  startsAt: DateTime.now(),
  expiresAt: DateTime.now().add(const Duration(minutes: 30)),
  status: 'Active',
  participantCount: 3,
);

void main() {
  late MockEventsRepository repo;

  setUp(() {
    repo = MockEventsRepository();
  });

  group('EventsBloc', () {
    blocTest<EventsBloc, EventsState>(
      'emite EventsLoaded con lista de eventos',
      build: () {
        when(() => repo.getNearbyEvents(
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              radius: any(named: 'radius'),
            )).thenAnswer((_) async => [_mockEvent]);
        return EventsBloc(repository: repo);
      },
      act: (bloc) => bloc.add(EventsNearbyRequested(
        lat: 40.4168,
        lng: -3.7038,
        radius: 1000,
      )),
      expect: () => [
        isA<EventsLoading>(),
        isA<EventsLoaded>(),
      ],
    );

    blocTest<EventsBloc, EventsState>(
      'elimina evento de la lista al recibir EventExpiredReceived',
      build: () => EventsBloc(repository: repo),
      seed: () => EventsLoaded(events: [_mockEvent]),
      act: (bloc) => bloc.add(EventExpiredReceived(eventId: 'e1')),
      expect: () => [isA<EventsLoaded>()],
      verify: (bloc) {
        final state = bloc.state as EventsLoaded;
        expect(state.events, isEmpty);
      },
    );

    blocTest<EventsBloc, EventsState>(
      'emite EventsError cuando falla la carga',
      build: () {
        when(() => repo.getNearbyEvents(
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              radius: any(named: 'radius'),
            )).thenThrow(Exception('network error'));
        return EventsBloc(repository: repo);
      },
      act: (bloc) => bloc.add(EventsNearbyRequested(
        lat: 40.4168,
        lng: -3.7038,
        radius: 1000,
      )),
      expect: () => [
        isA<EventsLoading>(),
        isA<EventsError>(),
      ],
    );
  });
}
