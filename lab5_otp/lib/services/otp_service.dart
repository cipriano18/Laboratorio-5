import 'dart:math';
import '../core/constants/app_constants.dart';
import '../models/otp_session.dart';

enum ValidationResult { success, wrongCode, expired, tooManyAttempts }

class OtpService {
  OtpSession generate(String email) {
    final code = (Random.secure().nextInt(900000) + 100000).toString();
    final now = DateTime.now();
    return OtpSession(
      code: code,
      email: email,
      createdAt: now,
      expiresAt: now.add(const Duration(seconds: AppConstants.expirySeconds)),
    );
  }

  ValidationResult validate(OtpSession session, String entered) {
    if (session.failedAttempts >= AppConstants.maxAttempts) {
      return ValidationResult.tooManyAttempts;
    }
    if (session.isExpired) {
      return ValidationResult.expired;
    }
    if (entered != session.code) {
      session.failedAttempts++;
      if (session.failedAttempts >= AppConstants.maxAttempts) {
        return ValidationResult.tooManyAttempts;
      }
      return ValidationResult.wrongCode;
    }
    session.isUsed = true;
    return ValidationResult.success;
  }
}
