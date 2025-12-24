import 'package:flutter/material.dart';

/// Parse color from either int or hex string format (handles Supabase data)
Color _parseColor(dynamic value) {
  if (value == null) return const Color(0xFF000000);
  if (value is int) return Color(value);
  if (value is String) {
    // Handle hex string like "#FF6B35FF" or "FF6B35FF"
    final hex = value.replaceFirst('#', '');
    return Color(int.parse(hex, radix: 16));
  }
  return const Color(0xFF000000);
}

/// Billing cycle for subscriptions
enum BillingCycle {
  weekly,
  monthly,
  quarterly,
  yearly;

  String get displayName {
    switch (this) {
      case BillingCycle.weekly:
        return 'Weekly';
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }

  static BillingCycle fromString(String value) {
    switch (value.toLowerCase()) {
      case 'weekly':
        return BillingCycle.weekly;
      case 'quarterly':
        return BillingCycle.quarterly;
      case 'yearly':
      case 'annual':
        return BillingCycle.yearly;
      default:
        return BillingCycle.monthly;
    }
  }
}

/// Status of a subscription
enum SubscriptionStatus {
  active,
  trial,
  paused,
  cancelled,
  expired;

  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.trial:
        return 'Trial';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
    }
  }

  static SubscriptionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'trial':
        return SubscriptionStatus.trial;
      case 'paused':
        return SubscriptionStatus.paused;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'expired':
        return SubscriptionStatus.expired;
      default:
        return SubscriptionStatus.active;
    }
  }
}

/// Subscription category
enum SubscriptionCategory {
  entertainment,
  music,
  productivity,
  shopping,
  development,
  health,
  professional,
  education,
  utilities,
  other;

  String get displayName {
    switch (this) {
      case SubscriptionCategory.entertainment:
        return 'Entertainment';
      case SubscriptionCategory.music:
        return 'Music';
      case SubscriptionCategory.productivity:
        return 'Productivity';
      case SubscriptionCategory.shopping:
        return 'Shopping';
      case SubscriptionCategory.development:
        return 'Development';
      case SubscriptionCategory.health:
        return 'Health';
      case SubscriptionCategory.professional:
        return 'Professional';
      case SubscriptionCategory.education:
        return 'Education';
      case SubscriptionCategory.utilities:
        return 'Utilities';
      case SubscriptionCategory.other:
        return 'Other';
    }
  }

  static SubscriptionCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'entertainment':
        return SubscriptionCategory.entertainment;
      case 'music':
        return SubscriptionCategory.music;
      case 'productivity':
        return SubscriptionCategory.productivity;
      case 'shopping':
        return SubscriptionCategory.shopping;
      case 'development':
        return SubscriptionCategory.development;
      case 'health':
        return SubscriptionCategory.health;
      case 'professional':
        return SubscriptionCategory.professional;
      case 'education':
        return SubscriptionCategory.education;
      case 'utilities':
        return SubscriptionCategory.utilities;
      default:
        return SubscriptionCategory.other;
    }
  }
}

/// Threshold for "expiring soon" in days
const int expiringThresholdDays = 7;

/// Immutable Subscription model
class Subscription {
  final String id;
  final String name;
  final String? logoUrl;
  final String? semanticLabel;
  final double cost;
  final BillingCycle billingCycle;
  final DateTime nextBillingDate;
  final SubscriptionCategory category;
  final SubscriptionStatus status;
  final Color brandColor;
  final DateTime? createdAt;
  final String? notes;

  const Subscription({
    required this.id,
    required this.name,
    this.logoUrl,
    this.semanticLabel,
    required this.cost,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.category,
    this.status = SubscriptionStatus.active,
    required this.brandColor,
    this.createdAt,
    this.notes,
  });

  /// Calculate monthly cost based on billing cycle
  double get monthlyCost {
    switch (billingCycle) {
      case BillingCycle.weekly:
        return cost * 4.33; // Average weeks per month
      case BillingCycle.monthly:
        return cost;
      case BillingCycle.quarterly:
        return cost / 3;
      case BillingCycle.yearly:
        return cost / 12;
    }
  }

  /// Calculate yearly cost
  double get yearlyCost => monthlyCost * 12;

  /// Days until next billing
  int get daysUntilBilling {
    return nextBillingDate.difference(DateTime.now()).inDays;
  }

  /// Hours until next billing (for urgent cases)
  int get hoursUntilBilling {
    return nextBillingDate.difference(DateTime.now()).inHours;
  }

  /// Whether billing is imminent (within threshold)
  bool get isExpiringSoon => daysUntilBilling <= expiringThresholdDays;

  /// Whether this is a trial subscription
  bool get isTrial => status == SubscriptionStatus.trial;

  /// Whether subscription is currently active
  bool get isActive =>
      status == SubscriptionStatus.active || status == SubscriptionStatus.trial;

  /// Formatted cost string
  String get formattedCost => '\$${cost.toStringAsFixed(2)}';

  /// Formatted monthly cost string
  String get formattedMonthlyCost => '\$${monthlyCost.toStringAsFixed(2)}';

  /// Create a copy with modified fields
  Subscription copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? semanticLabel,
    double? cost,
    BillingCycle? billingCycle,
    DateTime? nextBillingDate,
    SubscriptionCategory? category,
    SubscriptionStatus? status,
    Color? brandColor,
    DateTime? createdAt,
    String? notes,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      cost: cost ?? this.cost,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      category: category ?? this.category,
      status: status ?? this.status,
      brandColor: brandColor ?? this.brandColor,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'semanticLabel': semanticLabel,
      'cost': cost,
      'billingCycle': billingCycle.name,
      'nextBillingDate': nextBillingDate.toIso8601String(),
      'category': category.name,
      'status': status.name,
      'brandColor': brandColor.toARGB32(),
      'createdAt': createdAt?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Create from Map (for deserialization)
  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as String,
      name: map['name'] as String,
      logoUrl: map['logoUrl'] as String?,
      semanticLabel: map['semanticLabel'] as String?,
      cost: (map['cost'] as num).toDouble(),
      billingCycle: BillingCycle.fromString(map['billingCycle'] as String),
      nextBillingDate: DateTime.parse(map['nextBillingDate'] as String),
      category: SubscriptionCategory.fromString(map['category'] as String),
      status: SubscriptionStatus.fromString(map['status'] as String),
      brandColor: Color(map['brandColor'] as int),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      notes: map['notes'] as String?,
    );
  }

  /// Create from Supabase JSON (snake_case keys)
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      semanticLabel: json['semantic_label'] as String?,
      cost: (json['cost'] as num).toDouble(),
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.name == json['billing_cycle'],
        orElse: () => BillingCycle.monthly,
      ),
      nextBillingDate: DateTime.parse(json['next_billing_date'] as String),
      category: SubscriptionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => SubscriptionCategory.other,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      brandColor: _parseColor(json['brand_color']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  /// Convert to Supabase JSON (snake_case keys, excludes id for inserts)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo_url': logoUrl,
      'cost': cost,
      'billing_cycle': billingCycle.name,
      'next_billing_date': nextBillingDate.toIso8601String(),
      'category': category.name,
      'status': status.name,
      'brand_color': '#${brandColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
      'notes': notes,
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
    return other is Subscription && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Subscription(id: $id, name: $name, cost: $formattedCost, status: ${status.displayName})';
  }
}
