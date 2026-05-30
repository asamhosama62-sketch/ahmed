import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../data/models/audit/audit_log.dart';
import '../../providers/audit_providers.dart';
import '../../widgets/common/shared_widgets.dart';

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  final _searchController = TextEditingController();
  AuditEntity? _entityFilter;
  AuditAction? _actionFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final logsAsync = ref.watch(filteredAuditLogsProvider);
    final countAsync = ref.watch(auditLogCountProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل التدقيق الأمني'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(filteredAuditLogsProvider);
                ref.invalidate(auditLogCountProvider);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(scheme),
            _buildFilterChips(scheme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.security, size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'إجمالي السجلات: ${countAsync.asData?.value ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: logsAsync.when(
                data: (logs) {
                  var filtered = logs;
                  if (_entityFilter != null) {
                    filtered = filtered
                        .where((l) => l.entity == _entityFilter)
                        .toList();
                  }
                  if (_actionFilter != null) {
                    filtered = filtered
                        .where((l) => l.action == _actionFilter)
                        .toList();
                  }
                  if (filtered.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.shield_outlined,
                      message: 'لا توجد سجلات أمان',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _AuditLogCard(
                            log: filtered[index], scheme: scheme),
                  );
                },
                loading: () => const LoadingWidget(),
                error: (e, _) => Center(child: Text('خطأ: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          ref.read(auditSearchQueryProvider.notifier).state = v;
        },
        decoration: InputDecoration(
          hintText: 'بحث في سجل الأمان...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(auditSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('الكل'),
              selected: _entityFilter == null && _actionFilter == null,
              onSelected: (_) {
                setState(() {
                  _entityFilter = null;
                  _actionFilter = null;
                });
              },
            ),
            const SizedBox(width: 6),
            FilterChip(
              label: const Text('حوالات'),
              selected: _entityFilter == AuditEntity.transfer,
              onSelected: (v) {
                setState(() =>
                    _entityFilter = v ? AuditEntity.transfer : null);
              },
            ),
            const SizedBox(width: 6),
            FilterChip(
              label: const Text('إعدادات'),
              selected: _entityFilter == AuditEntity.setting,
              onSelected: (v) {
                setState(
                    () => _entityFilter = v ? AuditEntity.setting : null);
              },
            ),
            const SizedBox(width: 6),
            FilterChip(
              label: const Text('عملاء'),
              selected: _entityFilter == AuditEntity.customer,
              onSelected: (v) {
                setState(
                    () => _entityFilter = v ? AuditEntity.customer : null);
              },
            ),
            const SizedBox(width: 6),
            FilterChip(
              label: const Text('نسخ احتياطي'),
              selected: _entityFilter == AuditEntity.backup,
              onSelected: (v) {
                setState(
                    () => _entityFilter = v ? AuditEntity.backup : null);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final AuditLog log;
  final ColorScheme scheme;

  const _AuditLogCard({required this.log, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final actionColor = _getActionColor();
    final f = DateFormat('yyyy/MM/dd HH:mm:ss', 'ar');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getActionIcon(), color: actionColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${log.actionLabel} ${log.entityLabel}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      f.format(log.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 12,
                        color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      log.performedBy,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                    if (log.entityNumber != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.receipt, size: 12,
                          color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '#${log.entityNumber}',
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor() {
    switch (log.action) {
      case AuditAction.create:
        return Colors.green;
      case AuditAction.update:
        return Colors.blue;
      case AuditAction.archive:
        return Colors.orange;
      case AuditAction.delete:
        return Colors.red;
      case AuditAction.backup:
        return Colors.purple;
      case AuditAction.restore:
        return Colors.teal;
      case AuditAction.login:
        return Colors.indigo;
      case AuditAction.logout:
        return Colors.grey;
      case AuditAction.settingsChange:
        return Colors.amber;
      case AuditAction.export:
        return Colors.cyan;
      case AuditAction.print:
        return Colors.brown;
      case AuditAction.vaultTransaction:
        return Colors.deepOrange;
      case AuditAction.journalEntry:
        return Colors.lightBlue;
    }
  }

  IconData _getActionIcon() {
    switch (log.action) {
      case AuditAction.create:
        return Icons.add_circle_outline;
      case AuditAction.update:
        return Icons.edit_outlined;
      case AuditAction.archive:
        return Icons.archive_outlined;
      case AuditAction.delete:
        return Icons.delete_outline;
      case AuditAction.backup:
        return Icons.backup;
      case AuditAction.restore:
        return Icons.restore;
      case AuditAction.login:
        return Icons.login;
      case AuditAction.logout:
        return Icons.logout;
      case AuditAction.settingsChange:
        return Icons.settings;
      case AuditAction.export:
        return Icons.file_upload;
      case AuditAction.print:
        return Icons.print;
      case AuditAction.vaultTransaction:
        return Icons.account_balance;
      case AuditAction.journalEntry:
        return Icons.book;
    }
  }
}
