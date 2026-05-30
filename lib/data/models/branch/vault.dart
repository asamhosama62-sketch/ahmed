enum VaultTransactionType {
  deposit,
  withdrawal,
  transferToAgent,
  transferFromAgent,
  settlement,
  openingBalance,
}

class VaultTransaction {
  final String id;
  final VaultTransactionType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? agentName;
  final String? referenceNumber;
  final String description;
  final String createdBy;
  final DateTime createdAt;

  const VaultTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.agentName,
    this.referenceNumber,
    required this.description,
    required this.createdBy,
    required this.createdAt,
  });

  String get typeLabel {
    switch (type) {
      case VaultTransactionType.deposit:
        return 'إيداع';
      case VaultTransactionType.withdrawal:
        return 'سحب';
      case VaultTransactionType.transferToAgent:
        return 'تحويل لوكيل';
      case VaultTransactionType.transferFromAgent:
        return 'استلام من وكيل';
      case VaultTransactionType.settlement:
        return 'تسوية';
      case VaultTransactionType.openingBalance:
        return 'رصيد افتتاحي';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'balanceBefore': balanceBefore,
        'balanceAfter': balanceAfter,
        'agentName': agentName,
        'referenceNumber': referenceNumber,
        'description': description,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VaultTransaction.fromMap(Map<String, dynamic> map) =>
      VaultTransaction(
        id: map['id'] as String,
        type: VaultTransactionType.values.byName(map['type'] as String),
        amount: (map['amount'] as num).toDouble(),
        balanceBefore: (map['balanceBefore'] as num).toDouble(),
        balanceAfter: (map['balanceAfter'] as num).toDouble(),
        agentName: map['agentName'] as String?,
        referenceNumber: map['referenceNumber'] as String?,
        description: map['description'] as String,
        createdBy: map['createdBy'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class Vault {
  final String id;
  final String name;
  final double currentBalance;
  final double minBalance;
  final double maxBalance;
  final String? branchName;
  final bool isActive;
  final DateTime lastUpdated;
  final DateTime createdAt;

  const Vault({
    required this.id,
    required this.name,
    this.currentBalance = 0.0,
    this.minBalance = 10000,
    this.maxBalance = 5000000,
    this.branchName,
    this.isActive = true,
    required this.lastUpdated,
    required this.createdAt,
  });

  bool get isLowBalance => currentBalance < minBalance;
  bool get isHighBalance => currentBalance > maxBalance;
  double get balanceUtilization =>
      maxBalance > 0 ? (currentBalance / maxBalance) * 100 : 0;

  Vault copyWith({
    String? id,
    String? name,
    double? currentBalance,
    double? minBalance,
    double? maxBalance,
    String? branchName,
    bool? isActive,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return Vault(
      id: id ?? this.id,
      name: name ?? this.name,
      currentBalance: currentBalance ?? this.currentBalance,
      minBalance: minBalance ?? this.minBalance,
      maxBalance: maxBalance ?? this.maxBalance,
      branchName: branchName ?? this.branchName,
      isActive: isActive ?? this.isActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'currentBalance': currentBalance,
        'minBalance': minBalance,
        'maxBalance': maxBalance,
        'branchName': branchName,
        'isActive': isActive,
        'lastUpdated': lastUpdated.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Vault.fromMap(Map<String, dynamic> map) => Vault(
        id: map['id'] as String,
        name: map['name'] as String,
        currentBalance: (map['currentBalance'] as num).toDouble(),
        minBalance: (map['minBalance'] as num).toDouble(),
        maxBalance: (map['maxBalance'] as num).toDouble(),
        branchName: map['branchName'] as String?,
        isActive: map['isActive'] as bool,
        lastUpdated: DateTime.parse(map['lastUpdated'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
