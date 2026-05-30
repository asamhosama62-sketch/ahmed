import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../data/models/transfer_receipt.dart';
import '../providers/settings_providers.dart';
import '../providers/transfer_providers.dart';
import '../widgets/receipt_document_widget.dart';
import 'transfer_form_screen.dart';

class ReceiptPreviewScreen extends ConsumerStatefulWidget {
  const ReceiptPreviewScreen({super.key, required this.receipt});

  final TransferReceipt receipt;

  @override
  ConsumerState<ReceiptPreviewScreen> createState() =>
      _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends ConsumerState<ReceiptPreviewScreen> {
  static const _thermal80 = PdfPageFormat(
    80 * PdfPageFormat.mm,
    210 * PdfPageFormat.mm,
    marginAll: 4 * PdfPageFormat.mm,
  );

  PdfPageFormat _format = PdfPageFormat.a4;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 920;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('معاينة سند ${widget.receipt.transferNumber}'),
          actions: [
            IconButton(
              tooltip: 'تعديل',
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            TransferFormScreen(initialReceipt: widget.receipt),
                      ),
                    ),
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _ActionBar(
                    selectedFormat: _format,
                    onFormatChanged: (format) =>
                        setState(() => _format = format),
                    onPrint: () => _run('تم إرسال السند للطباعة', _print),
                    onShare: () => _run('تم فتح خيارات المشاركة', _share),
                    onWhatsApp: () =>
                        _run('اختر واتساب من نافذة المشاركة', _share),
                    onSave: () => _run('تم حفظ ملف PDF', _save),
                    onOpen: () => _run('تم فتح ملف PDF', _open),
                    onReprint: () =>
                        _run('تمت إعادة إرسال السند للطباعة', _print),
                  ),
                  Expanded(
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(
                                child: ColoredBox(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: .45),
                                  child: Center(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(18),
                                      child: ReceiptDocumentWidget(
                                        receipt: widget.receipt,
                                        compact: _format != PdfPageFormat.a4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                              Expanded(
                                child: PdfPreview(
                                  canChangeOrientation: false,
                                  canChangePageFormat: false,
                                  initialPageFormat: _format,
                                  build: (format) {
                                    final s = ref.read(settingsProvider);
                                    return ref
                                        .read(receiptPdfServiceProvider)
                                        .generatePdf(
                                          widget.receipt,
                                          s.companyName,
                                          s.branchName,
                                          s.companyPhones,
                                          s.companyAddress,
                                          pageFormat: _format,
                                          showQrCode: s.showQrCode,
                                          margin: s.pdfMargin,
                                          fontSize: s.fontSizePdf,
                                        );
                                  },
                                ),
                              ),
                            ],
                          )
                        : PdfPreview(
                            canChangeOrientation: false,
                            canChangePageFormat: false,
                            initialPageFormat: _format,
                            build: (format) {
                              final s = ref.read(settingsProvider);
                              return ref
                                  .read(receiptPdfServiceProvider)
                                  .generatePdf(
                                    widget.receipt,
                                    s.companyName,
                                    s.branchName,
                                    s.companyPhones,
                                    s.companyAddress,
                                    pageFormat: _format,
                                    showQrCode: s.showQrCode,
                                    margin: s.pdfMargin,
                                    fontSize: s.fontSizePdf,
                                  );
                            },
                          ),
                  ),
                ],
              ),
            ),
            if (_busy)
              ColoredBox(
                color: Colors.black.withValues(alpha: .22),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _run(
    String successMessage,
    Future<void> Function() action,
  ) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('تعذر تنفيذ العملية'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _print() async {
    final s = ref.read(settingsProvider);
    await Printing.layoutPdf(
      name: 'سند قبض ${widget.receipt.transferNumber}',
      format: _format,
      onLayout: (_) => ref
          .read(receiptPdfServiceProvider)
          .generatePdf(
            widget.receipt,
            s.companyName,
            s.branchName,
            s.companyPhones,
            s.companyAddress,
            pageFormat: _format,
            showQrCode: s.showQrCode,
            margin: s.pdfMargin,
            fontSize: s.fontSizePdf,
          ),
    );
  }

  Future<void> _share() {
    final s = ref.read(settingsProvider);
    return ref
        .read(receiptShareServiceProvider)
        .sharePdf(widget.receipt, pageFormat: _format, settings: s);
  }

  Future<void> _open() {
    final s = ref.read(settingsProvider);
    return ref
        .read(receiptShareServiceProvider)
        .openPdf(widget.receipt, pageFormat: _format, settings: s);
  }

  Future<void> _save() async {
    final s = ref.read(settingsProvider);
    await ref
        .read(receiptShareServiceProvider)
        .savePdf(widget.receipt, pageFormat: _format, settings: s);
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.selectedFormat,
    required this.onFormatChanged,
    required this.onPrint,
    required this.onShare,
    required this.onWhatsApp,
    required this.onSave,
    required this.onOpen,
    required this.onReprint,
  });

  final PdfPageFormat selectedFormat;
  final ValueChanged<PdfPageFormat> onFormatChanged;
  final VoidCallback onPrint;
  final VoidCallback onShare;
  final VoidCallback onWhatsApp;
  final VoidCallback onSave;
  final VoidCallback onOpen;
  final VoidCallback onReprint;

  @override
  Widget build(BuildContext context) {
    final isA4 = selectedFormat == PdfPageFormat.a4;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.description),
                  label: Text('A4'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.receipt),
                  label: Text('80mm'),
                ),
              ],
              selected: {isA4},
              onSelectionChanged: (value) {
                onFormatChanged(
                  value.first
                      ? PdfPageFormat.a4
                      : _ReceiptPreviewScreenState._thermal80,
                );
              },
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: onPrint,
              icon: const Icon(Icons.print),
              label: const Text('طباعة'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share),
              label: const Text('مشاركة'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onWhatsApp,
              icon: const Icon(Icons.chat),
              label: const Text('واتساب'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_alt),
              label: const Text('حفظ PDF'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('فتح'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onReprint,
              icon: const Icon(Icons.replay),
              label: const Text('إعادة طباعة'),
            ),
          ],
        ),
      ),
    );
  }
}
