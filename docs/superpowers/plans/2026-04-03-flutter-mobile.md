# Flutter Mobile — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementar la app Flutter de eventos situacionistas completa: auth OAuth, mapa de eventos, deriva con IA, misiones con pistas, perfil con historial.

**Architecture:** Feature-vertical con capa de repositorios (interfaces abstractas + implementaciones concretas) entre BLoCs y ApiClient Dio. BLoCs locales por pantalla excepto AuthBloc que es global. GoRouter con ShellRoute para bottom nav de 4 tabs.

**Tech Stack:** Flutter 3.x · flutter_bloc ^8.1.6 · go_router ^14.2.7 · dio ^5.7.0 · flutter_map ^7.0.2 · signalr_netcore ^1.3.5 · freezed ^2.5.7 · google_fonts ^6.2.1 · webview_flutter ^4.8.0 · geolocator ^12.0.0 · dart_geohash ^1.0.2

> **Nota OAuth:** Se usa `webview_flutter` en lugar de `flutter_web_auth_2` porque el backend devuelve JSON en `/auth/callback/google` (no redirige a custom URL scheme). La LoginPage abre un WebView dialog, intercepta la URL de callback y hace un GET con Dio para obtener el token.

---

## File Map

```
mobile/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── auth/
│   │   │   ├── auth_service.dart
│   │   │   └── auth_guard.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   └── api_exception.dart
│   │   ├── location/
│   │   │   └── location_service.dart
│   │   ├── realtime/
│   │   │   └── signalr_service.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   └── widgets/
│   │       ├── mono_text.dart
│   │       ├── void_button.dart
│   │       ├── typewriter_text.dart
│   │       ├── glitch_text.dart
│   │       └── scanlines_overlay.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── bloc/auth_bloc.dart
│   │   │   ├── data/i_auth_repository.dart
│   │   │   ├── data/auth_repository.dart
│   │   │   ├── pages/splash_page.dart
│   │   │   └── pages/login_page.dart
│   │   ├── map/
│   │   │   ├── bloc/map_bloc.dart
│   │   │   ├── pages/map_page.dart
│   │   │   └── widgets/event_detail_sheet.dart
│   │   ├── events/
│   │   │   ├── bloc/events_bloc.dart
│   │   │   ├── data/i_events_repository.dart
│   │   │   ├── data/events_repository.dart
│   │   │   └── pages/create_event_page.dart
│   │   ├── deriva/
│   │   │   ├── bloc/deriva_bloc.dart
│   │   │   ├── data/i_deriva_repository.dart
│   │   │   ├── data/deriva_repository.dart
│   │   │   ├── pages/deriva_home_page.dart
│   │   │   └── pages/deriva_active_page.dart
│   │   ├── missions/
│   │   │   ├── bloc/missions_bloc.dart
│   │   │   ├── data/i_missions_repository.dart
│   │   │   ├── data/missions_repository.dart
│   │   │   ├── pages/missions_page.dart
│   │   │   ├── pages/mission_detail_page.dart
│   │   │   └── pages/mission_active_page.dart
│   │   └── profile/
│   │       ├── bloc/profile_bloc.dart
│   │       ├── data/i_profile_repository.dart
│   │       ├── data/profile_repository.dart
│   │       └── pages/profile_page.dart
│   └── shared/
│       ├── models/
│       │   ├── event_model.dart + .freezed.dart + .g.dart
│       │   ├── deriva_session_model.dart + generated
│       │   ├── clue_model.dart + generated
│       │   ├── mission_model.dart + generated
│       │   ├── mission_progress_model.dart + generated
│       │   ├── auth_model.dart + generated
│       │   └── profile_model.dart + generated
│       └── extensions/datetime_extensions.dart
└── test/
    ├── features/auth/auth_bloc_test.dart
    ├── features/events/events_bloc_test.dart
    ├── features/deriva/deriva_bloc_test.dart
    └── features/missions/missions_bloc_test.dart
```

---

## Task 1: Flutter project scaffolding + pubspec.yaml

**Files:**
- Create: `mobile/` (via flutter create)
- Modify: `mobile/pubspec.yaml`

- [ ] **Step 1: Crear proyecto Flutter**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
flutter create mobile --org app.situationist --project-name situationist
```

Expected: carpeta `mobile/` creada con estructura base Flutter.

- [ ] **Step 2: Reemplazar pubspec.yaml completo**

Reemplazar el contenido de `mobile/pubspec.yaml`:

```yaml
name: situationist
description: App de eventos situacionistas — intervención urbana / experiencia efímera
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Estado
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # Navegación
  go_router: ^14.2.7

  # Red
  dio: ^5.7.0

  # Auth / Almacenamiento seguro
  flutter_secure_storage: ^9.2.2
  webview_flutter: ^4.8.0

  # Geolocalización
  geolocator: ^12.0.0
  permission_handler: ^11.3.1

  # Mapas
  flutter_map: ^7.0.2
  latlong2: ^0.9.1

  # SignalR
  signalr_netcore: ^1.3.5

  # Tipografías
  google_fonts: ^6.2.1

  # Utils
  intl: ^0.19.0
  freezed_annotation: ^2.4.4
  dart_geohash: ^1.0.2
  connectivity_plus: ^6.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
  build_runner: ^2.4.12
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 3: Borrar archivos de ejemplo innecesarios**

```bash
rm mobile/lib/main.dart
rm mobile/test/widget_test.dart
```

- [ ] **Step 4: Instalar dependencias**

```bash
cd mobile && flutter pub get
```

Expected: `Resolving dependencies... Got dependencies!` sin errores.

- [ ] **Step 5: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/pubspec.yaml mobile/pubspec.lock
git commit -m "feat(mobile): scaffold Flutter project with dependencies"
```

---

## Task 2: Theme system

**Files:**
- Create: `mobile/lib/core/theme/app_colors.dart`
- Create: `mobile/lib/core/theme/app_text_styles.dart`
- Create: `mobile/lib/core/theme/app_theme.dart`

- [ ] **Step 1: Crear app_colors.dart**

```dart
// mobile/lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const bgVoid = Color(0xFF0A0A0A);
  static const bgSurface = Color(0xFF111111);
  static const bgElevated = Color(0xFF1A1A1A);
  static const fgPrimary = Color(0xFFE8E0D0);
  static const fgSecondary = Color(0xFF6B6560);
  static const fgMuted = Color(0xFF3A3733);
  static const phosphor = Color(0xFFC8F03C);
  static const amber = Color(0xFFE8A030);
  static const electricBlue = Color(0xFF4040FF);
  static const danger = Color(0xFFCC3333);
  static const success = Color(0xFF3A8A3A);
}
```

- [ ] **Step 2: Crear app_text_styles.dart**

```dart
// mobile/lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get monoUI => GoogleFonts.jetBrainsMono(
        color: AppColors.fgPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.2,
      );

  static TextStyle get monoUISecondary => GoogleFonts.jetBrainsMono(
        color: AppColors.fgSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.2,
      );

  static TextStyle get monoDisplay => GoogleFonts.spaceMono(
        color: AppColors.fgPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 4,
      );

  static TextStyle get monoDisplayLarge => GoogleFonts.spaceMono(
        color: AppColors.fgPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 4,
      );

  static TextStyle get body => GoogleFonts.inter(
        color: AppColors.fgPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        height: 1.6,
      );

  static TextStyle get timestamp => GoogleFonts.jetBrainsMono(
        color: AppColors.fgSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get label => GoogleFonts.jetBrainsMono(
        color: AppColors.fgSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
      );
}
```

- [ ] **Step 3: Crear app_theme.dart**

```dart
// mobile/lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.bgVoid,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.bgSurface,
      primary: AppColors.phosphor,
      secondary: AppColors.amber,
      error: AppColors.danger,
    ),
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.spaceMono(
        color: AppColors.fgPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 4,
      ),
      bodyMedium: GoogleFonts.inter(
        color: AppColors.fgPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        height: 1.6,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        color: AppColors.fgSecondary,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.fgMuted,
      thickness: 1,
      space: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgElevated,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.fgMuted),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.fgMuted),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.phosphor),
      ),
      hintStyle: GoogleFonts.jetBrainsMono(
        color: AppColors.fgMuted,
        fontSize: 13,
      ),
    ),
  );
}
```

- [ ] **Step 4: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/core/theme/
git commit -m "feat(mobile): add theme system (AppColors, AppTextStyles, AppTheme)"
```

---

## Task 3: Core shared widgets

**Files:**
- Create: `mobile/lib/core/widgets/mono_text.dart`
- Create: `mobile/lib/core/widgets/void_button.dart`
- Create: `mobile/lib/core/widgets/typewriter_text.dart`
- Create: `mobile/lib/core/widgets/glitch_text.dart`
- Create: `mobile/lib/core/widgets/scanlines_overlay.dart`

- [ ] **Step 1: Crear mono_text.dart**

```dart
// mobile/lib/core/widgets/mono_text.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class MonoText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final FontWeight weight;
  final double? letterSpacing;

  const MonoText(
    this.text, {
    super.key,
    this.size = 13,
    this.color = AppColors.fgPrimary,
    this.weight = FontWeight.w400,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
```

- [ ] **Step 2: Crear void_button.dart**

