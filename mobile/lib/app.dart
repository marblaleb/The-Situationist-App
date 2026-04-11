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
import 'features/auth/pages/auth_callback_page.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/splash_page.dart';
import 'features/deriva/bloc/deriva_bloc.dart';
import 'features/deriva/data/deriva_repository.dart';
import 'features/deriva/pages/deriva_active_page.dart';
import 'features/deriva/pages/deriva_home_page.dart';
import 'features/events/pages/create_event_page.dart';
import 'features/events/pages/create_hub_page.dart';
import 'features/map/pages/map_page.dart';
import 'features/missions/pages/create_mission_page.dart';
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
  late final DerivaBloc _derivaBloc;
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
    _derivaBloc = DerivaBloc(repository: DerivaRepository(_apiClient));

    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
      redirect: authGuard,
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(
          path: '/auth-callback',
          builder: (_, state) => AuthCallbackPage(
            token: state.uri.queryParameters['token'],
          ),
        ),
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
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/home/create',
                builder: (_, __) => const CreateHubPage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/home/profile',
                builder: (_, __) => ProfilePage(apiClient: _apiClient),
              ),
            ]),
          ],
        ),
        GoRoute(
          path: '/home/events/:id',
          builder: (_, state) => MapPage(
            locationService: _locationService,
            signalRService: _signalRService,
            apiClient: _apiClient,
          ),
        ),
        GoRoute(
          path: '/home/deriva/active',
          builder: (_, __) => DerivaActivePage(
            locationService: _locationService,
            apiClient: _apiClient,
          ),
        ),
        GoRoute(
          path: '/home/create-event',
          builder: (_, __) => CreateEventPage(
            locationService: _locationService,
            apiClient: _apiClient,
          ),
        ),
        GoRoute(
          path: '/home/create-mission',
          builder: (_, __) => CreateMissionPage(
            locationService: _locationService,
            apiClient: _apiClient,
          ),
        ),
        GoRoute(
          path: '/home/missions/:id',
          builder: (_, state) => MissionDetailPage(
            missionId: state.pathParameters['id']!,
            apiClient: _apiClient,
          ),
        ),
        GoRoute(
          path: '/home/missions/:id/active',
          builder: (_, state) => MissionActivePage(
            missionId: state.pathParameters['id']!,
            apiClient: _apiClient,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    _derivaBloc.close();
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _derivaBloc),
        ],
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
        onTap: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}

class _VoidBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _VoidBottomNav({required this.currentIndex, required this.onTap});

  static const _icons = ['⌀', '↺', '◈', '⊕', '◉'];

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
                      Container(height: 2, color: AppColors.phosphor)
                    else
                      const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _icons[i],
                        style: AppTextStyles.monoDisplay.copyWith(
                          color:
                              isActive ? AppColors.phosphor : AppColors.fgMuted,
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
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.listen((_) => notifyListeners());
  }
}
