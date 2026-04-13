import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/otp_session.dart';
import '../services/otp_service.dart';

enum OtpStatus { idle, sending, waitingForInput, verifying, success, expired, locked }

class OtpProvider extends ChangeNotifier {
  final OtpService _otpService;

  OtpSession? _session;
  OtpStatus _status = OtpStatus.idle;
  Timer? _timer;
  int _secondsRemaining = AppConstants.expirySeconds;

  OtpProvider({required OtpService otpService}) : _otpService = otpService;

  OtpStatus get status => _status;
  OtpSession? get session => _session;
  int get secondsRemaining => _secondsRemaining;
  bool get canResend => _secondsRemaining == 0 || _status == OtpStatus.expired;
  bool get isLocked => _status == OtpStatus.locked;

  String get formattedCountdown {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get email => _session?.email ?? '';

  OtpSession generateOtp(String email) {
    _timer?.cancel();
    _session = _otpService.generate(email);
    _secondsRemaining = AppConstants.expirySeconds;
    _status = OtpStatus.waitingForInput;
    _startTimer();
    notifyListeners();
    return _session!;
  }

  ValidationResult validateOtp(String input) {
    if (_session == null) return ValidationResult.expired;
    _status = OtpStatus.verifying;
    notifyListeners();

    final result = _otpService.validate(_session!, input);

    if (result == ValidationResult.success) {
      _timer?.cancel();
      _status = OtpStatus.success;
    } else if (result == ValidationResult.tooManyAttempts) {
      _timer?.cancel();
      _status = OtpStatus.locked;
    } else if (result == ValidationResult.expired) {
      _status = OtpStatus.expired;
    } else {
      _status = OtpStatus.waitingForInput;
    }

    notifyListeners();
    return result;
  }

  OtpSession resendOtp() {
    _timer?.cancel();
    _session = _otpService.generate(_session!.email);
    _secondsRemaining = AppConstants.expirySeconds;
    _status = OtpStatus.waitingForInput;
    _startTimer();
    notifyListeners();
    return _session!;
  }

  void reset() {
    _timer?.cancel();
    _session = null;
    _status = OtpStatus.idle;
    _secondsRemaining = AppConstants.expirySeconds;
    notifyListeners();
  }

  int get attemptsRemaining =>
      AppConstants.maxAttempts - (_session?.failedAttempts ?? 0);

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        if (_status == OtpStatus.waitingForInput) {
          _status = OtpStatus.expired;
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
