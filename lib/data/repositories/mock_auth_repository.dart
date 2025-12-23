import 'dart:async';

import '../models/models.dart';
import 'auth_repository.dart';

/// Mock implementation of AuthRepository for development and testing
class MockAuthRepository implements AuthRepository {
  final Map<String, _MockUserRecord> _users = {};
  AppUser? _currentUser;

  final _authStateController = StreamController<AppUser?>.broadcast();

  // Simulation flags
  bool _simulateGoogleCancelled = false;
  bool _simulateNetworkError = false;
  bool _simulateAppleUnavailable = false;

  // Configuration
  static const int _minPasswordLength = 8;

  MockAuthRepository() {
    // Emit initial null state
    _authStateController.add(null);
  }

  @override
  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  /// Simulate Google Sign In being cancelled by user
  void simulateGoogleSignInCancelled() => _simulateGoogleCancelled = true;

  /// Simulate network error during OAuth
  void simulateNetworkError() => _simulateNetworkError = true;

  /// Simulate Apple Sign In not available (e.g., on Android)
  void simulateAppleSignInUnavailable() => _simulateAppleUnavailable = true;

  /// Reset all simulations to default behavior
  void resetSimulations() {
    _simulateGoogleCancelled = false;
    _simulateNetworkError = false;
    _simulateAppleUnavailable = false;
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    await _simulateNetworkDelay();

    final trimmedEmail = email.trim().toLowerCase();

    // Validate email
    if (!_isValidEmail(trimmedEmail)) {
      return AuthResult.failure(AuthError.invalidEmail);
    }

    // Validate password
    if (!_isValidPassword(password)) {
      return AuthResult.failure(AuthError.weakPassword);
    }

    // Check if email already exists
    if (_users.containsKey(trimmedEmail)) {
      return AuthResult.failure(AuthError.emailAlreadyInUse);
    }

    // Create user
    final user = AppUser(
      id: _generateId(),
      email: trimmedEmail,
      createdAt: DateTime.now(),
      provider: AuthProvider.email,
    );

    _users[trimmedEmail] = _MockUserRecord(user: user, password: password);
    _setCurrentUser(user);

    return AuthResult.success(user);
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    await _simulateNetworkDelay();

    final trimmedEmail = email.trim().toLowerCase();

    // Check if user exists
    final record = _users[trimmedEmail];
    if (record == null) {
      return AuthResult.failure(AuthError.userNotFound);
    }

    // Verify password
    if (record.password != password) {
      return AuthResult.failure(AuthError.wrongPassword);
    }

    _setCurrentUser(record.user);
    return AuthResult.success(record.user);
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    await _simulateNetworkDelay();

    if (_simulateNetworkError) {
      return AuthResult.failure(AuthError.networkError);
    }

    if (_simulateGoogleCancelled) {
      return AuthResult.failure(AuthError.cancelled);
    }

    final user = AppUser(
      id: _generateId(),
      email: 'google.user@gmail.com',
      displayName: 'Google User',
      createdAt: DateTime.now(),
      provider: AuthProvider.google,
    );

    _setCurrentUser(user);
    return AuthResult.success(user);
  }

  @override
  Future<AuthResult> signInWithApple() async {
    await _simulateNetworkDelay();

    if (_simulateAppleUnavailable) {
      return AuthResult.failure(AuthError.notAvailable);
    }

    final user = AppUser(
      id: _generateId(),
      email: 'apple.user@icloud.com',
      createdAt: DateTime.now(),
      provider: AuthProvider.apple,
    );

    _setCurrentUser(user);
    return AuthResult.success(user);
  }

  @override
  Future<AuthResult> signOut() async {
    await _simulateNetworkDelay();
    _setCurrentUser(null);
    // Return success - use a placeholder user since signOut doesn't return a real user
    return AuthResult.success(AppUser(
      id: '',
      email: '',
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<AuthResult> resetPassword({required String email}) async {
    await _simulateNetworkDelay();

    final trimmedEmail = email.trim().toLowerCase();

    if (!_isValidEmail(trimmedEmail)) {
      return AuthResult.failure(AuthError.invalidEmail);
    }

    // Always return success for security (don't reveal if email exists)
    return AuthResult.success(AppUser(
      id: '',
      email: trimmedEmail,
      createdAt: DateTime.now(),
    ));
  }

  @override
  AppUser? getCurrentUser() => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }

  // Private helpers

  void _setCurrentUser(AppUser? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    if (password.length < _minPasswordLength) return false;
    // Require uppercase, lowercase, and number
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'\d'));
    return hasUppercase && hasLowercase && hasNumber;
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

/// Internal record to store user and password
class _MockUserRecord {
  final AppUser user;
  final String password;

  _MockUserRecord({required this.user, required this.password});
}
