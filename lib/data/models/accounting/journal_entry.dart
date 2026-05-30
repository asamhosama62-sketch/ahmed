class JournalEntry {
  final String id;
  final String entryNumber;
  final DateTime date;
  final String description;
  final String debitAccountId;
  final String debitAccountName;
  final String creditAccountId;
  final String creditAccountName;
  final double amount;
  final String? transferReceiptId;
  final String? transferReceiptNumber;
  final String? agentName;
  final String createdBy;
  final DateTime createdAt;

  const JournalEntry({
    required this.id,
    required this.entryNumber,
    required this.date,
    required this.description,
    required this.debitAccountId,
    required this.debitAccountName,
    required this.creditAccountId,
    required this.creditAccountName,
    required this.amount,
    this.transferReceiptId,
    this.transferReceiptNumber,
    this.agentName,
    required this.createdBy,
    required this.createdAt,
  });

  JournalEntry copyWith({
    String? id,
    String? entryNumber,
    DateTime? date,
    String? description,
    String? debitAccountId,
    String? debitAccountName,
    String? creditAccountId,
    String? creditAccountName,
    double? amount,
    String? transferReceiptId,
    String? transferReceiptNumber,
    String? agentName,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      entryNumber: entryNumber ?? this.entryNumber,
      date: date ?? this.date,
      description: description ?? this.description,
      debitAccountId: debitAccountId ?? this.debitAccountId,
      debitAccountName: debitAccountName ?? this.debitAccountName,
      creditAccountId: creditAccountId ?? this.creditAccountId,
      creditAccountName: creditAccountName ?? this.creditAccountName,
      amount: amount ?? this.amount,
      transferReceiptId: transferReceiptId ?? this.transferReceiptId,
      transferReceiptNumber:
          transferReceiptNumber ?? this.transferReceiptNumber,
      agentName: agentName ?? this.agentName,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'entryNumber': entryNumber,
        'date': date.toIso8601String(),
        'description': description,
        'debitAccountId': debitAccountId,
        'debitAccountName': debitAccountName,
        'creditAccountId': creditAccountId,
        'creditAccountName': creditAccountName,
        'amount': amount,
        'transferReceiptId': transferReceiptId,
        'transferReceiptNumber': transferReceiptNumber,
        'agentName': agentName,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
        id: map['id'] as String,
        entryNumber: map['entryNumber'] as String,
        date: DateTime.parse(map['date'] as String),
        description: map['description'] as String,
        debitAccountId: map['debitAccountId'] as String,
        debitAccountName: map['debitAccountName'] as String,
        creditAccountId: map['creditAccountId'] as String,
        creditAccountName: map['creditAccountName'] as String,
        amount: (map['amount'] as num).toDouble(),
        transferReceiptId: map['transferReceiptId'] as String?,
        transferReceiptNumber: map['transferReceiptNumber'] as String?,
        agentName: map['agentName'] as String?,
        createdBy: map['createdBy'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  static JournalEntry fromTransfer(
    String id,
    String entryNumber,
    String debitAccountId,
    String debitAccountName,
    String creditAccountId,
    String creditAccountName,
    double amount,
    String? agentName,
    String transferReceiptId,
    String transferReceiptNumber,
    String description,
    String createdBy,
  ) {
    return JournalEntry(
      id: id,
      entryNumber: entryNumber,
      date: DateTime.now(),
      description: description,
      debitAccountId: debitAccountId,
      debitAccountName: debitAccountName,
      creditAccountId: creditAccountId,
      creditAccountName: creditAccountName,
      amount: amount,
      transferReceiptId: transferReceiptId,
      transferReceiptNumber: transferReceiptNumber,
      agentName: agentName,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
  }
}
