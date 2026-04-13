import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../providers/otp_provider.dart';
import '../../services/otp_service.dart';
import 'widgets/otp_input_field.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpFieldKey = GlobalKey<OtpInputFieldState>();
  bool _isComplete = false;

  void _onOtpChanged() {
    final current = _otpFieldKey.currentState?.currentValue ?? '';
    setState(() => _isComplete = current.length == AppConstants.otpLength);
  }

  Future<void> _verify() async {
    final input = _otpFieldKey.currentState?.currentValue ?? '';
    if (input.length != AppConstants.otpLength) return;

    final provider = context.read<OtpProvider>();
    final result = provider.validateOtp(input);

    if (!mounted) return;

    switch (result) {
      case ValidationResult.success:
        Navigator.pushReplacementNamed(context, '/success');
        break;
      case ValidationResult.wrongCode:
        _otpFieldKey.currentState?.clear();
        setState(() => _isComplete = false);
        final remaining = provider.attemptsRemaining;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código incorrecto. Te quedan $remaining intento${remaining == 1 ? '' : 's'}.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case ValidationResult.expired:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El código ha expirado. Por favor solicita uno nuevo.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case ValidationResult.tooManyAttempts:
        await _showLockedDialog();
        break;
    }
  }

  Future<void> _showLockedDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Acceso bloqueado'),
          ],
        ),
        content: const Text(
          'Has superado el número máximo de intentos. Solicita un nuevo código para continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _resend() {
    final provider = context.read<OtpProvider>();
    final session = provider.resendOtp();
    _otpFieldKey.currentState?.clear();
    setState(() => _isComplete = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nuevo OTP (Demo): ${session.code} — expira en 2:00'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresar OTP'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<OtpProvider>(
        builder: (context, provider, _) {
          final isExpired = provider.status == OtpStatus.expired;
          final isLocked = provider.status == OtpStatus.locked;
          final inputEnabled = !isExpired && !isLocked;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Icon
                  Icon(
                    Icons.smartphone_rounded,
                    size: 56,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),

                  // Headline
                  Text(
                    'Código de verificación',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Masked email
                  Text(
                    'Código enviado a ${Validators.maskEmail(provider.email)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.outline),
                  ),
                  const SizedBox(height: 36),

                  // OTP boxes
                  OtpInputField(
                    key: _otpFieldKey,
                    length: AppConstants.otpLength,
                    enabled: inputEnabled,
                    onCompleted: (_) => _verify(),
                    onChanged: _onOtpChanged,
                  ),
                  const SizedBox(height: 28),

                  // Countdown
                  _CountdownWidget(
                    provider: provider,
                    isExpired: isExpired,
                    isLocked: isLocked,
                  ),
                  const SizedBox(height: 28),

                  // Verify button
                  ElevatedButton(
                    onPressed: (_isComplete && inputEnabled) ? _verify : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor:
                          colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    child: const Text('Verificar'),
                  ),
                  const SizedBox(height: 12),

                  // Resend button
                  TextButton(
                    onPressed: (provider.canResend && !isLocked) ? _resend : null,
                    child: Text(
                      provider.canResend
                          ? 'Reenviar OTP'
                          : 'Reenviar en ${provider.formattedCountdown}',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CountdownWidget extends StatelessWidget {
  final OtpProvider provider;
  final bool isExpired;
  final bool isLocked;

  const _CountdownWidget({
    required this.provider,
    required this.isExpired,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLocked) {
      return _statusChip(
        icon: Icons.lock_outline,
        label: 'Cuenta bloqueada por exceso de intentos',
        color: Colors.red.shade700,
      );
    }

    if (isExpired) {
      return _statusChip(
        icon: Icons.timer_off_outlined,
        label: 'El código ha expirado',
        color: Colors.orange.shade800,
      );
    }

    final isUrgent = provider.secondsRemaining < 20;
    final countdownColor = isUrgent ? Colors.red.shade700 : colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined, size: 20, color: countdownColor),
        const SizedBox(width: 6),
        Text(
          'Expira en ${provider.formattedCountdown}',
          style: TextStyle(
            color: countdownColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _statusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
