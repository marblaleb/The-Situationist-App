import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/event_model.dart';
import '../bloc/create_event_bloc.dart';
import '../data/events_repository.dart';

class CreateEventPage extends StatelessWidget {
  final LocationService locationService;
  final ApiClient apiClient;

  const CreateEventPage({
    super.key,
    required this.locationService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateEventBloc(
        repository: EventsRepository(apiClient),
        locationService: locationService,
      ),
      child: const _CreateEventView(),
    );
  }
}

class _CreateEventView extends StatefulWidget {
  const _CreateEventView();

  @override
  State<_CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<_CreateEventView> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _actionType = 'Performativa';
  String _interventionLevel = 'Bajo';
  String _visibility = 'Public';
  int _durationMinutes = 60;
  LatLng? _pickedLocation;

  static const _actionTypes = ['Performativa', 'Social', 'Sensorial', 'Poetica'];
  static const _interventionLevels = ['Bajo', 'Medio', 'Alto'];
  static const _visibilities = ['Public', 'Unlisted'];
  static const _durations = [30, 60, 120, 240];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final result = await context.push<LatLng>('/home/location-picker');
    if (result != null && mounted) {
      setState(() => _pickedLocation = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateEventBloc, CreateEventState>(
      listener: (context, state) {
        if (state is CreateEventSuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgVoid,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
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
                  'NUEVO EVENTO',
                  color: AppColors.fgPrimary,
                  size: 18,
                  letterSpacing: 4,
                ),
                const SizedBox(height: 4),
                Container(height: 1, color: AppColors.fgMuted),
                const SizedBox(height: 24),

                // Generate suggestion
                VoidButton(
                  label: state is CreateEventGenerating
                      ? 'GENERANDO...'
                      : '⚙ GENERAR SUGERENCIA IA',
                  onPressed: state is CreateEventGenerating
                      ? null
                      : () => context.read<CreateEventBloc>().add(
                            CreateEventGenerateRequested(
                              actionType: _actionType,
                              interventionLevel: _interventionLevel,
                            ),
                          ),
                ),

                if (state is CreateEventError) ...[
                  const SizedBox(height: 8),
                  MonoText(state.message, color: AppColors.danger, size: 11),
                ],

                if (state is CreateEventSuggested) ...[
                  const SizedBox(height: 12),
                  _SuggestionCard(
                    suggestion: state.suggestion,
                    onAccept: () {
                      _titleCtrl.text = state.suggestion.title;
                      _descCtrl.text = state.suggestion.description;
                      setState(() {
                        _actionType = state.suggestion.actionType;
                        _interventionLevel = state.suggestion.interventionLevel;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 24),
                _Field(label: 'TÍTULO', child: _textInput(_titleCtrl, 'nombre del evento')),
                const SizedBox(height: 16),
                _Field(
                  label: 'DESCRIPCIÓN',
                  child: _textInput(_descCtrl, 'descripción', maxLines: 4),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'TIPO',
                  child: _Selector(
                    options: _actionTypes,
                    selected: _actionType,
                    onSelect: (v) => setState(() => _actionType = v),
                  ),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'INTENSIDAD',
                  child: _Selector(
                    options: _interventionLevels,
                    selected: _interventionLevel,
                    onSelect: (v) => setState(() => _interventionLevel = v),
                  ),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'VISIBILIDAD',
                  child: _Selector(
                    options: _visibilities,
                    selected: _visibility,
                    onSelect: (v) => setState(() => _visibility = v),
                  ),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'DURACIÓN (MIN)',
                  child: _Selector(
                    options: _durations.map((d) => d.toString()).toList(),
                    selected: _durationMinutes.toString(),
                    onSelect: (v) => setState(() => _durationMinutes = int.parse(v)),
                  ),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'UBICACIÓN',
                  child: GestureDetector(
                    onTap: _openLocationPicker,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _pickedLocation != null
                              ? AppColors.phosphor
                              : AppColors.fgMuted,
                          width: 1,
                        ),
                      ),
                      child: MonoText(
                        _pickedLocation != null
                            ? 'LAT ${_pickedLocation!.latitude.toStringAsFixed(5)}'
                                '  LNG ${_pickedLocation!.longitude.toStringAsFixed(5)}'
                            : 'TOCA PARA ELEGIR EN EL MAPA →',
                        color: _pickedLocation != null
                            ? AppColors.phosphor
                            : AppColors.fgMuted,
                        size: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                VoidButton(
                  label: state is CreateEventSubmitting
                      ? 'CREANDO...'
                      : 'CREAR EVENTO',
                  onPressed: (state is CreateEventSubmitting ||
                          _pickedLocation == null)
                      ? null
                      : () {
                          if (_titleCtrl.text.isEmpty ||
                              _descCtrl.text.isEmpty) {
                            return;
                          }
                          context.read<CreateEventBloc>().add(
                                CreateEventSubmitted(
                                  title: _titleCtrl.text.trim(),
                                  description: _descCtrl.text.trim(),
                                  actionType: _actionType,
                                  interventionLevel: _interventionLevel,
                                  visibility: _visibility,
                                  durationMinutes: _durationMinutes,
                                  latitude: _pickedLocation!.latitude,
                                  longitude: _pickedLocation!.longitude,
                                ),
                              );
                        },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _textInput(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.fgMuted),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoText(label, color: AppColors.fgSecondary, size: 10, letterSpacing: 2),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _Selector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _Selector({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.phosphor.withValues(alpha: 0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.phosphor : AppColors.fgMuted,
                width: 1,
              ),
            ),
            child: MonoText(
              opt.toUpperCase(),
              size: 11,
              color: isSelected ? AppColors.phosphor : AppColors.fgSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final GeneratedEventSuggestion suggestion;
  final VoidCallback onAccept;

  const _SuggestionCard({required this.suggestion, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppColors.phosphor.withValues(alpha: 0.3), width: 1),
        color: AppColors.bgSurface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoText(suggestion.title.toUpperCase(),
              color: AppColors.phosphor, size: 12),
          const SizedBox(height: 6),
          Text(suggestion.description, style: AppTextStyles.body),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onAccept,
            child: MonoText(
              '→ USAR ESTA SUGERENCIA',
              color: AppColors.phosphor,
              size: 11,
            ),
          ),
        ],
      ),
    );
  }
}
