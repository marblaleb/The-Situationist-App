import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/create_mission_bloc.dart';
import '../data/missions_repository.dart';

class CreateMissionPage extends StatelessWidget {
  final ApiClient apiClient;

  const CreateMissionPage({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateMissionBloc(repository: MissionsRepository(apiClient)),
      child: const _CreateMissionView(),
    );
  }
}

class _CreateMissionView extends StatefulWidget {
  const _CreateMissionView();

  @override
  State<_CreateMissionView> createState() => _CreateMissionViewState();
}

class _CreateMissionViewState extends State<_CreateMissionView> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _radiusMeters = 500;
  final List<_ClueEntry> _clues = [_ClueEntry()];
  LatLng? _pickedLocation;

  static const _radii = [100, 250, 500, 1000, 2000];
  static const _clueTypes = ['Textual', 'Sensorial', 'Contextual'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _clues) c.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final result = await context.push<LatLng>('/home/location-picker');
    if (result != null && mounted) {
      setState(() => _pickedLocation = result);
    }
  }

  void _submit() {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) return;
    if (_pickedLocation == null) return;
    if (_clues.any((c) =>
        c.contentCtrl.text.isEmpty || c.answerCtrl.text.isEmpty)) return;

    context.read<CreateMissionBloc>().add(CreateMissionSubmitted(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      latitude: _pickedLocation!.latitude,
      longitude: _pickedLocation!.longitude,
      radiusMeters: _radiusMeters,
      clues: _clues
          .map((c) => ClueFormData(
                type: c.selectedType,
                content: c.contentCtrl.text.trim(),
                answer: c.answerCtrl.text.trim(),
                hint: c.hintCtrl.text.trim(),
                isOptional: c.isOptional,
              ))
          .toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateMissionBloc, CreateMissionState>(
      listener: (context, state) {
        if (state is CreateMissionSuccess) context.pop();
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgVoid,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                MonoText('NUEVA MISIÓN',
                    color: AppColors.fgPrimary, size: 18, letterSpacing: 4),
                const SizedBox(height: 4),
                Container(height: 1, color: AppColors.fgMuted),
                const SizedBox(height: 24),
                _Field(
                    label: 'TÍTULO',
                    child: _textInput(_titleCtrl, 'nombre de la misión')),
                const SizedBox(height: 16),
                _Field(
                  label: 'DESCRIPCIÓN',
                  child: _textInput(_descCtrl, 'descripción de la misión',
                      maxLines: 3),
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'RADIO (METROS)',
                  child: _Selector(
                    options: _radii.map((r) => r.toString()).toList(),
                    selected: _radiusMeters.toString(),
                    onSelect: (v) =>
                        setState(() => _radiusMeters = int.parse(v)),
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
                const SizedBox(height: 24),
                Container(height: 1, color: AppColors.fgMuted),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PISTAS', style: AppTextStyles.monoDisplay),
                    GestureDetector(
                      onTap: () => setState(() => _clues.add(_ClueEntry())),
                      child: MonoText('+ AÑADIR',
                          color: AppColors.phosphor, size: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._clues.asMap().entries.map((entry) {
                  final i = entry.key;
                  final clue = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _ClueForm(
                      index: i,
                      entry: clue,
                      clueTypes: _clueTypes,
                      canRemove: _clues.length > 1,
                      onRemove: () => setState(() => _clues.removeAt(i)),
                      onChanged: () => setState(() {}),
                    ),
                  );
                }),
                if (state is CreateMissionError) ...[
                  const SizedBox(height: 8),
                  MonoText(state.message, color: AppColors.danger, size: 11),
                ],
                const SizedBox(height: 16),
                VoidButton(
                  label: state is CreateMissionSubmitting
                      ? 'CREANDO...'
                      : 'CREAR MISIÓN',
                  onPressed: (state is CreateMissionSubmitting ||
                          _pickedLocation == null)
                      ? null
                      : _submit,
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

// ── Clue form state ───────────────────────────────────────────────────────────

class _ClueEntry {
  final contentCtrl = TextEditingController();
  final answerCtrl = TextEditingController();
  final hintCtrl = TextEditingController();
  String selectedType = 'Textual';
  bool isOptional = false;

  void dispose() {
    contentCtrl.dispose();
    answerCtrl.dispose();
    hintCtrl.dispose();
  }
}

class _ClueForm extends StatelessWidget {
  final int index;
  final _ClueEntry entry;
  final List<String> clueTypes;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _ClueForm({
    required this.index,
    required this.entry,
    required this.clueTypes,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(border: Border.all(color: AppColors.fgMuted, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MonoText('PISTA ${index + 1}',
                  color: AppColors.fgSecondary, size: 10, letterSpacing: 2),
              if (canRemove)
                GestureDetector(
                  onTap: onRemove,
                  child:
                      MonoText('ELIMINAR', color: AppColors.danger, size: 10),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'TIPO',
            child: _Selector(
              options: clueTypes,
              selected: entry.selectedType,
              onSelect: (v) {
                entry.selectedType = v;
                onChanged();
              },
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'CONTENIDO',
            child: TextField(
              controller: entry.contentCtrl,
              maxLines: 2,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'descripción de la pista',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.fgMuted),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'RESPUESTA',
            child: TextField(
              controller: entry.answerCtrl,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'respuesta correcta',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.fgMuted),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'PISTA (OPCIONAL)',
            child: TextField(
              controller: entry.hintCtrl,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'ayuda para el jugador',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.fgMuted),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              entry.isOptional = !entry.isOptional;
              onChanged();
            },
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: entry.isOptional
                          ? AppColors.phosphor
                          : AppColors.fgMuted,
                    ),
                    color: entry.isOptional
                        ? AppColors.phosphor.withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                ),
                const SizedBox(width: 8),
                MonoText('PISTA OPCIONAL',
                    color: AppColors.fgSecondary, size: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared local widgets ──────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoText(label,
            color: AppColors.fgSecondary, size: 10, letterSpacing: 2),
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

  const _Selector(
      {required this.options, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
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
                  color: isSelected ? AppColors.phosphor : AppColors.fgMuted),
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
