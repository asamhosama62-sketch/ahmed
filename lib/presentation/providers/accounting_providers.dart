import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/accounting/account.dart';
import '../../data/models/accounting/journal_entry.dart';
import '../../data/repositories/accounting_repository.dart';

final accountingRepositoryProvider = Provider<AccountingRepository>((ref) {
  return AccountingRepository();
});

final allAccountsProvider = FutureProvider<List<Account>>((ref) async {
  final repo = ref.read(accountingRepositoryProvider);
  return repo.getAllAccounts();
});

final allJournalEntriesProvider =
    FutureProvider<List<JournalEntry>>((ref) async {
  final repo = ref.read(accountingRepositoryProvider);
  return repo.getAllJournalEntries();
});

final selectedJournalDateRangeProvider =
    StateProvider<DateTimeRange?>((ref) => null);

final filteredJournalEntriesProvider =
    FutureProvider<List<JournalEntry>>((ref) async {
  final repo = ref.read(accountingRepositoryProvider);
  final range = ref.watch(selectedJournalDateRangeProvider);
  if (range == null) return repo.getAllJournalEntries();
  return repo.getEntriesByDateRange(range.start, range.end);
});

final totalFeesIncomeProvider = FutureProvider<double>((ref) async {
  final repo = ref.read(accountingRepositoryProvider);
  return repo.getTotalFeesIncome();
});

final isAccountingBalancedProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(accountingRepositoryProvider);
  return repo.isBalanced();
});

final journalEntryCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(accountingRepositoryProvider);
  return repo.getJournalEntryCount();
});

final accountCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(accountingRepositoryProvider);
  return repo.getAccountCount();
});
