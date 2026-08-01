// mobile/lib/features/georandom/pages/georandom_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/georandom_bloc.dart';

class GeoRandomPage extends StatefulWidget {
  const GeoRandomPage({super.key});

  @override
  State<GeoRandomPage> createState() => _GeoRandomPageState();
}

class _GeoRandomPageState extends State<GeoRandomPage> {
  double _radiusMeters = 2000;
  String _selectedType = 'Atractor';

  static const _types = {
    'Atractor': 'zona de alta densidad',
    'Vacio': 'zona de baja densidad',
    'Anomalia': 'punto estadísticamente extremo',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: BlocBuilder<GeoRandomBloc, GeoRandomState>(
          builder: (context, state) {
            void onGenerate() => context.read<GeoRandomBloc>().add(
                  GeoRandomGenerateRequested(
                    radiusMeters: _radiusMeters.round(),
                    type: _selectedType,
                  ),
                );

            if (state is GeoRandomSuccess) {
              return _ResultView(state: state, onGenerateAgain: onGenerate);
            }
            return _FormView(
              radiusMeters: _radiusMeters,
              selectedType: _selectedType,
              types: _types,
              state: state,
              onRadiusChanged: (v) => setState(() => _radiusMeters = v),
              onTypeChanged: (t) => setState(() => _selectedType = t),
              onGenerate: onGenerate,
            );
          },
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final double radiusMeters;
  final String selectedType;
  final Map<String, String> types;
  final GeoRandomState state;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onGenerate;

  const _FormView({
    required this.radiusMeters,
    required this.selectedType,
    required this.types,
    required this.state,
    required this.onRadiusChanged,
    required this.onTypeChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text('EXPLORAR', style: AppTextStyles.monoDisplay),
          const SizedBox(height: 4),
          Container(height: 1, color: AppColors.fgMuted),
          const SizedBox(height: 24),
          MonoText(
            'RADIO: ${(radiusMeters / 1000).toStringAsFixed(1)} km',
            color: AppColors.fgPrimary,
          ),
          Slider(
            value: radiusMeters,
            min: 500,
            max: 5000,
            divisions: 45,
            activeColor: AppColors.phosphor,
            onChanged: onRadiusChanged,
          ),
          const SizedBox(height: 16),
          ...types.entries.map((e) => _TypeRow(
                type: e.key,
                description: e.value,
                selected: selectedType == e.key,
                onTap: () => onTypeChanged(e.key),
              )),
          const SizedBox(height: 24),
          if (state is GeoRandomLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          color: AppColors.phosphor,
                          strokeWidth: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      MonoText('BUSCANDO...', color: AppColors.fgSecondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  MonoText(
                    'puede tardar unos segundos la primera vez',
                    color: AppColors.fgMuted,
                    size: 10,
                  ),
                ],
              ),
            ),
          if (state is GeoRandomPermissionRequired)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MonoText(
                _permissionMessage((state as GeoRandomPermissionRequired).status),
                color: AppColors.fgSecondary,
              ),
            ),
          if (state is GeoRandomError)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MonoText(
                (state as GeoRandomError).message,
                color: AppColors.fgSecondary,
              ),
            ),
          VoidButton(
            label: 'GENERAR',
            onPressed: state is GeoRandomLoading ? null : onGenerate,
          ),
        ],
      ),
    );
  }
}

String _permissionMessage(LocationPermissionStatus status) {
  switch (status) {
    case LocationPermissionStatus.deniedForever:
      return 'el permiso de ubicación está bloqueado. activalo desde los ajustes del sistema para poder usar esto.';
    case LocationPermissionStatus.serviceDisabled:
      return 'tu ubicación está desactivada. activá el GPS del dispositivo e intentá de nuevo.';
    case LocationPermissionStatus.denied:
    case LocationPermissionStatus.granted:
      return 'necesitamos tu ubicación para generar un punto cerca tuyo. dale permiso e intentá de nuevo.';
  }
}

class _TypeRow extends StatelessWidget {
  final String type;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _TypeRow({
    required this.type,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            MonoText(selected ? '▸ ' : '  ', color: AppColors.phosphor),
            MonoText(
              type.toUpperCase(),
              color: selected ? AppColors.fgPrimary : AppColors.fgSecondary,
              size: 13,
            ),
            MonoText('   —  $description', color: AppColors.fgMuted, size: 11),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final GeoRandomSuccess state;
  final VoidCallback onGenerateAgain;

  const _ResultView({required this.state, required this.onGenerateAgain});

  @override
  Widget build(BuildContext context) {
    final point = state.point;
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(point.lat, point.lng),
            initialZoom: 15,
            backgroundColor: AppColors.bgVoid,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.situationist.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(point.lat, point.lng),
                  width: 20,
                  height: 20,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.phosphor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          child: GestureDetector(
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
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Column(
            children: [
              MonoText(point.type.toUpperCase(), color: AppColors.fgPrimary),
              const SizedBox(height: 8),
              VoidButton(label: 'GENERAR OTRO', onPressed: onGenerateAgain),
            ],
          ),
        ),
      ],
    );
  }
}
