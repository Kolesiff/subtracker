import '../models/models.dart';

/// Abstract interface for authentication operations
/// Allows for easy swapping between mock, local, and Supabase implementations
abstract class AuthRepository {
  /// Signs up a new user with email and password
  /// Returns [AuthResult.success] with the new user on success
  /// Returns [AuthResult.failure] with appropriate error on failure
  Future<AuthResult> signUp({required String email, required String password});

  /// Signs in an existing user with email and password
  /// Returns [AuthResult.success] with the user on success
  /// Returns [AuthResult.failure] with appropriate error on failure
  Future<AuthResult> signIn({required String email, required String password});

  /// Signs in with Google OAuth
  /// Returns [AuthResult.success] with the user on success
  /// Returns [AuthResult.failure] with [AuthError.cancelled] if user cancels
  Future<AuthResult> signInWithGoogle();

  /// Signs in with Apple (iOS only)
  /// Returns [AuthResult.success] with the user on success
  /// Returns [AuthResult.failure] with [AuthError.notAvailable] if not on iOS
  Future<AuthResult> signInWithApple();

  /// Signs out the current user
  /// Returns [AuthResult.success] on success
  Future<AuthResult> signOut();

  /// Sends a password reset email to the given address
  /// Returns [AuthResult.success] even if email doesn't exist (for security)
  /// Returns [AuthResult.failure] only for invalid email format
  Future<AuthResult> resetPassword({required String email});

  /// Gets the currently authenticated user, if any
  /// Returns null if no user is signed in
  AppUser? getCurrentUser();

  /// Stream of authentication state changes
  /// Emits the current user when auth state changes (sign in, sign out, token refresh)
  /// Emits null when no user is signed in
  Stream<AppUser?> get authStateChanges;

  /// Whether a user is currently authenticated
  bool get isAuthenticated;
}
