// =============================================================================
// خدمة توليد PDF - تطبيق العكابي - يستخدم خط Cairo المحلي (بدون إنترنت)
// =============================================================================

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/utils/arabic_formatters.dart';
import '../data/models/transfer_receipt.dart';

/// خدمة توليد سندات PDF احترافية
/// تستخدم خط Cairo المضمّن محلياً - لا تحتاج إنترنت
class ReceiptPdfService {
  // ─── تحميل خط Cairo المحلي ───────────────────────────────────────────────
  Future<pw.Font> _loadCairoFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo-Variable.ttf');
      return pw.Font.ttf(fontData);
    } catch (_) {
      // fallback to default if font not found
      return pw.Font.helvetica();
    }
  }

  // ─── الدالة الرئيسية لتوليد PDF ──────────────────────────────────────────
  Future<Uint8List> generatePdf(
    TransferReceipt receipt,
    String companyName,
    String branchName,
    String companyPhones,
    String companyAddress, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    bool showQrCode = true,
    double margin = 22,
    double fontSize = 10,
  }) async {
    final font = await _loadCairoFont();
    final boldFont = await _loadCairoFont();
    final isThermal = pageFormat.width <= PdfPageFormat.mm * 90;

    final document = pw.Document(
      title: 'سند قبض حوالة ${receipt.transferNumber}',
      author: companyName,
      creator: 'تطبيق العكابي',
      theme: pw.ThemeData.withFont(base: font, bold: boldFont),
    );

    document.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.all(isThermal ? 8 : margin),
          textDirection: pw.TextDirection.rtl,
        ),
        build: (ctx) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: isThermal
              ? _thermalReceipt(
                  receipt,
                  companyName,
                  branchName,
                  font,
                  boldFont,
                  showQrCode,
                )
              : _a4Receipt(
                  receipt,
                  companyName,
                  branchName,
                  companyPhones,
                  companyAddress,
                  pageFormat,
                  font,
                  boldFont,
                  showQrCode,
                  fontSize,
                ),
        ),
      ),
    );

    return document.save();
  }

  // ─── سند A4 ───────────────────────────────────────────────────────────────
  pw.Widget _a4Receipt(
    TransferReceipt receipt,
    String companyName,
    String branchName,
    String companyPhones,
    String companyAddress,
    PdfPageFormat format,
    pw.Font font,
    pw.Font boldFont,
    bool showQrCode,
    double fontSize,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      padding: const pw.EdgeInsets.all(14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _header(companyName, companyPhones, companyAddress, boldFont),
          pw.SizedBox(height: 10),
          _topNumbers(receipt, boldFont),
          pw.SizedBox(height: 4),
          _titleBar(receipt, boldFont),
          pw.SizedBox(height: 6),
          _financialRows(receipt, font, boldFont, fontSize),
          _partyRows(receipt, font, boldFont, fontSize),
          _notesRow(receipt, font, boldFont),
          pw.SizedBox(height: 10),
          _signatureFooter(receipt, branchName, font, boldFont, showQrCode),
        ],
      ),
    );
  }

  // ─── سند حراري ────────────────────────────────────────────────────────────
  pw.Widget _thermalReceipt(
    TransferReceipt receipt,
    String companyName,
    String branchName,
    pw.Font font,
    pw.Font boldFont,
    bool showQrCode,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Center(child: _logoMark(42, boldFont)),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            companyName,
            style: pw.TextStyle(font: boldFont, fontSize: 10),
          ),
        ),
        pw.Center(
          child: pw.Text(
            branchName,
            style: pw.TextStyle(font: font, fontSize: 7),
          ),
        ),
        pw.Divider(thickness: 0.7),
        pw.Center(
          child: pw.Text(
            'سند قبض حوالة',
            style: pw.TextStyle(font: boldFont, fontSize: 12),
          ),
        ),
        pw.SizedBox(height: 6),
        _thermalLine('رقم السند', receipt.receiptNumber, font, boldFont),
        _thermalLine('رقم الحوالة', receipt.transferNumber, font, boldFont),
        _thermalLine('المرجع', receipt.referenceNumber, font, boldFont),
        _thermalLine(
          'التاريخ',
          ArabicFormatters.formatDateTime(receipt.createdAt),
          font,
          boldFont,
        ),
        _thermalLine('المرسل', receipt.senderName, font, boldFont),
        _thermalLine('المستلم', receipt.receiverName, font, boldFont),
        _thermalLine('هاتف المرسل', receipt.senderPhone, font, boldFont),
        _thermalLine('هاتف المستلم', receipt.receiverPhone, font, boldFont),
        _thermalLine('الجهة', receipt.destination, font, boldFont),
        _thermalLine(
          'المبلغ',
          ArabicFormatters.formatAmount(
            receipt.amount,
            currency: receipt.currency,
          ),
          font,
          boldFont,
        ),
        _thermalLine(
          'الرسوم',
          ArabicFormatters.formatAmount(
            receipt.fee,
            currency: receipt.currency,
          ),
          font,
          boldFont,
        ),
        _thermalLine(
          'الإجمالي',
          ArabicFormatters.formatAmount(
            receipt.total,
            currency: receipt.currency,
          ),
          font,
          boldFont,
          bold: true,
        ),
        if (showQrCode) ...[
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: receipt.qrData,
              width: 70,
              height: 70,
            ),
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Text(
          'توقيع الموظف: ${receipt.employeeSignature}',
          style: pw.TextStyle(font: font, fontSize: 7),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            ArabicFormatters.formatDateTime(receipt.createdAt),
            style: pw.TextStyle(font: boldFont, fontSize: 7),
          ),
        ),
      ],
    );
  }

  // ─── المكونات المشتركة ─────────────────────────────────────────────────────

  pw.Widget _header(
    String companyName,
    String companyPhones,
    String companyAddress,
    pw.Font boldFont,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                companyName,
                style: pw.TextStyle(font: boldFont, fontSize: 15),
              ),
              pw.SizedBox(height: 3),
              pw.Text(companyAddress, style: const pw.TextStyle(fontSize: 8)),
              pw.Text(companyPhones, style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
        ),
        _logoMark(68, boldFont),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'العكابي',
                style: pw.TextStyle(font: boldFont, fontSize: 22),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                child: pw.Text(
                  'للصرافة والتحويلات',
                  style: pw.TextStyle(font: boldFont, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _logoMark(double size, pw.Font boldFont) {
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: PdfColors.grey700, width: 1.2),
      ),
      alignment: pw.Alignment.center,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'AK',
            style: pw.TextStyle(font: boldFont, fontSize: size * 0.24),
          ),
          pw.Text(
            'Exchange',
            style: pw.TextStyle(font: boldFont, fontSize: size * 0.09),
          ),
        ],
      ),
    );
  }

  pw.Widget _topNumbers(TransferReceipt receipt, pw.Font boldFont) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: _boxedCell(
            'رقم الصادر',
            receipt.receiptNumber,
            boldFont,
            largeValue: true,
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Expanded(
          flex: 2,
          child: _boxedCell(
            'رقم الحوالة ${ArabicFormatters.toArabicDigits(receipt.transferNumber)}',
            'المرجع - ${ArabicFormatters.toArabicDigits(receipt.referenceNumber)}',
            boldFont,
            largeValue: true,
          ),
        ),
      ],
    );
  }

  pw.Widget _titleBar(TransferReceipt receipt, pw.Font boldFont) {
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 2,
          child: _boxedCell(
            'التاريخ',
            ArabicFormatters.formatDate(receipt.createdAt),
            boldFont,
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            height: 36,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey700, width: 0.8),
              color: PdfColors.grey100,
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'سند قبض حوالة',
              style: pw.TextStyle(font: boldFont, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _financialRows(
    TransferReceipt receipt,
    pw.Font font,
    pw.Font boldFont,
    double fontSize,
  ) {
    return pw.Column(
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: _dataCell(
                'مبلغ الحوالة',
                '#${ArabicFormatters.formatPlainAmount(receipt.amount)}#',
                font,
                boldFont,
              ),
            ),
            pw.Expanded(
              child: _dataCell(
                'عملة الحوالة',
                receipt.currency,
                font,
                boldFont,
              ),
            ),
            pw.Expanded(
              child: _dataCell(
                'خدمات التحويل',
                ArabicFormatters.formatAmount(
                  receipt.fee,
                  currency: receipt.currency,
                ),
                font,
                boldFont,
              ),
            ),
            pw.Expanded(
              child: _dataCell(
                'الإجمالي المقبوض',
                ArabicFormatters.formatAmount(
                  receipt.total,
                  currency: receipt.currency,
                ),
                font,
                boldFont,
              ),
            ),
          ],
        ),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: _dataCell(
                'مبلغ الحوالة كتابة',
                ArabicFormatters.amountToArabicWords(
                  receipt.amount,
                  receipt.currency,
                ),
                font,
                boldFont,
              ),
            ),
            pw.Expanded(
              child: _dataCell('الجهة', receipt.destination, font, boldFont),
            ),
          ],
        ),
        _wideCell(
          'الوكيل',
          '${receipt.agent} - ${ArabicFormatters.toArabicDigits('8008800')}',
          font,
          boldFont,
        ),
      ],
    );
  }

  pw.Widget _partyRows(
    TransferReceipt receipt,
    pw.Font font,
    pw.Font boldFont,
    double fontSize,
  ) {
    return pw.Column(
      children: [
        pw.Row(
          children: [
            pw.Expanded(child: _dataCell('رقم البطاقة', '', font, boldFont)),
            pw.Expanded(
              child: _dataCell(
                'اسم المستلم',
                receipt.receiverName,
                font,
                boldFont,
              ),
            ),
          ],
        ),
        pw.Row(
          children: [
            pw.Expanded(
              child: _dataCell(
                'رقم السند',
                receipt.receiptNumber,
                font,
                boldFont,
              ),
            ),
            pw.Expanded(
              child: _dataCell(
                'اسم المرسل',
                receipt.senderName,
                font,
                boldFont,
              ),
            ),
          ],
        ),
        pw.Row(
          children: [
            pw.Expanded(
              child: _dataCell(
                'تلفون المرسل',
                receipt.senderPhone,
                font,
                boldFont,
              ),
            ),
            pw.Expanded(
              child: _dataCell(
                'تلفون المستلم',
                receipt.receiverPhone,
                font,
                boldFont,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _notesRow(TransferReceipt receipt, pw.Font font, pw.Font boldFont) {
    return _wideCell('ملاحظات', receipt.notes, font, boldFont);
  }

  pw.Widget _signatureFooter(
    TransferReceipt receipt,
    String branchName,
    pw.Font font,
    pw.Font boldFont,
    bool showQrCode,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        if (showQrCode)
          pw.Container(
            width: 88,
            height: 88,
            alignment: pw.Alignment.center,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: receipt.qrData,
              width: 82,
              height: 82,
            ),
          ),
        if (showQrCode) pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _lineBox(
                      'توقيع الموظف',
                      receipt.employeeSignature,
                      font,
                      boldFont,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(child: _lineBox('الختم', '', font, boldFont)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'الفرع: $branchName    الموظف: ${receipt.employeeName}',
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  ArabicFormatters.formatDateTime(receipt.createdAt),
                  style: pw.TextStyle(font: boldFont, fontSize: 9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── خلايا المساعدة ───────────────────────────────────────────────────────

  pw.Widget _boxedCell(
    String label,
    String value,
    pw.Font boldFont, {
    bool largeValue = false,
  }) {
    return pw.Container(
      height: 44,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700, width: 0.8),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
          pw.Text(
            ArabicFormatters.toArabicDigits(value),
            style: pw.TextStyle(font: boldFont, fontSize: largeValue ? 12 : 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _dataCell(
    String label,
    String value,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      constraints: const pw.BoxConstraints(minHeight: 30),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700, width: 0.6),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: pw.Row(
        children: [
          pw.Container(
            width: 76,
            alignment: pw.Alignment.center,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: boldFont, fontSize: 8),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              ArabicFormatters.toArabicDigits(value),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: boldFont, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _wideCell(
    String label,
    String value,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      constraints: const pw.BoxConstraints(minHeight: 28),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700, width: 0.6),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: pw.Row(
        children: [
          pw.Container(
            width: 84,
            alignment: pw.Alignment.center,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: boldFont, fontSize: 8),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              ArabicFormatters.toArabicDigits(value),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: boldFont, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _lineBox(
    String title,
    String value,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          title,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(font: boldFont, fontSize: 8),
        ),
        pw.SizedBox(height: 3),
        pw.Container(
          height: 22,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey700, width: 0.7),
          ),
          alignment: pw.Alignment.center,
          child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 8)),
        ),
      ],
    );
  }

  pw.Widget _thermalLine(
    String label,
    String value,
    pw.Font font,
    pw.Font boldFont, {
    bool bold = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.3),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Text('$label:', style: pw.TextStyle(font: boldFont, fontSize: 7)),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              ArabicFormatters.toArabicDigits(value),
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                font: bold ? boldFont : font,
                fontSize: bold ? 8 : 7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
