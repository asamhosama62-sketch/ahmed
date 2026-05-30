import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
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
    final s = settings ?? AppSettings.defaultSettings();
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

  Future<void> sharePdf(
    TransferReceipt receipt, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    AppSettings? settings,
  }) async {
    final bytes = await generatePdf(
      receipt,
      pageFormat: pageFormat,
      settings: settings,
    );
    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: _fileName(receipt),
          mimeType: 'application/pdf',
        ),
      ],
      subject: 'سند قبض حوالة ${receipt.transferNumber}',
      text: 'مرفق سند قبض الحوالة رقم ${receipt.transferNumber}.',
    );
  }

  Future<void> openPdf(
    TransferReceipt receipt, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    AppSettings? settings,
  }) async {
    final bytes = await generatePdf(
      receipt,
      pageFormat: pageFormat,
      settings: settings,
    );
    await Printing.layoutPdf(
      name: _fileName(receipt),
      format: pageFormat,
      onLayout: (_) async => bytes,
    );
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
    await Printing.sharePdf(bytes: bytes, filename: _fileName(receipt));
    return null;
  }

  String _fileName(TransferReceipt receipt) {
    final transfer = receipt.transferNumber.replaceAll(
      RegExp(r'[^0-9A-Za-z_-]'),
      '_',
    );
    return 'receipt_$transfer.pdf';
  }
}
