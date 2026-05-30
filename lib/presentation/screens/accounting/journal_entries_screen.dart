import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/utils/arabic_formatters.dart';
import '../../../data/models/accounting/journal_entry.dart';
import '../../providers/accounting_providers.dart';
import '../../widgets/common/shared_widgets.dart';

class JournalEntriesScreen extends ConsumerStatefulWidget {
  const JournalEntriesScreen({super.key});

  @override
  ConsumerState<JournalEntriesScreen> createState() =>
      _JournalEntriesScreenState();
}

class _JournalEntriesScreenState
    extends ConsumerState<JournalEntriesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entriesAsync = ref.watch(filteredJournalEntriesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قيود اليومية'),
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _pickDateRange,
              tooltip: 'فلترة حسب التاريخ',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(scheme),
            if (_dateRange != null)
              _buildDateRangeChip(scheme),
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.book_outlined,
                      message: 'لا توجد قيود محاسبية بعد',
                    );
                  }
                  final filtered = _searchQuery.isEmpty
                      ? entries
                      : entries.where((e) {
                          final q = _searchQuery.toLowerCase();
                          return e.entryNumber.toLowerCase().contains(q) ||
                              e.description.toLowerCase().contains(q) ||
                              e.debitAccountName.toLowerCase().contains(q) ||
                              e.creditAccountName.toLowerCase().contains(q);
                        }).toList();
                  if (filtered.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.search_off,
                      message: 'لا توجد نتائج للبحث',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _JournalEntryCard(
                            entry: filtered[index], scheme: scheme),
                  );
                },
                loading: () => const LoadingWidget(),
                error: (e, _) => EmptyStateWidget(
                  icon: Icons.error_outline,
                  message: 'خطأ: $e',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'بحث في القيود...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDateRangeChip(ColorScheme scheme) {
    final f = DateFormat.yMMMd('ar');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Chip(
            label: Text(
              '${f.format(_dateRange!.start)} - ${f.format(_dateRange!.end)}',
            ),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() => _dateRange = null);
              ref
                  .read(selectedJournalDateRangeProvider.notifier)
                  .state = null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _dateRange,
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      ref.read(selectedJournalDateRangeProvider.notifier).state = picked;
    }
  }
}

class _JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final ColorScheme scheme;

  const _JournalEntryCard({required this.entry, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('yyyy/MM/dd HH:mm', 'ar');

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
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.entryNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                f.format(entry.date),
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                ArabicFormatters.formatAmount(entry.amount),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.description,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _AccountLabel(
                  label: 'مدين',
                  name: entry.debitAccountName,
                  color: Colors.green,
                  scheme: scheme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AccountLabel(
                  label: 'دائن',
                  name: entry.creditAccountName,
                  color: Colors.red,
                  scheme: scheme,
                ),
              ),
            ],
          ),
          if (entry.transferReceiptNumber != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.receipt, size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'حوالة رقم: ${entry.transferReceiptNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountLabel extends StatelessWidget {
  final String label;
  final String name;
  final Color color;
  final ColorScheme scheme;

  const _AccountLabel({
    required this.label,
    required this.name,
    required this.color,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
