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
        username: '',
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
