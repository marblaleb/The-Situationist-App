import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/deriva_bloc.dart';
import '../data/deriva_repository.dart';

class DerivaHomePage extends StatelessWidget {
  final LocationService locationService;
  final ApiClient apiClient;

  const DerivaHomePage({
    super.key,
    required this.locationService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DerivaBloc(repository: DerivaRepository(apiClient)),
      child: _DerivaHomeView(locationService: locationService),
    );
  }
}

class _DerivaHomeView extends StatefulWidget {
  final LocationService locationService;
  const _DerivaHomeView({required this.locationService});

  @override
  State<_DerivaHomeView> createState() => _DerivaHomeViewState();
}

class _DerivaHomeViewState extends State<_DerivaHomeView> {
  String _selectedType = 'Caotica';

  static const _types = {
    'Caotica': 'sin reglas, sin dirección',
    'Poetica': 'instrucciones contemplativas',
    'Social': 'interacción con desconocidos',
    'Sensorial': 'percepción aumentada',
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<DerivaBloc, DerivaState>(
      listener: (context, state) {
        if (state is DerivaActive) context.go('/home/deriva/active');
      },
      child: Scaffold(
        backgroundColor: AppColors.bgVoid,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MODO DERIVA', style: AppTextStyles.monoDisplay),
                const SizedBox(height: 4),
                Container(height: 1, color: AppColors.fgMuted),
                const SizedBox(height: 32),
                ..._types.entries.map((e) => _TypeRow(
                      type: e.key,
                      description: e.value,
                      selected: _selectedType == e.key,
                      onTap: () => setState(() => _selectedType = e.key),
                    )),
                const SizedBox(height: 32),
                BlocBuilder<DerivaBloc, DerivaState>(
                  builder: (context, state) {
                    if (state is DerivaError) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MonoText(
                          state.message,
                          color: AppColors.fgSecondary,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                BlocBuilder<DerivaBloc, DerivaState>(
                  builder: (context, state) {
                    return VoidButton(
                      label: 'INICIAR',
                      onPressed: state is DerivaStarting
                          ? null
                          : () => _start(context),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    final (lat, lng) = await widget.locationService.getCurrentPosition();
    if (!context.mounted) return;
    context.read<DerivaBloc>().add(DerivaStartRequested(
          type: _selectedType,
          lat: lat,
          lng: lng,
        ));
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
            MonoText(
              selected ? '▸ ' : '  ',
              color: AppColors.phosphor,
            ),
            MonoText(
              type.toUpperCase(),
              color: selected ? AppColors.fgPrimary : AppColors.fgSecondary,
              size: 13,
            ),
            MonoText(
              '      —  $description',
              color: AppColors.fgMuted,
              size: 11,
            ),
          ],
        ),
      ),
    );
  }
}
