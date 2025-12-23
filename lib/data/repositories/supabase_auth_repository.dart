import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'auth_repository.dart';

/// Supabase implementation of AuthRepository
/// Handles real authentication with Supabase backend
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        return AuthResult.success(_mapUser(response.user!));
      }
      return AuthResult.failure(AuthError.unknown);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthException(e), e.message);
    } catch (e) {
      return AuthResult.failure(AuthError.unknown, e.toString());
    }
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        return AuthResult.success(_mapUser(response.user!));
      }
      return AuthResult.failure(AuthError.unknown);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthException(e), e.message);
    } catch (e) {
      return AuthResult.failure(AuthError.unknown, e.toString());
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final success = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.subtracker://login-callback',
      );

      if (success) {
        // OAuth flow initiated - user will be redirected to browser
        // The actual user will be available via authStateChanges after deep link callback
        // Note: currentUser will be null until the callback completes
        return AuthResult.failure(AuthError.oauthInProgress);
      }
      return AuthResult.failure(AuthError.cancelled);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthException(e), e.message);
    } catch (e) {
      return AuthResult.failure(AuthError.networkError, e.toString());
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      final success = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.subtracker://login-callback',
      );

      if (success) {
        // OAuth flow initiated - user will be redirected to browser
        // The actual user will be available via authStateChanges after deep link callback
        return AuthResult.failure(AuthError.oauthInProgress);
      }
      return AuthResult.failure(AuthError.cancelled);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthException(e), e.message);
    } catch (e) {
      return AuthResult.failure(AuthError.notAvailable, e.toString());
    }
  }

  @override
  Future<AuthResult> signOut() async {
    try {
      await _client.auth.signOut();
      return AuthResult.success(AppUser(
        id: '',
        email: '',
        createdAt: DateTime.now(),
      ));
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthException(e), e.message);
    } catch (e) {
      return AuthResult.failure(AuthError.unknown, e.toString());
    }
  }

  @override
  Future<AuthResult> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      return AuthResult.success(AppUser(
        id: '',
        email: email,
        createdAt: DateTime.now(),
      ));
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthException(e), e.message);
    } catch (e) {
      return AuthResult.failure(AuthError.unknown, e.toString());
    }
  }

  @override
  AppUser? getCurrentUser() {
    final user = _client.auth.currentUser;
    return user != null ? _mapUser(user) : null;
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? _mapUser(user) : null;
    });
  }

  @override
  bool get isAuthenticated => _client.auth.currentUser != null;

  // Private helpers

  AppUser _mapUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['full_name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      provider: _mapProvider(user.appMetadata['provider'] as String?),
    );
  }

  AuthProvider _mapProvider(String? provider) {
    switch (provider) {
      case 'google':
        return AuthProvider.google;
      case 'apple':
        return AuthProvider.apple;
      default:
        return AuthProvider.email;
    }
  }

  AuthError _mapAuthException(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid email') || message.contains('email')) {
      return AuthError.invalidEmail;
    }
    if (message.contains('weak password') || message.contains('password should be')) {
      return AuthError.weakPassword;
    }
    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('user already registered')) {
      return AuthError.emailAlreadyInUse;
    }
    if (message.contains('user not found') || message.contains('no user')) {
      return AuthError.userNotFound;
    }
    if (message.contains('invalid credentials') ||
        message.contains('invalid login') ||
        message.contains('wrong password')) {
      return AuthError.wrongPassword;
    }
    if (message.contains('too many requests') || message.contains('rate limit')) {
      return AuthError.tooManyAttempts;
    }
    if (message.contains('network') || message.contains('connection')) {
      return AuthError.networkError;
    }

    return AuthError.unknown;
  }
}
