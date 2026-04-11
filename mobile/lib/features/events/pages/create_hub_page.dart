import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';

class CreateHubPage extends StatelessWidget {
  const CreateHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CREAR', style: AppTextStyles.monoDisplay),
              const SizedBox(height: 4),
              Container(height: 1, color: AppColors.fgMuted),
              const SizedBox(height: 32),
              _HubOption(
                symbol: '⊕',
                title: 'NUEVO EVENTO',
                subtitle: 'Intervención efímera en el espacio urbano',
                onTap: () => context.push('/home/create-event'),
              ),
              const SizedBox(height: 20),
              _HubOption(
                symbol: '◈',
                title: 'NUEVA MISIÓN',
                subtitle: 'Secuencia de pistas para explorar el territorio',
                onTap: () => context.push('/home/create-mission'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubOption extends StatelessWidget {
  final String symbol;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubOption({
    required this.symbol,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(border: Border.all(color: AppColors.fgMuted, width: 1)),
        child: Row(
          children: [
            Text(
              symbol,
              style: AppTextStyles.monoDisplay.copyWith(fontSize: 28, color: AppColors.phosphor),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonoText(title, size: 14, letterSpacing: 2),
                  const SizedBox(height: 4),
                  MonoText(subtitle, color: AppColors.fgSecondary, size: 11),
                ],
              ),
            ),
            MonoText('→', color: AppColors.phosphor, size: 16),
          ],
        ),
      ),
    );
  }
}