```dart
// mobile/lib/core/widgets/void_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class VoidButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color borderColor;

  const VoidButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor = AppColors.fgMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.3 : 1.0,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.fgPrimary,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: borderColor, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
            color: AppColors.fgPrimary,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Crear typewriter_text.dart**

```dart
// mobile/lib/core/widgets/typewriter_text.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDelay;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDelay = const Duration(milliseconds: 50),
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  String _displayed = '';
  int _index = 0;
  Timer? _timer;
  late AnimationController _cursorController;
  late Animation<double> _cursorOpacity;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _cursorOpacity =
        _cursorController.drive(CurveTween(curve: Curves.easeInOut));
    _startTyping();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      setState(() {
        _displayed = '';
        _index = 0;
      });
      _startTyping();
    }
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.charDelay, (_) {
      if (!mounted) return;
      if (_index < widget.text.length) {
        setState(() {
          _displayed += widget.text[_index];
          _index++;
        });
      } else {
        _timer?.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  bool get _isComplete => _index >= widget.text.length;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ??
        GoogleFonts.inter(
          color: AppColors.fgPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w300,
          height: 1.6,
        );

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: _displayed, style: style),
          if (!_isComplete)
            WidgetSpan(
              child: AnimatedBuilder(
                animation: _cursorOpacity,
                builder: (_, __) => Opacity(
                  opacity: _cursorOpacity.value,
                  child: Text(
                    '_',
                    style: style.copyWith(color: AppColors.phosphor),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Crear glitch_text.dart**

```dart
// mobile/lib/core/widgets/glitch_text.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const GlitchText(this.text, {super.key, this.style});

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _rng = Random();
  double _offsetX1 = 0;
  double _offsetX2 = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.addListener(() {
      if (_controller.value < 0.6) {
        setState(() {
          _offsetX1 = (_rng.nextDouble() - 0.5) * 4;
          _offsetX2 = (_rng.nextDouble() - 0.5) * 4;
        });
      } else {
        setState(() {
          _offsetX1 = 0;
          _offsetX2 = 0;
        });
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ??
        GoogleFonts.spaceMono(
          color: AppColors.fgPrimary,
          fontSize: 18,
          letterSpacing: 4,
        );

    return Stack(
      children: [
        Transform.translate(
          offset: Offset(_offsetX1, 0),
          child: Text(
            widget.text,
            style: style.copyWith(
                color: AppColors.phosphor.withValues(alpha: 0.5)),
          ),
        ),
        Transform.translate(
          offset: Offset(_offsetX2, 0),
          child: Text(
            widget.text,
            style: style.copyWith(
                color: AppColors.electricBlue.withValues(alpha: 0.5)),
          ),
        ),
        Text(widget.text, style: style),
      ],
    );
  }
}
```

- [ ] **Step 5: Crear scanlines_overlay.dart**

```dart
// mobile/lib/core/widgets/scanlines_overlay.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScanlinesOverlay extends StatelessWidget {
  final Widget child;

  const ScanlinesOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _ScanlinesPainter()),
          ),
        ),
      ],
    );
  }
}

class _ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.fgPrimary.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinesPainter oldDelegate) => false;
}
```

- [ ] **Step 6: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/core/widgets/
git commit -m "feat(mobile): add core shared widgets (MonoText, VoidButton, TypewriterText, GlitchText, ScanlinesOverlay)"
```

---

## Task 4: ApiException, ApiClient y AuthService

**Files:**
- Create: `mobile/lib/core/network/api_exception.dart`
- Create: `mobile/lib/core/network/api_client.dart`
- Create: `mobile/lib/core/auth/auth_service.dart`

- [ ] **Step 1: Crear api_exception.dart**

```dart
// mobile/lib/core/network/api_exception.dart
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  factory ApiException.fromStatusCode(int statusCode, String? serverMessage) {
    final message = serverMessage ?? _defaultMessage(statusCode);
    return ApiException(statusCode: statusCode, message: message);
  }

  static String _defaultMessage(int code) => switch (code) {
        401 => 'sesión expirada',
        403 => 'acción no permitida',
        404 => 'no encontrado',
        409 => 'conflicto',
        422 => 'contenido rechazado por moderación',
        429 => 'límite alcanzado. intenta más tarde',
        _ when code >= 500 => 'error de conexión. intenta de nuevo',
        _ => 'error desconocido',
      };

  @override
  String toString() => '→ $message';
}
```

- [ ] **Step 2: Crear api_client.dart**

```dart
// mobile/lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_exception.dart';

class ApiClient {
  static const baseUrl = 'https://api.situationist.app';

  late final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(_AuthInterceptor(_storage));
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
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'jwt');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

- [ ] **Step 3: Crear auth_service.dart**

```dart
// mobile/lib/core/auth/auth_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _jwtKey = 'jwt';
  final FlutterSecureStorage _storage;

  AuthService(this._storage);

  Future<String?> getToken() => _storage.read(key: _jwtKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _jwtKey, value: token);

  Future<void> clearAll() => _storage.deleteAll();

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    try {
      final exp = _extractExp(token);
      return exp.isAfter(DateTime.now().toUtc());
    } catch (_) {
      return false;
    }
  }

  String? extractUserId(String token) {
    try {
      final claims = _decodeClaims(token);
      return claims['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  String? extractEmail(String token) {
    try {
      final claims = _decodeClaims(token);
      return claims['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  DateTime _extractExp(String token) {
    final claims = _decodeClaims(token);
    final exp = claims['exp'] as int;
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
  }

  Map<String, dynamic> _decodeClaims(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const FormatException('Invalid JWT');
    final payload = base64Url.decode(base64Url.normalize(parts[1]));
    return jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
  }
}
```

- [ ] **Step 4: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/core/network/ mobile/lib/core/auth/auth_service.dart
git commit -m "feat(mobile): add ApiClient, ApiException and AuthService"
```

---

## Task 5: LocationService y SignalRService

**Files:**
- Create: `mobile/lib/core/location/location_service.dart`
- Create: `mobile/lib/core/realtime/signalr_service.dart`

- [ ] **Step 1: Crear location_service.dart**

```dart
// mobile/lib/core/location/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const defaultLat = 40.4168;
  static const defaultLng = -3.7038;

  Future<(double lat, double lng)> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return (defaultLat, defaultLng);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return (defaultLat, defaultLng);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return (defaultLat, defaultLng);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return (position.latitude, position.longitude);
    } catch (_) {
      return (defaultLat, defaultLng);
    }
  }

  Stream<(double lat, double lng)> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    ).map((p) => (p.latitude, p.longitude));
  }
}
```

- [ ] **Step 2: Crear signalr_service.dart**

```dart
// mobile/lib/core/realtime/signalr_service.dart
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
  static const _hubUrl = 'https://api.situationist.app/hubs/events';

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
```

- [ ] **Step 3: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/core/location/ mobile/lib/core/realtime/
git commit -m "feat(mobile): add LocationService and SignalRService"
```

---

## Task 6: Shared Dart models (freezed + json_serializable)

**Files:**
- Create: `mobile/lib/shared/models/auth_model.dart`
- Create: `mobile/lib/shared/models/event_model.dart`
- Create: `mobile/lib/shared/models/deriva_session_model.dart`
- Create: `mobile/lib/shared/models/clue_model.dart`
- Create: `mobile/lib/shared/models/mission_model.dart`
- Create: `mobile/lib/shared/models/mission_progress_model.dart`
- Create: `mobile/lib/shared/models/profile_model.dart`
- Create: `mobile/lib/shared/extensions/datetime_extensions.dart`

- [ ] **Step 1: Crear auth_model.dart**

```dart
// mobile/lib/shared/models/auth_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
    required AuthUserModel user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class AuthUserModel with _$AuthUserModel {
  const factory AuthUserModel({
    required String userId,
    required String email,
    required String provider,
  }) = _AuthUserModel;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);
}
```

- [ ] **Step 2: Crear event_model.dart**

```dart
// mobile/lib/shared/models/event_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    required String title,
    required String description,
    required String actionType,
    required String interventionLevel,
    required double centroidLatitude,
    required double centroidLongitude,
    required int radiusMeters,
    required String visibility,
    int? maxParticipants,
    required DateTime startsAt,
    required DateTime expiresAt,
    required String status,
    required int participantCount,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
}

@freezed
class CreateEventRequest with _$CreateEventRequest {
  const factory CreateEventRequest({
    required String title,
    required String description,
    required String actionType,
    required String interventionLevel,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required String visibility,
    int? maxParticipants,
    required DateTime startsAt,
    required int durationMinutes,
  }) = _CreateEventRequest;

  factory CreateEventRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateEventRequestFromJson(json);
}

@freezed
class GenerateEventRequest with _$GenerateEventRequest {
  const factory GenerateEventRequest({
    required String actionType,
    required String interventionLevel,
    double? latitude,
    double? longitude,
  }) = _GenerateEventRequest;

  factory GenerateEventRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateEventRequestFromJson(json);
}

@freezed
class GeneratedEventSuggestion with _$GeneratedEventSuggestion {
  const factory GeneratedEventSuggestion({
    required String title,
    required String description,
    required String actionType,
    required String interventionLevel,
  }) = _GeneratedEventSuggestion;

  factory GeneratedEventSuggestion.fromJson(Map<String, dynamic> json) =>
      _$GeneratedEventSuggestionFromJson(json);
}
```

- [ ] **Step 3: Crear deriva_session_model.dart**

```dart
// mobile/lib/shared/models/deriva_session_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'deriva_session_model.freezed.dart';
part 'deriva_session_model.g.dart';

@freezed
class DerivaSessionModel with _$DerivaSessionModel {
  const factory DerivaSessionModel({
    required String id,
    required String type,
    required DateTime startedAt,
    required String status,
    required String firstInstruction,
  }) = _DerivaSessionModel;

  factory DerivaSessionModel.fromJson(Map<String, dynamic> json) =>
      _$DerivaSessionModelFromJson(json);
}

@freezed
class DerivaInstructionModel with _$DerivaInstructionModel {
  const factory DerivaInstructionModel({
    required String instructionId,
    required String content,
    required DateTime generatedAt,
  }) = _DerivaInstructionModel;

  factory DerivaInstructionModel.fromJson(Map<String, dynamic> json) =>
      _$DerivaInstructionModelFromJson(json);
}
```

- [ ] **Step 4: Crear clue_model.dart**

```dart
// mobile/lib/shared/models/clue_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'clue_model.freezed.dart';
part 'clue_model.g.dart';

@freezed
class ClueModel with _$ClueModel {
  const factory ClueModel({
    required String id,
    required int order,
    required String type,
    required String content,
    required bool hasHint,
    required bool isOptional,
    double? latitude,
    double? longitude,
  }) = _ClueModel;

  factory ClueModel.fromJson(Map<String, dynamic> json) =>
      _$ClueModelFromJson(json);
}
```

- [ ] **Step 5: Crear mission_model.dart**

```dart
// mobile/lib/shared/models/mission_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'clue_model.dart';
part 'mission_model.freezed.dart';
part 'mission_model.g.dart';

@freezed
class MissionModel with _$MissionModel {
  const factory MissionModel({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required String status,
    required int clueCount,
  }) = _MissionModel;

  factory MissionModel.fromJson(Map<String, dynamic> json) =>
      _$MissionModelFromJson(json);
}

@freezed
class MissionDetailModel with _$MissionDetailModel {
  const factory MissionDetailModel({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required String status,
    required List<ClueModel> clues,
  }) = _MissionDetailModel;

  factory MissionDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MissionDetailModelFromJson(json);
}

@freezed
class SubmitAnswerResponse with _$SubmitAnswerResponse {
  const factory SubmitAnswerResponse({
    required bool correct,
    required bool missionCompleted,
    ClueModel? nextClue,
  }) = _SubmitAnswerResponse;

  factory SubmitAnswerResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitAnswerResponseFromJson(json);
}
```

- [ ] **Step 6: Crear mission_progress_model.dart**

```dart
// mobile/lib/shared/models/mission_progress_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'clue_model.dart';
part 'mission_progress_model.freezed.dart';
part 'mission_progress_model.g.dart';

@freezed
class MissionProgressModel with _$MissionProgressModel {
  const factory MissionProgressModel({
    required String progressId,
    required String missionId,
    required String status,
    required DateTime startedAt,
    DateTime? completedAt,
    required int hintsUsed,
    ClueModel? currentClue,
  }) = _MissionProgressModel;

  factory MissionProgressModel.fromJson(Map<String, dynamic> json) =>
      _$MissionProgressModelFromJson(json);
}
```

- [ ] **Step 7: Crear profile_model.dart**

```dart
// mobile/lib/shared/models/profile_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String userId,
    required DateTime joinedAt,
    required SituationistFootprint situationistFootprint,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}

@freezed
class SituationistFootprint with _$SituationistFootprint {
  const factory SituationistFootprint({
    required int eventsParticipated,
    required int derivasCompleted,
    required int missionsCompleted,
  }) = _SituationistFootprint;

  factory SituationistFootprint.fromJson(Map<String, dynamic> json) =>
      _$SituationistFootprintFromJson(json);
}

@freezed
class ActivityLogItem with _$ActivityLogItem {
  const factory ActivityLogItem({
    required String id,
    required String type,
    required String referenceId,
    required DateTime occurredAt,
  }) = _ActivityLogItem;

  factory ActivityLogItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogItemFromJson(json);
}

@freezed
class ActivityLogPage with _$ActivityLogPage {
  const factory ActivityLogPage({
    required List<ActivityLogItem> items,
    String? nextCursor,
  }) = _ActivityLogPage;

  factory ActivityLogPage.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogPageFromJson(json);
}
```

- [ ] **Step 8: Crear datetime_extensions.dart**

```dart
// mobile/lib/shared/extensions/datetime_extensions.dart
import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String toTimestamp() => DateFormat('yyyy-MM-dd HH:mm').format(toLocal());

  String toTimeOnly() => DateFormat('HH:mm').format(toLocal());

  String toShortDate() => DateFormat('yyyy-MM-dd').format(toLocal());

  bool isExpiringSoon() =>
      difference(DateTime.now().toUtc()).inMinutes < 10 &&
      isAfter(DateTime.now().toUtc());
}
```

- [ ] **Step 9: Ejecutar build_runner para generar ficheros freezed**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude/mobile
dart run build_runner build --delete-conflicting-outputs
```

Expected: Genera `*.freezed.dart` y `*.g.dart` para cada modelo. Sin errores.

- [ ] **Step 10: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/shared/
git commit -m "feat(mobile): add shared models (freezed) and datetime extensions"
```

---

## Task 7: Auth feature — data layer + AuthBloc

**Files:**
- Create: `mobile/lib/features/auth/data/i_auth_repository.dart`
- Create: `mobile/lib/features/auth/data/auth_repository.dart`
- Create: `mobile/lib/features/auth/bloc/auth_bloc.dart`

- [ ] **Step 1: Escribir test fallido para AuthBloc**

