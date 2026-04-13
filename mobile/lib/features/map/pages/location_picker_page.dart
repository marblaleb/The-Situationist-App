import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';

class LocationPickerPage extends StatefulWidget {
  final LocationService locationService;

  const LocationPickerPage({super.key, required this.locationService});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final _mapController = MapController();
  LatLng? _selected;

  static const _defaultCenter = LatLng(40.4168, -3.7038); // Madrid

  @override
  void initState() {
    super.initState();
    _centerOnGps();
  }

  Future<void> _centerOnGps() async {
    final (lat, lng) = await widget.locationService.getCurrentPosition();
    final pos = LatLng(lat, lng);
    if (mounted) {
      _mapController.move(pos, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 14,
                onTap: (_, point) => setState(() => _selected = point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.situationist.app',
                ),
                if (_selected != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selected!,
                        width: 36,
                        height: 36,
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.phosphor,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.bgVoid.withValues(alpha: 0.88),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(null),
                      child: const MonoText(
                        '← CANCELAR',
                        color: AppColors.fgSecondary,
                        size: 12,
                      ),
                    ),
                    const Spacer(),
                    const MonoText(
                      'ELEGIR UBICACIÓN',
                      color: AppColors.fgPrimary,
                      size: 13,
                      letterSpacing: 2,
                    ),
                    const Spacer(),
                    const SizedBox(width: 80),
                  ],
                ),
              ),
            ),

            // Bottom bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.bgVoid.withValues(alpha: 0.92),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selected != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MonoText(
                          'LAT ${_selected!.latitude.toStringAsFixed(5)}  '
                          'LNG ${_selected!.longitude.toStringAsFixed(5)}',
                          color: AppColors.fgSecondary,
                          size: 11,
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: MonoText(
                          'TOCA EL MAPA PARA FIJAR UN PUNTO',
                          color: AppColors.fgMuted,
                          size: 11,
                        ),
                      ),
                    VoidButton(
                      label: 'CONFIRMAR UBICACIÓN',
                      onPressed: _selected == null
                          ? null
                          : () => context.pop(_selected),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
