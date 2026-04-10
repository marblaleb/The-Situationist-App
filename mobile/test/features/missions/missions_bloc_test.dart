import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:situationist/features/missions/bloc/missions_bloc.dart';
import 'package:situationist/features/missions/data/i_missions_repository.dart';
import 'package:situationist/shared/models/clue_model.dart';
import 'package:situationist/shared/models/mission_model.dart';
import 'package:situationist/shared/models/mission_progress_model.dart';

class MockMissionsRepository extends Mock implements IMissionsRepository {}

final _clue1 = ClueModel(
  id: 'clue-1',
  order: 1,
  type: 'Textual',
  content: 'Pista número 1',
  hasHint: true,
  isOptional: false,
);

final _clue2 = ClueModel(
  id: 'clue-2',
  order: 2,
  type: 'Sensorial',
  content: 'Pista número 2',
  hasHint: false,
  isOptional: false,
);

final _progress = MissionProgressModel(
  progressId: 'p1',
  missionId: 'm1',
  status: 'InProgress',
  startedAt: DateTime.now(),
  hintsUsed: 0,
  currentClue: _clue1,
);

void main() {
  late MockMissionsRepository repo;

  setUp(() => repo = MockMissionsRepository());

  group('MissionsBloc', () {
    blocTest<MissionsBloc, MissionsState>(
      'emite MissionsLoaded al cargar misiones cercanas',
      build: () {
        when(() => repo.getNearbyMissions(
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              radius: any(named: 'radius'),
            )).thenAnswer((_) async => [
              const MissionModel(
                id: 'm1',
                title: 'Misión test',
                description: 'Desc',
                latitude: 40.4168,
                longitude: -3.7038,
                radiusMeters: 500,
                status: 'Active',
                clueCount: 2,
              ),
            ]);
        return MissionsBloc(repository: repo);
      },
      act: (bloc) => bloc.add(MissionsNearbyRequested(
        lat: 40.4168,
        lng: -3.7038,
        radius: 1000,
      )),
      expect: () => [isA<MissionsLoading>(), isA<MissionsLoaded>()],
    );

    blocTest<MissionsBloc, MissionsState>(
      'emite MissionInProgress con primera pista al iniciar misión',
      build: () {
        when(() => repo.startMission(any()))
            .thenAnswer((_) async => _progress);
        return MissionsBloc(repository: repo);
      },
      act: (bloc) => bloc.add(MissionStartRequested(missionId: 'm1')),
      expect: () => [isA<MissionStarting>(), isA<MissionInProgress>()],
      verify: (bloc) {
        final state = bloc.state as MissionInProgress;
        expect(state.progress.currentClue?.id, 'clue-1');
      },
    );

    blocTest<MissionsBloc, MissionsState>(
      'actualiza pista en MissionInProgress tras respuesta correcta',
      build: () {
        when(() => repo.submitAnswer(
              missionId: any(named: 'missionId'),
              clueId: any(named: 'clueId'),
              answer: any(named: 'answer'),
            )).thenAnswer((_) async => SubmitAnswerResponse(
              correct: true,
              missionCompleted: false,
              nextClue: _clue2,
            ));
        return MissionsBloc(repository: repo);
      },
      seed: () => MissionInProgress(
        progress: _progress,
        lastAnswerCorrect: null,
      ),
      act: (bloc) => bloc.add(MissionAnswerSubmitted(
        missionId: 'm1',
        clueId: 'clue-1',
        answer: 'fuente',
      )),
      expect: () => [isA<MissionInProgress>()],
      verify: (bloc) {
        final state = bloc.state as MissionInProgress;
        expect(state.progress.currentClue?.id, 'clue-2');
        expect(state.lastAnswerCorrect, true);
      },
    );
  });
}
