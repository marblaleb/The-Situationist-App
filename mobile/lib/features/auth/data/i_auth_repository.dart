import '../../../shared/models/auth_model.dart';

abstract class IAuthRepository {
  Future<AuthUserModel?> getCurrentUser();
  Future<void> saveSession({
    required String token,
    required String userId,
    required String email,
  });
  Future<void> clearSession();
  Future<AuthResponse> exchangeCallbackUrl(String callbackUrl);
}
