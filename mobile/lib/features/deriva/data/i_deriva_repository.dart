import '../../../shared/models/deriva_session_model.dart';

abstract class IDerivaRepository {
  Future<DerivaSessionModel> startSession({
    required String type,
    required double lat,
    required double lng,
  });

  Future<DerivaInstructionModel> getNextInstruction({
    required String sessionId,
    required double lat,
    required double lng,
  });

  Future<void> completeSession(String sessionId);

  Future<void> abandonSession(String sessionId);
}
