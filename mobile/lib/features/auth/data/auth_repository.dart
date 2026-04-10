import '../../../core/auth/auth_service.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/auth_model.dart';
import 'i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final AuthService _authService;
  final ApiClient _apiClient;

  AuthRepository({required AuthService authService, required ApiClient apiClient})
      : _authService = authService,
        _apiClient = apiClient;

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    final authenticated = await _authService.isAuthenticated();
    if (!authenticated) return null;
    final token = await _authService.getToken();
    if (token == null) return null;
    final userId = _authService.extractUserId(token);
    final email = _authService.extractEmail(token);
    if (userId == null || email == null) return null;
    return AuthUserModel(userId: userId, email: email, provider: 'Google');
  }

  @override
  Future<void> saveSession({
    required String token,
    required String userId,
    required String email,
  }) async {
    await _authService.saveToken(token);
  }

  @override
  Future<void> clearSession() async {
    try {
      await _apiClient.delete('/auth/session');
    } catch (_) {
      // Token ya inválido — continuar con logout local
    }
    await _authService.clearAll();
  }

  @override
  Future<AuthResponse> exchangeCallbackUrl(String callbackUrl) async {
    final uri = Uri.parse(callbackUrl);
    final response = await _apiClient.get<Map<String, dynamic>>(
      uri.path,
      queryParameters: uri.queryParameters,
    );
    return AuthResponse.fromJson(response.data!);
  }
}
