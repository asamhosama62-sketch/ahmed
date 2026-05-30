import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/customer/customer.dart';
import '../../data/repositories/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

final allCustomersProvider = FutureProvider<List<Customer>>((ref) async {
  final repo = ref.read(customerRepositoryProvider);
  return repo.getAll();
});

final customerSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredCustomersProvider = FutureProvider<List<Customer>>((ref) async {
  final repo = ref.read(customerRepositoryProvider);
  final query = ref.watch(customerSearchQueryProvider);
  if (query.isEmpty) return repo.getAll();
  return repo.search(query);
});

final topCustomersProvider = FutureProvider<List<Customer>>((ref) async {
  final repo = ref.read(customerRepositoryProvider);
  return repo.getTopCustomers();
});

final customerCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(customerRepositoryProvider);
  return repo.getCount();
});
