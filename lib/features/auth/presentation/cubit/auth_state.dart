/// Authentication state classes for the AuthCubit
///
/// This file contains all possible authentication states that the app can be in.
/// Each state represents a specific phase of the authentication flow.

/// Base authentication state
abstract class AuthState {
  const AuthState();
}

/// Initial state when the app starts
class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is AuthInitial;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthInitial()';
}

/// State when authentication operations are in progress
class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is AuthLoading;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthLoading()';
}

/// State when OTP has been sent to the user's phone
class AuthOtpSent extends AuthState {
  final String phoneNumber;

  const AuthOtpSent(this.phoneNumber);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthOtpSent && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => phoneNumber.hashCode;

  @override
  String toString() => 'AuthOtpSent(phoneNumber: $phoneNumber)';
}

/// State when user is fully authenticated with a role
class AuthAuthenticated extends AuthState {
  final String userId;
  final String? currentRole;

  const AuthAuthenticated({required this.userId, this.currentRole});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthAuthenticated &&
        other.userId == userId &&
        other.currentRole == currentRole;
  }

  @override
  int get hashCode => userId.hashCode ^ currentRole.hashCode;

  @override
  String toString() => 'AuthAuthenticated(userId: $userId, role: $currentRole)';
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is AuthUnauthenticated;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthUnauthenticated()';
}

/// State when an authentication error occurs
class AuthError extends AuthState {
  final String message;
  final String? errorCode;

  const AuthError(this.message, {this.errorCode});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthError &&
        other.message == message &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode => message.hashCode ^ errorCode.hashCode;

  @override
  String toString() => 'AuthError(message: $message, code: $errorCode)';
}

/// State when user needs to select a role after OTP verification
class AuthRoleSelectionRequired extends AuthState {
  final String userId;

  const AuthRoleSelectionRequired(this.userId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthRoleSelectionRequired && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() => 'AuthRoleSelectionRequired(userId: $userId)';
}

/// State when token refresh is in progress
class AuthTokenRefreshing extends AuthState {
  const AuthTokenRefreshing();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is AuthTokenRefreshing;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthTokenRefreshing()';
}
