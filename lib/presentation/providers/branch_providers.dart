import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/branch/vault.dart';
import '../../data/repositories/branch_repository.dart';

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return BranchRepository();
});

final allVaultsProvider = FutureProvider<List<Vault>>((ref) async {
  final repo = ref.read(branchRepositoryProvider);
  return repo.getAllVaults();
});

final mainVaultProvider = FutureProvider<Vault>((ref) async {
  final repo = ref.read(branchRepositoryProvider);
  return repo.getMainVault();
});

final allVaultTransactionsProvider =
    FutureProvider<List<VaultTransaction>>((ref) async {
  final repo = ref.read(branchRepositoryProvider);
  return repo.getAllTransactions();
});

final vaultTransactionCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(branchRepositoryProvider);
  return repo.getTransactionCount();
});
