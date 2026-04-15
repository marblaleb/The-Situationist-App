import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../shared/models/event_model.dart';
import '../models/event_cluster.dart';

class ClusterListSheet extends StatelessWidget {
  final EventCluster cluster;
  final ValueChanged<EventModel> onEventSelected;
  final VoidCallback onDismiss;

  const ClusterListSheet({
    super.key,
    required this.cluster,
    required this.onEventSelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      builder: (_, scrollCtrl) => Container(
        color: AppColors.bgVoid,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(width: 32, height: 2, color: AppColors.fgMuted),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MonoText(
                    '${cluster.events.length} EVENTOS AQUÍ',
                    color: AppColors.fgSecondary,
                    size: 11,
                    letterSpacing: 2,
                  ),
                  GestureDetector(
                    onTap: onDismiss,
                    child: MonoText('✕', color: AppColors.fgMuted, size: 14),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: AppColors.fgMuted,
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: cluster.events.length,
                separatorBuilder: (_, __) => Container(height: 1, color: AppColors.fgMuted.withOpacity(0.3)),
                itemBuilder: (_, i) {
                  final event = cluster.events[i];
                  return _EventRow(event: event, onTap: () => onEventSelected(event));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const _EventRow({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpiring = event.expiresAt.difference(DateTime.now()).inMinutes < 10;
    final color = event.status == 'Full'
        ? AppColors.fgMuted
        : isExpiring
            ? AppColors.amber
            : AppColors.phosphor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonoText(event.title.toUpperCase(), size: 12),
                  const SizedBox(height: 3),
                  MonoText(
                    '${event.actionType} · ${event.interventionLevel}',
                    color: AppColors.fgSecondary,
                    size: 10,
                  ),
                ],
              ),
            ),
            MonoText('→', color: AppColors.fgMuted, size: 12),
          ],
        ),
      ),
    );
  }
}
