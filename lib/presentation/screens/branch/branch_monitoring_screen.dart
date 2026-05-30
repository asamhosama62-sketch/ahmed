import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/arabic_formatters.dart';
import '../../../data/models/branch/vault.dart';
import '../../providers/branch_providers.dart';
import '../../widgets/common/shared_widgets.dart';

class BranchMonitoringScreen extends ConsumerWidget {
  const BranchMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final vaultAsync = ref.watch(mainVaultProvider);
    final transactionsAsync = ref.watch(allVaultTransactionsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مراقبة الفروع والسيولة'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(mainVaultProvider);
            ref.invalidate(allVaultTransactionsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GradientCard(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.tertiary,
                    scheme.tertiary.withValues(alpha: 0.8),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.account_balance,
                        color: Colors.white, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'مراقبة السيولة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مؤشرات الأداء والسلامة المالية',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'مؤشرات الخزينة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              vaultAsync.when(
                data: (vault) => _VaultIndicators(
                    vault: vault, scheme: scheme),
                loading: () => const LoadingWidget(),
                error: (e, _) => Center(child: Text('خطأ: $e')),
              ),
              const SizedBox(height: 24),
              Text(
                'تحليل الحركات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              transactionsAsync.when(
                data: (transactions) {
                  final totalDeposits = transactions
                      .where((t) =>
                          t.type == VaultTransactionType.deposit ||
                          t.type == VaultTransactionType.transferFromAgent)
                      .fold(0.0, (s, t) => s + t.amount);
                  final totalWithdrawals = transactions
                      .where((t) =>
                          t.type == VaultTransactionType.withdrawal ||
                          t.type == VaultTransactionType.transferToAgent)
                      .fold(0.0, (s, t) => s + t.amount);
                  final todayTransactions = transactions
                      .where((t) =>
                          t.createdAt.day == DateTime.now().day &&
                          t.createdAt.month == DateTime.now().month &&
                          t.createdAt.year == DateTime.now().year)
                      .length;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _IndicatorCard(
                              label: 'إجمالي الإيداعات',
                              value: totalDeposits,
                              icon: Icons.arrow_downward,
                              color: Colors.green,
                              scheme: scheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _IndicatorCard(
                              label: 'إجمالي السحوبات',
                              value: totalWithdrawals,
                              icon: Icons.arrow_upward,
                              color: Colors.red,
                              scheme: scheme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _IndicatorCard(
                              label: 'صافي التدفق',
                              value: totalDeposits - totalWithdrawals,
                              icon: Icons.swap_vert,
                              color: totalDeposits >= totalWithdrawals
                                  ? Colors.green
                                  : Colors.red,
                              scheme: scheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _IndicatorCard(
                              label: 'حركات اليوم',
                              value: todayTransactions.toDouble(),
                              icon: Icons.today,
                              color: scheme.primary,
                              scheme: scheme,
                              isCount: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const LoadingWidget(),
                error: (e, _) => Center(child: Text('خطأ: $e')),
              ),
              const SizedBox(height: 24),
              Text(
                'تقارير الأداء',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _ReportCard(
                icon: Icons.pie_chart,
                title: 'تقرير السيولة اليومي',
                subtitle: 'عرض تفصيلي للسيولة النقدية والإيداعات والسحوبات',
                scheme: scheme,
                onTap: () {},
              ),
              _ReportCard(
                icon: Icons.trending_up,
                title: 'تحليل الاتجاهات',
                subtitle: 'مقارنة الحركات المالية عبر الفترات المختلفة',
                scheme: scheme,
                onTap: () {},
              ),
              _ReportCard(
                icon: Icons.warning_amber,
                title: 'تقرير التنبيهات',
                subtitle: 'عرض حالات تجاوز الحدود الدنيا والقصوى للسيولة',
                scheme: scheme,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VaultIndicators extends StatelessWidget {
  final Vault vault;
  final ColorScheme scheme;

  const _VaultIndicators({required this.vault, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Indicator(
                label: 'الرصيد الحالي',
                value: vault.currentBalance,
                scheme: scheme,
              ),
              const SizedBox(width: 12),
              _Indicator(
                label: 'الحد الأدنى',
                value: vault.minBalance,
                scheme: scheme,
              ),
              const SizedBox(width: 12),
              _Indicator(
                label: 'الحد الأقصى',
                value: vault.maxBalance,
                scheme: scheme,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'مستوى السيولة',
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${vault.balanceUtilization.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: vault.isLowBalance
                      ? Colors.red
                      : vault.isHighBalance
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: vault.balanceUtilization / 100,
              minHeight: 12,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                vault.isLowBalance
                    ? Colors.red
                    : vault.isHighBalance
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatusDot(
                label: 'حالة الخزينة',
                isActive: !vault.isLowBalance && !vault.isHighBalance,
                activeText: 'طبيعية',
                inactiveText: vault.isLowBalance
                    ? 'رصيد منخفض'
                    : 'رصيد مرتفع',
                scheme: scheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final String label;
  final double value;
  final ColorScheme scheme;

  const _Indicator({
    required this.label,
    required this.value,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            ArabicFormatters.formatAmount(value),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final String activeText;
  final String inactiveText;
  final ColorScheme scheme;

  const _StatusDot({
    required this.label,
    required this.isActive,
    required this.activeText,
    required this.inactiveText,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isActive ? activeText : inactiveText,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: isActive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final ColorScheme scheme;
  final bool isCount;

  const _IndicatorCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.scheme,
    this.isCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            isCount
                ? '${value.toInt()}'
                : ArabicFormatters.formatAmount(value),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme scheme;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.scheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: scheme.onPrimaryContainer),
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
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
