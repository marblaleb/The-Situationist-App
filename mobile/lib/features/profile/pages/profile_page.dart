import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../shared/extensions/datetime_extensions.dart';
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
      child: _ProfileView(apiClient: apiClient),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final ApiClient apiClient;

  const _ProfileView({required this.apiClient});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _scrollController = ScrollController();
  final _usernameController = TextEditingController();
  Timer? _usernameDebounce;
  bool? _usernameAvailable;
  bool _usernameChecking = false;
  bool _usernameSaving = false;
  bool _loggingOut = false;
  String? _usernameError;

  static final _regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{2,19}$');
  bool get _usernameFormatValid => _regex.hasMatch(_usernameController.text.trim());
  bool get _canSaveUsername => _usernameFormatValid && _usernameAvailable == true && !_usernameSaving;

  @override
  void dispose() {
    _scrollController.dispose();
    _usernameController.dispose();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    if (!_usernameFormatValid) {
      setState(() {
        _usernameAvailable = null;
        _usernameChecking = false;
      });
      return;
    }
    setState(() {
      _usernameChecking = true;
      _usernameAvailable = null;
    });
    _usernameDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _checkUsernameAvailability(value.trim()),
    );
  }

  Future<void> _checkUsernameAvailability(String username) async {
    try {
      final response = await widget.apiClient.get<Map<String, dynamic>>(
        '/users/username-available',
        queryParameters: {'username': username},
      );
      if (mounted) {
        setState(() {
          _usernameAvailable = response.data?['available'] as bool? ?? false;
          _usernameChecking = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _usernameChecking = false;
          _usernameAvailable = null;
        });
      }
    }
  }

  Future<void> _saveUsername(BuildContext ctx) async {
    if (!_canSaveUsername) return;
    final authBloc = ctx.read<AuthBloc>();
    setState(() {
      _usernameSaving = true;
      _usernameError = null;
    });
    try {
      final response = await widget.apiClient.put<Map<String, dynamic>>(
        '/users/me/username',
        data: {'username': _usernameController.text.trim()},
      );
      final newToken = response.data?['accessToken'] as String?;
      if (newToken != null && mounted) {
        authBloc.add(AuthUsernameUpdated(token: newToken));
        setState(() {
          _usernameSaving = false;
          _usernameAvailable = null;
        });
        _usernameController.clear();
      }
    } on ApiException catch (e) {
      setState(() {
        _usernameError = e.message;
        _usernameSaving = false;
      });
    } catch (_) {
      setState(() {
        _usernameError = '→ error de conexión';
        _usernameSaving = false;
      });
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

        // ── Username section
        const SizedBox(height: 16),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 16),
        Builder(builder: (ctx) {
          final authState = ctx.watch<AuthBloc>().state;
          final currentUsername = authState is AuthAuthenticated ? authState.username : '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MonoText('@$currentUsername', size: 13),
                  const SizedBox(width: 8),
                  const MonoText('nombre de usuario', color: AppColors.fgSecondary, size: 10),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      onChanged: _onUsernameChanged,
                      style: const TextStyle(color: AppColors.fgPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'nuevo nombre...',
                        hintStyle: const TextStyle(color: AppColors.fgSecondary, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.bgElevated,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.fgMuted),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.phosphor),
                        ),
                        suffixIcon: _usernameChecking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.fgSecondary),
                                ),
                              )
                            : _usernameAvailable == true
                                ? const Icon(Icons.check, color: AppColors.phosphor, size: 16)
                                : _usernameAvailable == false
                                    ? const Icon(Icons.close, color: AppColors.danger, size: 16)
                                    : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _canSaveUsername ? () => _saveUsername(ctx) : null,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _canSaveUsername ? AppColors.phosphor : AppColors.fgMuted,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        color: _canSaveUsername ? AppColors.phosphor : AppColors.fgMuted,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              if (_usernameError != null) ...[
                const SizedBox(height: 6),
                MonoText(_usernameError!, color: AppColors.danger, size: 11),
              ],
              if (_usernameAvailable == false) ...[
                const SizedBox(height: 6),
                const MonoText('nombre en uso', color: AppColors.danger, size: 11),
              ],
            ],
          );
        }),

        const SizedBox(height: 16),
        _StatRow('eventos', fp.eventsParticipated.toString()),
        const SizedBox(height: 8),
        _StatRow('derivas completadas', fp.derivasCompleted.toString()),
        const SizedBox(height: 8),
        _StatRow('misiones completadas', fp.missionsCompleted.toString()),

        // ── Created events
        const SizedBox(height: 24),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 16),
        Text('EVENTOS CREADOS', style: AppTextStyles.monoDisplay),
        const SizedBox(height: 12),
        if (state.createdEvents.isEmpty)
          const MonoText('ninguno', color: AppColors.fgMuted, size: 12)
        else
          ...state.createdEvents.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ContentCard(
                  title: e.title,
                  subtitle: '${e.actionType} · ${e.status}',
                ),
              )),

        // ── Created missions
        const SizedBox(height: 24),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 16),
        Text('MISIONES CREADAS', style: AppTextStyles.monoDisplay),
        const SizedBox(height: 12),
        if (state.createdMissions.isEmpty)
          const MonoText('ninguna', color: AppColors.fgMuted, size: 12)
        else
          ...state.createdMissions.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ContentCard(
                  title: m.title,
                  subtitle: '${m.clueCount} pistas · ${m.status}',
                ),
              )),

        const SizedBox(height: 32),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 16),
        VoidButton(
          label: _loggingOut ? '...' : 'CERRAR SESIÓN',
          onPressed: _loggingOut
              ? null
              : () {
                  setState(() => _loggingOut = true);
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
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

class _ContentCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ContentCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.fgMuted, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoText(title.toUpperCase(), size: 12),
          const SizedBox(height: 4),
          MonoText(subtitle, color: AppColors.fgSecondary, size: 10),
        ],
      ),
    );
  }
}
