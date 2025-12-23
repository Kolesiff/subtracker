import 'app_user.dart';

/// Types of authentication errors
enum AuthError {
  invalidEmail,
  weakPassword,
  emailAlreadyInUse,
  userNotFound,
  wrongPassword,
  tooManyAttempts,
  networkError,
  cancelled,
  notAvailable,
  /// OAuth flow initiated - waiting for callback via deep link
  /// This is not an error, just indicates OAuth is in progress
  oauthInProgress,
  unknown,
}

/// Extension to provide user-friendly error messages
extension AuthErrorExtension on AuthError {
  String get message {
    switch (this) {
      case AuthError.invalidEmail:
        return 'Please enter a valid email address';
      case AuthError.weakPassword:
        return 'Password must be at least 8 characters with uppercase, lowercase, and number';
      case AuthError.emailAlreadyInUse:
        return 'An account with this email already exists';
      case AuthError.userNotFound:
        return 'No account found with this email';
      case AuthError.wrongPassword:
        return 'Incorrect password';
      case AuthError.tooManyAttempts:
        return 'Too many attempts. Please try again later';
      case AuthError.networkError:
        return 'Network error. Please check your connection';
      case AuthError.cancelled:
        return 'Sign in was cancelled';
      case AuthError.notAvailable:
        return 'This sign in method is not available';
      case AuthError.oauthInProgress:
        return 'Sign in in progress...';
      case AuthError.unknown:
        return 'An unexpected error occurred';
    }
  }
}

/// Result wrapper for authentication operations
/// Provides consistent success/failure handling across the app
class AuthResult {
  final AppUser? user;
  final AuthError? error;
  final String? errorMessage;

  const AuthResult._({this.user, this.error, this.errorMessage});

  /// Create a successful result with a user
  factory AuthResult.success(AppUser user) => AuthResult._(user: user);

  /// Create a failure result with an error
  factory AuthResult.failure(AuthError error, [String? message]) =>
      AuthResult._(error: error, errorMessage: message ?? error.message);

  /// Whether the operation was successful
  bool get isSuccess => user != null && error == null;

  /// Whether the operation failed
  bool get isFailure => !isSuccess;

  /// Get the error message (uses default if not custom)
  String? get displayError => errorMessage ?? error?.message;

  @override
  String toString() {
    if (isSuccess) {
      return 'AuthResult.success(user: ${user?.email})';
    }
    return 'AuthResult.failure(error: $error)';
  }
}
