import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';

String? authGuard(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthBloc>().state;

  final isLoginRoute = state.matchedLocation == '/login';
  final isSplashRoute = state.matchedLocation == '/';
  final isCallbackRoute = state.matchedLocation == '/auth-callback';

  if (authState is AuthAuthenticated) {
    if (isLoginRoute || isSplashRoute) return '/home/map';
    return null;
  }

  if (authState is AuthUnauthenticated) {
    if (!isLoginRoute && !isCallbackRoute) return '/login';
    return null;
  }

  // AuthLoading, AuthInitial → quedarse en splash (callback page handles itself)
  if (!isSplashRoute && !isLoginRoute && !isCallbackRoute) return '/';
  return null;
}
