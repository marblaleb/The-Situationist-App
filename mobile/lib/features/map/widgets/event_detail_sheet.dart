import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../../../features/events/bloc/events_bloc.dart';
import '../../../shared/extensions/datetime_extensions.dart';
import '../../../shared/models/event_model.dart';

class EventDetailSheet extends StatelessWidget {
  final EventModel event;
  final VoidCallback onDismiss;

  const EventDetailSheet({
    super.key,
    required this.event,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon = event.expiresAt.isExpiringSoon();
    final borderColor = isExpiringSoon ? AppColors.amber : AppColors.fgMuted;
    final statusColor =
        event.status == 'Active' ? AppColors.phosphor : AppColors.fgSecondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            border: Border(top: BorderSide(color: borderColor, width: 1)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                    width: 40, height: 2, color: AppColors.fgMuted),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.title.toUpperCase(),
                      style: AppTextStyles.monoDisplay.copyWith(fontSize: 14),
                    ),
                  ),
                  Row(
                    children: [
                      _BlinkDot(color: statusColor),
                      const SizedBox(width: 6),
                      MonoText(
                        event.status.toUpperCase(),
                        color: statusColor,
                        size: 11,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 1, color: AppColors.fgMuted),
              const SizedBox(height: 12),
              MonoText(
                '${event.actionType} · ${event.interventionLevel} · hasta ${event.expiresAt.toTimeOnly()}',
                color: AppColors.fgSecondary,
                size: 11,
              ),
              const SizedBox(height: 16),
              Text(event.description, style: AppTextStyles.body),
              const SizedBox(height: 16),
              () {
                final current =
                    event.participantCount.toString().padLeft(2, '0');
                final max = event.maxParticipants != null
                    ? ' / ${event.maxParticipants.toString().padLeft(2, '0')}'
                    : '';
                return MonoText(
                  'participantes: $current$max',
                  color: AppColors.fgSecondary,
                );
              }(),
              const SizedBox(height: 16),
              Builder(builder: (context) {
                final isFull = event.status == 'Full';
                final isExpired =
                    event.expiresAt.isBefore(DateTime.now().toUtc());
                final disabled = isFull || isExpired;

                return Row(
                  children: [
                    Expanded(
                      child: VoidButton(
                        label: 'PARTICIPAR',
                        onPressed: disabled
                            ? null
                            : () => context.read<EventsBloc>().add(
                                  EventParticipateRequested(
                                    eventId: event.id,
                                    role: 'Participante',
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: VoidButton(
                        label: 'OBSERVAR',
                        onPressed: disabled
                            ? null
                            : () => context.read<EventsBloc>().add(
                                  EventParticipateRequested(
                                    eventId: event.id,
                                    role: 'Observador',
                                  ),
                                ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              BlocBuilder<EventsBloc, EventsState>(
                builder: (ctx, state) {
                  if (state is EventsError) {
                    return MonoText(state.message,
                        color: AppColors.fgSecondary);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BlinkDot extends StatefulWidget {
  final Color color;
  const _BlinkDot({required this.color});

  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: _controller.value,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
