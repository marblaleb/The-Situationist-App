import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:situationist/features/deriva/bloc/deriva_bloc.dart';
import 'package:situationist/features/deriva/data/i_deriva_repository.dart';
import 'package:situationist/shared/models/deriva_session_model.dart';

class MockDerivaRepository extends Mock implements IDerivaRepository {}

final _mockSession = DerivaSessionModel(
  id: 'session-1',
  type: 'Poetica',
  startedAt: DateTime.now(),
  status: 'Active',
  firstInstruction: 'Camina hacia el sonido más lejano.',
);

final _mockInstruction = DerivaInstructionModel(
  instructionId: 'inst-2',
  content: 'Detente frente al próximo edificio con puerta roja.',
  generatedAt: DateTime.now(),
);

void main() {
  late MockDerivaRepository repo;

  setUp(() => repo = MockDerivaRepository());

  group('DerivaBloc', () {
    blocTest<DerivaBloc, DerivaState>(
      'emite DerivaActive al iniciar sesión exitosamente',
      build: () {
        when(() => repo.startSession(
              type: any(named: 'type'),
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
            )).thenAnswer((_) async => _mockSession);
        return DerivaBloc(repository: repo);
      },
      act: (bloc) => bloc.add(DerivaStartRequested(
        type: 'Poetica',
        lat: 40.4168,
        lng: -3.7038,
      )),
      expect: () => [
        isA<DerivaStarting>(),
        isA<DerivaActive>(),
      ],
    );

    blocTest<DerivaBloc, DerivaState>(
      'actualiza instrucción al solicitar siguiente',
      build: () {
        when(() => repo.getNextInstruction(
              sessionId: any(named: 'sessionId'),
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
            )).thenAnswer((_) async => _mockInstruction);
        return DerivaBloc(repository: repo);
      },
      seed: () => DerivaActive(
        sessionId: 'session-1',
        currentInstruction: 'Primera instrucción',
        type: 'Poetica',
        isWriting: false,
      ),
      act: (bloc) => bloc.add(DerivaNextInstructionRequested(
        lat: 40.4168,
        lng: -3.7038,
      )),
      expect: () => [
        isA<DerivaActive>(),
      ],
      verify: (bloc) {
        final state = bloc.state as DerivaActive;
        expect(state.currentInstruction,
            'Detente frente al próximo edificio con puerta roja.');
      },
    );

    blocTest<DerivaBloc, DerivaState>(
      'emite DerivaCompleted al completar sesión',
      build: () {
        when(() => repo.completeSession(any()))
            .thenAnswer((_) async {});
        return DerivaBloc(repository: repo);
      },
      seed: () => DerivaActive(
        sessionId: 'session-1',
        currentInstruction: 'instrucción',
        type: 'Poetica',
        isWriting: false,
      ),
      act: (bloc) => bloc.add(DerivaCompleteRequested()),
      expect: () => [isA<DerivaCompleted>()],
    );
  });
}
