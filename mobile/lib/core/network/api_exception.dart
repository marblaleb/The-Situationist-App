class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  factory ApiException.fromStatusCode(int statusCode, String? serverMessage) {
    final message = serverMessage ?? _defaultMessage(statusCode);
    return ApiException(statusCode: statusCode, message: message);
  }

  static String _defaultMessage(int code) => switch (code) {
        401 => '→ sesión expirada',
        403 => '→ acción no permitida',
        404 => '→ no encontrado',
        409 => '→ conflicto',
        422 => '→ contenido rechazado por moderación',
        429 => '→ límite alcanzado. intenta más tarde',
        _ when code >= 500 => '→ error de conexión. intenta de nuevo',
        _ => '→ error desconocido',
      };

  @override
  String toString() => message;
}
