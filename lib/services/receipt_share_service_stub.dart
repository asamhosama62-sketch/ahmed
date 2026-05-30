import 'dart:typed_data';

import 'package:pdf/pdf.dart';

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
    throw UnsupportedError('المشاركة غير مدعومة على هذه المنصة.');
  }

  Future<void> openPdf(
    TransferReceipt receipt, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    AppSettings? settings,
  }) async {
    throw UnsupportedError('فتح PDF غير مدعوم على هذه المنصة.');
  }

  Future<String?> savePdf(
    TransferReceipt receipt, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    AppSettings? settings,
  }) async {
    throw UnsupportedError('حفظ PDF غير مدعوم على هذه المنصة.');
  }
}
