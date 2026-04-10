import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/scanlines_overlay.dart';
import '../../../core/widgets/typewriter_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/deriva_bloc.dart';
import '../data/deriva_repository.dart';

class DerivaActivePage extends StatelessWidget {
  final LocationService locationService;
  final ApiClient apiClient;

  const DerivaActivePage({
    super.key,
    required this.locationService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DerivaBloc(repository: DerivaRepository(apiClient)),
      child: _DerivaActiveView(locationService: locationService),
    );
  }
}

class _DerivaActiveView extends StatefulWidget {
  final LocationService locationService;
  const _DerivaActiveView({required this.locationService});

  @override
  State<_DerivaActiveView> createState() => _DerivaActiveViewState();
}

class _DerivaActiveViewState extends State<_DerivaActiveView>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _writingComplete = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0,
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DerivaBloc, DerivaState>(
      listener: (context, state) {
        if (state is DerivaIdle || state is DerivaCompleted) {
          context.go('/home/deriva');
        }
      },
      builder: (context, state) {
        if (state is! DerivaActive) {
          return const Scaffold(backgroundColor: AppColors.bgVoid);
        }

        return FadeTransition(
          opacity: _fadeController,
          child: ScanlinesOverlay(
            child: Scaffold(
              backgroundColor: AppColors.bgVoid,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: _LiveClock(),
                      ),
                      const Spacer(),
                      TypewriterText(
                        text: state.currentInstruction,
                        style: AppTextStyles.body.copyWith(fontSize: 16),
                        onComplete: () =>
                            setState(() => _writingComplete = true),
                      ),
                      const SizedBox(height: 40),
                      Container(height: 1, color: AppColors.fgMuted),
                      const SizedBox(height: 24),
                      VoidButton(
                        label: 'SIGUIENTE INSTRUCCIÓN',
                        onPressed: _writingComplete
                            ? () => _requestNext(context, state)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: VoidButton(
                              label: 'COMPLETAR',
                              onPressed: () => context
                                  .read<DerivaBloc>()
                                  .add(DerivaCompleteRequested()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: VoidButton(
                              label: 'ABANDONAR',
                              onPressed: () => context
                                  .read<DerivaBloc>()
                                  .add(DerivaAbandonRequested()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestNext(BuildContext context, DerivaActive state) async {
    setState(() => _writingComplete = false);
    final (lat, lng) = await widget.locationService.getCurrentPosition();
    if (!context.mounted) return;
    context.read<DerivaBloc>().add(DerivaNextInstructionRequested(
          lat: lat,
          lng: lng,
        ));
  }
}

class _LiveClock extends StatefulWidget {
  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late String _time;

  @override
  void initState() {
    super.initState();
    _updateTime();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return false;
      setState(_updateTime);
      return true;
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    _time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return MonoText(_time, color: AppColors.fgSecondary);
  }
}
