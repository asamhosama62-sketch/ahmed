import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/arabic_formatters.dart';
import '../../../data/models/accounting/account.dart';
import '../../../data/models/accounting/journal_entry.dart';
import '../../providers/accounting_providers.dart';
import '../../widgets/common/shared_widgets.dart';

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final accountsAsync = ref.watch(allAccountsProvider);
    final entriesAsync = ref.watch(allJournalEntriesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('دفتر الأستاذ العام'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allAccountsProvider);
            ref.invalidate(allJournalEntriesProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BalanceSummaryCard(scheme: scheme),
              const SizedBox(height: 20),
              Text(
                'الحسابات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              accountsAsync.when(
                data: (accounts) => Column(
                  children: accounts
                      .where((a) => a.isActive)
                      .map((a) => _AccountCard(
                            account: a,
                            scheme: scheme,
                            entriesAsync: entriesAsync,
                          ))
                      .toList(),
                ),
                loading: () => const LoadingWidget(),
                error: (e, _) => Center(child: Text('خطأ: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceSummaryCard extends StatelessWidget {
  final ColorScheme scheme;

  const _BalanceSummaryCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
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
          const Icon(Icons.account_balance, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            'دفتر الأستاذ العام',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'سجل جميع الحسابات والحركات المالية',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final ColorScheme scheme;
  final AsyncValue<List<JournalEntry>> entriesAsync;

  const _AccountCard({
    required this.account,
    required this.scheme,
    required this.entriesAsync,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();
    final typeLabel = _getTypeLabel();
    final entries = entriesAsync.asData?.value ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  account.code,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: typeColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  account.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _BalanceItem(
                label: 'الرصيد الحالي',
                value: account.currentBalance,
                color: account.currentBalance >= 0
                    ? Colors.green
                    : Colors.red,
                scheme: scheme,
              ),
              const SizedBox(width: 12),
              _BalanceItem(
                label: 'الحركات',
                value: entries
                    .where((e) =>
                        e.debitAccountId == account.id ||
                        e.creditAccountId == account.id)
                    .length
                    .toDouble(),
                color: scheme.primary,
                scheme: scheme,
                isCount: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: account.type == AccountType.asset ||
                        account.type == AccountType.expense
                    ? account.currentBalance.clamp(0, 1000000) / 1000000
                    : 0,
                backgroundColor: typeColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(typeColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (account.type) {
      case AccountType.asset:
        return Colors.blue;
      case AccountType.liability:
        return Colors.orange;
      case AccountType.equity:
        return Colors.purple;
      case AccountType.revenue:
        return Colors.green;
      case AccountType.expense:
        return Colors.red;
    }
  }

  String _getTypeLabel() {
    switch (account.type) {
      case AccountType.asset:
        return 'أصل';
      case AccountType.liability:
        return 'خصم';
      case AccountType.equity:
        return 'حقوق ملكية';
      case AccountType.revenue:
        return 'إيراد';
      case AccountType.expense:
        return 'مصروف';
    }
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ColorScheme scheme;
  final bool isCount;

  const _BalanceItem({
    required this.label,
    required this.value,
    required this.color,
    required this.scheme,
    this.isCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isCount
                  ? '${value.toInt()}'
                  : ArabicFormatters.formatAmount(value),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
