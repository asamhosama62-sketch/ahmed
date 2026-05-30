// =============================================================================
// موفرو الحوالات - محدّث ليشمل البحث في الأرشيف
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transfer_receipt.dart';
import '../../data/repositories/transfer_repository.dart';
import '../../services/receipt_pdf_service.dart';
import '../../services/receipt_share_service.dart';

// ─── موفر المستودع ────────────────────────────────────────────────────────────
final transferRepositoryProvider = Provider<TransferRepository>(
  (_) => throw UnimplementedError('override in main.dart'),
);

// ─── موفر خدمة PDF ────────────────────────────────────────────────────────────
final receiptPdfServiceProvider = Provider<ReceiptPdfService>(
  (_) => ReceiptPdfService(),
);

// ─── موفر خدمة المشاركة ──────────────────────────────────────────────────────
final receiptShareServiceProvider = Provider<ReceiptShareService>(
  (ref) => ReceiptShareService(ref.read(receiptPdfServiceProvider)),
);

// ─── موفر الحوالات النشطة ──────────────────────────────────────────────────────
class ActiveTransfersNotifier
    extends AutoDisposeAsyncNotifier<List<TransferReceipt>> {
  @override
  Future<List<TransferReceipt>> build() async {
    final repo = ref.read(transferRepositoryProvider);
    return repo.getAll(archived: false);
  }

  Future<void> add(TransferReceipt receipt) async {
    final repo = ref.read(transferRepositoryProvider);
    await repo.save(receipt);
    ref.invalidateSelf();
  }

  Future<void> editTransfer(TransferReceipt receipt) async {
    final repo = ref.read(transferRepositoryProvider);
    await repo.update(receipt);
    ref.invalidateSelf();
  }

  Future<void> archive(String id, {bool archived = true}) async {
    final repo = ref.read(transferRepositoryProvider);
    await repo.archive(id, archived: archived);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    final repo = ref.read(transferRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }

  Future<List<TransferReceipt>> search(
    String query, {
    bool archived = false,
  }) async {
    final repo = ref.read(transferRepositoryProvider);
    final all = await repo.getAll(archived: archived);
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((r) {
      final text = [
        r.receiptNumber,
        r.transferNumber,
        r.referenceNumber,
        r.senderName,
        r.receiverName,
        r.senderPhone,
        r.receiverPhone,
        r.destination,
        r.employeeName,
        r.notes,
      ].join(' ').toLowerCase();
      return text.contains(q);
    }).toList();
  }
}

final activeTransfersProvider =
    AsyncNotifierProvider.autoDispose<
      ActiveTransfersNotifier,
      List<TransferReceipt>
    >(ActiveTransfersNotifier.new);

// ─── الحوالات المؤرشفة ────────────────────────────────────────────────────────
final archivedTransfersProvider =
    FutureProvider.autoDispose<List<TransferReceipt>>((ref) async {
      final repo = ref.read(transferRepositoryProvider);
      return repo.getAll(archived: true);
    });

// ─── آخر رقم متسلسل ──────────────────────────────────────────────────────────
final nextTransferNumberProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.read(transferRepositoryProvider);
  final all = await repo.getAll(archived: false);
  final archived = await repo.getAll(archived: true);
  final combined = [...all, ...archived];
  if (combined.isEmpty) return 1;
  final numbers = combined
      .map(
        (r) =>
            int.tryParse(r.transferNumber.replaceAll(RegExp(r'\D'), '')) ?? 0,
      )
      .where((n) => n > 0)
      .toList();
  if (numbers.isEmpty) return 1;
  numbers.sort();
  return numbers.last + 1;
});
