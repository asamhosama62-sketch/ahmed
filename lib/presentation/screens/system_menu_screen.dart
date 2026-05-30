import 'package:flutter/material.dart';

import '../screens/accounting/financial_reports_screen.dart';
import '../screens/accounting/journal_entries_screen.dart';
import '../screens/accounting/ledger_screen.dart';
import '../screens/branch/branch_monitoring_screen.dart';
import '../screens/branch/vault_ledger_screen.dart';
import '../screens/customer/customer_list_screen.dart';
import '../screens/customer/loyalty_tier_screen.dart';
import '../screens/developer/audit_logs_screen.dart';
import '../screens/developer/developer_console_screen.dart';
import '../widgets/common/shared_widgets.dart';

class SystemMenuScreen extends StatelessWidget {
  const SystemMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('النظام'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GradientCard(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary,
                  scheme.primary.withValues(alpha: 0.8),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.dashboard_customize,
                      color: Colors.white, size: 36),
                  const SizedBox(height: 8),
                  const Text(
                    'لوحة الأنظمة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'جميع الأنظمة الفرعية المتكاملة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(
              label: 'المحاسبة',
              icon: Icons.account_balance,
              scheme: scheme,
            ),
            _MenuItem(
              icon: Icons.book,
              title: 'قيود اليومية',
              subtitle: 'تتبع القيود المحاسبية اليومية',
              color: scheme.primary,
              scheme: scheme,
              onTap: () => _push(context, const JournalEntriesScreen()),
            ),
            _MenuItem(
              icon: Icons.account_balance,
              title: 'دفتر الأستاذ',
              subtitle: 'سجل الحسابات والأرصدة',
              color: Colors.orange,
              scheme: scheme,
              onTap: () => _push(context, const LedgerScreen()),
            ),
            _MenuItem(
              icon: Icons.assessment,
              title: 'التقارير المالية',
              subtitle: 'ميزان المراجعة وتحليل الإيرادات',
              color: Colors.green,
              scheme: scheme,
              onTap: () =>
                  _push(context, const FinancialReportsScreen()),
            ),
            const SizedBox(height: 16),
            _SectionLabel(
              label: 'العملاء',
              icon: Icons.people,
              scheme: scheme,
            ),
            _MenuItem(
              icon: Icons.people,
              title: 'إدارة العملاء',
              subtitle: 'قائمة العملاء والبحث',
              color: Colors.teal,
              scheme: scheme,
              onTap: () => _push(context, const CustomerListScreen()),
            ),
            _MenuItem(
              icon: Icons.diamond,
              title: 'برنامج الولاء',
              subtitle: 'مستويات العضوية والخصومات',
              color: const Color(0xFF6C63FF),
              scheme: scheme,
              onTap: () => _push(context, const LoyaltyTierScreen()),
            ),
            const SizedBox(height: 16),
            _SectionLabel(
              label: 'الخزينة والفروع',
              icon: Icons.account_balance_wallet,
              scheme: scheme,
            ),
            _MenuItem(
              icon: Icons.receipt_long,
              title: 'حركة الخزينة',
              subtitle: 'إيداع وسحب وتسوية النقدية',
              color: Colors.brown,
              scheme: scheme,
              onTap: () => _push(context, const VaultLedgerScreen()),
            ),
            _MenuItem(
              icon: Icons.analytics,
              title: 'مراقبة السيولة',
              subtitle: 'مؤشرات الأداء المالي',
              color: Colors.indigo,
              scheme: scheme,
              onTap: () =>
                  _push(context, const BranchMonitoringScreen()),
            ),
            const SizedBox(height: 16),
            _SectionLabel(
              label: 'الأمان والتطوير',
              icon: Icons.security,
              scheme: scheme,
            ),
            _MenuItem(
              icon: Icons.shield,
              title: 'سجل التدقيق الأمني',
              subtitle: 'تتبع جميع العمليات الحساسة',
              color: Colors.red,
              scheme: scheme,
              onTap: () => _push(context, const AuditLogsScreen()),
            ),
            _MenuItem(
              icon: Icons.developer_mode,
              title: 'لوحة المطورين',
              subtitle: 'أدوات التشخيص واختبار الأداء',
              color: const Color(0xFF1A1A2E),
              scheme: scheme,
              onTap: () =>
                  _push(context, const DeveloperConsoleScreen()),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final ColorScheme scheme;

  const _SectionLabel({
    required this.label,
    required this.icon,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final ColorScheme scheme;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.scheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        trailing: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.chevron_left,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
