import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../../profile/data/profile_repository.dart';
import '../bloc/create_hub_bloc.dart';

class CreateHubPage extends StatelessWidget {
  final ApiClient apiClient;

  const CreateHubPage({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateHubBloc(repository: ProfileRepository(apiClient)),
      child: const _CreateHubView(),
    );
  }
}

class _CreateHubView extends StatelessWidget {
  const _CreateHubView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CREAR', style: AppTextStyles.monoDisplay),
              const SizedBox(height: 4),
              Container(height: 1, color: AppColors.fgMuted),
              const SizedBox(height: 32),
              BlocBuilder<CreateHubBloc, CreateHubState>(
                builder: (context, state) {
                  if (state is CreateHubLoading || state is CreateHubInitial) {
                    return const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: AppColors.fgMuted,
                        ),
                      ),
                    );
                  }

                  if (state is CreateHubError) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MonoText(
                          'error al cargar límites',
                          color: AppColors.danger,
                          size: 11,
                        ),
                        const SizedBox(height: 12),
                        VoidButton(
                          label: 'REINTENTAR',
                          onPressed: () => context
                              .read<CreateHubBloc>()
                              .add(CreateHubLimitsRequested()),
                        ),
                      ],
                    );
                  }

                  final limits = (state as CreateHubLoaded).limits;
                  final eventsLimited =
                      limits.eventsToday >= limits.dailyLimit;
                  final missionsLimited =
                      limits.missionsToday >= limits.dailyLimit;

                  return Column(
                    children: [
                      _HubOption(
                        symbol: '⊕',
                        title: 'NUEVO EVENTO',
                        subtitle: 'Intervención efímera en el espacio urbano',
                        limitReached: eventsLimited,
                        onTap: eventsLimited
                            ? null
                            : () => context.push('/home/create-event'),
                      ),
                      const SizedBox(height: 20),
                      _HubOption(
                        symbol: '◈',
                        title: 'NUEVA MISIÓN',
                        subtitle:
                            'Secuencia de pistas para explorar el territorio',
                        limitReached: missionsLimited,
                        onTap: missionsLimited
                            ? null
                            : () => context.push('/home/create-mission'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubOption extends StatelessWidget {
  final String symbol;
  final String title;
  final String subtitle;
  final bool limitReached;
  final VoidCallback? onTap;

  const _HubOption({
    required this.symbol,
    required this.title,
    required this.subtitle,
    required this.limitReached,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: limitReached ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.fgMuted, width: 1),
          ),
          child: Row(
            children: [
              Text(
                symbol,
                style: AppTextStyles.monoDisplay.copyWith(
                  fontSize: 28,
                  color: limitReached
                      ? AppColors.fgMuted
                      : AppColors.phosphor,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MonoText(title, size: 14, letterSpacing: 2),
                    const SizedBox(height: 4),
                    MonoText(subtitle,
                        color: AppColors.fgSecondary, size: 11),
                    if (limitReached) ...[
                      const SizedBox(height: 6),
                      MonoText(
                        'LÍMITE DIARIO ALCANZADO',
                        color: AppColors.danger,
                        size: 10,
                        letterSpacing: 1,
                      ),
                    ],
                  ],
                ),
              ),
              if (!limitReached)
                MonoText('→', color: AppColors.phosphor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
