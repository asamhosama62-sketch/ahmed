import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/arabic_formatters.dart';
import '../../data/models/transfer_receipt.dart';

class ReceiptDocumentWidget extends StatelessWidget {
  const ReceiptDocumentWidget({
    super.key,
    required this.receipt,
    this.compact = false,
  });

  final TransferReceipt receipt;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: compact ? 340 : 760,
        color: Colors.white,
        padding: EdgeInsets.all(compact ? 10 : 18),
        child: DefaultTextStyle(
          style: TextStyle(
            color: Colors.black87,
            fontSize: compact ? 10 : 13,
            height: 1.25,
            fontFamily: 'Cairo',
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(compact ? 8 : 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(compact: compact),
                  const SizedBox(height: 8),
                  _TopNumbers(receipt: receipt),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _BoxCell(
                          label: 'التاريخ',
                          value: ArabicFormatters.formatDate(receipt.createdAt),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: compact ? 36 : 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black87),
                            color: colors.primary.withValues(alpha: .06),
                          ),
                          child: Text(
                            'سند قبض حوالة',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: compact ? 18 : 26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  _ReceiptGrid(receipt: receipt),
                  const SizedBox(height: 10),
                  _Footer(receipt: receipt, compact: compact),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                AppConstants.companyName,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              SizedBox(height: 2),
              Text(AppConstants.companyAddress),
              Text(AppConstants.companyPhones),
            ],
          ),
        ),
        _Logo(size: compact ? 58 : 76),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'بن شمسان',
                style: TextStyle(
                  fontSize: compact ? 25 : 32,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                color: Colors.grey.shade300,
                child: Text(
                  'للصرافة والتحويلات',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 12 : 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade700, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BS',
              style: TextStyle(
                fontSize: size * .28,
                fontWeight: FontWeight.w900,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              'Exchange',
              style: TextStyle(
                fontSize: size * .09,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNumbers extends StatelessWidget {
  const _TopNumbers({required this.receipt});

  final TransferReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BoxCell(
            label: 'رقم الصادر',
            value: receipt.receiptNumber,
            emphasized: true,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 2,
          child: _BoxCell(
            label:
                'رقم الحوالة ${ArabicFormatters.toArabicDigits(receipt.transferNumber)}',
            value:
                'الإكسبرس المرجعي - ${ArabicFormatters.toArabicDigits(receipt.referenceNumber)}',
            emphasized: true,
          ),
        ),
      ],
    );
  }
}

class _ReceiptGrid extends StatelessWidget {
  const _ReceiptGrid({required this.receipt});

  final TransferReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DataCell(
                label: 'مبلغ الحوالة',
                value:
                    '#${ArabicFormatters.formatPlainAmount(receipt.amount)}#',
              ),
            ),
            Expanded(
              child: _DataCell(label: 'عملة الحوالة', value: receipt.currency),
            ),
            Expanded(
              child: _DataCell(
                label: 'خدمات التحويل',
                value: ArabicFormatters.formatAmount(
                  receipt.fee,
                  currency: receipt.currency,
                ),
              ),
            ),
            Expanded(
              child: _DataCell(
                label: 'الإجمالي المقبوض',
                value: ArabicFormatters.formatAmount(
                  receipt.total,
                  currency: receipt.currency,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _DataCell(
                label: 'مبلغ الحوالة كتابة',
                value: ArabicFormatters.amountToArabicWords(
                  receipt.amount,
                  receipt.currency,
                ),
              ),
            ),
            Expanded(
              child: _DataCell(label: 'الجهة', value: receipt.destination),
            ),
          ],
        ),
        _WideCell(
          label: 'الوكيل',
          value:
              '${receipt.agent} - ${ArabicFormatters.toArabicDigits('8008800')}',
        ),
        Row(
          children: [
            const Expanded(
              child: _DataCell(label: 'رقم البطاقة', value: ''),
            ),
            Expanded(
              child: _DataCell(
                label: 'اسم المستلم',
                value: receipt.receiverName,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _DataCell(
                label: 'رقم السند',
                value: receipt.receiptNumber,
              ),
            ),
            Expanded(
              child: _DataCell(label: 'اسم المرسل', value: receipt.senderName),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _DataCell(
                label: 'تلفون المرسل',
                value: receipt.senderPhone,
              ),
            ),
            Expanded(
              child: _DataCell(
                label: 'تلفون المستلم',
                value: receipt.receiverPhone,
              ),
            ),
          ],
        ),
        _WideCell(label: 'ملاحظات', value: receipt.notes),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.receipt, required this.compact});

  final TransferReceipt receipt;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        QrImageView(
          data: receipt.qrData,
          size: compact ? 86 : 112,
          backgroundColor: Colors.white,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SignatureBox(
                      title: 'توقيع الموظف',
                      value: receipt.employeeSignature,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: _SignatureBox(title: 'الختم', value: ''),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'الفرع: ${AppConstants.branchName}    الموظف: ${receipt.employeeName}',
                style: const TextStyle(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              Text(
                ArabicFormatters.formatDateTime(receipt.createdAt),
                style: const TextStyle(fontWeight: FontWeight.w900),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BoxCell extends StatelessWidget {
  const _BoxCell({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.black87)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, textAlign: TextAlign.center),
          Text(
            ArabicFormatters.toArabicDigits(value),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: emphasized ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: .8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 94,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Text(
              ArabicFormatters.toArabicDigits(value),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _WideCell extends StatelessWidget {
  const _WideCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: .8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Text(
              ArabicFormatters.toArabicDigits(value),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignatureBox extends StatelessWidget {
  const _SignatureBox({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: Colors.black87)),
          child: Text(value, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