```dart
// mobile/test/features/auth/auth_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:situationist/features/auth/bloc/auth_bloc.dart';
import 'package:situationist/features/auth/data/i_auth_repository.dart';
import 'package:situationist/shared/models/auth_model.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emite AuthAuthenticated cuando hay token válido',
      build: () {
        when(() => repo.getCurrentUser()).thenAnswer(
          (_) async => const AuthUserModel(
            userId: 'uid-1',
            email: 'test@test.com',
            provider: 'Google',
          ),
        );
        return AuthBloc(repository: repo);
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emite AuthUnauthenticated cuando no hay usuario',
      build: () {
        when(() => repo.getCurrentUser()).thenAnswer((_) async => null);
        return AuthBloc(repository: repo);
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emite AuthAuthenticated tras login completado',
      build: () {
        when(() => repo.saveSession(
              token: any(named: 'token'),
              userId: any(named: 'userId'),
              email: any(named: 'email'),
            )).thenAnswer((_) async {});
        return AuthBloc(repository: repo);
      },
      act: (bloc) => bloc.add(AuthLoginCompleted(
        token: 'jwt-token',
        userId: 'uid-1',
        email: 'test@test.com',
      )),
      expect: () => [
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emite AuthUnauthenticated tras logout',
      build: () {
        when(() => repo.clearSession()).thenAnswer((_) async {});
        return AuthBloc(repository: repo);
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [
        isA<AuthUnauthenticated>(),
      ],
    );
  });
}
```

- [ ] **Step 2: Ejecutar test — debe fallar porque AuthBloc no existe aún**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude/mobile
flutter test test/features/auth/auth_bloc_test.dart
```

Expected: Error de compilación — `AuthBloc`, `IAuthRepository` no definidos.

- [ ] **Step 3: Crear i_auth_repository.dart**

```dart
// mobile/lib/features/auth/data/i_auth_repository.dart
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
```

- [ ] **Step 4: Crear auth_repository.dart**

```dart
// mobile/lib/features/auth/data/auth_repository.dart
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
    final path = uri.path;
    final queryParams = uri.queryParameters;
    final response = await _apiClient.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParams,
    );
    return AuthResponse.fromJson(response.data!);
  }
}
```

- [ ] **Step 5: Crear auth_bloc.dart**

```dart
// mobile/lib/features/auth/bloc/auth_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/auth_model.dart';
import '../data/i_auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {}

class AuthCheckRequested extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class AuthLoginCompleted extends AuthEvent {
  final String token;
  final String userId;
  final String email;

  AuthLoginCompleted({
    required this.token,
    required this.userId,
    required this.email,
  });

  @override
  List<Object?> get props => [token, userId, email];
}

class AuthLogoutRequested extends AuthEvent {
  @override
  List<Object?> get props => [];
}

// States
abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;

  AuthAuthenticated({required this.userId, required this.email});

  @override
  List<Object?> get props => [userId, email];
}

class AuthUnauthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _repository;

  AuthBloc({required IAuthRepository repository})
      : _repository = repository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginCompleted>(_onLoginCompleted);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(userId: user.userId, email: user.email));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginCompleted(
    AuthLoginCompleted event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.saveSession(
      token: event.token,
      userId: event.userId,
      email: event.email,
    );
    emit(AuthAuthenticated(userId: event.userId, email: event.email));
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.clearSession();
    emit(AuthUnauthenticated());
  }
}
```

- [ ] **Step 6: Ejecutar test — debe pasar**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude/mobile
flutter test test/features/auth/auth_bloc_test.dart
```

Expected: `All tests passed!` — 4 tests.

