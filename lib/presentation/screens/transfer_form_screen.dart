import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/arabic_formatters.dart';
import '../../data/models/transfer_receipt.dart';
import '../../services/receipt_number_service.dart';
import '../providers/transfer_providers.dart';
import 'receipt_preview_screen.dart';

class TransferFormScreen extends ConsumerStatefulWidget {
  const TransferFormScreen({super.key, this.initialReceipt});

  final TransferReceipt? initialReceipt;

  @override
  ConsumerState<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends ConsumerState<TransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _receiptNumber;
  late final TextEditingController _transferNumber;
  late final TextEditingController _referenceNumber;
  late final TextEditingController _amount;
  late final TextEditingController _fee;
  late final TextEditingController _currency;
  late final TextEditingController _senderName;
  late final TextEditingController _receiverName;
  late final TextEditingController _senderPhone;
  late final TextEditingController _receiverPhone;
  late final TextEditingController _destination;
  late final TextEditingController _agent;
  late final TextEditingController _employeeName;
  late final TextEditingController _employeeSignature;
  late final TextEditingController _notes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final receipt = widget.initialReceipt;
    const numbers = ReceiptNumberService();
    _receiptNumber = TextEditingController(
      text: receipt?.receiptNumber ?? numbers.generateReceiptNumber(),
    );
    _transferNumber = TextEditingController(
      text: receipt?.transferNumber ?? numbers.generateTransferNumber(),
    );
    _referenceNumber = TextEditingController(
      text: receipt?.referenceNumber ?? numbers.generateReferenceNumber(),
    );
    _amount = TextEditingController(
      text: (receipt?.amount ?? 100).toStringAsFixed(2),
    );
    _fee = TextEditingController(
      text: (receipt?.fee ?? 2.18).toStringAsFixed(2),
    );
    _currency = TextEditingController(
      text: receipt?.currency ?? AppConstants.defaultCurrency,
    );
    _senderName = TextEditingController(text: receipt?.senderName ?? '');
    _receiverName = TextEditingController(text: receipt?.receiverName ?? '');
    _senderPhone = TextEditingController(text: receipt?.senderPhone ?? '');
    _receiverPhone = TextEditingController(text: receipt?.receiverPhone ?? '');
    _destination = TextEditingController(
      text: receipt?.destination ?? AppConstants.defaultDestination,
    );
    _agent = TextEditingController(
      text: receipt?.agent ?? AppConstants.defaultAgent,
    );
    _employeeName = TextEditingController(
      text: receipt?.employeeName ?? AppConstants.defaultEmployee,
    );
    _employeeSignature = TextEditingController(
      text:
          receipt?.employeeSignature ?? 'صندوق ${AppConstants.defaultEmployee}',
    );
    _notes = TextEditingController(text: receipt?.notes ?? '');
  }

  @override
  void dispose() {
    _receiptNumber.dispose();
    _transferNumber.dispose();
    _referenceNumber.dispose();
    _amount.dispose();
    _fee.dispose();
    _currency.dispose();
    _senderName.dispose();
    _receiverName.dispose();
    _senderPhone.dispose();
    _receiverPhone.dispose();
    _destination.dispose();
    _agent.dispose();
    _employeeName.dispose();
    _employeeSignature.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.initialReceipt == null
        ? 'إنشاء سند قبض حوالة'
        : 'تعديل سند حوالة';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Section(
                  title: 'البيانات التي تدخلها فقط',
                  subtitle:
                      'اكتب بيانات العميل والعمولة والجهة، وباقي بيانات السند تتولد تلقائيًا.',
                  children: [
                    _TextField(
                      controller: _amount,
                      label: 'مبلغ الحوالة',
                      icon: Icons.account_balance_wallet,
                      number: true,
                    ),
                    _TextField(
                      controller: _fee,
                      label: 'حق العمولة',
                      icon: Icons.price_change,
                      number: true,
                    ),
                    _TextField(
                      controller: _senderName,
                      label: 'اسم المرسل',
                      icon: Icons.person,
                    ),
                    _TextField(
                      controller: _senderPhone,
                      label: 'رقم المرسل',
                      icon: Icons.call,
                      phone: true,
                    ),
                    _TextField(
                      controller: _receiverName,
                      label: 'اسم المستلم',
                      icon: Icons.person_pin,
                    ),
                    _TextField(
                      controller: _receiverPhone,
                      label: 'رقم المستلم',
                      icon: Icons.phone_android,
                      phone: true,
                    ),
                    _TextField(
                      controller: _destination,
                      label: 'عبر من / الجهة',
                      icon: Icons.account_tree,
                    ),
                  ],
                ),
                _AutoDataPreview(
                  receiptNumber: _receiptNumber.text,
                  transferNumber: _transferNumber.text,
                  referenceNumber: _referenceNumber.text,
                  currency: _currency.text,
                  employeeName: _employeeName.text,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    widget.initialReceipt == null
                        ? 'حفظ ومعاينة السند'
                        : 'تحديث ومعاينة السند',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    const numbers = ReceiptNumberService();
    final now = DateTime.now();
    final initial = widget.initialReceipt;
    final referenceNumber =
        initial?.referenceNumber ?? _referenceNumber.text.trim();
    final receipt = TransferReceipt(
      id: initial?.id ?? numbers.generateId(),
      receiptNumber: initial?.receiptNumber ?? _receiptNumber.text.trim(),
      transferNumber: initial?.transferNumber ?? _transferNumber.text.trim(),
      referenceNumber: referenceNumber,
      createdAt: initial?.createdAt ?? now,
      amount: _asDouble(_amount.text),
      fee: _asDouble(_fee.text),
      currency: _currency.text.trim().isEmpty
          ? AppConstants.defaultCurrency
          : _currency.text.trim(),
      senderName: _senderName.text.trim(),
      receiverName: _receiverName.text.trim(),
      senderPhone: _senderPhone.text.trim(),
      receiverPhone: _receiverPhone.text.trim(),
      destination: _destination.text.trim(),
      agent: _agent.text.trim().isEmpty
          ? AppConstants.defaultAgent
          : _agent.text.trim(),
      employeeName: _employeeName.text.trim().isEmpty
          ? AppConstants.defaultEmployee
          : _employeeName.text.trim(),
      employeeSignature: _employeeSignature.text.trim().isEmpty
          ? 'صندوق ${AppConstants.defaultEmployee}'
          : _employeeSignature.text.trim(),
      notes: _buildAutoNotes(referenceNumber),
      isArchived: initial?.isArchived ?? false,
    );

    try {
      final controller = ref.read(activeTransfersProvider.notifier);
      if (initial == null) {
        await controller.add(receipt);
      } else {
        await controller.editTransfer(receipt);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ السند بنجاح')));
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReceiptPreviewScreen(receipt: receipt),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('تعذر حفظ الحوالة'),
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
      if (mounted) setState(() => _saving = false);
    }
  }

  double _asDouble(String value) {
    final western = ArabicFormatters.toWesternDigits(value).replaceAll(',', '');
    return double.tryParse(western) ?? 0;
  }

  String _buildAutoNotes(String referenceNumber) {
    if (widget.initialReceipt != null && _notes.text.trim().isNotEmpty) {
      return _notes.text.trim();
    }
    return 'الإكسبرس ${ArabicFormatters.toArabicDigits(referenceNumber)}';
  }
}

class _AutoDataPreview extends StatelessWidget {
  const _AutoDataPreview({
    required this.receiptNumber,
    required this.transferNumber,
    required this.referenceNumber,
    required this.currency,
    required this.employeeName,
  });

  final String receiptNumber;
  final String transferNumber;
  final String referenceNumber;
  final String currency;
  final String employeeName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: .35),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'بيانات تلقائية',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AutoChip(
                  icon: Icons.receipt_long,
                  label: 'رقم السند',
                  value: receiptNumber,
                ),
                _AutoChip(
                  icon: Icons.tag,
                  label: 'رقم الحوالة',
                  value: transferNumber,
                ),
                _AutoChip(
                  icon: Icons.numbers,
                  label: 'المرجع',
                  value: referenceNumber,
                ),
                _AutoChip(
                  icon: Icons.payments,
                  label: 'العملة',
                  value: currency,
                ),
                _AutoChip(
                  icon: Icons.badge,
                  label: 'الموظف',
                  value: employeeName,
                ),
                const _AutoChip(
                  icon: Icons.qr_code,
                  label: 'QR',
                  value: 'تلقائي',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AutoChip extends StatelessWidget {
  const _AutoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label: ${ArabicFormatters.toArabicDigits(value)}'),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, this.subtitle});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 780
                    ? 3
                    : (constraints.maxWidth > 520 ? 2 : 1);
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: children
                      .map(
                        (child) => SizedBox(
                          width:
                              (constraints.maxWidth - (columns - 1) * 12) /
                              columns,
                          child: child,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.number = false,
    this.phone = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool number;
  final bool phone;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : (phone ? TextInputType.phone : TextInputType.text),
      inputFormatters: number || phone
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.,]+'))]
          : null,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'هذا الحقل مطلوب';
        }
        if (number &&
            double.tryParse(
                  ArabicFormatters.toWesternDigits(value).replaceAll(',', ''),
                ) ==
                null) {
          return 'أدخل رقمًا صحيحًا';
        }
        return null;
      },
    );
  }
}
