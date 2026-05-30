enum AccountType {
  asset,
  liability,
  equity,
  revenue,
  expense,
}

enum AccountCategory {
  cash,
  feesIncome,
  agentReceivable,
  customerReceivable,
  customerPayable,
  expenseGeneral,
  equityCapital,
}

class Account {
  final String id;
  final String code;
  final String name;
  final AccountType type;
  final AccountCategory category;
  final double openingBalance;
  final double currentBalance;
  final bool isActive;
  final DateTime createdAt;

  const Account({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.category,
    this.openingBalance = 0.0,
    this.currentBalance = 0.0,
    this.isActive = true,
    required this.createdAt,
  });

  Account copyWith({
    String? id,
    String? code,
    String? name,
    AccountType? type,
    AccountCategory? category,
    double? openingBalance,
    double? currentBalance,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'name': name,
        'type': type.name,
        'category': category.name,
        'openingBalance': openingBalance,
        'currentBalance': currentBalance,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Account.fromMap(Map<String, dynamic> map) => Account(
        id: map['id'] as String,
        code: map['code'] as String,
        name: map['name'] as String,
        type: AccountType.values.byName(map['type'] as String),
        category: AccountCategory.values.byName(map['category'] as String),
        openingBalance: (map['openingBalance'] as num).toDouble(),
        currentBalance: (map['currentBalance'] as num).toDouble(),
        isActive: map['isActive'] as bool,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  static Account cashAccount() => Account(
        id: 'acc_cash',
        code: '1001',
        name: 'صندوق النقدية',
        type: AccountType.asset,
        category: AccountCategory.cash,
        createdAt: DateTime.now(),
      );

  static Account feesIncomeAccount() => Account(
        id: 'acc_fees',
        code: '4001',
        name: 'إيرادات العمولات',
        type: AccountType.revenue,
        category: AccountCategory.feesIncome,
        createdAt: DateTime.now(),
      );

  static Account agentAccount(String agentName) => Account(
        id: 'acc_agent_${agentName.replaceAll(' ', '_')}',
        code: '2001',
        name: 'حساب الوكيل - $agentName',
        type: AccountType.liability,
        category: AccountCategory.agentReceivable,
        createdAt: DateTime.now(),
      );
}
