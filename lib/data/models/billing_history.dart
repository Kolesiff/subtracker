/// Payment status for billing records
enum PaymentStatus {
  completed,
  pending,
  failed,
  refunded;

  String get displayName {
    switch (this) {
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.completed;
    }
  }
}

/// Immutable BillingHistory model for tracking payment records
class BillingHistory {
  final String id;
  final String subscriptionId;
  final DateTime billingDate;
  final double amount;
  final PaymentStatus status;
  final String? paymentMethod;
  final String? transactionId;
  final String? notes;

  const BillingHistory({
    required this.id,
    required this.subscriptionId,
    required this.billingDate,
    required this.amount,
    this.status = PaymentStatus.completed,
    this.paymentMethod,
    this.transactionId,
    this.notes,
  });

  /// Formatted amount string
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  /// Whether this is a successful payment
  bool get isSuccessful => status == PaymentStatus.completed;

  /// Create a copy with modified fields
  BillingHistory copyWith({
    String? id,
    String? subscriptionId,
    DateTime? billingDate,
    double? amount,
    PaymentStatus? status,
    String? paymentMethod,
    String? transactionId,
    String? notes,
  }) {
    return BillingHistory(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      billingDate: billingDate ?? this.billingDate,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'billingDate': billingDate.toIso8601String(),
      'amount': amount,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'notes': notes,
    };
  }

  /// Create from Map (for deserialization)
  factory BillingHistory.fromMap(Map<String, dynamic> map) {
    return BillingHistory(
      id: map['id'] as String,
      subscriptionId: map['subscriptionId'] as String,
      billingDate: DateTime.parse(map['billingDate'] as String),
      amount: (map['amount'] as num).toDouble(),
      status: PaymentStatus.fromString(map['status'] as String),
      paymentMethod: map['paymentMethod'] as String?,
      transactionId: map['transactionId'] as String?,
      notes: map['notes'] as String?,
    );
  }

  /// Create from Supabase JSON (snake_case keys)
  factory BillingHistory.fromJson(Map<String, dynamic> json) {
    return BillingHistory(
      id: json['id'] as String,
      subscriptionId: json['subscription_id'] as String,
      billingDate: DateTime.parse(json['billing_date'] as String),
      amount: (json['amount'] as num).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.completed,
      ),
      paymentMethod: json['payment_method'] as String?,
      transactionId: json['transaction_id'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// Convert to Supabase JSON (snake_case keys, excludes id for inserts)
  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'billing_date': billingDate.toIso8601String(),
      'amount': amount,
      'status': status.name,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
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
    return other is BillingHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BillingHistory(id: $id, amount: $formattedAmount, status: ${status.displayName})';
  }
}
