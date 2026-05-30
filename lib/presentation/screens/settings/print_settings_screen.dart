// =============================================================================
// شاشة إعدادات الطباعة - تطبيق العكابي
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/arabic_formatters.dart';
import '../../../presentation/providers/settings_providers.dart';
import '../../../presentation/widgets/common/shared_widgets.dart';

class PrintSettingsScreen extends ConsumerStatefulWidget {
  const PrintSettingsScreen({super.key});

  @override
  ConsumerState<PrintSettingsScreen> createState() =>
      _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends ConsumerState<PrintSettingsScreen> {
  late TextEditingController _copiesCtrl;
  late TextEditingController _marginCtrl;
  late TextEditingController _fontSizeCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _copiesCtrl = TextEditingController(text: s.printCopies.toString());
    _marginCtrl = TextEditingController(text: s.pdfMargin.toString());
    _fontSizeCtrl = TextEditingController(text: s.fontSizePdf.toString());
  }

  @override
  void dispose() {
    _copiesCtrl.dispose();
    _marginCtrl.dispose();
    _fontSizeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إعدادات الطباعة')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── تنسيق الطباعة ──────────────────────────────────
            const SectionHeader(
              title: 'تنسيق الورق',
              icon: Icons.article_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _FormatOption(
                    icon: Icons.picture_as_pdf_rounded,
                    title: 'A4 عادي',
                    subtitle: 'أفضل للطباعة المكتبية والحفظ',
                    value: 'a4',
                    currentValue: settings.defaultPrintFormat,
                    onChanged: (v) => notifier.updatePrintSettings(format: v),
                  ),
                  const AkabDivider(),
                  _FormatOption(
                    icon: Icons.receipt_long_rounded,
                    title: 'حراري ٨٠ مم',
                    subtitle: 'للطابعات الحرارية العريضة',
                    value: 'thermal80',
                    currentValue: settings.defaultPrintFormat,
                    onChanged: (v) => notifier.updatePrintSettings(format: v),
                  ),
                  const AkabDivider(),
                  _FormatOption(
                    icon: Icons.receipt_rounded,
                    title: 'حراري ٥٨ مم',
                    subtitle: 'للطابعات الحرارية الضيقة',
                    value: 'thermal58',
                    currentValue: settings.defaultPrintFormat,
                    onChanged: (v) => notifier.updatePrintSettings(format: v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── خيارات السند ─────────────────────────────────────
            const SectionHeader(
              title: 'محتوى السند',
              icon: Icons.tune_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('رمز QR على السند'),
                    subtitle: const Text('يتيح التحقق السريع من الحوالة'),
                    secondary: const Icon(Icons.qr_code_rounded),
                    value: settings.showQrCode,
                    onChanged: (v) =>
                        notifier.updatePrintSettings(showQrCode: v),
                    activeThumbColor: scheme.primary,
                  ),
                  const AkabDivider(),
                  SwitchListTile.adaptive(
                    title: const Text('شعار الشركة'),
                    subtitle: const Text('عرض شعار الشركة في رأس السند'),
                    secondary: const Icon(Icons.business_rounded),
                    value: settings.showCompanyLogo,
                    onChanged: (v) => notifier.updatePrintSettings(showLogo: v),
                    activeThumbColor: scheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── إعدادات متقدمة ────────────────────────────────────
            const SectionHeader(
              title: 'إعدادات متقدمة',
              icon: Icons.settings_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // عدد النسخ
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'عدد النسخ',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'عدد نسخ السند عند الطباعة',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton.outlined(
                            onPressed: settings.printCopies > 1
                                ? () => notifier.updatePrintSettings(
                                    copies: settings.printCopies - 1,
                                  )
                                : null,
                            icon: const Icon(Icons.remove_rounded, size: 18),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              ArabicFormatters.toArabicDigits(
                                settings.printCopies.toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton.outlined(
                            onPressed: settings.printCopies < 5
                                ? () => notifier.updatePrintSettings(
                                    copies: settings.printCopies + 1,
                                  )
                                : null,
                            icon: const Icon(Icons.add_rounded, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // هوامش PDF
                  TextFormField(
                    controller: _marginCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'الهوامش (مم)',
                      prefixIcon: Icon(Icons.border_all_rounded),
                    ),
                    onChanged: (v) async {
                      final margin = double.tryParse(
                        ArabicFormatters.toWesternDigits(v),
                      );
                      if (margin != null) {
                        await notifier.updatePrintSettings(margin: margin);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fontSizeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'حجم الخط في PDF',
                      prefixIcon: Icon(Icons.format_size_rounded),
                    ),
                    onChanged: (v) async {
                      final size = double.tryParse(
                        ArabicFormatters.toWesternDigits(v),
                      );
                      if (size != null) {
                        await notifier.updatePrintSettings(fontSize: size);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FormatOption extends StatelessWidget {
  const _FormatOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.currentValue,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String currentValue;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = value == currentValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}
