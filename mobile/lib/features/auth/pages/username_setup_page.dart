import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mono_text.dart';
import '../../../core/widgets/void_button.dart';
import '../bloc/auth_bloc.dart';

class UsernameSetupPage extends StatefulWidget {
  final ApiClient apiClient;

  const UsernameSetupPage({super.key, required this.apiClient});

  @override
  State<UsernameSetupPage> createState() => _UsernameSetupPageState();
}

class _UsernameSetupPageState extends State<UsernameSetupPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool? _available;
  bool _checking = false;
  bool _submitting = false;
  String? _errorMessage;

  static final _regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{2,19}$');

  bool get _formatValid => _regex.hasMatch(_controller.text.trim());
  bool get _canSubmit => _formatValid && _available == true && !_submitting;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (!_formatValid) {
      setState(() {
        _available = null;
        _checking = false;
      });
      return;
    }
    setState(() {
      _checking = true;
      _available = null;
    });
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _checkAvailability(value.trim()),
    );
  }

  Future<void> _checkAvailability(String username) async {
    try {
      final response = await widget.apiClient.get<Map<String, dynamic>>(
        '/users/username-available',
        queryParameters: {'username': username},
      );
      if (mounted) {
        setState(() {
          _available = response.data?['available'] as bool? ?? false;
          _checking = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _checking = false;
          _available = null;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final response = await widget.apiClient.post<Map<String, dynamic>>(
        '/users/me/username',
        data: {'username': _controller.text.trim()},
      );
      final newToken = response.data?['accessToken'] as String?;
      if (newToken != null && mounted) {
        context.read<AuthBloc>().add(AuthUsernameUpdated(token: newToken));
        context.go('/home/map');
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _submitting = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = '→ error de conexión';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text('ELIGE TU NOMBRE', style: AppTextStyles.monoDisplay),
              const SizedBox(height: 8),
              Container(height: 1, color: AppColors.fgMuted),
              const SizedBox(height: 24),
              const MonoText(
                'único · 3–20 caracteres · solo letras, números y _',
                color: AppColors.fgSecondary,
                size: 11,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                onChanged: _onChanged,
                style: const TextStyle(color: AppColors.fgPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'nombre_usuario',
                  hintStyle: const TextStyle(color: AppColors.fgSecondary, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.bgElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: AppColors.fgMuted),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: AppColors.phosphor),
                  ),
                  suffixIcon: _buildSuffix(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              _buildAvailabilityHint(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                MonoText(_errorMessage!, color: AppColors.danger, size: 11),
              ],
              const SizedBox(height: 24),
              VoidButton(
                label: _submitting ? '...' : 'CONFIRMAR',
                onPressed: _canSubmit ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffix() {
    if (_checking) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.fgSecondary),
        ),
      );
    }
    if (_available == true) return const Icon(Icons.check, color: AppColors.phosphor, size: 18);
    if (_available == false) return const Icon(Icons.close, color: AppColors.danger, size: 18);
    return null;
  }

  Widget _buildAvailabilityHint() {
    if (!_formatValid && _controller.text.isNotEmpty) {
      return const MonoText('formato inválido', color: AppColors.fgSecondary, size: 11);
    }
    if (_available == true) return const MonoText('disponible', color: AppColors.phosphor, size: 11);
    if (_available == false) return const MonoText('nombre en uso', color: AppColors.danger, size: 11);
    return const SizedBox.shrink();
  }
}
