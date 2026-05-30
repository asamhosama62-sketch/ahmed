import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../models/transfer_receipt.dart';
import 'transfer_repository.dart';

class HiveTransferRepository implements TransferRepository {
  Box<dynamic>? _box;

  Box<dynamic> get _receiptsBox {
    final box = _box;
    if (box == null || !box.isOpen) {
      throw StateError('لم يتم تهيئة قاعدة بيانات الحوالات.');
    }
    return box;
  }

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(AppConstants.hiveBoxName);
    if (_receiptsBox.isEmpty) {
      await save(TransferReceipt.demo());
    }
  }

  @override
  Future<List<TransferReceipt>> getAll({bool archived = false}) async {
    final receipts =
        _receiptsBox.values
            .whereType<Map<dynamic, dynamic>>()
            .map(TransferReceipt.fromMap)
            .where((receipt) => receipt.isArchived == archived)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return receipts;
  }

  @override
  Future<TransferReceipt?> findById(String id) async {
    final value = _receiptsBox.get(id);
    if (value is Map<dynamic, dynamic>) {
      return TransferReceipt.fromMap(value);
    }
    return null;
  }

  @override
  Future<List<TransferReceipt>> search(
    String query, {
    bool archived = false,
  }) async {
    final normalized = query.trim().toLowerCase();
    final all = await getAll(archived: archived);
    if (normalized.isEmpty) return all;

    return all.where((receipt) {
      final haystack = [
        receipt.receiptNumber,
        receipt.transferNumber,
        receipt.referenceNumber,
        receipt.senderName,
        receipt.receiverName,
        receipt.senderPhone,
        receipt.receiverPhone,
        receipt.destination,
        receipt.employeeName,
      ].join(' ').toLowerCase();
      return haystack.contains(normalized);
    }).toList();
  }

  @override
  Future<void> save(TransferReceipt receipt) async {
    await _receiptsBox.put(receipt.id, receipt.toMap());
  }

  @override
  Future<void> update(TransferReceipt receipt) async {
    await _receiptsBox.put(receipt.id, receipt.toMap());
  }

  @override
  Future<void> archive(String id, {required bool archived}) async {
    final receipt = await findById(id);
    if (receipt == null) return;
    await update(receipt.copyWith(isArchived: archived));
  }

  @override
  Future<void> delete(String id) async {
    await _receiptsBox.delete(id);
  }

  @override
  Stream<List<TransferReceipt>> watch({bool archived = false}) async* {
    yield await getAll(archived: archived);
    await for (final _ in _receiptsBox.watch()) {
      yield await getAll(archived: archived);
    }
  }
}
