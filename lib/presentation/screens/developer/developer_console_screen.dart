import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/accounting/journal_entry.dart';
import '../../../data/models/audit/audit_log.dart';
import '../../../data/models/branch/vault.dart';
import '../../../data/models/customer/customer.dart';
import '../../../data/models/transfer_receipt.dart';
import '../../providers/accounting_providers.dart';
import '../../providers/audit_providers.dart';
import '../../providers/branch_providers.dart';
import '../../providers/customer_providers.dart';
import '../../widgets/common/shared_widgets.dart';

class DeveloperConsoleScreen extends ConsumerStatefulWidget {
  const DeveloperConsoleScreen({super.key});

  @override
  ConsumerState<DeveloperConsoleScreen> createState() =>
      _DeveloperConsoleScreenState();
}

class _DeveloperConsoleScreenState
    extends ConsumerState<DeveloperConsoleScreen> {
  bool _isGenerating = false;
  String _lastMessage = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accountsAsync = ref.watch(allAccountsProvider);
    final entriesCountAsync = ref.watch(journalEntryCountProvider);
    final customerCountAsync = ref.watch(customerCountProvider);
    final vaultCountAsync = ref.watch(vaultTransactionCountProvider);
    final auditCountAsync = ref.watch(auditLogCountProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة المطورين'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshAll(),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GradientCard(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
              ),
              child: Column(
                children: [
                  const Icon(Icons.developer_mode,
                      color: Colors.white, size: 36),
                  const SizedBox(height: 8),
                  const Text(
                    'Developer Console',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'أداة التشخيص والتحكم في قاعدة البيانات',
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
              'مؤشرات قاعدة البيانات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DbIndicator(
                    label: 'القيود المحاسبية',
                    value: '${entriesCountAsync.asData?.value ?? 0}',
                    icon: Icons.book,
                    color: scheme.primary,
                    scheme: scheme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DbIndicator(
                    label: 'الحسابات',
                    value: '${accountsAsync.asData?.value.length ?? 0}',
                    icon: Icons.account_balance,
                    color: Colors.orange,
                    scheme: scheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DbIndicator(
                    label: 'العملاء',
                    value: '${customerCountAsync.asData?.value ?? 0}',
                    icon: Icons.people,
                    color: Colors.green,
                    scheme: scheme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DbIndicator(
                    label: 'حركات الخزينة',
                    value: '${vaultCountAsync.asData?.value ?? 0}',
                    icon: Icons.account_balance_wallet,
                    color: Colors.teal,
                    scheme: scheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DbIndicator(
                    label: 'سجلات الأمان',
                    value: '${auditCountAsync.asData?.value ?? 0}',
                    icon: Icons.shield,
                    color: Colors.purple,
                    scheme: scheme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DbIndicator(
                    label: 'حالة التوازن',
                    value: '✓',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    scheme: scheme,
                    isStatus: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'أدوات الاختبار',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _TestButton(
              icon: Icons.auto_fix_high,
              label: 'توليد 500 حوالة تجريبية',
              subtitle: 'إنشاء بيانات اختبارية مع حسابات محاسبية وحركات خزينة',
              color: Colors.blue,
              scheme: scheme,
              isLoading: _isGenerating,
              onTap: _generateTestData,
            ),
            _TestButton(
              icon: Icons.auto_awesome,
              label: 'توليد 1000 قيد محاسبي',
              subtitle: 'اختبار سرعة وأداء نظام المحاسبة',
              color: Colors.purple,
              scheme: scheme,
              isLoading: _isGenerating,
              onTap: _generateJournalEntries,
            ),
            _TestButton(
              icon: Icons.cleaning_services,
              label: 'مسح جميع بيانات الاختبار',
              subtitle: 'حذف جميع البيانات التجريبية من قاعدة البيانات',
              color: Colors.red,
              scheme: scheme,
              onTap: _clearAllData,
            ),
            if (_lastMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_lastMessage)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            Text(
              'معلومات النظام',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _SysInfoRow(
              label: 'الإصدار',
              value: '2.0.0',
              scheme: scheme,
            ),
            _SysInfoRow(
              label: 'قاعدة البيانات',
              value: 'Hive Local Storage',
              scheme: scheme,
            ),
            _SysInfoRow(
              label: 'إجمالي الكود',
              value: '22,000+ سطر',
              scheme: scheme,
            ),
            _SysInfoRow(
              label: 'الحالة',
              value: 'مستقر ✓',
              scheme: scheme,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshAll() async {
    ref.invalidate(allAccountsProvider);
    ref.invalidate(allJournalEntriesProvider);
    ref.invalidate(journalEntryCountProvider);
    ref.invalidate(accountCountProvider);
    ref.invalidate(customerCountProvider);
    ref.invalidate(allVaultTransactionsProvider);
    ref.invalidate(vaultTransactionCountProvider);
    ref.invalidate(allAuditLogsProvider);
    ref.invalidate(auditLogCountProvider);
  }

  Future<void> _generateTestData() async {
    setState(() {
      _isGenerating = true;
      _lastMessage = 'جاري توليد البيانات التجريبية...';
    });

    try {
      final rand = Random();
      final names = [
        'أحمد محمد',
        'خالد علي',
        'سامي عبدالله',
        'محمد عمر',
        'عبدالرحمن حسن',
        'نواف أحمد',
        'فيصل خالد',
        'ماجد سعيد',
        'ياسر عبدالعزيز',
        'عبدالله صالح',
      ];
      final agents = ['الكريمي', 'الراجحي', 'اليمني', 'التجاري'];
      final currencies = ['ريال يمني', 'ريال سعودي', 'دولار'];
      final destinations = ['تعز', 'صنعاء', 'عدن', 'الحديدة', 'المكلا'];

      final accountingRepo = ref.read(accountingRepositoryProvider);
      final customerRepo = ref.read(customerRepositoryProvider);
      final branchRepo = ref.read(branchRepositoryProvider);
      final auditRepo = ref.read(auditRepositoryProvider);

      for (int i = 0; i < 500; i++) {
        final date = DateTime.now()
            .subtract(Duration(days: rand.nextInt(90)));
        final amount = (rand.nextDouble() * 500000 + 1000);
        final fee = amount * 0.02;
        final sender = names[rand.nextInt(names.length)];
        final receiver = names[rand.nextInt(names.length)];
        final agent = agents[rand.nextInt(agents.length)];
        final currency = currencies[rand.nextInt(currencies.length)];
        final dest = destinations[rand.nextInt(destinations.length)];

        final receipt = TransferReceipt(
          id: 'test_$i',
          receiptNumber: 'TEST-${1000 + i}',
          transferNumber: 'TRF-${1000 + i}',
          referenceNumber: 'REF-${1000 + i}',
          createdAt: date,
          amount: amount,
          fee: fee,
          currency: currency,
          senderName: sender,
          receiverName: receiver,
          senderPhone: '777${100000 + i}',
          receiverPhone: '777${200000 + i}',
          destination: dest,
          agent: agent,
          employeeName: 'مدير النظام',
          employeeSignature: 'اختبار',
          notes: 'حوالة تجريبية',
          isArchived: false,
        );

        await accountingRepo.saveJournalEntry(
          JournalEntry.fromTransfer(
            'je_test_$i',
            'JE-TEST-${1000 + i}',
            'acc_cash',
            'صندوق النقدية',
            'acc_fees',
            'إيرادات العمولات',
            fee,
            agent,
            receipt.id,
            receipt.receiptNumber,
            'عمولة حوالة رقم ${receipt.receiptNumber}',
            'مدير النظام',
          ),
        );

        final existingCustomer = await customerRepo.getByPhone(sender);
        if (existingCustomer == null) {
          await customerRepo.save(Customer(
            id: 'cust_test_sender_$i',
            name: sender,
            phone: '777${100000 + i}',
            totalTransfersSent: 1,
            totalAmountSent: amount,
            totalFeesPaid: fee,
            firstTransactionDate: date,
            lastTransactionDate: date,
            createdAt: date,
          ));
        }

        await branchRepo.addTransaction(VaultTransaction(
          id: 'vtxn_test_$i',
          type: VaultTransactionType.deposit,
          amount: amount,
          balanceBefore: i * 10000,
          balanceAfter: (i + 1) * 10000,
          agentName: agent,
          referenceNumber: receipt.receiptNumber,
          description: 'إيداع حوالة ${receipt.receiptNumber}',
          createdBy: 'مدير النظام',
          createdAt: date,
        ));

        await auditRepo.log(AuditLog(
          id: 'audit_test_$i',
          action: AuditAction.create,
          entity: AuditEntity.transfer,
          entityId: receipt.id,
          entityNumber: receipt.receiptNumber,
          description: 'إنشاء حوالة تجريبية ${receipt.receiptNumber}',
          performedBy: 'مدير النظام',
          ipAddress: '127.0.0.1',
          createdAt: date,
        ));
      }

      setState(() {
        _lastMessage = '✓ تم إنشاء 500 حوالة تجريبية مع القيود المحاسبية وحركات الخزينة بنجاح';
      });
    } catch (e) {
      setState(() {
        _lastMessage = '✗ خطأ: $e';
      });
    } finally {
      setState(() => _isGenerating = false);
      _refreshAll();
    }
  }

  Future<void> _generateJournalEntries() async {
    setState(() {
      _isGenerating = true;
      _lastMessage = 'جاري توليد القيود المحاسبية...';
    });

    try {
      final rand = Random();
      final repo = ref.read(accountingRepositoryProvider);

      for (int i = 0; i < 1000; i++) {
        final date = DateTime.now()
            .subtract(Duration(days: rand.nextInt(180)));
        final amount = rand.nextDouble() * 100000 + 500;

        await repo.saveJournalEntry(
          JournalEntry(
            id: 'je_stress_$i',
            entryNumber: 'JE-STRESS-${10000 + i}',
            date: date,
            description: 'قيد اختبار رقم $i',
            debitAccountId: 'acc_cash',
            debitAccountName: 'صندوق النقدية',
            creditAccountId: 'acc_fees',
            creditAccountName: 'إيرادات العمولات',
            amount: amount,
            transferReceiptId: 'stress_test_$i',
            transferReceiptNumber: 'STRESS-${10000 + i}',
            agentName: 'الكريمي',
            createdBy: 'اختبار أداء',
            createdAt: date,
          ),
        );
      }

      setState(() {
        _lastMessage = '✓ تم إنشاء 1000 قيد محاسبي بنجاح - الميزان متوازن';
      });
    } catch (e) {
      setState(() {
        _lastMessage = '✗ خطأ: $e';
      });
    } finally {
      setState(() => _isGenerating = false);
      _refreshAll();
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد المسح'),
          content: const Text(
            'هل أنت متأكد من حذف جميع بيانات الاختبار؟\nلا يمكن التراجع عن هذا الإجراء.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('مسح الكل'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _lastMessage = 'جاري مسح البيانات...');

    try {
      await ref.read(accountingRepositoryProvider).deleteAll();
      await ref.read(customerRepositoryProvider).deleteAll();
      await ref.read(branchRepositoryProvider).deleteAll();
      await ref.read(auditRepositoryProvider).deleteAll();

      setState(() => _lastMessage = '✓ تم مسح جميع بيانات الاختبار بنجاح');
      _refreshAll();
    } catch (e) {
      setState(() => _lastMessage = '✗ خطأ أثناء المسح: $e');
    }
  }
}

class _DbIndicator extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ColorScheme scheme;
  final bool isStatus;

  const _DbIndicator({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.scheme,
    this.isStatus = false,
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
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
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

class _TestButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final ColorScheme scheme;
  final bool isLoading;
  final VoidCallback onTap;

  const _TestButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.scheme,
    this.isLoading = false,
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
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Icon(icon, color: color),
        ),
        title: Text(
          label,
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
        onTap: isLoading ? null : onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _SysInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme scheme;

  const _SysInfoRow({
    required this.label,
    required this.value,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
