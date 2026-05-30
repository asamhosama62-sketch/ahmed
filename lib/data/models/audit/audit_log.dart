enum AuditAction {
  create,
  update,
  archive,
  delete,
  backup,
  restore,
  login,
  logout,
  settingsChange,
  export,
  print,
  vaultTransaction,
  journalEntry,
}

enum AuditEntity {
  transfer,
  setting,
  customer,
  account,
  journalEntry,
  vault,
  backup,
}

class AuditLog {
  final String id;
  final AuditAction action;
  final AuditEntity entity;
  final String entityId;
  final String? entityNumber;
  final String description;
  final String performedBy;
  final String? ipAddress;
  final Map<String, dynamic>? details;
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    required this.action,
    required this.entity,
    required this.entityId,
    this.entityNumber,
    required this.description,
    required this.performedBy,
    this.ipAddress,
    this.details,
    required this.createdAt,
  });

  String get actionLabel {
    switch (action) {
      case AuditAction.create:
        return 'إنشاء';
      case AuditAction.update:
        return 'تعديل';
      case AuditAction.archive:
        return 'أرشفة';
      case AuditAction.delete:
        return 'حذف';
      case AuditAction.backup:
        return 'نسخ احتياطي';
      case AuditAction.restore:
        return 'استعادة';
      case AuditAction.login:
        return 'دخول';
      case AuditAction.logout:
        return 'خروج';
      case AuditAction.settingsChange:
        return 'تغيير إعدادات';
      case AuditAction.export:
        return 'تصدير';
      case AuditAction.print:
        return 'طباعة';
      case AuditAction.vaultTransaction:
        return 'حركة خزينة';
      case AuditAction.journalEntry:
        return 'قيد محاسبي';
    }
  }

  String get entityLabel {
    switch (entity) {
      case AuditEntity.transfer:
        return 'حوالة';
      case AuditEntity.setting:
        return 'إعدادات';
      case AuditEntity.customer:
        return 'عميل';
      case AuditEntity.account:
        return 'حساب محاسبي';
      case AuditEntity.journalEntry:
        return 'قيد يومية';
      case AuditEntity.vault:
        return 'خزينة';
      case AuditEntity.backup:
        return 'نسخ احتياطي';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'action': action.name,
        'entity': entity.name,
        'entityId': entityId,
        'entityNumber': entityNumber,
        'description': description,
        'performedBy': performedBy,
        'ipAddress': ipAddress,
        'details': details,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AuditLog.fromMap(Map<String, dynamic> map) => AuditLog(
        id: map['id'] as String,
        action: AuditAction.values.byName(map['action'] as String),
        entity: AuditEntity.values.byName(map['entity'] as String),
        entityId: map['entityId'] as String,
        entityNumber: map['entityNumber'] as String?,
        description: map['description'] as String,
        performedBy: map['performedBy'] as String,
        ipAddress: map['ipAddress'] as String?,
        details: map['details'] as Map<String, dynamic>?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
