import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

        // ── Created events
        const SizedBox(height: 24),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 16),
        Text('EVENTOS CREADOS', style: AppTextStyles.monoDisplay),
        const SizedBox(height: 12),
        if (state.createdEvents.isEmpty)
          MonoText('ninguno', color: AppColors.fgMuted, size: 12)
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
          MonoText('ninguna', color: AppColors.fgMuted, size: 12)
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
