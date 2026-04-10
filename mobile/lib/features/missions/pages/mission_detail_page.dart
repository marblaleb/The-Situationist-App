import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../../../shared/models/mission_model.dart';
import '../data/missions_repository.dart';

class MissionDetailPage extends StatefulWidget {
  final String missionId;
  final ApiClient apiClient;

  const MissionDetailPage({
    super.key,
    required this.missionId,
    required this.apiClient,
  });

  @override
  State<MissionDetailPage> createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends State<MissionDetailPage> {
  MissionDetailModel? _mission;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = MissionsRepository(widget.apiClient);
      final mission = await repo.getMissionDetail(widget.missionId);
      if (mounted) setState(() { _mission = mission; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _loading
              ? const SizedBox.shrink()
              : _error != null
                  ? MonoText(_error!, color: AppColors.fgSecondary)
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final m = _mission!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: MonoText('← ', color: AppColors.phosphor),
            ),
            Expanded(
              child: Text(m.title.toUpperCase(), style: AppTextStyles.monoDisplay),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(height: 1, color: AppColors.fgMuted),
        const SizedBox(height: 16),
        Text(m.description, style: AppTextStyles.body),
        const SizedBox(height: 24),
        MonoText('${m.clues.length} PISTAS', color: AppColors.fgSecondary, size: 11),
        const SizedBox(height: 8),
        ...m.clues.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: MonoText('${c.order}.  ${c.type}', color: AppColors.fgMuted),
        )),
        const Spacer(),
        VoidButton(
          label: 'INICIAR MISIÓN',
          onPressed: () => context.push('/home/missions/${m.id}/active'),
          borderColor: AppColors.phosphor,
        ),
      ],
    );
  }
}
