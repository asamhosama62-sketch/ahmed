import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/accounting/account.dart';
import '../models/accounting/journal_entry.dart';

class AccountingRepository {
  late Box _accountsBox;
  late Box _journalBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _accountsBox = await Hive.openBox('ledger_accounts');
    _journalBox = await Hive.openBox('journal_entries');
    if (_accountsBox.isEmpty) {
      await _seedDefaultAccounts();
    }
    _initialized = true;
  }

  Future<void> _seedDefaultAccounts() async {
    final accounts = [
      Account.cashAccount(),
      Account.feesIncomeAccount(),
      Account(
        id: 'acc_capital',
        code: '3001',
        name: 'رأس المال',
        type: AccountType.equity,
        category: AccountCategory.equityCapital,
        createdAt: DateTime.now(),
      ),
      Account(
        id: 'acc_expenses',
        code: '5001',
        name: 'مصروفات عامة',
        type: AccountType.expense,
        category: AccountCategory.expenseGeneral,
        createdAt: DateTime.now(),
      ),
    ];
    for (final account in accounts) {
      await _accountsBox.put(account.id, jsonEncode(account.toMap()));
    }
  }

  Future<List<Account>> getAllAccounts() async {
    await init();
    final entries = _accountsBox.values.cast<String>();
    return entries.map((e) => Account.fromMap(jsonDecode(e))).toList();
  }

  Future<Account?> getAccount(String id) async {
    await init();
    final data = _accountsBox.get(id) as String?;
    if (data == null) return null;
    return Account.fromMap(jsonDecode(data));
  }

  Future<void> saveAccount(Account account) async {
    await init();
    await _accountsBox.put(account.id, jsonEncode(account.toMap()));
  }

  Future<void> updateAccountBalance(
      String accountId, double newBalance) async {
    final account = await getAccount(accountId);
    if (account != null) {
      await saveAccount(account.copyWith(currentBalance: newBalance));
    }
  }

  Future<List<JournalEntry>> getAllJournalEntries() async {
    await init();
    final entries = _journalBox.values.cast<String>();
    return entries
        .map((e) => JournalEntry.fromMap(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<JournalEntry>> getEntriesByDateRange(
      DateTime start, DateTime end) async {
    final all = await getAllJournalEntries();
    return all
        .where((e) => e.date.isAfter(start.subtract(Duration(days: 1))) && 
                       e.date.isBefore(end.add(Duration(days: 1))))
        .toList();
  }

  Future<List<JournalEntry>> getEntriesByAccount(String accountId) async {
    final all = await getAllJournalEntries();
    return all
        .where((e) =>
            e.debitAccountId == accountId || e.creditAccountId == accountId)
        .toList();
  }

  Future<void> saveJournalEntry(JournalEntry entry) async {
    await init();
    await _journalBox.put(entry.id, jsonEncode(entry.toMap()));
    final debitAccount = await getAccount(entry.debitAccountId);
    final creditAccount = await getAccount(entry.creditAccountId);
    if (debitAccount != null) {
      await updateAccountBalance(
          entry.debitAccountId, debitAccount.currentBalance + entry.amount);
    }
    if (creditAccount != null) {
      await updateAccountBalance(
          entry.creditAccountId, creditAccount.currentBalance - entry.amount);
    }
  }

  Future<double> getTotalFeesIncome() async {
    final entries = await getAllJournalEntries();
    double total = 0;
    for (final e in entries) {
      if (e.creditAccountId == 'acc_fees') total += e.amount;
    }
    return total;
  }

  Future<double> getTotalRevenue(DateTime start, DateTime end) async {
    final entries = await getEntriesByDateRange(start, end);
    double total = 0;
    for (final e in entries) {
      if (e.creditAccountId == 'acc_fees') total += e.amount;
    }
    return total;
  }

  Future<Map<String, double>> getAccountBalances() async {
    final accounts = await getAllAccounts();
    final map = <String, double>{};
    for (final a in accounts) {
      map[a.id] = a.currentBalance;
    }
    return map;
  }

  Future<bool> isBalanced() async {
    final entries = await getAllJournalEntries();
    double totalDebit = 0, totalCredit = 0;
    for (final e in entries) {
      totalDebit += e.amount;
      totalCredit += e.amount;
    }
    return totalDebit == totalCredit;
  }

  Future<void> deleteAll() async {
    await _accountsBox.clear();
    await _journalBox.clear();
  }

  Future<int> getJournalEntryCount() async {
    await init();
    return _journalBox.length;
  }

  Future<int> getAccountCount() async {
    await init();
    return _accountsBox.length;
  }
}