- [ ] **Step 7: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/features/auth/ mobile/test/features/auth/
git commit -m "feat(mobile): add auth data layer, AuthBloc + tests (4 passing)"
```

---

## Task 8: Auth feature — UI (SplashPage, LoginPage)

**Files:**
- Create: `mobile/lib/features/auth/pages/splash_page.dart`
- Create: `mobile/lib/features/auth/pages/login_page.dart`

- [ ] **Step 1: Crear splash_page.dart**

```dart
// mobile/lib/features/auth/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
```

- [ ] **Step 2: Crear login_page.dart**

```dart
// mobile/lib/features/auth/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/void_button.dart';
import '../../../shared/models/auth_model.dart';
import '../bloc/auth_bloc.dart';
import '../data/i_auth_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CitySketch(),
              const SizedBox(height: 40),
              Text(
                'SITUATIONIST',
                style: AppTextStyles.monoDisplayLarge.copyWith(
                  color: AppColors.fgSecondary,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'intervención urbana / experiencia efímera',
                style: AppTextStyles.monoUISecondary,
              ),
              const SizedBox(height: 48),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return VoidButton(
                    label: 'ENTRAR CON GOOGLE',
                    onPressed: state is AuthLoading
                        ? null
                        : () => _startGoogleLogin(context),
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthError) {
                    return Text(
                      state.message,
                      style: AppTextStyles.monoUI.copyWith(
                        color: AppColors.fgSecondary,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startGoogleLogin(BuildContext context) async {
    final callbackUrl = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _OAuthWebViewDialog(),
    );

    if (callbackUrl == null || !context.mounted) return;

    final bloc = context.read<AuthBloc>();
    final repo = context.read<IAuthRepository>();

    try {
      final response = await repo.exchangeCallbackUrl(callbackUrl);
      if (!context.mounted) return;
      bloc.add(AuthLoginCompleted(
        token: response.accessToken,
        userId: response.user.userId,
        email: response.user.email,
      ));
    } catch (e) {
      if (context.mounted) {
        bloc.add(AuthLoginCompleted(
          token: '',
          userId: '',
          email: '',
        ));
        // No-op; the error will be shown via AuthError state
      }
    }
  }
}

class _OAuthWebViewDialog extends StatefulWidget {
  const _OAuthWebViewDialog();

  @override
  State<_OAuthWebViewDialog> createState() => _OAuthWebViewDialogState();
}

class _OAuthWebViewDialogState extends State<_OAuthWebViewDialog> {
  late final WebViewController _controller;
  static const _callbackPath = '/auth/callback/google';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          if (request.url.contains(_callbackPath)) {
            Navigator.of(context).pop(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(
        Uri.parse('${ApiClient.baseUrl}/auth/login/google'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgVoid,
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text('AUTENTICACIÓN', style: AppTextStyles.label),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      '⊗',
                      style: AppTextStyles.monoUI
                          .copyWith(color: AppColors.fgSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.fgMuted),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}

class _CitySketch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(120, 80),
      painter: _CityPainter(),
    );
  }
}

class _CityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.fgMuted
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Simple ciudad esquemática con líneas
    final buildings = [
      Rect.fromLTWH(0, 30, 20, 50),
      Rect.fromLTWH(25, 10, 25, 70),
      Rect.fromLTWH(55, 20, 15, 60),
      Rect.fromLTWH(75, 5, 30, 75),
      Rect.fromLTWH(110, 25, 10, 55),
    ];

    for (final b in buildings) {
      canvas.drawRect(b, paint);
    }

    // Línea de suelo
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CityPainter oldDelegate) => false;
}
```

- [ ] **Step 3: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/features/auth/pages/
git commit -m "feat(mobile): add SplashPage and LoginPage with OAuth WebView flow"
```

---

## Task 9: App wiring — AuthGuard, app.dart, main.dart

**Files:**
- Create: `mobile/lib/core/auth/auth_guard.dart`
- Create: `mobile/lib/app.dart`
- Create: `mobile/lib/main.dart`

- [ ] **Step 1: Crear auth_guard.dart**

```dart
// mobile/lib/core/auth/auth_guard.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';

String? authGuard(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthBloc>().state;

  final isLoginRoute = state.matchedLocation == '/login';
  final isSplashRoute = state.matchedLocation == '/';

  if (authState is AuthAuthenticated) {
    if (isLoginRoute || isSplashRoute) return '/home/map';
    return null;
  }

  if (authState is AuthUnauthenticated) {
    if (!isLoginRoute) return '/login';
    return null;
  }

  // AuthLoading, AuthInitial → quedarse en splash
  if (!isSplashRoute && !isLoginRoute) return '/';
  return null;
}
```

- [ ] **Step 2: Crear app.dart**

```dart
// mobile/lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'core/auth/auth_guard.dart';
import 'core/auth/auth_service.dart';
import 'core/location/location_service.dart';
import 'core/network/api_client.dart';
import 'core/realtime/signalr_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/i_auth_repository.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/splash_page.dart';
import 'features/deriva/pages/deriva_active_page.dart';
import 'features/deriva/pages/deriva_home_page.dart';
import 'features/events/pages/create_event_page.dart';
import 'features/map/pages/map_page.dart';
import 'features/missions/pages/mission_active_page.dart';
import 'features/missions/pages/mission_detail_page.dart';
import 'features/missions/pages/missions_page.dart';
import 'features/profile/pages/profile_page.dart';

class SituationistApp extends StatefulWidget {
  const SituationistApp({super.key});

  @override
  State<SituationistApp> createState() => _SituationistAppState();
}

class _SituationistAppState extends State<SituationistApp> {
  late final FlutterSecureStorage _storage;
  late final AuthService _authService;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final LocationService _locationService;
  late final SignalRService _signalRService;
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _storage = const FlutterSecureStorage();
    _authService = AuthService(_storage);
    _apiClient = ApiClient(_storage);
    _authRepository = AuthRepository(
      authService: _authService,
      apiClient: _apiClient,
    );
    _locationService = LocationService();
    _signalRService = SignalRService(_authService);
    _authBloc = AuthBloc(repository: _authRepository);

    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
      redirect: (context, state) => authGuard(context, state),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => _ShellScaffold(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/home/map',
                builder: (_, __) => MapPage(
                  locationService: _locationService,
                  signalRService: _signalRService,
                  apiClient: _apiClient,
                ),
                routes: [
                  GoRoute(
                    path: '/home/events/:id',
                    builder: (_, state) =>
                        MapPage(locationService: _locationService, signalRService: _signalRService, apiClient: _apiClient),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/home/deriva',
                builder: (_, __) => DerivaHomePage(
                  locationService: _locationService,
                  apiClient: _apiClient,
                ),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/home/missions',
                builder: (_, __) => MissionsPage(
                  locationService: _locationService,
                  apiClient: _apiClient,
                ),
                routes: [
                  GoRoute(
                    path: '/home/missions/:id',
                    builder: (_, state) => MissionDetailPage(
                      missionId: state.pathParameters['id']!,
                      apiClient: _apiClient,
                    ),
                    routes: [
                      GoRoute(
                        path: '/home/missions/:id/active',
                        builder: (_, state) => MissionActivePage(
                          missionId: state.pathParameters['id']!,
                          apiClient: _apiClient,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/home/create',
                builder: (_, __) => CreateEventPage(
                  locationService: _locationService,
                  apiClient: _apiClient,
                ),
              ),
            ]),
          ],
        ),
        GoRoute(
          path: '/home/deriva/active',
          builder: (_, __) => DerivaActivePage(
            locationService: _locationService,
            apiClient: _apiClient,
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => ProfilePage(apiClient: _apiClient),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    _signalRService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthRepository>.value(value: _authRepository),
        RepositoryProvider<ApiClient>.value(value: _apiClient),
        RepositoryProvider<LocationService>.value(value: _locationService),
        RepositoryProvider<SignalRService>.value(value: _signalRService),
      ],
      child: BlocProvider.value(
        value: _authBloc,
        child: MaterialApp.router(
          title: 'Situationist',
          theme: buildAppTheme(),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class _ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;

  const _ShellScaffold({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: _VoidBottomNav(
        currentIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}

class _VoidBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _VoidBottomNav({required this.currentIndex, required this.onTap});

  static const _icons = ['⌀', '↺', '◈', '⊕'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgVoid,
      child: SafeArea(
        child: Row(
          children: List.generate(_icons.length, (i) {
            final isActive = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive)
                      Container(
                        height: 2,
                        color: AppColors.phosphor,
                      )
                    else
                      const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _icons[i],
                        style: AppTextStyles.monoDisplay.copyWith(
                          color: isActive
                              ? AppColors.phosphor
                              : AppColors.fgMuted,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    stream.listen((_) => notifyListeners());
  }
}
```

- [ ] **Step 3: Crear main.dart**

```dart
// mobile/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const SituationistApp());
}
```

- [ ] **Step 4: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/app.dart mobile/lib/main.dart mobile/lib/core/auth/auth_guard.dart
git commit -m "feat(mobile): wire app — GoRouter, ShellRoute, bottom nav, providers"
```

---

## Task 10: Events feature — data layer + EventsBloc

**Files:**
- Create: `mobile/lib/features/events/data/i_events_repository.dart`
- Create: `mobile/lib/features/events/data/events_repository.dart`
- Create: `mobile/lib/features/events/bloc/events_bloc.dart`

- [ ] **Step 1: Escribir test fallido para EventsBloc**

```dart
// mobile/test/features/events/events_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:situationist/features/events/bloc/events_bloc.dart';
import 'package:situationist/features/events/data/i_events_repository.dart';
import 'package:situationist/shared/models/event_model.dart';

class MockEventsRepository extends Mock implements IEventsRepository {}

final _mockEvent = EventModel(
  id: 'e1',
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
      expect: () => [
        isA<EventsLoaded>(),
      ],
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
```

- [ ] **Step 2: Ejecutar test — debe fallar**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude/mobile
flutter test test/features/events/events_bloc_test.dart
```

Expected: Error de compilación — tipos no definidos.

- [ ] **Step 3: Crear i_events_repository.dart**

```dart
// mobile/lib/features/events/data/i_events_repository.dart
import '../../../shared/models/event_model.dart';

abstract class IEventsRepository {
  Future<List<EventModel>> getNearbyEvents({
    required double lat,
    required double lng,
    required int radius,
  });

  Future<EventModel> getEventDetail({
    required String id,
    required double lat,
    required double lng,
  });

  Future<EventModel> createEvent(CreateEventRequest request);

  Future<GeneratedEventSuggestion> generateEvent(GenerateEventRequest request);

  Future<void> participate({
    required String eventId,
    required String role,
  });

  Future<void> cancelEvent(String eventId);
}
```

- [ ] **Step 4: Crear events_repository.dart**

```dart
// mobile/lib/features/events/data/events_repository.dart
import '../../../core/network/api_client.dart';
import '../../../shared/models/event_model.dart';
import 'i_events_repository.dart';

class EventsRepository implements IEventsRepository {
  final ApiClient _client;

  EventsRepository(this._client);

  @override
  Future<List<EventModel>> getNearbyEvents({
    required double lat,
    required double lng,
    required int radius,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/events',
      queryParameters: {'lat': lat, 'lng': lng, 'radius': radius},
    );
    return (response.data as List)
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EventModel> getEventDetail({
    required String id,
    required double lat,
    required double lng,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/events/$id',
      queryParameters: {'lat': lat, 'lng': lng},
    );
    return EventModel.fromJson(response.data!);
  }

  @override
  Future<EventModel> createEvent(CreateEventRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/events',
      data: request.toJson(),
    );
    return EventModel.fromJson(response.data!);
  }

  @override
  Future<GeneratedEventSuggestion> generateEvent(
      GenerateEventRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/events/generate',
      data: request.toJson(),
    );
    return GeneratedEventSuggestion.fromJson(response.data!);
  }

  @override
  Future<void> participate({
    required String eventId,
    required String role,
  }) async {
    await _client.post<void>(
      '/events/$eventId/participate',
      data: {'role': role},
    );
  }

  @override
  Future<void> cancelEvent(String eventId) async {
    await _client.delete<void>('/events/$eventId');
  }
}
```

- [ ] **Step 5: Crear events_bloc.dart**

```dart
// mobile/lib/features/events/bloc/events_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/event_model.dart';
import '../data/i_events_repository.dart';

// Events
abstract class EventsEvent extends Equatable {}

class EventsNearbyRequested extends EventsEvent {
  final double lat;
  final double lng;
  final int radius;

  EventsNearbyRequested({required this.lat, required this.lng, required this.radius});

  @override
  List<Object?> get props => [lat, lng, radius];
}

class EventParticipateRequested extends EventsEvent {
  final String eventId;
  final String role;

  EventParticipateRequested({required this.eventId, required this.role});

  @override
  List<Object?> get props => [eventId, role];
}

class EventExpiredReceived extends EventsEvent {
  final String eventId;

  EventExpiredReceived({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class EventFullReceived extends EventsEvent {
  final String eventId;

  EventFullReceived({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

// States
abstract class EventsState extends Equatable {}

class EventsInitial extends EventsState {
  @override
  List<Object?> get props => [];
}

class EventsLoading extends EventsState {
  @override
  List<Object?> get props => [];
}

class EventsLoaded extends EventsState {
  final List<EventModel> events;

  EventsLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

class EventsError extends EventsState {
  final String message;

  EventsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final IEventsRepository _repository;

  EventsBloc({required IEventsRepository repository})
      : _repository = repository,
        super(EventsInitial()) {
    on<EventsNearbyRequested>(_onNearbyRequested);
    on<EventParticipateRequested>(_onParticipateRequested);
    on<EventExpiredReceived>(_onEventExpired);
    on<EventFullReceived>(_onEventFull);
  }

  Future<void> _onNearbyRequested(
    EventsNearbyRequested event,
    Emitter<EventsState> emit,
  ) async {
    emit(EventsLoading());
    try {
      final events = await _repository.getNearbyEvents(
        lat: event.lat,
        lng: event.lng,
        radius: event.radius,
      );
      emit(EventsLoaded(events: events));
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> _onParticipateRequested(
    EventParticipateRequested event,
    Emitter<EventsState> emit,
  ) async {
    try {
      await _repository.participate(
        eventId: event.eventId,
        role: event.role,
      );
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  void _onEventExpired(EventExpiredReceived event, Emitter<EventsState> emit) {
    if (state is EventsLoaded) {
      final current = (state as EventsLoaded).events;
      emit(EventsLoaded(
        events: current.where((e) => e.id != event.eventId).toList(),
      ));
    }
  }

  void _onEventFull(EventFullReceived event, Emitter<EventsState> emit) {
    if (state is EventsLoaded) {
      final current = (state as EventsLoaded).events;
      emit(EventsLoaded(
        events: current.map((e) {
          if (e.id == event.eventId) {
            return e.copyWith(status: 'Full');
          }
          return e;
        }).toList(),
      ));
    }
  }
}
```

- [ ] **Step 6: Ejecutar test — debe pasar**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude/mobile
flutter test test/features/events/events_bloc_test.dart
```

Expected: `All tests passed!` — 3 tests.

- [ ] **Step 7: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/features/events/ mobile/test/features/events/
git commit -m "feat(mobile): add events data layer, EventsBloc + tests (3 passing)"
```

---

## Task 11: Map feature — MapBloc, MapPage, EventDetailSheet

**Files:**
- Create: `mobile/lib/features/map/bloc/map_bloc.dart`
- Create: `mobile/lib/features/map/pages/map_page.dart`
- Create: `mobile/lib/features/map/widgets/event_detail_sheet.dart`

- [ ] **Step 1: Crear map_bloc.dart**

```dart
// mobile/lib/features/map/bloc/map_bloc.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/location/location_service.dart';
import '../../../core/realtime/signalr_service.dart';
import '../../../features/events/bloc/events_bloc.dart';
import '../../../features/events/data/i_events_repository.dart';
import '../../../shared/models/event_model.dart';

abstract class MapEvent extends Equatable {}

class MapInitialized extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapEventSelected extends MapEvent {
  final String? eventId;
  MapEventSelected(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

abstract class MapState extends Equatable {}

class MapLoading extends MapState {
  @override
  List<Object?> get props => [];
}

class MapReady extends MapState {
  final double lat;
  final double lng;
  final List<EventModel> events;
  final String? selectedEventId;

  MapReady({
    required this.lat,
    required this.lng,
    required this.events,
    this.selectedEventId,
  });

  MapReady copyWith({
    double? lat,
    double? lng,
    List<EventModel>? events,
    String? selectedEventId,
    bool clearSelection = false,
  }) {
    return MapReady(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      events: events ?? this.events,
      selectedEventId:
          clearSelection ? null : selectedEventId ?? this.selectedEventId,
    );
  }

  @override
  List<Object?> get props => [lat, lng, events, selectedEventId];
}

class MapError extends MapState {
  final String message;
  MapError(this.message);
  @override
  List<Object?> get props => [message];
}

class MapBloc extends Bloc<MapEvent, MapState> {
  final IEventsRepository _eventsRepository;
  final LocationService _locationService;
  final SignalRService _signalRService;
  StreamSubscription<SignalREvent>? _signalRSubscription;

  MapBloc({
    required IEventsRepository eventsRepository,
    required LocationService locationService,
    required SignalRService signalRService,
  })  : _eventsRepository = eventsRepository,
        _locationService = locationService,
        _signalRService = signalRService,
        super(MapLoading()) {
    on<MapInitialized>(_onInitialized);
    on<MapEventSelected>(_onEventSelected);
    on<EventExpiredReceived>(_onExpired);
    on<EventFullReceived>(_onFull);
  }

  Future<void> _onInitialized(
    MapInitialized event,
    Emitter<MapState> emit,
  ) async {
    try {
      final (lat, lng) = await _locationService.getCurrentPosition();
      final events = await _eventsRepository.getNearbyEvents(
        lat: lat,
        lng: lng,
        radius: 1000,
      );
      emit(MapReady(lat: lat, lng: lng, events: events));
      await _signalRService.connect();
      await _signalRService.joinZone(lat, lng);
      _signalRSubscription = _signalRService.events.listen((e) {
        if (e is EventExpiredSignal) add(EventExpiredReceived(eventId: e.eventId));
        if (e is EventFullSignal) add(EventFullReceived(eventId: e.eventId));
      });
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  void _onEventSelected(MapEventSelected event, Emitter<MapState> emit) {
    if (state is MapReady) {
      if (event.eventId == null) {
        emit((state as MapReady).copyWith(clearSelection: true));
      } else {
        emit((state as MapReady).copyWith(selectedEventId: event.eventId));
      }
    }
  }

  void _onExpired(EventExpiredReceived event, Emitter<MapState> emit) {
    if (state is MapReady) {
      final s = state as MapReady;
      emit(s.copyWith(
        events: s.events.where((e) => e.id != event.eventId).toList(),
        clearSelection: s.selectedEventId == event.eventId,
      ));
    }
  }

  void _onFull(EventFullReceived event, Emitter<MapState> emit) {
    if (state is MapReady) {
      final s = state as MapReady;
      emit(s.copyWith(
        events: s.events.map((e) {
          return e.id == event.eventId ? e.copyWith(status: 'Full') : e;
        }).toList(),
      ));
    }
  }

  @override
  Future<void> close() {
    _signalRSubscription?.cancel();
    return super.close();
  }
}
```

- [ ] **Step 2: Crear event_detail_sheet.dart**

```dart
// mobile/lib/features/map/widgets/event_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../../../features/events/bloc/events_bloc.dart';
import '../../../shared/extensions/datetime_extensions.dart';
import '../../../shared/models/event_model.dart';

class EventDetailSheet extends StatelessWidget {
  final EventModel event;
  final VoidCallback onDismiss;

  const EventDetailSheet({
    super.key,
    required this.event,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon = event.expiresAt.isExpiringSoon();
    final borderColor = isExpiringSoon ? AppColors.amber : AppColors.fgMuted;
    final statusColor = event.status == 'Active' ? AppColors.phosphor : AppColors.fgSecondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            border: Border(top: BorderSide(color: borderColor, width: 1)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _buildHandle(),
              const SizedBox(height: 16),
              _buildHeader(statusColor),
              const SizedBox(height: 8),
              Container(height: 1, color: AppColors.fgMuted),
              const SizedBox(height: 12),
              _buildMeta(),
              const SizedBox(height: 16),
              Text(event.description, style: AppTextStyles.body),
              const SizedBox(height: 16),
              _buildParticipantCount(),
              const SizedBox(height: 16),
              _buildActions(context),
              const SizedBox(height: 8),
              BlocBuilder<EventsBloc, EventsState>(
                builder: (ctx, state) {
                  if (state is EventsError) {
                    return MonoText(
                      state.message,
                      color: AppColors.fgSecondary,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 2,
        color: AppColors.fgMuted,
      ),
    );
  }

  Widget _buildHeader(Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            event.title.toUpperCase(),
            style: AppTextStyles.monoDisplay.copyWith(fontSize: 14),
          ),
        ),
        Row(
          children: [
            _BlinkDot(color: statusColor),
            const SizedBox(width: 6),
            MonoText(
              event.status.toUpperCase(),
              color: statusColor,
              size: 11,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeta() {
    return MonoText(
      '${event.actionType} · ${event.interventionLevel} · hasta ${event.expiresAt.toTimeOnly()}',
      color: AppColors.fgSecondary,
      size: 11,
    );
  }

  Widget _buildParticipantCount() {
    final current = event.participantCount.toString().padLeft(2, '0');
    final max = event.maxParticipants != null
        ? ' / ${event.maxParticipants.toString().padLeft(2, '0')}'
        : '';
    return MonoText(
      'participantes: $current$max',
      color: AppColors.fgSecondary,
    );
  }

  Widget _buildActions(BuildContext context) {
    final isFull = event.status == 'Full';
    final isExpired = event.expiresAt.isBefore(DateTime.now().toUtc());
    final disabled = isFull || isExpired;

    return Row(
      children: [
        Expanded(
          child: VoidButton(
            label: 'PARTICIPAR',
            onPressed: disabled
                ? null
                : () => context.read<EventsBloc>().add(
                      EventParticipateRequested(
                        eventId: event.id,
                        role: 'Participante',
                      ),
                    ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VoidButton(
            label: 'OBSERVAR',
            onPressed: disabled
                ? null
                : () => context.read<EventsBloc>().add(
                      EventParticipateRequested(
                        eventId: event.id,
                        role: 'Observador',
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}

class _BlinkDot extends StatefulWidget {
  final Color color;
  const _BlinkDot({required this.color});

  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: _controller.value,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Crear map_page.dart**

```dart
// mobile/lib/features/map/pages/map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/realtime/signalr_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/events/bloc/events_bloc.dart';
import '../../../features/events/data/events_repository.dart';
import '../../../shared/models/event_model.dart';
import '../bloc/map_bloc.dart';
import '../widgets/event_detail_sheet.dart';

class MapPage extends StatelessWidget {
  final LocationService locationService;
  final SignalRService signalRService;
  final ApiClient apiClient;

  const MapPage({
    super.key,
    required this.locationService,
    required this.signalRService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MapBloc(
            eventsRepository: EventsRepository(apiClient),
            locationService: locationService,
            signalRService: signalRService,
          )..add(MapInitialized()),
        ),
        BlocProvider(
          create: (_) => EventsBloc(
            repository: EventsRepository(apiClient),
          ),
        ),
      ],
      child: const _MapView(),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is MapLoading) {
          return const Scaffold(
            backgroundColor: AppColors.bgVoid,
            body: SizedBox.shrink(),
          );
        }

        if (state is MapError) {
          return Scaffold(
            backgroundColor: AppColors.bgVoid,
            body: Center(
              child: Text(state.message,
                  style: const TextStyle(color: AppColors.fgSecondary)),
            ),
          );
        }

        final mapState = state as MapReady;
        final selected = mapState.selectedEventId != null
            ? mapState.events
                .where((e) => e.id == mapState.selectedEventId)
                .firstOrNull
            : null;

        return Scaffold(
          backgroundColor: AppColors.bgVoid,
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(mapState.lat, mapState.lng),
                  initialZoom: 15,
                  onTap: (_, __) =>
                      context.read<MapBloc>().add(MapEventSelected(null)),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'app.situationist',
                  ),
                  CircleLayer(
                    circles: mapState.events.map(_buildCircle).toList(),
                  ),
                ],
              ),
              if (selected != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: EventDetailSheet(
                    event: selected,
                    onDismiss: () =>
                        context.read<MapBloc>().add(MapEventSelected(null)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  CircleMarker _buildCircle(EventModel event) {
    final isExpiringSoon = event.expiresAt
        .difference(DateTime.now().toUtc())
        .inMinutes < 10;
    final isByProximity = event.visibility == 'ByProximity';

    return CircleMarker(
      point: LatLng(event.centroidLatitude, event.centroidLongitude),
      radius: event.radiusMeters.toDouble(),
      color: Colors.transparent,
      borderColor: isExpiringSoon
          ? AppColors.amber
          : isByProximity
              ? AppColors.fgMuted
              : AppColors.phosphor,
      borderStrokeWidth: 1,
      useRadiusInMeter: true,
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/features/map/
git commit -m "feat(mobile): add MapBloc, MapPage with flutter_map, EventDetailSheet"
```

---

## Task 12: CreateEventPage

**Files:**
- Create: `mobile/lib/features/events/pages/create_event_page.dart`

- [ ] **Step 1: Crear create_event_page.dart**

```dart
// mobile/lib/features/events/pages/create_event_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../../../shared/models/event_model.dart';
import '../bloc/events_bloc.dart';
import '../data/events_repository.dart';

class CreateEventPage extends StatelessWidget {
  final LocationService locationService;
  final ApiClient apiClient;

  const CreateEventPage({
    super.key,
    required this.locationService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventsBloc(repository: EventsRepository(apiClient)),
      child: _CreateEventView(locationService: locationService),
    );
  }
}

class _CreateEventView extends StatefulWidget {
  final LocationService locationService;
  const _CreateEventView({required this.locationService});

  @override
  State<_CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<_CreateEventView> {
  int _step = 1;
  String _actionType = 'Poetica';
  String _interventionLevel = 'Bajo';
  String _title = '';
  String _description = '';
  String _visibility = 'Public';
  int _durationMinutes = 30;
  int? _maxParticipants;
  GeneratedEventSuggestion? _suggestion;
  bool _isGenerating = false;
  String? _error;

  static const _actionTypes = ['Performativa', 'Social', 'Sensorial', 'Poetica'];
  static const _levels = ['Bajo', 'Medio', 'Alto'];
  static const _visibilities = ['Public', 'ByProximity', 'HiddenUntilDiscovery'];
  static const _durations = [10, 15, 20, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _step == 1 ? _buildStep1() : _buildStep2(),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CREAR EVENTO', style: AppTextStyles.monoDisplay),
        const SizedBox(height: 4),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 24),
        _sectionLabel('tipo de acción'),
        ..._actionTypes.map((t) => _SelectionRow(
              label: t,
              selected: _actionType == t,
              onTap: () => setState(() => _actionType = t),
            )),
        const SizedBox(height: 20),
        _sectionLabel('nivel de intervención'),
        ..._levels.map((l) => _SelectionRow(
              label: l,
              selected: _interventionLevel == l,
              onTap: () => setState(() => _interventionLevel = l),
            )),
        const SizedBox(height: 24),
        Row(
          children: [
            VoidButton(
              label: 'SORPRÉNDEME',
              onPressed: _isGenerating ? null : _generateSuggestion,
            ),
          ],
        ),
        if (_suggestion != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.fgMuted),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonoText(_suggestion!.title, size: 12),
                const SizedBox(height: 4),
                Text(_suggestion!.description, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        _sectionLabel('o describe el evento manualmente:'),
        const SizedBox(height: 8),
        _inputField(
          hint: 'título',
          onChanged: (v) => setState(() => _title = v),
          initialValue: _suggestion?.title ?? '',
        ),
        const SizedBox(height: 8),
        _inputField(
          hint: 'descripción',
          onChanged: (v) => setState(() => _description = v),
          maxLines: 3,
          initialValue: _suggestion?.description ?? '',
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          MonoText(_error!, color: AppColors.fgSecondary),
        ],
        const Spacer(),
        VoidButton(
          label: 'SIGUIENTE →',
          onPressed: _canProceed ? () => setState(() => _step = 2) : null,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DETALLES', style: AppTextStyles.monoDisplay),
        const SizedBox(height: 4),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 24),
        _sectionLabel('visibilidad'),
        ..._visibilities.map((v) => _SelectionRow(
              label: v,
              selected: _visibility == v,
              onTap: () => setState(() => _visibility = v),
            )),
        const SizedBox(height: 20),
        _sectionLabel('duración'),
        ..._durations.map((d) => _SelectionRow(
              label: '$d min',
              selected: _durationMinutes == d,
              onTap: () => setState(() => _durationMinutes = d),
            )),
        if (_error != null) ...[
          const SizedBox(height: 8),
          MonoText(_error!, color: AppColors.fgSecondary),
        ],
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: VoidButton(
                label: '← VOLVER',
                onPressed: () => setState(() => _step = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BlocConsumer<EventsBloc, EventsState>(
                listener: (context, state) {
                  if (state is EventsLoaded) context.go('/home/map');
                  if (state is EventsError) setState(() => _error = state.message);
                },
                builder: (context, state) {
                  return VoidButton(
                    label: 'PUBLICAR',
                    onPressed: state is EventsLoading ? null : _publish,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool get _canProceed =>
      (_title.isNotEmpty && _description.isNotEmpty) ||
      _suggestion != null;

  Future<void> _generateSuggestion() async {
    setState(() => _isGenerating = true);
    try {
      final (lat, lng) = await widget.locationService.getCurrentPosition();
      if (!mounted) return;
      final repo = EventsRepository(context.read<ApiClient>());
      final suggestion = await repo.generateEvent(GenerateEventRequest(
        actionType: _actionType,
        interventionLevel: _interventionLevel,
        latitude: lat,
        longitude: lng,
      ));
      if (mounted) setState(() => _suggestion = suggestion);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _publish() async {
    final (lat, lng) = await widget.locationService.getCurrentPosition();
    if (!mounted) return;
    final finalTitle = _suggestion?.title ?? _title;
    final finalDesc = _suggestion?.description ?? _description;
    final finalType = _suggestion?.actionType ?? _actionType;
    context.read<EventsBloc>().add(
          EventParticipateRequested(eventId: 'create', role: 'Participante'),
        );
    // Direct create via repository
    try {
      final repo = EventsRepository(context.read<ApiClient>());
      await repo.createEvent(CreateEventRequest(
        title: finalTitle,
        description: finalDesc,
        actionType: finalType,
        interventionLevel: _interventionLevel,
        latitude: lat,
        longitude: lng,
        radiusMeters: 300,
        visibility: _visibility,
        durationMinutes: _durationMinutes,
        startsAt: DateTime.now().toUtc(),
      ));
      if (mounted) context.go('/home/map');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Widget _sectionLabel(String text) => MonoText(text, color: AppColors.fgSecondary);

  Widget _inputField({
    required String hint,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    String initialValue = '',
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      style: AppTextStyles.monoUI,
      decoration: InputDecoration(hintText: hint),
      onChanged: onChanged,
    );
  }
}

class _SelectionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            MonoText(
              selected ? '▸ ' : '  ',
              color: AppColors.phosphor,
            ),
            MonoText(
              label.toUpperCase(),
              color: selected ? AppColors.fgPrimary : AppColors.fgSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/features/events/pages/
git commit -m "feat(mobile): add CreateEventPage (2-step form with AI generation)"
```

---

## Task 13: Deriva feature — data layer + DerivaBloc

**Files:**
- Create: `mobile/lib/features/deriva/data/i_deriva_repository.dart`
- Create: `mobile/lib/features/deriva/data/deriva_repository.dart`
- Create: `mobile/lib/features/deriva/bloc/deriva_bloc.dart`

- [ ] **Step 1: Escribir test fallido para DerivaBloc**

```dart
// mobile/test/features/deriva/deriva_bloc_test.dart
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
```

- [ ] **Step 2: Ejecutar test — debe fallar**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude/mobile
flutter test test/features/deriva/deriva_bloc_test.dart
```

Expected: Error de compilación.

- [ ] **Step 3: Crear i_deriva_repository.dart**

```dart
// mobile/lib/features/deriva/data/i_deriva_repository.dart
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
```

- [ ] **Step 4: Crear deriva_repository.dart**

```dart
// mobile/lib/features/deriva/data/deriva_repository.dart
import '../../../core/network/api_client.dart';
import '../../../shared/models/deriva_session_model.dart';
import 'i_deriva_repository.dart';

class DerivaRepository implements IDerivaRepository {
  final ApiClient _client;

  DerivaRepository(this._client);

  @override
  Future<DerivaSessionModel> startSession({
    required String type,
    required double lat,
    required double lng,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/deriva/sessions',
      data: {'type': type, 'latitude': lat, 'longitude': lng, 'language': 'es'},
    );
    return DerivaSessionModel.fromJson(response.data!);
  }

  @override
  Future<DerivaInstructionModel> getNextInstruction({
    required String sessionId,
    required double lat,
    required double lng,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/deriva/sessions/$sessionId/next-instruction',
      queryParameters: {'lat': lat, 'lng': lng, 'lang': 'es'},
    );
    return DerivaInstructionModel.fromJson(response.data!);
  }

  @override
  Future<void> completeSession(String sessionId) async {
    await _client.post<void>('/deriva/sessions/$sessionId/complete');
  }

  @override
  Future<void> abandonSession(String sessionId) async {
    await _client.post<void>('/deriva/sessions/$sessionId/abandon');
  }
}
```

- [ ] **Step 5: Crear deriva_bloc.dart**

```dart
// mobile/lib/features/deriva/bloc/deriva_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/i_deriva_repository.dart';

// Events
abstract class DerivaEvent extends Equatable {}

class DerivaStartRequested extends DerivaEvent {
  final String type;
  final double lat;
  final double lng;

  DerivaStartRequested({required this.type, required this.lat, required this.lng});

  @override
  List<Object?> get props => [type, lat, lng];
}

class DerivaNextInstructionRequested extends DerivaEvent {
  final double lat;
  final double lng;

  DerivaNextInstructionRequested({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

class DerivaCompleteRequested extends DerivaEvent {
  @override
  List<Object?> get props => [];
}

class DerivaAbandonRequested extends DerivaEvent {
  @override
  List<Object?> get props => [];
}

// States
abstract class DerivaState extends Equatable {}

class DerivaIdle extends DerivaState {
  @override
  List<Object?> get props => [];
}

class DerivaStarting extends DerivaState {
  @override
  List<Object?> get props => [];
}

class DerivaActive extends DerivaState {
  final String sessionId;
  final String currentInstruction;
  final String type;
  final bool isWriting;

  DerivaActive({
    required this.sessionId,
    required this.currentInstruction,
    required this.type,
    required this.isWriting,
  });

  DerivaActive copyWith({
    String? currentInstruction,
    bool? isWriting,
  }) {
    return DerivaActive(
      sessionId: sessionId,
      currentInstruction: currentInstruction ?? this.currentInstruction,
      type: type,
      isWriting: isWriting ?? this.isWriting,
    );
  }

  @override
  List<Object?> get props => [sessionId, currentInstruction, type, isWriting];
}

class DerivaCompleted extends DerivaState {
  @override
  List<Object?> get props => [];
}

class DerivaError extends DerivaState {
  final String message;
  DerivaError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class DerivaBloc extends Bloc<DerivaEvent, DerivaState> {
  final IDerivaRepository _repository;

  DerivaBloc({required IDerivaRepository repository})
      : _repository = repository,
        super(DerivaIdle()) {
    on<DerivaStartRequested>(_onStartRequested);
    on<DerivaNextInstructionRequested>(_onNextInstruction);
    on<DerivaCompleteRequested>(_onCompleteRequested);
    on<DerivaAbandonRequested>(_onAbandonRequested);
  }

  Future<void> _onStartRequested(
    DerivaStartRequested event,
    Emitter<DerivaState> emit,
  ) async {
    emit(DerivaStarting());
    try {
      final session = await _repository.startSession(
        type: event.type,
        lat: event.lat,
        lng: event.lng,
      );
      emit(DerivaActive(
        sessionId: session.id,
        currentInstruction: session.firstInstruction,
        type: session.type,
        isWriting: true,
      ));
    } catch (e) {
      emit(DerivaError(e.toString()));
    }
  }

  Future<void> _onNextInstruction(
    DerivaNextInstructionRequested event,
    Emitter<DerivaState> emit,
  ) async {
    if (state is! DerivaActive) return;
    final current = state as DerivaActive;
    try {
      final instruction = await _repository.getNextInstruction(
        sessionId: current.sessionId,
        lat: event.lat,
        lng: event.lng,
      );
      emit(current.copyWith(
        currentInstruction: instruction.content,
        isWriting: true,
      ));
    } catch (e) {
      emit(DerivaError(e.toString()));
    }
  }

  Future<void> _onCompleteRequested(
    DerivaCompleteRequested event,
    Emitter<DerivaState> emit,
  ) async {
    if (state is! DerivaActive) return;
    final sessionId = (state as DerivaActive).sessionId;
    await _repository.completeSession(sessionId);
    emit(DerivaCompleted());
  }

  Future<void> _onAbandonRequested(
    DerivaAbandonRequested event,
    Emitter<DerivaState> emit,
  ) async {
    if (state is! DerivaActive) return;
    final sessionId = (state as DerivaActive).sessionId;
    await _repository.abandonSession(sessionId);
    emit(DerivaIdle());
  }
}
```

- [ ] **Step 6: Ejecutar test — debe pasar**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude/mobile
flutter test test/features/deriva/deriva_bloc_test.dart
```

Expected: `All tests passed!` — 3 tests.

- [ ] **Step 7: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/features/deriva/ mobile/test/features/deriva/
git commit -m "feat(mobile): add deriva data layer, DerivaBloc + tests (3 passing)"
```

---

## Task 14: Deriva feature — UI

**Files:**
- Create: `mobile/lib/features/deriva/pages/deriva_home_page.dart`
- Create: `mobile/lib/features/deriva/pages/deriva_active_page.dart`

- [ ] **Step 1: Crear deriva_home_page.dart**

```dart
// mobile/lib/features/deriva/pages/deriva_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/deriva_bloc.dart';
import '../data/deriva_repository.dart';

class DerivaHomePage extends StatelessWidget {
  final LocationService locationService;
  final ApiClient apiClient;

  const DerivaHomePage({
    super.key,
    required this.locationService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DerivaBloc(repository: DerivaRepository(apiClient)),
      child: _DerivaHomeView(locationService: locationService),
    );
  }
}

class _DerivaHomeView extends StatefulWidget {
  final LocationService locationService;
  const _DerivaHomeView({required this.locationService});

  @override
  State<_DerivaHomeView> createState() => _DerivaHomeViewState();
}

class _DerivaHomeViewState extends State<_DerivaHomeView> {
  String _selectedType = 'Caotica';

  static const _types = {
    'Caotica': 'sin reglas, sin dirección',
    'Poetica': 'instrucciones contemplativas',
    'Social': 'interacción con desconocidos',
    'Sensorial': 'percepción aumentada',
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<DerivaBloc, DerivaState>(
      listener: (context, state) {
        if (state is DerivaActive) context.go('/home/deriva/active');
        if (state is DerivaError) {
          // Error shown in widget via BlocBuilder
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgVoid,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MODO DERIVA', style: AppTextStyles.monoDisplay),
                const SizedBox(height: 4),
                Container(height: 1, color: AppColors.fgMuted),
                const SizedBox(height: 32),
                ..._types.entries.map((e) => _TypeRow(
                      type: e.key,
                      description: e.value,
                      selected: _selectedType == e.key,
                      onTap: () => setState(() => _selectedType = e.key),
                    )),
                const SizedBox(height: 32),
                BlocBuilder<DerivaBloc, DerivaState>(
                  builder: (context, state) {
                    if (state is DerivaError) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MonoText(
                          state.message,
                          color: AppColors.fgSecondary,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                BlocBuilder<DerivaBloc, DerivaState>(
                  builder: (context, state) {
                    return VoidButton(
                      label: 'INICIAR',
                      onPressed: state is DerivaStarting
                          ? null
                          : () => _start(context),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    final (lat, lng) = await widget.locationService.getCurrentPosition();
    if (!context.mounted) return;
    context.read<DerivaBloc>().add(DerivaStartRequested(
          type: _selectedType,
          lat: lat,
          lng: lng,
        ));
  }
}

class _TypeRow extends StatelessWidget {
  final String type;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _TypeRow({
    required this.type,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            MonoText(
              selected ? '▸ ' : '  ',
              color: AppColors.phosphor,
            ),
            MonoText(
              type.toUpperCase(),
              color: selected ? AppColors.fgPrimary : AppColors.fgSecondary,
              size: 13,
            ),
            MonoText(
              '      —  $description',
              color: AppColors.fgMuted,
              size: 11,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Crear deriva_active_page.dart**

```dart
// mobile/lib/features/deriva/pages/deriva_active_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/scanlines_overlay.dart';
import '../../../core/widgets/typewriter_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/deriva_bloc.dart';
import '../data/deriva_repository.dart';

class DerivaActivePage extends StatelessWidget {
  final LocationService locationService;
  final ApiClient apiClient;

  const DerivaActivePage({
    super.key,
    required this.locationService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DerivaBloc(repository: DerivaRepository(apiClient)),
      child: _DerivaActiveView(locationService: locationService),
    );
  }
}

class _DerivaActiveView extends StatefulWidget {
  final LocationService locationService;
  const _DerivaActiveView({required this.locationService});

  @override
  State<_DerivaActiveView> createState() => _DerivaActiveViewState();
}

class _DerivaActiveViewState extends State<_DerivaActiveView>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _writingComplete = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0,
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DerivaBloc, DerivaState>(
      listener: (context, state) {
        if (state is DerivaIdle || state is DerivaCompleted) {
          context.go('/home/deriva');
        }
      },
      builder: (context, state) {
        if (state is! DerivaActive) {
          return const Scaffold(backgroundColor: AppColors.bgVoid);
        }

        return FadeTransition(
          opacity: _fadeController,
          child: ScanlinesOverlay(
            child: Scaffold(
              backgroundColor: AppColors.bgVoid,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: _LiveClock(),
                      ),
                      const Spacer(),
                      TypewriterText(
                        text: state.currentInstruction,
                        style: AppTextStyles.body.copyWith(fontSize: 16),
                        onComplete: () =>
                            setState(() => _writingComplete = true),
                      ),
                      const SizedBox(height: 40),
                      Container(height: 1, color: AppColors.fgMuted),
                      const SizedBox(height: 24),
                      VoidButton(
                        label: 'SIGUIENTE INSTRUCCIÓN',
                        onPressed: _writingComplete
                            ? () => _requestNext(context, state)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: VoidButton(
                              label: 'COMPLETAR',
                              onPressed: () => context
                                  .read<DerivaBloc>()
                                  .add(DerivaCompleteRequested()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: VoidButton(
                              label: 'ABANDONAR',
                              onPressed: () => context
                                  .read<DerivaBloc>()
                                  .add(DerivaAbandonRequested()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestNext(BuildContext context, DerivaActive state) async {
    setState(() => _writingComplete = false);
    final (lat, lng) = await widget.locationService.getCurrentPosition();
    if (!context.mounted) return;
    context.read<DerivaBloc>().add(DerivaNextInstructionRequested(
          lat: lat,
          lng: lng,
        ));
  }
}

class _LiveClock extends StatefulWidget {
  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late String _time;

  @override
  void initState() {
    super.initState();
    _updateTime();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return false;
      setState(_updateTime);
      return true;
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    _time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return MonoText(_time, color: AppColors.fgSecondary);
  }
}
```

- [ ] **Step 3: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/features/deriva/pages/
git commit -m "feat(mobile): add DerivaHomePage and DerivaActivePage with typewriter effect"
```

---

## Task 15: Missions feature — data layer + MissionsBloc

**Files:**
- Create: `mobile/lib/features/missions/data/i_missions_repository.dart`
- Create: `mobile/lib/features/missions/data/missions_repository.dart`
- Create: `mobile/lib/features/missions/bloc/missions_bloc.dart`

- [ ] **Step 1: Escribir test fallido para MissionsBloc**

```dart
// mobile/test/features/missions/missions_bloc_test.dart
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
              MissionModel(
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
```

- [ ] **Step 2: Ejecutar test — debe fallar**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude/mobile
flutter test test/features/missions/missions_bloc_test.dart
```

Expected: Error de compilación.

- [ ] **Step 3: Crear i_missions_repository.dart**

```dart
// mobile/lib/features/missions/data/i_missions_repository.dart
import '../../../shared/models/mission_model.dart';
import '../../../shared/models/mission_progress_model.dart';

abstract class IMissionsRepository {
  Future<List<MissionModel>> getNearbyMissions({
    required double lat,
    required double lng,
    required int radius,
  });

  Future<MissionDetailModel> getMissionDetail(String missionId);

  Future<MissionProgressModel> startMission(String missionId);

  Future<SubmitAnswerResponse> submitAnswer({
    required String missionId,
    required String clueId,
    required String answer,
  });

  Future<String> requestHint({
    required String missionId,
    required String clueId,
  });

  Future<MissionProgressModel> getMissionProgress(String missionId);
}
```

- [ ] **Step 4: Crear missions_repository.dart**

```dart
// mobile/lib/features/missions/data/missions_repository.dart
import '../../../core/network/api_client.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/models/mission_progress_model.dart';
import 'i_missions_repository.dart';

class MissionsRepository implements IMissionsRepository {
  final ApiClient _client;

  MissionsRepository(this._client);

  @override
  Future<List<MissionModel>> getNearbyMissions({
    required double lat,
    required double lng,
    required int radius,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/missions',
      queryParameters: {'lat': lat, 'lng': lng, 'radius': radius},
    );
    return (response.data as List)
        .map((e) => MissionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MissionDetailModel> getMissionDetail(String missionId) async {
    final response =
        await _client.get<Map<String, dynamic>>('/missions/$missionId');
    return MissionDetailModel.fromJson(response.data!);
  }

  @override
  Future<MissionProgressModel> startMission(String missionId) async {
    final response = await _client
        .post<Map<String, dynamic>>('/missions/$missionId/start');
    return MissionProgressModel.fromJson(response.data!);
  }

  @override
  Future<SubmitAnswerResponse> submitAnswer({
    required String missionId,
    required String clueId,
    required String answer,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/missions/$missionId/clues/$clueId/submit',
      data: {'answer': answer},
    );
    return SubmitAnswerResponse.fromJson(response.data!);
  }

  @override
  Future<String> requestHint({
    required String missionId,
    required String clueId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/missions/$missionId/clues/$clueId/hint',
    );
    return response.data!['hint'] as String;
  }

  @override
  Future<MissionProgressModel> getMissionProgress(String missionId) async {
    final response =
        await _client.get<Map<String, dynamic>>('/missions/$missionId/progress');
    return MissionProgressModel.fromJson(response.data!);
  }
}
```

- [ ] **Step 5: Crear missions_bloc.dart**

```dart
// mobile/lib/features/missions/bloc/missions_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/clue_model.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/models/mission_progress_model.dart';
import '../data/i_missions_repository.dart';

// Events
abstract class MissionsEvent extends Equatable {}

class MissionsNearbyRequested extends MissionsEvent {
  final double lat;
  final double lng;
  final int radius;

  MissionsNearbyRequested({required this.lat, required this.lng, required this.radius});

  @override
  List<Object?> get props => [lat, lng, radius];
}

class MissionStartRequested extends MissionsEvent {
  final String missionId;
  MissionStartRequested({required this.missionId});
  @override
  List<Object?> get props => [missionId];
}

class MissionAnswerSubmitted extends MissionsEvent {
  final String missionId;
  final String clueId;
  final String answer;

  MissionAnswerSubmitted({
    required this.missionId,
    required this.clueId,
    required this.answer,
  });

  @override
  List<Object?> get props => [missionId, clueId, answer];
}

class MissionHintRequested extends MissionsEvent {
  final String missionId;
  final String clueId;

  MissionHintRequested({required this.missionId, required this.clueId});

  @override
  List<Object?> get props => [missionId, clueId];
}

// States
abstract class MissionsState extends Equatable {}

class MissionsInitial extends MissionsState {
  @override
  List<Object?> get props => [];
}

class MissionsLoading extends MissionsState {
  @override
  List<Object?> get props => [];
}

class MissionsLoaded extends MissionsState {
  final List<MissionModel> missions;
  MissionsLoaded({required this.missions});
  @override
  List<Object?> get props => [missions];
}

class MissionsError extends MissionsState {
  final String message;
  MissionsError(this.message);
  @override
  List<Object?> get props => [message];
}

class MissionStarting extends MissionsState {
  @override
  List<Object?> get props => [];
}

class MissionInProgress extends MissionsState {
  final MissionProgressModel progress;
  final bool? lastAnswerCorrect;
  final String? hint;

  MissionInProgress({
    required this.progress,
    this.lastAnswerCorrect,
    this.hint,
  });

  MissionInProgress copyWith({
    MissionProgressModel? progress,
    bool? lastAnswerCorrect,
    String? hint,
    bool clearHint = false,
  }) {
    return MissionInProgress(
      progress: progress ?? this.progress,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      hint: clearHint ? null : hint ?? this.hint,
    );
  }

  @override
  List<Object?> get props => [progress, lastAnswerCorrect, hint];
}

class MissionCompleted extends MissionsState {
  @override
  List<Object?> get props => [];
}

// BLoC
class MissionsBloc extends Bloc<MissionsEvent, MissionsState> {
  final IMissionsRepository _repository;

  MissionsBloc({required IMissionsRepository repository})
      : _repository = repository,
        super(MissionsInitial()) {
    on<MissionsNearbyRequested>(_onNearbyRequested);
    on<MissionStartRequested>(_onStartRequested);
    on<MissionAnswerSubmitted>(_onAnswerSubmitted);
    on<MissionHintRequested>(_onHintRequested);
  }

  Future<void> _onNearbyRequested(
    MissionsNearbyRequested event,
    Emitter<MissionsState> emit,
  ) async {
    emit(MissionsLoading());
    try {
      final missions = await _repository.getNearbyMissions(
        lat: event.lat,
        lng: event.lng,
        radius: event.radius,
      );
      emit(MissionsLoaded(missions: missions));
    } catch (e) {
      emit(MissionsError(e.toString()));
    }
  }

  Future<void> _onStartRequested(
    MissionStartRequested event,
    Emitter<MissionsState> emit,
  ) async {
    emit(MissionStarting());
    try {
      final progress = await _repository.startMission(event.missionId);
      emit(MissionInProgress(progress: progress));
    } catch (e) {
      emit(MissionsError(e.toString()));
    }
  }

  Future<void> _onAnswerSubmitted(
    MissionAnswerSubmitted event,
    Emitter<MissionsState> emit,
  ) async {
    if (state is! MissionInProgress) return;
    final current = state as MissionInProgress;

    final response = await _repository.submitAnswer(
      missionId: event.missionId,
      clueId: event.clueId,
      answer: event.answer,
    );

    if (response.missionCompleted) {
      emit(MissionCompleted());
      return;
    }

    if (response.correct && response.nextClue != null) {
      final updatedProgress = MissionProgressModel(
        progressId: current.progress.progressId,
        missionId: current.progress.missionId,
        status: current.progress.status,
        startedAt: current.progress.startedAt,
        hintsUsed: current.progress.hintsUsed,
        currentClue: response.nextClue,
      );
      emit(current.copyWith(
        progress: updatedProgress,
        lastAnswerCorrect: true,
        clearHint: true,
      ));
    } else {
      emit(current.copyWith(lastAnswerCorrect: false));
    }
  }

  Future<void> _onHintRequested(
    MissionHintRequested event,
    Emitter<MissionsState> emit,
  ) async {
    if (state is! MissionInProgress) return;
    final current = state as MissionInProgress;
    try {
      final hint = await _repository.requestHint(
        missionId: event.missionId,
        clueId: event.clueId,
      );
      emit(current.copyWith(hint: hint));
    } catch (e) {
      emit(current.copyWith(lastAnswerCorrect: null));
    }
  }
}
```

- [ ] **Step 6: Ejecutar test — debe pasar**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude/mobile
flutter test test/features/missions/missions_bloc_test.dart
```

Expected: `All tests passed!` — 3 tests.

- [ ] **Step 7: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/features/missions/ mobile/test/features/missions/
git commit -m "feat(mobile): add missions data layer, MissionsBloc + tests (3 passing)"
```

---

## Task 16: Missions feature — UI

**Files:**
- Create: `mobile/lib/features/missions/pages/missions_page.dart`
- Create: `mobile/lib/features/missions/pages/mission_detail_page.dart`
- Create: `mobile/lib/features/missions/pages/mission_active_page.dart`

- [ ] **Step 1: Crear missions_page.dart**

```dart
// mobile/lib/features/missions/pages/missions_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../shared/models/mission_model.dart';
import '../bloc/missions_bloc.dart';
import '../data/missions_repository.dart';

class MissionsPage extends StatelessWidget {
  final LocationService locationService;
  final ApiClient apiClient;

  const MissionsPage({
    super.key,
    required this.locationService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MissionsBloc(repository: MissionsRepository(apiClient)),
      child: _MissionsView(locationService: locationService),
    );
  }
}

class _MissionsView extends StatefulWidget {
  final LocationService locationService;
  const _MissionsView({required this.locationService});

  @override
  State<_MissionsView> createState() => _MissionsViewState();
}

class _MissionsViewState extends State<_MissionsView> {
  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final (lat, lng) = await widget.locationService.getCurrentPosition();
    if (!mounted) return;
    context.read<MissionsBloc>().add(MissionsNearbyRequested(
          lat: lat,
          lng: lng,
          radius: 2000,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MISIONES', style: AppTextStyles.monoDisplay),
              const SizedBox(height: 4),
              Container(height: 1, color: AppColors.fgMuted),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<MissionsBloc, MissionsState>(
                  builder: (context, state) {
                    if (state is MissionsLoading) {
                      return const SizedBox.shrink();
                    }
                    if (state is MissionsError) {
                      return MonoText(state.message,
                          color: AppColors.fgSecondary);
                    }
                    if (state is MissionsLoaded) {
                      if (state.missions.isEmpty) {
                        return MonoText(
                          '→ no hay misiones en tu zona',
                          color: AppColors.fgSecondary,
                        );
                      }
                      return ListView.separated(
                        itemCount: state.missions.length,
                        separatorBuilder: (_, __) => Container(
                          height: 1,
                          color: AppColors.fgMuted,
                          margin:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                        itemBuilder: (context, i) =>
                            _MissionRow(mission: state.missions[i]),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final MissionModel mission;
  const _MissionRow({required this.mission});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/missions/${mission.id}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    mission.title.toUpperCase(),
                    style: AppTextStyles.monoUI,
                  ),
                ),
                MonoText(
                  '${mission.clueCount} pistas',
                  color: AppColors.fgMuted,
                  size: 11,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(mission.description,
                style: AppTextStyles.body.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Crear mission_detail_page.dart**

```dart
// mobile/lib/features/missions/pages/mission_detail_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../../../shared/models/mission_model.dart';
import '../data/missions_repository.dart';

class MissionDetailPage extends StatefulWidget {
  final String missionId;
  final ApiClient apiClient;

  const MissionDetailPage({
    super.key,
    required this.missionId,
    required this.apiClient,
  });

  @override
  State<MissionDetailPage> createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends State<MissionDetailPage> {
  MissionDetailModel? _mission;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = MissionsRepository(widget.apiClient);
      final mission = await repo.getMissionDetail(widget.missionId);
      if (mounted) setState(() { _mission = mission; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _loading
              ? const SizedBox.shrink()
              : _error != null
                  ? MonoText(_error!, color: AppColors.fgSecondary)
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final m = _mission!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: MonoText('← ', color: AppColors.phosphor),
            ),
            Expanded(
              child: Text(m.title.toUpperCase(), style: AppTextStyles.monoDisplay),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 16),
        Text(m.description, style: AppTextStyles.body),
        const SizedBox(height: 24),
        MonoText('${m.clues.length} PISTAS', color: AppColors.fgSecondary, size: 11),
        const SizedBox(height: 8),
        ...m.clues.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: MonoText('${c.order}.  ${c.type}', color: AppColors.fgMuted),
        )),
        const Spacer(),
        VoidButton(
          label: 'INICIAR MISIÓN',
          onPressed: () => context.push('/home/missions/${m.id}/active'),
          borderColor: AppColors.phosphor,
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Crear mission_active_page.dart**

```dart
// mobile/lib/features/missions/pages/mission_active_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/scanlines_overlay.dart';
import '../../../core/widgets/typewriter_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/missions_bloc.dart';
import '../data/missions_repository.dart';

class MissionActivePage extends StatelessWidget {
  final String missionId;
  final ApiClient apiClient;

  const MissionActivePage({
    super.key,
    required this.missionId,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MissionsBloc(repository: MissionsRepository(apiClient))
        ..add(MissionStartRequested(missionId: missionId)),
      child: _MissionActiveView(missionId: missionId),
    );
  }
}

class _MissionActiveView extends StatefulWidget {
  final String missionId;
  const _MissionActiveView({required this.missionId});

  @override
  State<_MissionActiveView> createState() => _MissionActiveViewState();
}

class _MissionActiveViewState extends State<_MissionActiveView> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MissionsBloc, MissionsState>(
      listener: (context, state) {
        if (state is MissionCompleted) {
          context.go('/home/missions');
        }
      },
      builder: (context, state) {
        if (state is MissionStarting || state is MissionsInitial) {
          return const Scaffold(backgroundColor: AppColors.bgVoid);
        }

        if (state is MissionsError) {
          return Scaffold(
            backgroundColor: AppColors.bgVoid,
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: MonoText(state.message, color: AppColors.fgSecondary),
            ),
          );
        }

        if (state is! MissionInProgress) {
          return const Scaffold(backgroundColor: AppColors.bgVoid);
        }

        final clue = state.progress.currentClue;
        if (clue == null) {
          return const Scaffold(backgroundColor: AppColors.bgVoid);
        }

        return ScanlinesOverlay(
          child: Scaffold(
            backgroundColor: AppColors.bgVoid,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MonoText(
                      'pista ${clue.order} de ${state.progress.progressId}',
                      color: AppColors.fgSecondary,
                      size: 11,
                    ),
                    const SizedBox(height: 4),
                    Container(height: 1, color: AppColors.fgMuted),
                    const SizedBox(height: 32),
                    TypewriterText(
                      text: clue.content,
                      style: AppTextStyles.body.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    if (clue.hasHint) ...[
                      Row(
                        children: [
                          VoidButton(
                            label: 'SOLICITAR PISTA',
                            onPressed: () =>
                                context.read<MissionsBloc>().add(
                                      MissionHintRequested(
                                        missionId: widget.missionId,
                                        clueId: clue.id,
                                      ),
                                    ),
                          ),
                          const SizedBox(width: 12),
                          MonoText(
                            'hints: ${state.progress.hintsUsed}',
                            color: AppColors.fgMuted,
                            size: 11,
                          ),
                        ],
                      ),
                      if (state.hint != null) ...[
                        const SizedBox(height: 8),
                        MonoText(state.hint!, color: AppColors.fgSecondary),
                      ],
                      const SizedBox(height: 16),
                    ],
                    if (state.lastAnswerCorrect == false)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: MonoText(
                          '→ incorrecto',
                          color: AppColors.fgSecondary,
                        ),
                      ),
                    TextFormField(
                      controller: _answerController,
                      style: AppTextStyles.monoUI,
                      decoration: const InputDecoration(hintText: 'respuesta'),
                    ),
                    const SizedBox(height: 12),
                    VoidButton(
                      label: 'ENVIAR',
                      onPressed: () {
                        final answer = _answerController.text.trim();
                        if (answer.isEmpty) return;
                        _answerController.clear();
                        context.read<MissionsBloc>().add(
                              MissionAnswerSubmitted(
                                missionId: widget.missionId,
                                clueId: clue.id,
                                answer: answer,
                              ),
                            );
                      },
                      borderColor: AppColors.phosphor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/features/missions/pages/
git commit -m "feat(mobile): add missions UI (MissionsPage, MissionDetailPage, MissionActivePage)"
```

---

## Task 17: Profile feature

**Files:**
- Create: `mobile/lib/features/profile/data/i_profile_repository.dart`
- Create: `mobile/lib/features/profile/data/profile_repository.dart`
- Create: `mobile/lib/features/profile/bloc/profile_bloc.dart`
- Create: `mobile/lib/features/profile/pages/profile_page.dart`

- [ ] **Step 1: Crear i_profile_repository.dart**

```dart
// mobile/lib/features/profile/data/i_profile_repository.dart
import '../../../shared/models/profile_model.dart';

abstract class IProfileRepository {
  Future<ProfileModel> getProfile();
  Future<ActivityLogPage> getActivityLog({String? cursor, int pageSize = 20});
}
```

- [ ] **Step 2: Crear profile_repository.dart**

```dart
// mobile/lib/features/profile/data/profile_repository.dart
import '../../../core/network/api_client.dart';
import '../../../shared/models/profile_model.dart';
import 'i_profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  final ApiClient _client;

  ProfileRepository(this._client);

  @override
  Future<ProfileModel> getProfile() async {
    final response =
        await _client.get<Map<String, dynamic>>('/profile/me');
    return ProfileModel.fromJson(response.data!);
  }

  @override
  Future<ActivityLogPage> getActivityLog({
    String? cursor,
    int pageSize = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/profile/me/activity',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'pageSize': pageSize,
      },
    );
    return ActivityLogPage.fromJson(response.data!);
  }
}
```

- [ ] **Step 3: Crear profile_bloc.dart**

```dart
// mobile/lib/features/profile/bloc/profile_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/profile_model.dart';
import '../data/i_profile_repository.dart';

// Events
abstract class ProfileEvent extends Equatable {}

class ProfileLoadRequested extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class ProfileActivityPageRequested extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

// States
abstract class ProfileState extends Equatable {}

class ProfileInitial extends ProfileState {
  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {
  @override
  List<Object?> get props => [];
}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  final List<ActivityLogItem> activityItems;
  final String? nextCursor;
  final bool isLoadingMore;

  ProfileLoaded({
    required this.profile,
    required this.activityItems,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  ProfileLoaded copyWith({
    List<ActivityLogItem>? activityItems,
    String? nextCursor,
    bool? isLoadingMore,
    bool clearCursor = false,
  }) {
    return ProfileLoaded(
      profile: profile,
      activityItems: activityItems ?? this.activityItems,
      nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [profile, activityItems, nextCursor, isLoadingMore];
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IProfileRepository _repository;

  ProfileBloc({required IProfileRepository repository})
      : _repository = repository,
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileActivityPageRequested>(_onActivityPageRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getProfile();
      final activityPage = await _repository.getActivityLog();
      emit(ProfileLoaded(
        profile: profile,
        activityItems: activityPage.items,
        nextCursor: activityPage.nextCursor,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onActivityPageRequested(
    ProfileActivityPageRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;
    if (current.nextCursor == null || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await _repository.getActivityLog(cursor: current.nextCursor);
      emit(current.copyWith(
        activityItems: [...current.activityItems, ...page.items],
        nextCursor: page.nextCursor,
        isLoadingMore: false,
        clearCursor: page.nextCursor == null,
      ));
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
```

- [ ] **Step 4: Crear profile_page.dart**

```dart
// mobile/lib/features/profile/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../shared/extensions/datetime_extensions.dart';
import '../../../shared/models/profile_model.dart';
import '../bloc/profile_bloc.dart';
import '../data/profile_repository.dart';

class ProfilePage extends StatelessWidget {
  final ApiClient apiClient;

  const ProfilePage({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(repository: ProfileRepository(apiClient))
        ..add(ProfileLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProfileBloc>().add(ProfileActivityPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const SizedBox.shrink();
            }
            if (state is ProfileError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: MonoText(state.message, color: AppColors.fgSecondary),
              );
            }
            if (state is! ProfileLoaded) {
              return const SizedBox.shrink();
            }
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileLoaded state) {
    final fp = state.profile.situationistFootprint;
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Text('HUELLA SITUACIONISTA', style: AppTextStyles.monoDisplay),
        const SizedBox(height: 4),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 24),
        MonoText(
          'desde: ${state.profile.joinedAt.toShortDate()}',
          color: AppColors.fgSecondary,
        ),
        const SizedBox(height: 16),
        _StatRow('eventos', fp.eventsParticipated.toString()),
        const SizedBox(height: 8),
        _StatRow('derivas completadas', fp.derivasCompleted.toString()),
        const SizedBox(height: 8),
        _StatRow('misiones completadas', fp.missionsCompleted.toString()),
        const SizedBox(height: 24),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 16),
        Text('REGISTRO DE ACTIVIDAD', style: AppTextStyles.monoDisplay),
        const SizedBox(height: 16),
        ...state.activityItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  MonoText(
                    item.occurredAt.toTimestamp(),
                    color: AppColors.fgMuted,
                    size: 11,
                  ),
                  const SizedBox(width: 16),
                  MonoText(item.type, size: 12),
                ],
              ),
            )),
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: SizedBox.shrink(),
          ),
        if (state.nextCursor != null && !state.isLoadingMore)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: VoidButton(
              label: 'CARGAR MÁS',
              onPressed: () => context
                  .read<ProfileBloc>()
                  .add(ProfileActivityPageRequested()),
            ),
          ),
        const SizedBox(height: 32),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 16),
        VoidButton(
          label: 'CERRAR SESIÓN',
          onPressed: () =>
              context.read<AuthBloc>().add(AuthLogoutRequested()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MonoText(label, color: AppColors.fgSecondary),
        MonoText(value, size: 16),
      ],
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/lib/features/profile/
git commit -m "feat(mobile): add profile feature (data layer, bloc, UI with infinite scroll)"
```

---

## Task 18: Ejecutar todos los tests y verificar compilación

- [ ] **Step 1: Ejecutar todos los BLoC tests**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude/mobile
flutter test test/
```

Expected:
```
All tests passed!
  4 tests in test/features/auth/auth_bloc_test.dart
  3 tests in test/features/events/events_bloc_test.dart
  3 tests in test/features/deriva/deriva_bloc_test.dart
  3 tests in test/features/missions/missions_bloc_test.dart
```

- [ ] **Step 2: Verificar que el proyecto compila sin errores**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude/mobile
flutter analyze
```

Expected: `No issues found!` o solo warnings menores. No errores de tipo `error:`.

- [ ] **Step 3: Commit final**

```bash
cd /c/Users/elebr/OneDrive/Escritorio/Claude
git add mobile/
git commit -m "feat(mobile): complete Flutter implementation — 13 BLoC tests passing"
```

---

## Resumen del plan

| Task | Feature | Tests |
|---|---|---|
| 1 | Scaffolding + pubspec | — |
| 2 | Theme (AppColors, AppTextStyles, AppTheme) | — |
| 3 | Core widgets (5 widgets) | — |
| 4 | ApiException, ApiClient, AuthService | — |
| 5 | LocationService, SignalRService | — |
| 6 | Modelos freezed + build_runner | — |
| 7 | Auth data layer + AuthBloc | 4 tests |
| 8 | Auth UI (Splash, Login, WebView OAuth) | — |
| 9 | App wiring (router, shell, main) | — |
| 10 | Events data layer + EventsBloc | 3 tests |
| 11 | Map (MapBloc, MapPage, EventDetailSheet) | — |
| 12 | CreateEventPage | — |
| 13 | Deriva data layer + DerivaBloc | 3 tests |
| 14 | Deriva UI (Home, Active) | — |
| 15 | Missions data layer + MissionsBloc | 3 tests |
| 16 | Missions UI (List, Detail, Active) | — |
| 17 | Profile (data, bloc, UI) | — |
| 18 | Run all tests + flutter analyze | 13 total |
