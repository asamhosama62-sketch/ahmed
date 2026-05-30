import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer/customer.dart';

class CustomerRepository {
  late Box _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox('customers');
    _initialized = true;
  }

  Future<List<Customer>> getAll() async {
    await init();
    final entries = _box.values.cast<String>();
    return entries.map((e) => Customer.fromMap(jsonDecode(e))).toList()
      ..sort((a, b) => b.lastTransactionDate.compareTo(a.lastTransactionDate));
  }

  Future<Customer?> getById(String id) async {
    await init();
    final data = _box.get(id) as String?;
    if (data == null) return null;
    return Customer.fromMap(jsonDecode(data));
  }

  Future<Customer?> getByPhone(String phone) async {
    await init();
    final all = await getAll();
    try {
      return all.firstWhere((c) => c.phone == phone);
    } catch (_) {
      return null;
    }
  }

  Future<List<Customer>> search(String query) async {
    final all = await getAll();
    final q = query.toLowerCase();
    return all
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.phone.contains(q) ||
            (c.secondaryPhone?.contains(q) ?? false))
        .toList();
  }

  Future<void> save(Customer customer) async {
    await init();
    await _box.put(customer.id, jsonEncode(customer.toMap()));
  }

  Future<Customer> recordTransaction(
    String customerId, {
    required bool isSent,
    required double amount,
    required double fee,
    required String currency,
    required String agent,
  }) async {
    final customer = await getById(customerId);
    if (customer == null) throw Exception('العميل غير موجود');

    final updated = customer.copyWith(
      totalTransfersSent: isSent
          ? customer.totalTransfersSent + 1
          : customer.totalTransfersSent,
      totalTransfersReceived: !isSent
          ? customer.totalTransfersReceived + 1
          : customer.totalTransfersReceived,
      totalAmountSent:
          isSent ? customer.totalAmountSent + amount : customer.totalAmountSent,
      totalAmountReceived: !isSent
          ? customer.totalAmountReceived + amount
          : customer.totalAmountReceived,
      totalFeesPaid: customer.totalFeesPaid + fee,
      preferredCurrency: customer.preferredCurrency ?? currency,
      preferredAgent: customer.preferredAgent ?? agent,
      lastTransactionDate: DateTime.now(),
    );

    final points = updated.calculatePoints();
    final newTier = updated.calculateTier();

    final finalCustomer = updated.copyWith(
      loyaltyPoints: points,
      tier: newTier,
    );

    await save(finalCustomer);
    return finalCustomer;
  }

  Future<List<Customer>> getTopCustomers({int limit = 10}) async {
    final all = await getAll();
    all.sort((a, b) => b.totalVolume.compareTo(a.totalVolume));
    return all.take(limit).toList();
  }

  Future<int> getCount() async {
    await init();
    return _box.length;
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}
