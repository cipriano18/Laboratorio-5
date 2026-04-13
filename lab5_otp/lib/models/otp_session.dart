class OtpSession {
  final String code;
  final String email;
  final DateTime createdAt;
  final DateTime expiresAt;
  bool isUsed;
  int failedAttempts;

  OtpSession({
    required this.code,
    required this.email,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
    this.failedAttempts = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && !isUsed;
}
