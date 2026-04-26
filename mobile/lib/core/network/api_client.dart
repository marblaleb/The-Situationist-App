import 'package:dio/dio.dart';
import '../auth/auth_service.dart';
import 'api_exception.dart';

class ApiClient {
  static final String baseUrl = () {
    const env = String.fromEnvironment('API_BASE_URL');
    return env.isEmpty ? 'https://the-situationist-app.onrender.com' : env;
  }();

  late final Dio _dio;
  final AuthService _authService;

  ApiClient(this._authService) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(_AuthInterceptor(_authService));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    try {
      return await _dio.put<T>(path, data: data);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Response<T>> delete<T>(String path) async {
    try {
      return await _dio.delete<T>(path);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final statusCode = e.response?.statusCode ?? 0;
    final serverMessage = e.response?.data is Map
        ? (e.response!.data as Map)['error'] as String?
        : null;
    return ApiException.fromStatusCode(statusCode, serverMessage);
  }
}

class _AuthInterceptor extends Interceptor {
  final AuthService _authService;

  _AuthInterceptor(this._authService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
