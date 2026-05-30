import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/branch/vault.dart';

class BranchRepository {
  late Box _vaultBox;
  late Box _transactionsBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _vaultBox = await Hive.openBox('vaults');
    _transactionsBox = await Hive.openBox('vault_transactions');
    if (_vaultBox.isEmpty) {
      await _seedDefaultVault();
    }
    _initialized = true;
  }

  Future<void> _seedDefaultVault() async {
    final vault = Vault(
      id: 'vault_main',
      name: 'الخزينة الرئيسية',
      currentBalance: 0,
      minBalance: 10000,
      maxBalance: 5000000,
      branchName: 'المركز الرئيسي - تعز',
      lastUpdated: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await _vaultBox.put(vault.id, jsonEncode(vault.toMap()));
  }

  Future<List<Vault>> getAllVaults() async {
    await init();
    final entries = _vaultBox.values.cast<String>();
    return entries.map((e) => Vault.fromMap(jsonDecode(e))).toList();
  }

  Future<Vault?> getVault(String id) async {
    await init();
    final data = _vaultBox.get(id) as String?;
    if (data == null) return null;
    return Vault.fromMap(jsonDecode(data));
  }

  Future<Vault> getMainVault() async {
    final vault = await getVault('vault_main');
    return vault ?? Vault(
      id: 'vault_main',
      name: 'الخزينة الرئيسية',
      lastUpdated: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  Future<void> saveVault(Vault vault) async {
    await init();
    await _vaultBox.put(vault.id, jsonEncode(vault.toMap()));
  }

  Future<void> updateBalance(String vaultId, double newBalance) async {
    final vault = await getVault(vaultId);
    if (vault != null) {
      await saveVault(vault.copyWith(
        currentBalance: newBalance,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<List<VaultTransaction>> getAllTransactions() async {
    await init();
    final entries = _transactionsBox.values.cast<String>();
    return entries
        .map((e) => VaultTransaction.fromMap(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<VaultTransaction>> getTransactionsByVault(String vaultId) async {
    final all = await getAllTransactions();
    return all.where((t) => t.id.startsWith(vaultId)).toList();
  }

  Future<List<VaultTransaction>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    final all = await getAllTransactions();
    return all
        .where((t) =>
            t.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
            t.createdAt.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  Future<void> addTransaction(VaultTransaction transaction) async {
    await init();
    await _transactionsBox.put(
        transaction.id, jsonEncode(transaction.toMap()));

    final vault = await getMainVault();
    double newBalance = vault.currentBalance;
    switch (transaction.type) {
      case VaultTransactionType.deposit:
      case VaultTransactionType.transferFromAgent:
        newBalance += transaction.amount;
        break;
      case VaultTransactionType.withdrawal:
      case VaultTransactionType.transferToAgent:
        newBalance -= transaction.amount;
        break;
      case VaultTransactionType.settlement:
      case VaultTransactionType.openingBalance:
        newBalance = transaction.balanceAfter;
        break;
    }
    await updateBalance('vault_main', newBalance);
  }

  Future<int> getTransactionCount() async {
    await init();
    return _transactionsBox.length;
  }

  Future<void> deleteAll() async {
    await _vaultBox.clear();
    await _transactionsBox.clear();
  }
}
