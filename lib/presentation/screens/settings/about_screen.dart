// =============================================================================
// شاشة حول التطبيق - تطبيق العكابي
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/settings_providers.dart';
import '../../../presentation/widgets/common/shared_widgets.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('حول التطبيق')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── شعار التطبيق ──────────────────────────────────────
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary,
                          scheme.primary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.currency_exchange_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'تطبيق العكابي',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Al-Akabi Money Transfer System',
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'الإصدار ${settings.version}',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // ─── معلومات ──────────────────────────────────────────
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.storefront_rounded,
                    label: 'الشركة',
                    value: settings.companyName,
                  ),
                  const AkabDivider(),
                  _InfoRow(
                    icon: Icons.location_on_rounded,
                    label: 'الفرع',
                    value: settings.branchName,
                  ),
                  const AkabDivider(),
                  _InfoRow(
                    icon: Icons.badge_rounded,
                    label: 'الموظف',
                    value: settings.defaultEmployeeName,
                  ),
                  const AkabDivider(),
                  _InfoRow(
                    icon: Icons.phone_rounded,
                    label: 'الهاتف',
                    value: settings.companyPhones,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── ميزات التطبيق ────────────────────────────────────
            const SectionHeader(
              title: 'ميزات التطبيق',
              icon: Icons.star_rounded,
              padding: EdgeInsets.only(bottom: 12),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _FeatureRow(
                    icon: Icons.receipt_long_rounded,
                    title: 'سندات الحوالات',
                    subtitle: 'إنشاء وطباعة سندات احترافية بصيغة PDF',
                    color: scheme.primary,
                  ),
                  const AkabDivider(),
                  _FeatureRow(
                    icon: Icons.bar_chart_rounded,
                    title: 'الإحصائيات',
                    subtitle: 'تقارير يومية وشهرية مع رسوم بيانية',
                    color: Colors.green,
                  ),
                  const AkabDivider(),
                  _FeatureRow(
                    icon: Icons.settings_rounded,
                    title: 'الإعدادات',
                    subtitle: 'تخصيص كامل بدون تعديل الكود',
                    color: Colors.orange,
                  ),
                  const AkabDivider(),
                  _FeatureRow(
                    icon: Icons.qr_code_rounded,
                    title: 'رمز QR',
                    subtitle: 'التحقق السريع من الحوالات',
                    color: Colors.purple,
                  ),
                  const AkabDivider(),
                  _FeatureRow(
                    icon: Icons.search_rounded,
                    title: 'بحث متقدم',
                    subtitle: 'بحث بالاسم، الهاتف، الرقم',
                    color: Colors.teal,
                  ),
                  const AkabDivider(),
                  _FeatureRow(
                    icon: Icons.archive_rounded,
                    title: 'الأرشيف',
                    subtitle: 'حفظ السجلات القديمة بأمان',
                    color: Colors.brown,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── معلومات تقنية ────────────────────────────────────
            const SectionHeader(
              title: 'معلومات تقنية',
              icon: Icons.code_rounded,
              padding: EdgeInsets.only(bottom: 8),
            ),
            GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.phone_android_rounded,
                    label: 'المنصة',
                    value: 'Flutter (Android / iOS / Desktop)',
                  ),
                  const AkabDivider(),
                  _InfoRow(
                    icon: Icons.font_download_rounded,
                    label: 'الخط',
                    value: 'Cairo (محلي - يعمل بدون إنترنت)',
                  ),
                  const AkabDivider(),
                  _InfoRow(
                    icon: Icons.storage_rounded,
                    label: 'قاعدة البيانات',
                    value: 'Hive (محلية - لا تحتاج سيرفر)',
                  ),
                  const AkabDivider(),
                  _InfoRow(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'الـ PDF',
                    value: 'pdf & printing (محلي بخط Cairo)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── حقوق النشر ───────────────────────────────────────
            Center(
              child: Text(
                '© ${DateTime.now().year} ${settings.companyName}\nجميع الحقوق محفوظة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
