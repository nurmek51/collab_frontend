/// Model for authentication response data
class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String userId;
  final String? currentRole;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.userId,
    this.currentRole,
  });

  /// Create from JSON response
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      userId: json['user_id'] as String,
      currentRole: json['current_role'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'user_id': userId,
      if (currentRole != null) 'current_role': currentRole,
    };
  }

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
    return 'AuthResponseModel(userId: $userId, role: $currentRole, expiresIn: ${expiresIn}s)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthResponseModel &&
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

/// Model for OTP verification request
class OtpVerificationModel {
  final String phoneNumber;
  final String otp;

  const OtpVerificationModel({required this.phoneNumber, required this.otp});

  Map<String, dynamic> toJson() {
    return {'phone': phoneNumber, 'otp': otp};
  }

  /// Validate OTP format
  bool get isValid {
    return phoneNumber.isNotEmpty &&
        otp.isNotEmpty &&
        otp.length >= 4 &&
        otp.length <= 6;
  }
}

/// Model for token refresh request
class TokenRefreshModel {
  final String refreshToken;

  const TokenRefreshModel({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refresh_token': refreshToken};
  }

  bool get isValid => refreshToken.isNotEmpty;
}

/// Model for role selection request
class RoleSelectionModel {
  final String role;

  const RoleSelectionModel({required this.role});

  Map<String, dynamic> toJson() {
    return {'role': role};
  }

  bool get isValid => role.isNotEmpty;
}
