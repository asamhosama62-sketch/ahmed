enum LoyaltyTier {
  regular,
  silver,
  gold,
  platinum,
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String? secondaryPhone;
  final int totalTransfersSent;
  final int totalTransfersReceived;
  final double totalAmountSent;
  final double totalAmountReceived;
  final double totalFeesPaid;
  final int loyaltyPoints;
  final LoyaltyTier tier;
  final String? preferredCurrency;
  final String? preferredAgent;
  final String? notes;
  final bool isActive;
  final DateTime firstTransactionDate;
  final DateTime lastTransactionDate;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.secondaryPhone,
    this.totalTransfersSent = 0,
    this.totalTransfersReceived = 0,
    this.totalAmountSent = 0.0,
    this.totalAmountReceived = 0.0,
    this.totalFeesPaid = 0.0,
    this.loyaltyPoints = 0,
    this.tier = LoyaltyTier.regular,
    this.preferredCurrency,
    this.preferredAgent,
    this.notes,
    this.isActive = true,
    required this.firstTransactionDate,
    required this.lastTransactionDate,
    required this.createdAt,
  });

  int get totalTransactions => totalTransfersSent + totalTransfersReceived;
  double get totalVolume => totalAmountSent + totalAmountReceived;

  double get discountRate {
    switch (tier) {
      case LoyaltyTier.regular:
        return 0.0;
      case LoyaltyTier.silver:
        return 0.05;
      case LoyaltyTier.gold:
        return 0.10;
      case LoyaltyTier.platinum:
        return 0.20;
    }
  }

  String get tierLabel {
    switch (tier) {
      case LoyaltyTier.regular:
        return 'عادي';
      case LoyaltyTier.silver:
        return 'فضي';
      case LoyaltyTier.gold:
        return 'ذهبي';
      case LoyaltyTier.platinum:
        return 'بلاتيني';
    }
  }

  LoyaltyTier calculateTier() {
    if (totalTransactions >= 100 && totalVolume >= 5000000) {
      return LoyaltyTier.platinum;
    } else if (totalTransactions >= 50 && totalVolume >= 1000000) {
      return LoyaltyTier.gold;
    } else if (totalTransactions >= 20 && totalVolume >= 250000) {
      return LoyaltyTier.silver;
    }
    return LoyaltyTier.regular;
  }

  int calculatePoints() {
    return (totalFeesPaid ~/ 10) + (totalTransactions * 5);
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? secondaryPhone,
    int? totalTransfersSent,
    int? totalTransfersReceived,
    double? totalAmountSent,
    double? totalAmountReceived,
    double? totalFeesPaid,
    int? loyaltyPoints,
    LoyaltyTier? tier,
    String? preferredCurrency,
    String? preferredAgent,
    String? notes,
    bool? isActive,
    DateTime? firstTransactionDate,
    DateTime? lastTransactionDate,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      totalTransfersSent: totalTransfersSent ?? this.totalTransfersSent,
      totalTransfersReceived:
          totalTransfersReceived ?? this.totalTransfersReceived,
      totalAmountSent: totalAmountSent ?? this.totalAmountSent,
      totalAmountReceived: totalAmountReceived ?? this.totalAmountReceived,
      totalFeesPaid: totalFeesPaid ?? this.totalFeesPaid,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      tier: tier ?? this.tier,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      preferredAgent: preferredAgent ?? this.preferredAgent,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      firstTransactionDate:
          firstTransactionDate ?? this.firstTransactionDate,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'secondaryPhone': secondaryPhone,
        'totalTransfersSent': totalTransfersSent,
        'totalTransfersReceived': totalTransfersReceived,
        'totalAmountSent': totalAmountSent,
        'totalAmountReceived': totalAmountReceived,
        'totalFeesPaid': totalFeesPaid,
        'loyaltyPoints': loyaltyPoints,
        'tier': tier.name,
        'preferredCurrency': preferredCurrency,
        'preferredAgent': preferredAgent,
        'notes': notes,
        'isActive': isActive,
        'firstTransactionDate': firstTransactionDate.toIso8601String(),
        'lastTransactionDate': lastTransactionDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
        id: map['id'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String,
        secondaryPhone: map['secondaryPhone'] as String?,
        totalTransfersSent: map['totalTransfersSent'] as int,
        totalTransfersReceived: map['totalTransfersReceived'] as int,
        totalAmountSent: (map['totalAmountSent'] as num).toDouble(),
        totalAmountReceived: (map['totalAmountReceived'] as num).toDouble(),
        totalFeesPaid: (map['totalFeesPaid'] as num).toDouble(),
        loyaltyPoints: map['loyaltyPoints'] as int,
        tier: LoyaltyTier.values.byName(map['tier'] as String),
        preferredCurrency: map['preferredCurrency'] as String?,
        preferredAgent: map['preferredAgent'] as String?,
        notes: map['notes'] as String?,
        isActive: map['isActive'] as bool,
        firstTransactionDate:
            DateTime.parse(map['firstTransactionDate'] as String),
        lastTransactionDate:
            DateTime.parse(map['lastTransactionDate'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
