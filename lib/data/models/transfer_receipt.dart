import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../../core/utils/arabic_formatters.dart';

class TransferReceipt {
  const TransferReceipt({
    required this.id,
    required this.receiptNumber,
    required this.transferNumber,
    required this.referenceNumber,
    required this.createdAt,
    required this.amount,
    required this.fee,
    required this.currency,
    required this.senderName,
    required this.receiverName,
    required this.senderPhone,
    required this.receiverPhone,
    required this.destination,
    required this.agent,
    required this.employeeName,
    required this.notes,
    required this.employeeSignature,
    required this.isArchived,
  });

  final String id;
  final String receiptNumber;
  final String transferNumber;
  final String referenceNumber;
  final DateTime createdAt;
  final double amount;
  final double fee;
  final String currency;
  final String senderName;
  final String receiverName;
  final String senderPhone;
  final String receiverPhone;
  final String destination;
  final String agent;
  final String employeeName;
  final String notes;
  final String employeeSignature;
  final bool isArchived;

  double get total => amount + fee;

  String get qrData {
    return jsonEncode({
      'receiptNumber': receiptNumber,
      'transferNumber': transferNumber,
      'referenceNumber': referenceNumber,
      'createdAt': createdAt.toIso8601String(),
      'amount': amount,
      'fee': fee,
      'total': total,
      'currency': currency,
      'senderName': senderName,
      'receiverName': receiverName,
      'senderPhone': senderPhone,
      'receiverPhone': receiverPhone,
      'destination': destination,
      'employeeName': employeeName,
    });
  }

  TransferReceipt copyWith({
    String? id,
    String? receiptNumber,
    String? transferNumber,
    String? referenceNumber,
    DateTime? createdAt,
    double? amount,
    double? fee,
    String? currency,
    String? senderName,
    String? receiverName,
    String? senderPhone,
    String? receiverPhone,
    String? destination,
    String? agent,
    String? employeeName,
    String? notes,
    String? employeeSignature,
    bool? isArchived,
  }) {
    return TransferReceipt(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      transferNumber: transferNumber ?? this.transferNumber,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      createdAt: createdAt ?? this.createdAt,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      currency: currency ?? this.currency,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
      senderPhone: senderPhone ?? this.senderPhone,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      destination: destination ?? this.destination,
      agent: agent ?? this.agent,
      employeeName: employeeName ?? this.employeeName,
      notes: notes ?? this.notes,
      employeeSignature: employeeSignature ?? this.employeeSignature,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receiptNumber': receiptNumber,
      'transferNumber': transferNumber,
      'referenceNumber': referenceNumber,
      'createdAt': createdAt.toIso8601String(),
      'amount': amount,
      'fee': fee,
      'currency': currency,
      'senderName': senderName,
      'receiverName': receiverName,
      'senderPhone': senderPhone,
      'receiverPhone': receiverPhone,
      'destination': destination,
      'agent': agent,
      'employeeName': employeeName,
      'notes': notes,
      'employeeSignature': employeeSignature,
      'isArchived': isArchived,
    };
  }

  factory TransferReceipt.fromMap(Map<dynamic, dynamic> map) {
    return TransferReceipt(
      id: map['id'] as String,
      receiptNumber: map['receiptNumber'] as String,
      transferNumber: map['transferNumber'] as String,
      referenceNumber: map['referenceNumber'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      amount: (map['amount'] as num).toDouble(),
      fee: (map['fee'] as num).toDouble(),
      currency: map['currency'] as String,
      senderName: map['senderName'] as String,
      receiverName: map['receiverName'] as String,
      senderPhone: map['senderPhone'] as String,
      receiverPhone: map['receiverPhone'] as String,
      destination: map['destination'] as String,
      agent: map['agent'] as String? ?? AppConstants.defaultAgent,
      employeeName: map['employeeName'] as String,
      notes: map['notes'] as String,
      employeeSignature: map['employeeSignature'] as String? ?? '',
      isArchived: map['isArchived'] as bool? ?? false,
    );
  }

  static TransferReceipt demo() {
    final now = DateTime(2026, 5, 19, 17, 30, 48);
    return TransferReceipt(
      id: 'demo-6075942892',
      receiptNumber: '24049',
      transferNumber: '6075942892',
      referenceNumber: '814475007',
      createdAt: now,
      amount: 100,
      fee: 2.18,
      currency: AppConstants.defaultCurrency,
      senderName: 'عمري محفوظ قاسم محمد',
      receiverName: 'عبده أحمد سالم القدري',
      senderPhone: '771623866',
      receiverPhone: '770878456',
      destination: AppConstants.defaultDestination,
      agent: AppConstants.defaultAgent,
      employeeName: AppConstants.defaultEmployee,
      notes: 'الإكسبرس ${ArabicFormatters.toArabicDigits('814475007')}',
      employeeSignature: 'صندوق رعد عبدالوارت',
      isArchived: false,
    );
  }
}
