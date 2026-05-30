import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/audit/audit_log.dart';

class AuditRepository {
  late Box _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox('audit_logs');
    _initialized = true;
  }

  Future<void> log(AuditLog entry) async {
    await init();
    await _box.add(jsonEncode(entry.toMap()));
  }

  Future<List<AuditLog>> getAll() async {
    await init();
    final entries = _box.values.cast<String>();
    return entries
        .map((e) => AuditLog.fromMap(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<AuditLog>> getByAction(AuditAction action) async {
    final all = await getAll();
    return all.where((e) => e.action == action).toList();
  }

  Future<List<AuditLog>> getByEntity(AuditEntity entity) async {
    final all = await getAll();
    return all.where((e) => e.entity == entity).toList();
  }

  Future<List<AuditLog>> getByDateRange(
      DateTime start, DateTime end) async {
    final all = await getAll();
    return all
        .where((e) =>
            e.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
            e.createdAt.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  Future<List<AuditLog>> getByPerformer(String name) async {
    final all = await getAll();
    return all.where((e) => e.performedBy == name).toList();
  }

  Future<List<AuditLog>> search(String query) async {
    final all = await getAll();
    final q = query.toLowerCase();
    return all
        .where((e) =>
            e.description.toLowerCase().contains(q) ||
            e.performedBy.toLowerCase().contains(q) ||
            e.entityLabel.contains(q) ||
            e.actionLabel.contains(q))
        .toList();
  }

  Future<AuditLog> logCreate({
    required AuditEntity entity,
    required String entityId,
    String? entityNumber,
    required String description,
    required String performedBy,
    Map<String, dynamic>? details,
  }) async {
    final auditLogEntry = AuditLog(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}_$entityId',
      action: AuditAction.create,
      entity: entity,
      entityId: entityId,
      entityNumber: entityNumber,
      description: description,
      performedBy: performedBy,
      ipAddress: '127.0.0.1',
      details: details,
      createdAt: DateTime.now(),
    );
    await log(auditLogEntry);
    return auditLogEntry;
  }

  Future<AuditLog> logUpdate({
    required AuditEntity entity,
    required String entityId,
    String? entityNumber,
    required String description,
    required String performedBy,
    Map<String, dynamic>? details,
  }) async {
    final auditLogEntry = AuditLog(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}_$entityId',
      action: AuditAction.update,
      entity: entity,
      entityId: entityId,
      entityNumber: entityNumber,
      description: description,
      performedBy: performedBy,
      ipAddress: '127.0.0.1',
      details: details,
      createdAt: DateTime.now(),
    );
    await log(auditLogEntry);
    return auditLogEntry;
  }

  Future<AuditLog> logDelete({
    required AuditEntity entity,
    required String entityId,
    String? entityNumber,
    required String description,
    required String performedBy,
    Map<String, dynamic>? details,
  }) async {
    final auditLogEntry = AuditLog(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}_$entityId',
      action: AuditAction.delete,
      entity: entity,
      entityId: entityId,
      entityNumber: entityNumber,
      description: description,
      performedBy: performedBy,
      ipAddress: '127.0.0.1',
      details: details,
      createdAt: DateTime.now(),
    );
    await log(auditLogEntry);
    return auditLogEntry;
  }

  Future<AuditLog> logAction({
    required AuditAction action,
    required AuditEntity entity,
    required String entityId,
    String? entityNumber,
    required String description,
    required String performedBy,
    Map<String, dynamic>? details,
  }) async {
    final auditLogEntry = AuditLog(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}_$entityId',
      action: action,
      entity: entity,
      entityId: entityId,
      entityNumber: entityNumber,
      description: description,
      performedBy: performedBy,
      ipAddress: '127.0.0.1',
      details: details,
      createdAt: DateTime.now(),
    );
    await log(auditLogEntry);
    return auditLogEntry;
  }

  Future<int> getCount() async {
    await init();
    return _box.length;
  }

  Future<Map<String, int>> getActionSummary() async {
    final all = await getAll();
    final summary = <String, int>{};
    for (final e in all) {
      summary.update(e.actionLabel, (v) => v + 1, ifAbsent: () => 1);
    }
    return summary;
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}
