import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/auth_bloc.dart';
import '_web_redirect_stub.dart'
    if (dart.library.html) '_web_redirect.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const _callbackScheme = 'app.situationist';
  static const _callbackHost = 'auth-callback';
  static const _mobileCallbackUrl = '$_callbackScheme://$_callbackHost';

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
              CustomPaint(
                size: const Size(120, 80),
                painter: _CityPainter(),
              ),
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
        ),
      ),
    );
  }

  Future<void> _startGoogleLogin(BuildContext context) async {
    if (kIsWeb) {
      final origin = getWebOrigin();
      final webCallback = Uri.encodeComponent('$origin/#/auth-callback');
      redirectBrowser(
          '${ApiClient.baseUrl}/auth/login/google?webCallback=$webCallback');
      return;
    }

    final bloc = context.read<AuthBloc>();

    try {
      // El backend encoda mobileCallbackUrl en state y redirige a
      // app.situationist://auth-callback?token=JWT tras el OAuth de Google.
      final mobileCallback = Uri.encodeComponent(_mobileCallbackUrl);
      final authUrl =
          '${ApiClient.baseUrl}/auth/login/google?webCallback=$mobileCallback';

      final resultUrl = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: _callbackScheme,
      );

      final token = Uri.parse(resultUrl).queryParameters['token'];
      if (token == null || token.isEmpty) {
        bloc.add(AuthErrorOccurred('No se recibió token de autenticación'));
        return;
      }

      if (!context.mounted) return;
      bloc.add(AuthWebCallbackReceived(token: token));
    } catch (e) {
      if (context.mounted) {
        bloc.add(AuthErrorOccurred('Error al autenticar: ${e.toString()}'));
      }
    }
  }
}

class _CityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.fgMuted
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

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

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CityPainter oldDelegate) => false;
}
