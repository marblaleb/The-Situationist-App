import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class AuthErrorOccurred extends AuthEvent {
  final String message;
  AuthErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}

/// Fired by AuthCallbackPage on web after Google OAuth redirect returns a token.
class AuthWebCallbackReceived extends AuthEvent {
  final String token;
  AuthWebCallbackReceived({required this.token});

  @override
  List<Object?> get props => [token];
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
    on<AuthWebCallbackReceived>(_onWebCallbackReceived);
    on<AuthErrorOccurred>((event, emit) => emit(AuthError(event.message)));
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

  Future<void> _onWebCallbackReceived(
    AuthWebCallbackReceived event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Save token first; saveSession implementation only uses the token field.
      await _repository.saveSession(token: event.token, userId: '', email: '');
      // Now decode userId/email from the saved token.
      final user = await _repository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(userId: user.userId, email: user.email));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
