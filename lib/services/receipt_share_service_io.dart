import 'dart:io';
import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models/app_settings.dart';
import '../data/models/transfer_receipt.dart';
import 'receipt_pdf_service.dart';

class ReceiptShareService {
  ReceiptShareService(this._pdfService);

  final ReceiptPdfService _pdfService;

  Future<Uint8List> generatePdf(
    TransferReceipt receipt, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    AppSettings? settings,
  }) {
    final s = settings;
    if (s != null) {
      return _pdfService.generatePdf(
        receipt,
        s.companyName,
        s.branchName,
        s.companyPhones,
        s.companyAddress,
        pageFormat: pageFormat,
        showQrCode: s.showQrCode,
        margin: s.pdfMargin,
        fontSize: s.fontSizePdf,
      );
    }
    return _pdfService.generatePdf(
      receipt,
      'العكابي للصرافة والتحويلات',
      'الفرع الرئيسي',
      '',
      '',
      pageFormat: pageFormat,
    );
  }

  Future<void> sharePdf(
    TransferReceipt receipt, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    AppSettings? settings,
  }) async {
    final filePath = await savePdf(
      receipt,
      pageFormat: pageFormat,
      settings: settings,
    );
    if (filePath == null) return;
    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'application/pdf')],
      subject: 'سند قبض حوالة ${receipt.transferNumber}',
      text: 'مرفق سند قبض الحوالة رقم ${receipt.transferNumber}.',
    );
  }

  Future<void> openPdf(
    TransferReceipt receipt, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    AppSettings? settings,
  }) async {
    final filePath = await savePdf(
      receipt,
      pageFormat: pageFormat,
      settings: settings,
    );
    if (filePath == null) return;
    await OpenFile.open(filePath);
  }

  Future<String?> savePdf(
    TransferReceipt receipt, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    AppSettings? settings,
  }) async {
    final bytes = await generatePdf(
      receipt,
      pageFormat: pageFormat,
      settings: settings,
    );
    final directory = await getApplicationDocumentsDirectory();
    final receiptsDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}receipts',
    );
    if (!receiptsDirectory.existsSync()) {
      await receiptsDirectory.create(recursive: true);
    }
    final file = File(
      '${receiptsDirectory.path}${Platform.pathSeparator}${_fileName(receipt)}',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  String _fileName(TransferReceipt receipt) {
    final transfer = receipt.transferNumber.replaceAll(
      RegExp(r'[^0-9A-Za-z_-]'),
      '_',
    );
    return 'receipt_$transfer.pdf';
  }
}
