// =============================================================================
// شاشة إعدادات المظهر - تطبيق العكابي
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/settings_providers.dart';
import '../../../presentation/widgets/common/shared_widgets.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  static const _colors = [
    ({'label': 'أزرق كلاسيكي', 'hex': '#1A4B8B'}),
    ({'label': 'أزرق فيروزي', 'hex': '#0277BD'}),
    ({'label': 'أخضر زمردي', 'hex': '#2E7D32'}),
    ({'label': 'بنفسجي', 'hex': '#6A1B9A'}),
    ({'label': 'بُني ذهبي', 'hex': '#B7570B'}),
    ({'label': 'أحمر داكن', 'hex': '#B71C1C'}),
    ({'label': 'رمادي أنيق', 'hex': '#37474F'}),
    ({'label': 'وردي داكن', 'hex': '#880E4F'}),
    ({'label': 'أزرق نيلي', 'hex': '#283593'}),
    ({'label': 'أخضر نعناعي', 'hex': '#00695C'}),
    ({'label': 'ذهبي', 'hex': '#F57F17'}),
    ({'label': 'نيلي أفاتار', 'hex': '#1A237E'}),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(settingsProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المظهر والواجهة')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── وضع العرض ────────────────────────────────────────────
            const SectionHeader(
              title: 'وضع العرض',
              icon: Icons.contrast_rounded,
              padding: EdgeInsets.only(bottom: 12),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _ThemeOption(
                    icon: Icons.brightness_auto_rounded,
                    label: 'تلقائي (حسب النظام)',
                    subtitle: 'يتبع إعداد جهازك',
                    value: 'system',
                    currentValue: settings.themeMode,
                    onChanged: notifier.updateThemeMode,
                  ),
                  const AkabDivider(),
                  _ThemeOption(
                    icon: Icons.light_mode_rounded,
                    label: 'فاتح',
                    subtitle: 'واجهة بيضاء مشرقة',
                    value: 'light',
                    currentValue: settings.themeMode,
                    onChanged: notifier.updateThemeMode,
                  ),
                  const AkabDivider(),
                  _ThemeOption(
                    icon: Icons.dark_mode_rounded,
                    label: 'داكن',
                    subtitle: 'واجهة داكنة مريحة للعيون',
                    value: 'dark',
                    currentValue: settings.themeMode,
                    onChanged: notifier.updateThemeMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── اللون الرئيسي ─────────────────────────────────────────
            const SectionHeader(
              title: 'اللون الرئيسي',
              icon: Icons.color_lens_rounded,
              padding: EdgeInsets.only(bottom: 12),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colors.map((colorData) {
                  final hex = colorData['hex']!;
                  final label = colorData['label']!;
                  final isSelected = settings.primaryColorHex == hex;
                  final color = _hexToColor(hex);

                  return GestureDetector(
                    onTap: () => notifier.updatePrimaryColor(hex),
                    child: Tooltip(
                      message: label,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: scheme.onSurface, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ─── خيارات إضافية ─────────────────────────────────────────
            const SectionHeader(
              title: 'خيارات الواجهة',
              icon: Icons.tune_rounded,
              padding: EdgeInsets.only(bottom: 12),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('التأثيرات الحركية'),
                    subtitle: const Text('تفعيل المؤثرات البصرية'),
                    secondary: const Icon(Icons.animation_rounded),
                    value: settings.showAnimations,
                    onChanged: (_) => notifier.toggleAnimations(),
                    activeThumbColor: scheme.primary,
                  ),
                  const AkabDivider(),
                  SwitchListTile.adaptive(
                    title: const Text('الوضع المضغوط'),
                    subtitle: const Text('عرض أكثر عناصر في المساحة'),
                    secondary: const Icon(Icons.view_compact_rounded),
                    value: settings.compactMode,
                    onChanged: (_) => notifier.toggleCompactMode(),
                    activeThumbColor: scheme.primary,
                  ),
                  const AkabDivider(),
                  SwitchListTile.adaptive(
                    title: const Text('الأرقام العربية'),
                    subtitle: const Text('استخدام ١٢٣ بدلاً من 123'),
                    secondary: const Icon(Icons.text_fields_rounded),
                    value: settings.useArabicNumerals,
                    onChanged: (_) => notifier.toggleArabicNumerals(),
                    activeThumbColor: scheme.primary,
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

  Color _hexToColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFF1A4B8B);
    }
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.currentValue,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
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
                    label,
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
