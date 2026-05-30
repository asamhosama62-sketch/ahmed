// =============================================================================
// شاشة الإعدادات الرئيسية - تطبيق العكابي للحوالات المالية
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/arabic_formatters.dart';
import '../providers/settings_providers.dart';
import '../widgets/common/shared_widgets.dart';
import 'settings/company_settings_screen.dart';
import 'settings/employee_settings_screen.dart';
import 'settings/appearance_settings_screen.dart';
import 'settings/transfer_defaults_screen.dart';
import 'settings/print_settings_screen.dart';
import 'settings/backup_settings_screen.dart';
import 'settings/security_settings_screen.dart';
import 'settings/about_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // ─── AppBar منسجم ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: scheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 16,
                  bottom: 16,
                ),
                title: Text(
                  'الإعدادات',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        scheme.primary.withValues(alpha: 0.08),
                        scheme.surface,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(bottom: 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ─── بطاقة الملف الشخصي ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: GestureDetector(
                      onTap: () =>
                          _navigate(context, const CompanySettingsScreen()),
                      child: GradientCard(
                        gradient: LinearGradient(
                          colors: [
                            scheme.primary,
                            scheme.primary.withValues(alpha: 0.78),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    settings.companyName,
                                    style: textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    settings.branchName,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    settings.companyPhones,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── بطاقة الموظف ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: GestureDetector(
                      onTap: () =>
                          _navigate(context, const EmployeeSettingsScreen()),
                      child: GradientCard(
                        color: scheme.surfaceContainerLow,
                        border: true,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.badge_rounded,
                                color: Colors.teal,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الموظف المسؤول',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    settings.defaultEmployeeName,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (settings
                                      .defaultEmployeePosition
                                      .isNotEmpty)
                                    Text(
                                      settings.defaultEmployeePosition,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── قسم: المظهر ─────────────────────────────────────
                  _SettingsSection(
                    title: 'المظهر والواجهة',
                    icon: Icons.palette_rounded,
                    items: [
                      _SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        iconColor: Colors.indigo,
                        title: 'وضع العرض',
                        subtitle: _themeLabel(settings.themeMode),
                        onTap: () => _navigate(
                          context,
                          const AppearanceSettingsScreen(),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.color_lens_rounded,
                        iconColor: Colors.pink,
                        title: 'اللون الرئيسي',
                        subtitle: 'تخصيص ألوان التطبيق',
                        trailing: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: settings.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.outlineVariant,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onTap: () => _navigate(
                          context,
                          const AppearanceSettingsScreen(),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.animation_rounded,
                        iconColor: Colors.orange,
                        title: 'التأثيرات الحركية',
                        subtitle: settings.showAnimations ? 'مفعّلة' : 'معطّلة',
                        trailing: Switch.adaptive(
                          value: settings.showAnimations,
                          onChanged: (_) => ref
                              .read(settingsProvider.notifier)
                              .toggleAnimations(),
                          activeThumbColor: scheme.primary,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.view_compact_rounded,
                        iconColor: Colors.brown,
                        title: 'الوضع المضغوط',
                        subtitle: settings.compactMode ? 'مفعّل' : 'معطّل',
                        trailing: Switch.adaptive(
                          value: settings.compactMode,
                          onChanged: (_) => ref
                              .read(settingsProvider.notifier)
                              .toggleCompactMode(),
                          activeThumbColor: scheme.primary,
                        ),
                      ),
                    ],
                  ),

                  // ─── قسم: إعدادات الحوالة ────────────────────────────
                  _SettingsSection(
                    title: 'إعدادات الحوالة',
                    icon: Icons.swap_horiz_rounded,
                    items: [
                      _SettingsTile(
                        icon: Icons.currency_exchange_rounded,
                        iconColor: Colors.green.shade700,
                        title: 'العملة الافتراضية',
                        subtitle: settings.defaultCurrency,
                        onTap: () =>
                            _navigate(context, const TransferDefaultsScreen()),
                      ),
                      _SettingsTile(
                        icon: Icons.send_rounded,
                        iconColor: Colors.blue.shade700,
                        title: 'الوجهة الافتراضية',
                        subtitle: settings.defaultDestination,
                        onTap: () =>
                            _navigate(context, const TransferDefaultsScreen()),
                      ),
                      _SettingsTile(
                        icon: Icons.account_balance_rounded,
                        iconColor: Colors.teal.shade700,
                        title: 'الوكيل الافتراضي',
                        subtitle: settings.defaultAgent,
                        onTap: () =>
                            _navigate(context, const TransferDefaultsScreen()),
                      ),
                      _SettingsTile(
                        icon: Icons.percent_rounded,
                        iconColor: Colors.deepOrange,
                        title: 'نسبة الرسوم الافتراضية',
                        subtitle:
                            '${ArabicFormatters.toArabicDigits(settings.defaultFeePercentage.toStringAsFixed(1))}%',
                        onTap: () =>
                            _navigate(context, const TransferDefaultsScreen()),
                      ),
                    ],
                  ),

                  // ─── قسم: الطباعة ────────────────────────────────────
                  _SettingsSection(
                    title: 'إعدادات الطباعة',
                    icon: Icons.print_rounded,
                    items: [
                      _SettingsTile(
                        icon: Icons.description_rounded,
                        iconColor: Colors.blueGrey,
                        title: 'تنسيق الطباعة الافتراضي',
                        subtitle: _printFormatLabel(
                          settings.defaultPrintFormat,
                        ),
                        onTap: () =>
                            _navigate(context, const PrintSettingsScreen()),
                      ),
                      _SettingsTile(
                        icon: Icons.qr_code_rounded,
                        iconColor: Colors.black87,
                        title: 'عرض رمز QR',
                        subtitle: settings.showQrCode ? 'مفعّل' : 'معطّل',
                        trailing: Switch.adaptive(
                          value: settings.showQrCode,
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .updatePrintSettings(showQrCode: v),
                          activeThumbColor: scheme.primary,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.copy_rounded,
                        iconColor: Colors.purple,
                        title: 'عدد النسخ',
                        subtitle:
                            '${ArabicFormatters.toArabicDigits(settings.printCopies.toString())} نسخ',
                        onTap: () =>
                            _navigate(context, const PrintSettingsScreen()),
                      ),
                    ],
                  ),

                  // ─── قسم: الأمان ──────────────────────────────────────
                  _SettingsSection(
                    title: 'الأمان والخصوصية',
                    icon: Icons.security_rounded,
                    items: [
                      _SettingsTile(
                        icon: Icons.pin_rounded,
                        iconColor: Colors.red.shade700,
                        title: 'قفل بالرمز السري',
                        subtitle: settings.requirePinToOpen ? 'مفعّل' : 'معطّل',
                        trailing: Switch.adaptive(
                          value: settings.requirePinToOpen,
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .updateSecuritySettings(requirePin: v),
                          activeThumbColor: scheme.primary,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.visibility_rounded,
                        iconColor: Colors.blue,
                        title: 'إظهار المبالغ في القائمة',
                        subtitle: settings.showAmountsInList
                            ? 'مفعّل'
                            : 'معطّل',
                        trailing: Switch.adaptive(
                          value: settings.showAmountsInList,
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .updateSecuritySettings(showAmounts: v),
                          activeThumbColor: scheme.primary,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.lock_clock_rounded,
                        iconColor: Colors.orange.shade700,
                        title: 'انتهاء الجلسة',
                        subtitle:
                            'بعد ${ArabicFormatters.toArabicDigits(settings.sessionTimeoutMinutes.toString())} دقيقة',
                        onTap: () =>
                            _navigate(context, const SecuritySettingsScreen()),
                      ),
                    ],
                  ),

                  // ─── قسم: النسخ الاحتياطي ────────────────────────────
                  _SettingsSection(
                    title: 'النسخ الاحتياطي',
                    icon: Icons.backup_rounded,
                    items: [
                      _SettingsTile(
                        icon: Icons.cloud_upload_rounded,
                        iconColor: Colors.blue.shade600,
                        title: 'نسخ احتياطي تلقائي',
                        subtitle: settings.autoBackupEnabled
                            ? 'كل ${ArabicFormatters.toArabicDigits(settings.backupIntervalDays.toString())} أيام'
                            : 'معطّل',
                        trailing: Switch.adaptive(
                          value: settings.autoBackupEnabled,
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .updateSettings(
                                settings.copyWith(autoBackupEnabled: v),
                              ),
                          activeThumbColor: scheme.primary,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.save_alt_rounded,
                        iconColor: Colors.green.shade700,
                        title: 'تصدير البيانات',
                        subtitle: 'تصدير جميع الحوالات',
                        onTap: () =>
                            _navigate(context, const BackupSettingsScreen()),
                      ),
                      _SettingsTile(
                        icon: Icons.restore_rounded,
                        iconColor: Colors.amber.shade700,
                        title: 'استعادة البيانات',
                        subtitle: settings.lastBackupDate != null
                            ? 'آخر نسخة: ${ArabicFormatters.formatDate(settings.lastBackupDate!)}'
                            : 'لم يتم نسخ احتياطي بعد',
                        onTap: () =>
                            _navigate(context, const BackupSettingsScreen()),
                      ),
                    ],
                  ),

                  // ─── قسم: عن التطبيق ──────────────────────────────────
                  _SettingsSection(
                    title: 'حول التطبيق',
                    icon: Icons.info_rounded,
                    items: [
                      _SettingsTile(
                        icon: Icons.app_shortcut_rounded,
                        iconColor: const Color(0xFF1A4B8B),
                        title: 'تطبيق العكابي',
                        subtitle: 'الإصدار ${settings.version}',
                        onTap: () => _navigate(context, const AboutScreen()),
                      ),
                      _SettingsTile(
                        icon: Icons.refresh_rounded,
                        iconColor: Colors.red,
                        title: 'إعادة تعيين الإعدادات',
                        subtitle: 'العودة للإعدادات الافتراضية',
                        onTap: () => _confirmReset(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'فاتح';
      case 'dark':
        return 'داكن';
      default:
        return 'تلقائي (حسب النظام)';
    }
  }

  String _printFormatLabel(String format) {
    switch (format) {
      case 'thermal80':
        return 'حراري ٨٠ مم';
      case 'thermal58':
        return 'حراري ٥٨ مم';
      default:
        return 'A4 عادي';
    }
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة تعيين الإعدادات'),
        content: const Text(
          'هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟\nلا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(settingsProvider.notifier).resetToDefaults();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إعادة تعيين الإعدادات بنجاح'),
                  ),
                );
              }
            },
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ويدجت قسم الإعدادات
// =============================================================================
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 4),
            child: Row(
              children: [
                Icon(icon, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          GradientCard(
            color: scheme.surfaceContainerLow,
            border: true,
            padding: EdgeInsets.zero,
            shadow: false,
            child: Column(children: items),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// =============================================================================
// ويدجت عنصر الإعداد
// =============================================================================
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(
                        Icons.chevron_left_rounded,
                        size: 18,
                        color: scheme.onSurface.withValues(alpha: 0.35),
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
