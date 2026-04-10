import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
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
        bloc.add(AuthLoginCompleted(token: '', userId: '', email: ''));
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
      ..loadRequest(Uri.parse('${ApiClient.baseUrl}/auth/login/google'));
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
                    child: MonoText(
                      '⊗',
                      color: AppColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.fgMuted),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
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
