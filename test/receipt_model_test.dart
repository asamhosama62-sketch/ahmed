import 'package:flutter_test/flutter_test.dart';

import 'package:ahmed/core/utils/arabic_formatters.dart';
import 'package:ahmed/data/models/transfer_receipt.dart';

void main() {
  test('demo receipt computes total and QR payload', () {
    final receipt = TransferReceipt.demo();

    expect(receipt.total, closeTo(102.18, .001));
    expect(receipt.qrData, contains(receipt.transferNumber));
    expect(ArabicFormatters.toArabicDigits('123'), '١٢٣');
  });
}
