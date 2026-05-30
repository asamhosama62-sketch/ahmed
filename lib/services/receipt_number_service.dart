import 'dart:math';

class ReceiptNumberService {
  const ReceiptNumberService();

  String generateId() {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'TR-$stamp-$random';
  }

  String generateReceiptNumber() {
    final now = DateTime.now();
    return '${now.day}${now.hour}${now.minute}${Random().nextInt(90) + 10}';
  }

  String generateTransferNumber() {
    final random = Random();
    final first = 6000000000 + random.nextInt(399999999);
    return first.toString();
  }

  String generateReferenceNumber() {
    final random = Random();
    return (810000000 + random.nextInt(8999999)).toString();
  }
}
