// =============================================================================
// شاشة إعدادات الأمان - تطبيق العكابي
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/arabic_formatters.dart';
import '../../../presentation/providers/settings_providers.dart';
import '../../../presentation/widgets/common/shared_widgets.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  bool _obscurePin = true;

  @override
  void dispose() {
    _pinCtrl.dispose();
    _confirmPinCtrl.dispose();
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
        appBar: AppBar(title: const Text('الأمان والخصوصية')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── تحذير أمني ───────────────────────────────────────
            GradientCard(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withValues(alpha: 0.08),
                  Colors.orange.withValues(alpha: 0.08),
                ],
              ),
              border: true,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تنبيه: إعدادات الأمان تحمي بيانات الحوالات الحساسة. تأكد من حفظ الرمز السري في مكان آمن.',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── قفل التطبيق ──────────────────────────────────────
            const SectionHeader(
              title: 'قفل التطبيق',
              icon: Icons.lock_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('الرمز السري'),
                    subtitle: Text(
                      settings.requirePinToOpen
                          ? 'مطلوب رمز سري عند فتح التطبيق'
                          : 'التطبيق مفتوح بدون رمز سري',
                    ),
                    secondary: const Icon(Icons.pin_rounded),
                    value: settings.requirePinToOpen,
                    onChanged: (v) =>
                        notifier.updateSecuritySettings(requirePin: v),
                    activeThumbColor: scheme.primary,
                  ),
                  if (settings.requirePinToOpen) ...[
                    const AkabDivider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _pinCtrl,
                            obscureText: _obscurePin,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: InputDecoration(
                              labelText: 'الرمز السري الجديد',
                              prefixIcon: const Icon(Icons.lock_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePin
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePin = !_obscurePin);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPinCtrl,
                            obscureText: _obscurePin,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              labelText: 'تأكيد الرمز السري',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _savePin(context, notifier),
                              icon: const Icon(Icons.save_rounded, size: 18),
                              label: const Text('حفظ الرمز السري'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── مهلة الجلسة ──────────────────────────────────────
            const SectionHeader(
              title: 'مهلة الجلسة',
              icon: Icons.timer_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'يُقفل التطبيق تلقائياً بعد فترة من عدم الاستخدام',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [5, 15, 30, 60, 120].map((minutes) {
                      final isSelected =
                          settings.sessionTimeoutMinutes == minutes;
                      return ChoiceChip(
                        label: Text(
                          '${ArabicFormatters.toArabicDigits(minutes.toString())} د',
                        ),
                        selected: isSelected,
                        onSelected: (_) => notifier.updateSecuritySettings(
                          sessionTimeout: minutes,
                        ),
                        selectedColor: scheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── خصوصية البيانات ───────────────────────────────────
            const SectionHeader(
              title: 'خصوصية البيانات',
              icon: Icons.privacy_tip_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: EdgeInsets.zero,
              child: SwitchListTile.adaptive(
                title: const Text('إظهار المبالغ في القائمة'),
                subtitle: const Text(
                  'عند إيقافه، تُخفى المبالغ في القائمة الرئيسية',
                ),
                secondary: const Icon(Icons.visibility_rounded),
                value: settings.showAmountsInList,
                onChanged: (v) =>
                    notifier.updateSecuritySettings(showAmounts: v),
                activeThumbColor: scheme.primary,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _savePin(BuildContext context, SettingsNotifier notifier) {
    if (_pinCtrl.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرمز السري يجب أن يكون ٤ أرقام على الأقل'),
        ),
      );
      return;
    }
    if (_pinCtrl.text != _confirmPinCtrl.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرمزان غير متطابقين')));
      return;
    }
    notifier.updateSecuritySettings(pinCode: _pinCtrl.text);
    _pinCtrl.clear();
    _confirmPinCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الرمز السري بنجاح ✓'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
