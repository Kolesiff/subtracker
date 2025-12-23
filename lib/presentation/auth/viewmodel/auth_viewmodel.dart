import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/auth_repository.dart';

/// Authentication status states
enum AuthStatus {
  /// Initial state, no action taken
  idle,

  /// Authentication operation in progress
  loading,

  /// User is authenticated
  authenticated,

  /// Operation completed successfully (e.g., password reset email sent)
  success,

  /// An error occurred
  error,
}

/// ViewModel for authentication screens
/// Manages auth state and provides form validation
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSubscription;

  AuthStatus _status = AuthStatus.idle;
  AppUser? _currentUser;
  String? _errorMessage;

  AuthViewModel({required AuthRepository repository})
      : _repository = repository {
    // Check if already authenticated on creation
    _currentUser = _repository.getCurrentUser();
    if (_currentUser != null) {
      _status = AuthStatus.authenticated;
    }

    // Subscribe to auth state changes to detect OAuth callbacks,
    // token refreshes, and external sign-outs
    _authSubscription = _repository.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Handle auth state changes from the repository stream
  void _onAuthStateChanged(AppUser? user) {
    _currentUser = user;
    _status = user != null ? AuthStatus.authenticated : AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // Getters
  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _status == AuthStatus.loading;

  /// Sign up a new user with email and password
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading();

    final result = await _repository.signUp(email: email, password: password);
    _handleResult(result);
  }

  /// Sign in an existing user with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();

    final result = await _repository.signIn(email: email, password: password);
    _handleResult(result);
  }

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    _setLoading();

    final result = await _repository.signInWithGoogle();
    _handleResult(result, treatCancelAsIdle: true);
  }

  /// Sign in with Apple (iOS only)
  Future<void> signInWithApple() async {
    _setLoading();

    final result = await _repository.signInWithApple();
    _handleResult(result, treatCancelAsIdle: true);
  }

  /// Sign out the current user
  Future<void> signOut() async {
    _setLoading();

    await _repository.signOut();
    _currentUser = null;
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    _setLoading();

    final result = await _repository.resetPassword(email: email);
    if (result.isSuccess) {
      _status = AuthStatus.success;
      _errorMessage = null;
    } else {
      _status = AuthStatus.error;
      _errorMessage = result.displayError;
    }
    notifyListeners();
  }

  /// Clear error state and reset to idle
  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  // Form validation helpers

  /// Validate email format
  /// Returns null if valid, error message if invalid
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password strength
  /// Returns null if valid, error message if invalid
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    if (!password.contains(RegExp(r'\d'))) {
      return 'Password must contain a number';
    }
    return null;
  }

  /// Validate password confirmation matches
  /// Returns null if matching, error message if not
  String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Private helpers

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _handleResult(AuthResult result, {bool treatCancelAsIdle = false}) {
    if (result.isSuccess) {
      _currentUser = result.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } else if (treatCancelAsIdle &&
        (result.error == AuthError.cancelled ||
            result.error == AuthError.oauthInProgress)) {
      // For OAuth: browser opened, waiting for callback via authStateChanges
      // For cancelled: user closed the OAuth dialog
      _status = AuthStatus.idle;
      _errorMessage = null;
    } else {
      _status = AuthStatus.error;
      _errorMessage = result.displayError;
    }
    notifyListeners();
  }
}
