import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';

/// Handles the OAuth web redirect: reads ?token= from the URL and logs in.
class AuthCallbackPage extends StatefulWidget {
  final String? token;

  const AuthCallbackPage({super.key, this.token});

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleCallback());
  }

  void _handleCallback() {
    final token = widget.token;
    if (token == null || token.isEmpty) {
      context.go('/login');
      return;
    }

    // Decode JWT claims to extract userId and email
    final authService = context.read<AuthBloc>();
    authService.add(AuthWebCallbackReceived(token: token));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) context.go('/home/map');
        if (state is AuthUnauthenticated) context.go('/login');
      },
      child: Scaffold(
        backgroundColor: AppColors.bgVoid,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.phosphor),
        ),
      ),
    );
  }
}
