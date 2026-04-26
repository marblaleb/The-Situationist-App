import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';

String? authGuard(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthBloc>().state;

  final isLoginRoute = state.matchedLocation == '/login';
  final isSplashRoute = state.matchedLocation == '/';
  final isCallbackRoute = state.matchedLocation == '/auth-callback';
  final isUsernameSetupRoute = state.matchedLocation == '/username-setup';

  if (authState is AuthAuthenticated) {
    if (isLoginRoute || isSplashRoute) {
      return authState.username.isEmpty ? '/username-setup' : '/home/map';
    }
    if (authState.username.isEmpty && !isUsernameSetupRoute) {
      return '/username-setup';
    }
    return null;
  }

  if (authState is AuthUnauthenticated) {
    if (!isLoginRoute && !isCallbackRoute) return '/login';
    return null;
  }

  // AuthLoading, AuthInitial → stay on splash
  if (!isSplashRoute && !isLoginRoute && !isCallbackRoute) return '/';
  return null;
}
