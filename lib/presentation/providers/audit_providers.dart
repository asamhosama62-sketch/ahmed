import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/audit/audit_log.dart';
import '../../data/repositories/audit_repository.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository();
});

final allAuditLogsProvider = FutureProvider<List<AuditLog>>((ref) async {
  final repo = ref.read(auditRepositoryProvider);
  return repo.getAll();
});

final auditSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredAuditLogsProvider = FutureProvider<List<AuditLog>>((ref) async {
  final repo = ref.read(auditRepositoryProvider);
  final query = ref.watch(auditSearchQueryProvider);
  if (query.isEmpty) return repo.getAll();
  return repo.search(query);
});

final auditLogCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(auditRepositoryProvider);
  return repo.getCount();
});

final auditActionSummaryProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.read(auditRepositoryProvider);
  return repo.getActionSummary();
});
