import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/realtime/signalr_service.dart';
import '../../../features/events/bloc/events_bloc.dart';
import '../../../features/events/data/events_repository.dart';
import '../../../shared/models/event_model.dart';
import '../bloc/map_bloc.dart';
import '../widgets/cluster_list_sheet.dart';
import '../widgets/event_detail_sheet.dart';

class MapPage extends StatelessWidget {
  final LocationService locationService;
  final SignalRService signalRService;
  final ApiClient apiClient;

  const MapPage({
    super.key,
    required this.locationService,
    required this.signalRService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    final eventsRepo = EventsRepository(apiClient);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MapBloc(
            eventsRepository: eventsRepo,
            locationService: locationService,
            signalRService: signalRService,
          )..add(MapInitialized()),
        ),
        BlocProvider(
          create: (_) => EventsBloc(repository: eventsRepo),
        ),
      ],
      child: const _MapView(),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is MapLoading) {
          return const Scaffold(
            backgroundColor: AppColors.bgVoid,
            body: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: AppColors.phosphor,
                  strokeWidth: 1,
                ),
              ),
            ),
          );
        }

        if (state is MapError) {
          return Scaffold(
            backgroundColor: AppColors.bgVoid,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ERROR AL CARGAR',
                    style: const TextStyle(
                      color: AppColors.fgSecondary,
                      fontFamily: 'JetBrainsMono',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => context.read<MapBloc>().add(MapInitialized()),
                    child: const Text(
                      '↺ REINTENTAR',
                      style: TextStyle(
                        color: AppColors.phosphor,
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is MapReady) {
          return _MapReady(state: state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _MapReady extends StatelessWidget {
  final MapReady state;

  const _MapReady({required this.state});

  Color _markerColor(EventModel event) {
    if (event.status == 'Full') return AppColors.fgMuted;
    final now = DateTime.now().toUtc();
    if (event.expiresAt.isBefore(now.add(const Duration(minutes: 10))) &&
        event.expiresAt.isAfter(now)) {
      return AppColors.amber;
    }
    return AppColors.phosphor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(state.lat, state.lng),
              initialZoom: 15,
              backgroundColor: AppColors.bgVoid,
              onTap: (_, __) {
                context.read<MapBloc>().add(MapEventSelected(null));
                context.read<MapBloc>().add(MapClusterSelected(null));
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.situationist.app',
              ),
              CircleLayer(
                circles: state.events.map((event) {
                  final isSelected = event.id == state.selectedEventId;
                  final color = _markerColor(event);
                  return CircleMarker(
                    point: LatLng(event.centroidLatitude, event.centroidLongitude),
                    radius: event.radiusMeters.toDouble(),
                    useRadiusInMeter: true,
                    color: color.withValues(alpha:isSelected ? 0.1 : 0.05),
                    borderColor: color.withValues(alpha:isSelected ? 0.7 : 0.4),
                    borderStrokeWidth: 1,
                  );
                }).toList(),
              ),
              MarkerLayer(
                markers: state.clusters.map((cluster) {
                  final isSelected = cluster.isSingle
                      ? state.selectedEventId == cluster.single.id
                      : state.selectedCluster == cluster;

                  if (cluster.isSingle) {
                    final event = cluster.single;
                    final color = _markerColor(event);
                    final size = isSelected ? 20.0 : 14.0;
                    return Marker(
                      point: LatLng(cluster.lat, cluster.lng),
                      width: size,
                      height: size,
                      child: GestureDetector(
                        onTap: () => context
                            .read<MapBloc>()
                            .add(MapEventSelected(event.id)),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha:isSelected ? 0.9 : 0.6),
                            border: Border.all(color: color, width: 1),
                          ),
                        ),
                      ),
                    );
                  } else {
                    final size = isSelected ? 32.0 : 26.0;
                    return Marker(
                      point: LatLng(cluster.lat, cluster.lng),
                      width: size,
                      height: size,
                      child: GestureDetector(
                        onTap: () => context
                            .read<MapBloc>()
                            .add(MapClusterSelected(cluster)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.bgVoid,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.phosphor
                                  .withValues(alpha:isSelected ? 0.9 : 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cluster.events.length.toString(),
                              style: AppTextStyles.body.copyWith(
                                fontSize: 11,
                                color: AppColors.phosphor
                                    .withValues(alpha:isSelected ? 0.9 : 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }).toList(),
              ),
            ],
          ),
          if (state.selectedCluster != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height * 0.7,
              child: ClusterListSheet(
                cluster: state.selectedCluster!,
                onDismiss: () =>
                    context.read<MapBloc>().add(MapClusterSelected(null)),
                onEventSelected: (event) {
                  context.read<MapBloc>()
                    ..add(MapClusterSelected(null))
                    ..add(MapEventSelected(event.id));
                },
              ),
            ),
          if (state.selectedEvent != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height * 0.7,
              child: EventDetailSheet(
                event: state.selectedEvent!,
                onDismiss: () =>
                    context.read<MapBloc>().add(MapEventSelected(null)),
              ),
            ),
        ],
      ),
    );
  }
}
