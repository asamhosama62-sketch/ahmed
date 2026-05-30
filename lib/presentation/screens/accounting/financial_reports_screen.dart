import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/utils/arabic_formatters.dart';
import '../../../data/models/accounting/account.dart';
import '../../providers/accounting_providers.dart';
import '../../widgets/common/shared_widgets.dart';
import '../../widgets/accounting/accounting_charts.dart';

class FinancialReportsScreen extends ConsumerStatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  ConsumerState<FinancialReportsScreen> createState() =>
      _FinancialReportsScreenState();
}

class _FinancialReportsScreenState
    extends ConsumerState<FinancialReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير المالية'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'ملخص', icon: Icon(Icons.summarize)),
              Tab(text: 'إيرادات', icon: Icon(Icons.trending_up)),
              Tab(text: 'ميزان المراجعة', icon: Icon(Icons.balance)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _SummaryTab(scheme: scheme),
            _RevenueTab(scheme: scheme),
            _TrialBalanceTab(scheme: scheme),
          ],
        ),
      ),
    );
  }
}

class _SummaryTab extends ConsumerWidget {
  final ColorScheme scheme;

  const _SummaryTab({required this.scheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feesAsync = ref.watch(totalFeesIncomeProvider);
    final entriesAsync = ref.watch(allJournalEntriesProvider);
    final balanceAsync = ref.watch(isAccountingBalancedProvider);
    final entriesCountAsync = ref.watch(journalEntryCountProvider);
    final accountsCountAsync = ref.watch(accountCountProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(totalFeesIncomeProvider);
        ref.invalidate(allJournalEntriesProvider);
        ref.invalidate(isAccountingBalancedProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GradientCard(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, scheme.primary.withValues(alpha: 0.8)],
            ),
            child: Column(
              children: [
                const Icon(Icons.assessment, color: Colors.white, size: 36),
                const SizedBox(height: 8),
                Text(
                  'التقرير المالي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نظرة شاملة على الوضع المالي',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryStatCard(
                  label: 'إجمالي العمولات',
                  value: feesAsync.asData?.value ?? 0,
                  icon: Icons.monetization_on,
                  color: Colors.green,
                  scheme: scheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryStatCard(
                  label: 'عدد القيود',
                  value: (entriesCountAsync.asData?.value ?? 0).toDouble(),
                  icon: Icons.book,
                  color: scheme.primary,
                  scheme: scheme,
                  isCount: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryStatCard(
                  label: 'الحسابات',
                  value: (accountsCountAsync.asData?.value ?? 0).toDouble(),
                  icon: Icons.account_balance,
                  color: Colors.orange,
                  scheme: scheme,
                  isCount: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryStatCard(
                  label: 'حالة التوازن',
                  value: balanceAsync.asData?.value == true ? 1 : 0,
                  icon: balanceAsync.asData?.value == true
                      ? Icons.check_circle
                      : Icons.error,
                  color: balanceAsync.asData?.value == true
                      ? Colors.green
                      : Colors.red,
                  scheme: scheme,
                  isStatus: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'حركة الإيرادات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: entriesAsync.when(
              data: (entries) => entries.isEmpty
                  ? const Center(child: Text('لا توجد بيانات بعد'))
                  : RevenueBarChart(entries: entries),
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('خطأ: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final ColorScheme scheme;
  final bool isCount;
  final bool isStatus;

  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.scheme,
    this.isCount = false,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isStatus
                ? (value == 1 ? 'متوازن ✓' : 'غير متوازن ✗')
                : isCount
                    ? '${value.toInt()}'
                    : ArabicFormatters.formatAmount(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isStatus
                  ? (value == 1 ? Colors.green : Colors.red)
                  : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueTab extends ConsumerWidget {
  final ColorScheme scheme;

  const _RevenueTab({required this.scheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(allJournalEntriesProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'تحليل الإيرادات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        entriesAsync.when(
          data: (entries) {
            final feeEntries = entries
                .where((e) => e.creditAccountId == 'acc_fees')
                .toList();
            final totalFees =
                feeEntries.fold(0.0, (sum, e) => sum + e.amount);
            return Column(
              children: [
                GradientCard(
                  color: scheme.primaryContainer,
                  child: Column(
                    children: [
                      Text(
                        'إجمالي إيرادات العمولات',
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ArabicFormatters.formatAmount(totalFees),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'القيود المحاسبية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ...feeEntries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  DateFormat('yyyy/MM/dd', 'ar')
                                      .format(e.date),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            ArabicFormatters.formatAmount(e.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            );
          },
          loading: () => const LoadingWidget(),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ],
    );
  }
}

class _TrialBalanceTab extends ConsumerWidget {
  final ColorScheme scheme;

  const _TrialBalanceTab({required this.scheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(allAccountsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'ميزان المراجعة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ملخص أرصدة الحسابات للتحقق من التوازن المحاسبي',
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        accountsAsync.when(
          data: (accounts) {
            double totalDebit = 0, totalCredit = 0;
            final rows = accounts.where((a) => a.isActive).map((a) {
              if (a.type == AccountType.asset ||
                  a.type == AccountType.expense) {
                totalDebit += a.currentBalance.abs();
                return _TrialBalanceRow(
                  account: a,
                  debit: a.currentBalance.abs(),
                  credit: 0,
                  scheme: scheme,
                );
              } else {
                totalCredit += a.currentBalance.abs();
                return _TrialBalanceRow(
                  account: a,
                  debit: 0,
                  credit: a.currentBalance.abs(),
                  scheme: scheme,
                );
              }
            }).toList();

            return Column(
              children: [
                ...rows,
                const SizedBox(height: 8),
                _TrialBalanceTotal(
                  label: 'المجموع',
                  debit: totalDebit,
                  credit: totalCredit,
                  scheme: scheme,
                  isTotal: true,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: totalDebit == totalCredit
                        ? Colors.green.withValues(alpha: 0.08)
                        : Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: totalDebit == totalCredit
                          ? Colors.green
                          : Colors.red,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        totalDebit == totalCredit
                            ? Icons.check_circle
                            : Icons.error,
                        color:
                            totalDebit == totalCredit ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        totalDebit == totalCredit
                            ? 'الميزان متوازن ✓'
                            : 'الميزان غير متوازن - الفرق: ${ArabicFormatters.formatAmount((totalDebit - totalCredit).abs())}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: totalDebit == totalCredit
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const LoadingWidget(),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ],
    );
  }
}

class _TrialBalanceRow extends StatelessWidget {
  final Account account;
  final double debit;
  final double credit;
  final ColorScheme scheme;

  const _TrialBalanceRow({
    required this.account,
    required this.debit,
    required this.credit,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              account.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              debit > 0 ? ArabicFormatters.formatAmount(debit) : '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: debit > 0 ? Colors.red : scheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              credit > 0 ? ArabicFormatters.formatAmount(credit) : '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: credit > 0 ? Colors.green : scheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrialBalanceTotal extends StatelessWidget {
  final String label;
  final double debit;
  final double credit;
  final ColorScheme scheme;
  final bool isTotal;

  const _TrialBalanceTotal({
    required this.label,
    required this.debit,
    required this.credit,
    required this.scheme,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: scheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ArabicFormatters.formatAmount(debit),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ArabicFormatters.formatAmount(credit),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.green,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
