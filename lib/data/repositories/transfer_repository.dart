import '../models/transfer_receipt.dart';

abstract class TransferRepository {
  Future<void> init();

  Future<List<TransferReceipt>> getAll({bool archived = false});

  Future<TransferReceipt?> findById(String id);

  Future<List<TransferReceipt>> search(String query, {bool archived = false});

  Future<void> save(TransferReceipt receipt);

  Future<void> update(TransferReceipt receipt);

  Future<void> archive(String id, {required bool archived});

  Future<void> delete(String id);

  Stream<List<TransferReceipt>> watch({bool archived = false});
}
