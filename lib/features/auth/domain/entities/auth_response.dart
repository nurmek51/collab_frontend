/// Domain entity for authentication response
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String userId;
  final String? currentRole;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.userId,
    this.currentRole,
  });

  /// Calculate expiration timestamp
  DateTime get expirationTime {
    return DateTime.now().add(Duration(seconds: expiresIn));
  }

  /// Check if this auth response is valid
  bool get isValid {
    return accessToken.isNotEmpty &&
        refreshToken.isNotEmpty &&
        expiresIn > 0 &&
        userId.isNotEmpty;
  }

  @override
  String toString() {
    return 'AuthResponse(userId: $userId, role: $currentRole, expiresIn: ${expiresIn}s)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthResponse &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresIn == expiresIn &&
        other.userId == userId &&
        other.currentRole == currentRole;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        refreshToken.hashCode ^
        expiresIn.hashCode ^
        userId.hashCode ^
        currentRole.hashCode;
  }
}
