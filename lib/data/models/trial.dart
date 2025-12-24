import 'package:flutter/material.dart';
import 'subscription.dart';

/// Urgency level for trial expiration
enum UrgencyLevel {
  critical, // < 24 hours
  warning, // 1-7 days
  safe; // > 7 days

  String get displayName {
    switch (this) {
      case UrgencyLevel.critical:
        return 'Critical';
      case UrgencyLevel.warning:
        return 'Warning';
      case UrgencyLevel.safe:
        return 'Safe';
    }
  }

  Color get color {
    switch (this) {
      case UrgencyLevel.critical:
        return const Color(0xFFE74C3C); // Red
      case UrgencyLevel.warning:
        return const Color(0xFFF39C12); // Amber
      case UrgencyLevel.safe:
        return const Color(0xFF2ECC71); // Green
    }
  }

  static UrgencyLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'critical':
        return UrgencyLevel.critical;
      case 'warning':
        return UrgencyLevel.warning;
      default:
        return UrgencyLevel.safe;
    }
  }

  static UrgencyLevel fromDaysRemaining(int days) {
    if (days < 1) return UrgencyLevel.critical;
    if (days <= 7) return UrgencyLevel.warning;
    return UrgencyLevel.safe;
  }

  static UrgencyLevel fromHoursRemaining(int hours) {
    if (hours < 24) return UrgencyLevel.critical;
    if (hours <= 168) return UrgencyLevel.warning; // 7 days
    return UrgencyLevel.safe;
  }
}

/// Cancellation difficulty rating
enum CancellationDifficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case CancellationDifficulty.easy:
        return 'Easy';
      case CancellationDifficulty.medium:
        return 'Medium';
      case CancellationDifficulty.hard:
        return 'Hard';
    }
  }

  Color get color {
    switch (this) {
      case CancellationDifficulty.easy:
        return const Color(0xFF2ECC71); // Green
      case CancellationDifficulty.medium:
        return const Color(0xFFF39C12); // Amber
      case CancellationDifficulty.hard:
        return const Color(0xFFE74C3C); // Red
    }
  }

  static CancellationDifficulty fromString(String value) {
    switch (value.toLowerCase()) {
      case 'easy':
        return CancellationDifficulty.easy;
      case 'hard':
        return CancellationDifficulty.hard;
      default:
        return CancellationDifficulty.medium;
    }
  }
}

/// Immutable Trial model for tracking free trial periods
class Trial {
  final String id;
  final String serviceName;
  final String? logoUrl;
  final String? semanticLabel;
  final SubscriptionCategory category;
  final DateTime trialEndDate;
  final double conversionCost;
  final CancellationDifficulty cancellationDifficulty;
  final String? cancellationUrl;
  final DateTime? createdAt;
  final String? notes;
  final bool isNotificationEnabled;

  const Trial({
    required this.id,
    required this.serviceName,
    this.logoUrl,
    this.semanticLabel,
    required this.category,
    required this.trialEndDate,
    required this.conversionCost,
    this.cancellationDifficulty = CancellationDifficulty.medium,
    this.cancellationUrl,
    this.createdAt,
    this.notes,
    this.isNotificationEnabled = true,
  });

  /// Calculate urgency level based on time remaining
  UrgencyLevel get urgencyLevel {
    final hours = hoursRemaining;
    return UrgencyLevel.fromHoursRemaining(hours);
  }

  /// Days until trial ends
  int get daysRemaining {
    return trialEndDate.difference(DateTime.now()).inDays;
  }

  /// Hours until trial ends
  int get hoursRemaining {
    return trialEndDate.difference(DateTime.now()).inHours;
  }

  /// Whether trial has expired
  bool get isExpired => trialEndDate.isBefore(DateTime.now());

  /// Whether trial is expiring within 24 hours
  bool get isCritical => hoursRemaining < 24 && !isExpired;

  /// Whether trial needs attention (within 7 days)
  bool get needsAttention => daysRemaining <= 7 && !isExpired;

  /// Formatted conversion cost string
  String get formattedConversionCost =>
      '\$${conversionCost.toStringAsFixed(2)}/month';

