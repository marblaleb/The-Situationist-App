import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/scanlines_overlay.dart';
import '../../../core/widgets/typewriter_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/missions_bloc.dart';
import '../data/missions_repository.dart';

class MissionActivePage extends StatelessWidget {
  final String missionId;
  final ApiClient apiClient;

  const MissionActivePage({
    super.key,
    required this.missionId,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MissionsBloc(repository: MissionsRepository(apiClient))
        ..add(MissionStartRequested(missionId: missionId)),
      child: _MissionActiveView(missionId: missionId),
    );
  }
}

class _MissionActiveView extends StatefulWidget {
  final String missionId;
  const _MissionActiveView({required this.missionId});

  @override
  State<_MissionActiveView> createState() => _MissionActiveViewState();
}

class _MissionActiveViewState extends State<_MissionActiveView> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MissionsBloc, MissionsState>(
      listener: (context, state) {
        if (state is MissionCompleted) {
          context.go('/home/missions');
        }
      },
      builder: (context, state) {
        if (state is MissionStarting || state is MissionsInitial) {
          return const Scaffold(backgroundColor: AppColors.bgVoid);
        }

        if (state is MissionsError) {
          return Scaffold(
            backgroundColor: AppColors.bgVoid,
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: MonoText(state.message, color: AppColors.fgSecondary),
            ),
          );
        }

        if (state is! MissionInProgress) {
          return const Scaffold(backgroundColor: AppColors.bgVoid);
        }

        final clue = state.progress.currentClue;
        if (clue == null) {
          return const Scaffold(backgroundColor: AppColors.bgVoid);
        }

        return ScanlinesOverlay(
          child: Scaffold(
            backgroundColor: AppColors.bgVoid,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home/missions'),
                      child: const Text(
                        '← VOLVER',
                        style: TextStyle(
                          color: AppColors.fgMuted,
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    MonoText(
                      'pista ${clue.order}',
                      color: AppColors.fgSecondary,
                      size: 11,
                    ),
                    const SizedBox(height: 4),
                    Container(height: 1, color: AppColors.fgMuted),
                    const SizedBox(height: 32),
                    TypewriterText(
                      text: clue.content,
                      style: AppTextStyles.body.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    if (clue.hasHint) ...[
                      Row(
                        children: [
                          VoidButton(
                            label: 'SOLICITAR PISTA',
                            onPressed: () =>
                                context.read<MissionsBloc>().add(
                                      MissionHintRequested(
                                        missionId: widget.missionId,
                                        clueId: clue.id,
                                      ),
                                    ),
                          ),
                          const SizedBox(width: 12),
                          MonoText(
                            'hints: ${state.progress.hintsUsed}',
                            color: AppColors.fgMuted,
                            size: 11,
                          ),
                        ],
                      ),
                      if (state.hint != null) ...[
                        const SizedBox(height: 8),
                        MonoText(state.hint!, color: AppColors.fgSecondary),
                      ],
                      const SizedBox(height: 16),
                    ],
                    if (state.lastAnswerCorrect == false)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: MonoText(
                          '→ incorrecto',
                          color: AppColors.fgSecondary,
                        ),
                      ),
                    TextFormField(
                      controller: _answerController,
                      style: AppTextStyles.monoUI,
                      decoration: const InputDecoration(hintText: 'respuesta'),
                    ),
                    const SizedBox(height: 12),
                    VoidButton(
                      label: 'ENVIAR',
                      onPressed: () {
                        final answer = _answerController.text.trim();
                        if (answer.isEmpty) return;
                        _answerController.clear();
                        context.read<MissionsBloc>().add(
                              MissionAnswerSubmitted(
                                missionId: widget.missionId,
                                clueId: clue.id,
                                answer: answer,
                              ),
                            );
                      },
                      borderColor: AppColors.phosphor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
