import 'package:flutter/foundation.dart';

/// Authentication provider type
enum AuthProvider { email, google, apple }

/// User model abstraction over Supabase User
/// Provides a clean interface for the app's auth layer
@immutable
class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final AuthProvider provider;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.provider = AuthProvider.email,
  });

  /// Whether the user signed up via email/password
  bool get isEmailUser => provider == AuthProvider.email;

  /// Whether the user signed up via Google OAuth
  bool get isGoogleUser => provider == AuthProvider.google;

  /// Whether the user signed up via Apple Sign In
  bool get isAppleUser => provider == AuthProvider.apple;

  /// Display name or email prefix as fallback
  String get displayNameOrEmail => displayName ?? email.split('@').first;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    AuthProvider? provider,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      provider: provider ?? this.provider,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.createdAt == createdAt &&
        other.provider == provider;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, displayName, photoUrl, createdAt, provider);
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, provider: $provider)';
  }
}