  /// Human-readable time remaining
  String get timeRemainingText {
    if (isExpired) return 'Expired';

    final hours = hoursRemaining;
    if (hours < 1) {
      final minutes = trialEndDate.difference(DateTime.now()).inMinutes;
      return '$minutes min left';
    }
    if (hours < 24) return '$hours hours left';

    final days = daysRemaining;
    if (days == 1) return '1 day left';
    return '$days days left';
  }

  /// Create a copy with modified fields
  Trial copyWith({
    String? id,
    String? serviceName,
    String? logoUrl,
    String? semanticLabel,
    SubscriptionCategory? category,
    DateTime? trialEndDate,
    double? conversionCost,
    CancellationDifficulty? cancellationDifficulty,
    String? cancellationUrl,
    DateTime? createdAt,
    String? notes,
    bool? isNotificationEnabled,
  }) {
    return Trial(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      logoUrl: logoUrl ?? this.logoUrl,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      category: category ?? this.category,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      conversionCost: conversionCost ?? this.conversionCost,
      cancellationDifficulty:
          cancellationDifficulty ?? this.cancellationDifficulty,
      cancellationUrl: cancellationUrl ?? this.cancellationUrl,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }

  /// Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceName': serviceName,
      'logoUrl': logoUrl,
      'semanticLabel': semanticLabel,
      'category': category.name,
      'trialEndDate': trialEndDate.toIso8601String(),
      'conversionCost': conversionCost,
      'cancellationDifficulty': cancellationDifficulty.name,
      'cancellationUrl': cancellationUrl,
      'createdAt': createdAt?.toIso8601String(),
      'notes': notes,
      'isNotificationEnabled': isNotificationEnabled,
    };
  }

  /// Create from Map (for deserialization)
  factory Trial.fromMap(Map<String, dynamic> map) {
    return Trial(
      id: map['id'].toString(),
      serviceName: map['serviceName'] as String,
      logoUrl: map['logoUrl'] as String?,
      semanticLabel: map['semanticLabel'] as String?,
      category: SubscriptionCategory.fromString(map['category'] as String),
      trialEndDate: DateTime.parse(map['trialEndDate'] as String),
      conversionCost: (map['conversionCost'] as num).toDouble(),
      cancellationDifficulty: CancellationDifficulty.fromString(
        map['cancellationDifficulty'] as String,
      ),
      cancellationUrl: map['cancellationUrl'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      notes: map['notes'] as String?,
      isNotificationEnabled: map['isNotificationEnabled'] as bool? ?? true,
    );
  }

  /// Create from Supabase JSON (snake_case keys)
  factory Trial.fromJson(Map<String, dynamic> json) {
    return Trial(
      id: json['id'] as String,
      serviceName: json['service_name'] as String,
      logoUrl: json['logo_url'] as String?,
      semanticLabel: json['semantic_label'] as String?,
      category: SubscriptionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => SubscriptionCategory.other,
      ),
      trialEndDate: DateTime.parse(json['trial_end_date'] as String),
      conversionCost: (json['conversion_cost'] as num).toDouble(),
      cancellationDifficulty: CancellationDifficulty.values.firstWhere(
        (e) => e.name == json['cancellation_difficulty'],
        orElse: () => CancellationDifficulty.medium,
      ),
      cancellationUrl: json['cancellation_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      notes: json['notes'] as String?,
      isNotificationEnabled: json['is_notification_enabled'] as bool? ?? true,
    );
  }

  /// Convert to Supabase JSON (snake_case keys, excludes id for inserts)
  Map<String, dynamic> toJson() {
    return {
      'service_name': serviceName,
      'logo_url': logoUrl,
      'category': category.name,
      'trial_end_date': trialEndDate.toIso8601String(),
      'conversion_cost': conversionCost,
      'cancellation_difficulty': cancellationDifficulty.name,
      'cancellation_url': cancellationUrl,
      'notes': notes,
      'is_notification_enabled': isNotificationEnabled,
    };
  }

  /// Convert to Supabase JSON with ID (for updates)
  Map<String, dynamic> toJsonWithId() {
    return {
      'id': id,
      ...toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trial && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Trial(id: $id, serviceName: $serviceName, urgency: ${urgencyLevel.displayName}, daysRemaining: $daysRemaining)';
  }
}
