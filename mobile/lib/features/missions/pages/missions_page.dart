import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../shared/models/mission_model.dart';
import '../bloc/missions_bloc.dart';
import '../data/missions_repository.dart';

class MissionsPage extends StatelessWidget {
  final LocationService locationService;
  final ApiClient apiClient;

  const MissionsPage({
    super.key,
    required this.locationService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MissionsBloc(repository: MissionsRepository(apiClient)),
      child: _MissionsView(locationService: locationService),
    );
  }
}

class _MissionsView extends StatefulWidget {
  final LocationService locationService;
  const _MissionsView({required this.locationService});

  @override
  State<_MissionsView> createState() => _MissionsViewState();
}

class _MissionsViewState extends State<_MissionsView> {
  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final (lat, lng) = await widget.locationService.getCurrentPosition();
    if (!mounted) return;
    context.read<MissionsBloc>().add(MissionsNearbyRequested(
          lat: lat,
          lng: lng,
          radius: 2000,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MISIONES', style: AppTextStyles.monoDisplay),
              const SizedBox(height: 4),
              Container(height: 1, color: AppColors.fgMuted),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<MissionsBloc, MissionsState>(
                  builder: (context, state) {
                    if (state is MissionsLoading) {
                      return const SizedBox.shrink();
                    }
                    if (state is MissionsError) {
                      return MonoText(state.message,
                          color: AppColors.fgSecondary);
                    }
                    if (state is MissionsLoaded) {
                      if (state.missions.isEmpty) {
                        return MonoText(
                          '→ no hay misiones en tu zona',
                          color: AppColors.fgSecondary,
                        );
                      }
                      return ListView.separated(
                        itemCount: state.missions.length,
                        separatorBuilder: (_, __) => Container(
                          height: 1,
                          color: AppColors.fgMuted,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        itemBuilder: (context, i) =>
                            _MissionRow(mission: state.missions[i]),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final MissionModel mission;
  const _MissionRow({required this.mission});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/missions/${mission.id}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    mission.title.toUpperCase(),
                    style: AppTextStyles.monoUI,
                  ),
                ),
                MonoText(
                  '${mission.clueCount} pistas',
                  color: AppColors.fgMuted,
                  size: 11,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(mission.description,
                style: AppTextStyles.body.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
