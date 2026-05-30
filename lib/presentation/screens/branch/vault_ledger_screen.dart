import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/utils/arabic_formatters.dart';
import '../../../data/models/branch/vault.dart';
import '../../providers/branch_providers.dart';
import '../../widgets/common/shared_widgets.dart';

class VaultLedgerScreen extends ConsumerStatefulWidget {
  const VaultLedgerScreen({super.key});

  @override
  ConsumerState<VaultLedgerScreen> createState() => _VaultLedgerScreenState();
}

class _VaultLedgerScreenState extends ConsumerState<VaultLedgerScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final vaultAsync = ref.watch(mainVaultProvider);
    final transactionsAsync = ref.watch(allVaultTransactionsProvider);
    final countAsync = ref.watch(vaultTransactionCountProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حركة الخزينة'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(mainVaultProvider);
                ref.invalidate(allVaultTransactionsProvider);
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            vaultAsync.when(
              data: (vault) => _VaultHeader(vault: vault, scheme: scheme),
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('خطأ: $e')),
            ),
            const SizedBox(height: 20),
            _buildQuickActions(scheme),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'سجل الحركات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '${countAsync.asData?.value ?? 0} حركة',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.receipt_long,
                    message: 'لا توجد حركات بعد',
                    subtitle: 'أضف حركة جديدة باستخدام الأزرار أعلاه',
                  );
                }
                return Column(
                  children: transactions
                      .map((t) => _TransactionCard(
                            transaction: t,
                            scheme: scheme,
                          ))
                      .toList(),
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('خطأ: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme scheme) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.add_circle,
            label: 'إيداع',
            color: Colors.green,
            scheme: scheme,
            onTap: () => _showTransactionDialog(VaultTransactionType.deposit),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.remove_circle,
            label: 'سحب',
            color: Colors.red,
            scheme: scheme,
            onTap: () =>
                _showTransactionDialog(VaultTransactionType.withdrawal),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.swap_horiz,
            label: 'تسوية',
            color: Colors.orange,
            scheme: scheme,
            onTap: () =>
                _showTransactionDialog(VaultTransactionType.settlement),
          ),
        ),
      ],
    );
  }

  Future<void> _showTransactionDialog(VaultTransactionType type) async {
    _amountController.clear();
    _descController.clear();
    final label = _typeLabel(type);

    await showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(label),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  prefixText: 'ريال ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(_amountController.text);
                if (amount == null || amount <= 0) return;
                final desc = _descController.text.isEmpty
                    ? _typeLabel(type)
                    : _descController.text;

                final repo = ref.read(branchRepositoryProvider);
                final vault = await repo.getMainVault();

                double balanceAfter = vault.currentBalance;
                switch (type) {
                  case VaultTransactionType.deposit:
                    balanceAfter += amount;
                    break;
                  case VaultTransactionType.withdrawal:
                    balanceAfter -= amount;
                    break;
                  case VaultTransactionType.settlement:
                    balanceAfter = amount;
                    break;
                  default:
                    break;
                }

                final txn = VaultTransaction(
                  id: 'vtxn_${DateTime.now().millisecondsSinceEpoch}',
                  type: type,
                  amount: amount,
                  balanceBefore: vault.currentBalance,
                  balanceAfter: balanceAfter,
                  description: desc,
                  createdBy: 'مدير النظام',
                  createdAt: DateTime.now(),
                );

                await repo.addTransaction(txn);
                ref.invalidate(mainVaultProvider);
                ref.invalidate(allVaultTransactionsProvider);
                ref.invalidate(vaultTransactionCountProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(VaultTransactionType type) {
    switch (type) {
      case VaultTransactionType.deposit:
        return 'إيداع';
      case VaultTransactionType.withdrawal:
        return 'سحب';
      case VaultTransactionType.settlement:
        return 'تسوية';
      default:
        return 'حركة';
    }
  }
}

class _VaultHeader extends StatelessWidget {
  final Vault vault;
  final ColorScheme scheme;

  const _VaultHeader({required this.vault, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          vault.isLowBalance
              ? Colors.red
              : vault.isHighBalance
                  ? Colors.orange
                  : scheme.primary,
          vault.isLowBalance
              ? Colors.red.shade700
              : vault.isHighBalance
                  ? Colors.orange.shade700
                  : scheme.primary.withValues(alpha: 0.8),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 8),
              Text(
                vault.name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              if (vault.isLowBalance)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'تنبيه: رصيد منخفض',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else if (vault.isHighBalance)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'تنبيه: رصيد مرتفع',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ArabicFormatters.formatAmount(vault.currentBalance),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'الرصيد الحالي',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(
                label: 'الحد الأدنى',
                value: vault.minBalance,
                scheme: scheme,
              ),
              const SizedBox(width: 12),
              _MiniStat(
                label: 'الحد الأقصى',
                value: vault.maxBalance,
                scheme: scheme,
              ),
              const SizedBox(width: 12),
              _MiniStat(
                label: 'الاستخدام',
                value: vault.balanceUtilization,
                scheme: scheme,
                isPercent: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final ColorScheme scheme;
  final bool isPercent;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.scheme,
    this.isPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              isPercent
                  ? '${value.toStringAsFixed(0)}%'
                  : ArabicFormatters.formatAmount(value),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ColorScheme scheme;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.scheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final VaultTransaction transaction;
  final ColorScheme scheme;

  const _TransactionCard({
    required this.transaction,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.type == VaultTransactionType.deposit ||
        transaction.type == VaultTransactionType.transferFromAgent;
    final f = DateFormat('yyyy/MM/dd HH:mm', 'ar');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isPositive ? Colors.green : Colors.red)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPositive
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: isPositive ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      transaction.typeLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      ArabicFormatters.formatAmount(transaction.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  f.format(transaction.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
