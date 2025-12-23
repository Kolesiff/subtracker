import 'package:flutter/material.dart';

/// User settings model for app preferences
/// Synced with Supabase user_settings table
class UserSettings {
  final String id;
  final String userId;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettings({
    required this.id,
    required this.userId,
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.currency = 'USD',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Default settings for a new user
  factory UserSettings.defaults(String userId) {
    final now = DateTime.now();
    return UserSettings(
      id: '',
      userId: userId,
      themeMode: ThemeMode.system,
      notificationsEnabled: true,
      currency: 'USD',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create from Supabase JSON response
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      themeMode: _parseThemeMode(json['theme_mode'] as String?),
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'USD',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'theme_mode': _themeModeToString(themeMode),
      'notifications_enabled': notificationsEnabled,
      'currency': currency,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Copy with new values
  UserSettings copyWith({
    String? id,
    String? userId,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  static ThemeMode _parseThemeMode(String? mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          themeMode == other.themeMode &&
          notificationsEnabled == other.notificationsEnabled &&
          currency == other.currency;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      themeMode.hashCode ^
      notificationsEnabled.hashCode ^
      currency.hashCode;

  @override
  String toString() {
    return 'UserSettings(id: $id, userId: $userId, themeMode: $themeMode, '
        'notificationsEnabled: $notificationsEnabled, currency: $currency)';
  }
}

/// Supported currencies
class SupportedCurrencies {
  static const List<String> all = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'JPY',
    'CNY',
    'INR',
    'BRL',
    'MXN',
  ];

  static String symbol(String code) {
    switch (code) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'A\$';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'BRL':
        return 'R\$';
      case 'MXN':
        return 'MX\$';
      default:
        return '\$';
    }
  }

  static String name(String code) {
    switch (code) {
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound';
      case 'CAD':
        return 'Canadian Dollar';
      case 'AUD':
        return 'Australian Dollar';
      case 'JPY':
        return 'Japanese Yen';
      case 'CNY':
        return 'Chinese Yuan';
      case 'INR':
        return 'Indian Rupee';
      case 'BRL':
        return 'Brazilian Real';
      case 'MXN':
        return 'Mexican Peso';
      default:
        return code;
    }
  }
}
