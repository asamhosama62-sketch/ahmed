// =============================================================================
// موفرو الإحصائيات - تطبيق العكابي للحوالات المالية
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transfer_receipt.dart';
import '../../services/statistics_service.dart';
import 'transfer_providers.dart';

// ─── خدمة الإحصائيات ──────────────────────────────────────────────────────────
final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return const StatisticsService();
});

// ─── جميع الحوالات (نشطة + مؤرشفة) لأغراض الإحصاء ───────────────────────────
final allReceiptsForStatsProvider =
    FutureProvider<List<TransferReceipt>>((ref) async {
  final repo = ref.read(transferRepositoryProvider);
  final active = await repo.getAll(archived: false);
  final archived = await repo.getAll(archived: true);
  return [...active, ...archived];
});

// ─── الإحصائيات الشاملة ───────────────────────────────────────────────────────
final overallStatsProvider = FutureProvider<OverallStats>((ref) async {
  final receipts = await ref.watch(allReceiptsForStatsProvider.future);
  final service = ref.read(statisticsServiceProvider);
  return service.computeOverallStats(receipts);
});

// ─── الإحصائيات اليومية ───────────────────────────────────────────────────────
final selectedDateForStatsProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final dayStatsProvider = FutureProvider<PeriodStats>((ref) async {
  final receipts = await ref.watch(allReceiptsForStatsProvider.future);
  final date = ref.watch(selectedDateForStatsProvider);
  final service = ref.read(statisticsServiceProvider);
  return service.getDayStats(receipts, date);
});

// ─── الإحصائيات الشهرية ───────────────────────────────────────────────────────
final selectedMonthProvider = StateProvider<({int year, int month})>((ref) {
  final now = DateTime.now();
  return (year: now.year, month: now.month);
});

final monthStatsProvider = FutureProvider<PeriodStats>((ref) async {
  final receipts = await ref.watch(allReceiptsForStatsProvider.future);
  final selected = ref.watch(selectedMonthProvider);
  final service = ref.read(statisticsServiceProvider);
  return service.getMonthStats(receipts, selected.year, selected.month);
});

final monthDailyTotalsProvider = FutureProvider<List<DailyTotal>>((ref) async {
  final receipts = await ref.watch(allReceiptsForStatsProvider.future);
  final selected = ref.watch(selectedMonthProvider);
  final service = ref.read(statisticsServiceProvider);
  return service.getMonthDailyTotals(receipts, selected.year, selected.month);
});

// ─── الأشهر المتاحة ───────────────────────────────────────────────────────────
final availableMonthsProvider = FutureProvider<List<String>>((ref) async {
  final receipts = await ref.watch(allReceiptsForStatsProvider.future);
  final service = ref.read(statisticsServiceProvider);
  return service.getAvailableMonths(receipts);
});

// ─── نطاق مخصص ────────────────────────────────────────────────────────────────
final customDateRangeProvider = StateProvider<({DateTime from, DateTime to})?>(
  (ref) => null,
);

final customRangeStatsProvider = FutureProvider<PeriodStats?>((ref) async {
  final range = ref.watch(customDateRangeProvider);
  if (range == null) return null;
  final receipts = await ref.watch(allReceiptsForStatsProvider.future);
  final service = ref.read(statisticsServiceProvider);
  final filtered = service.getReceiptsBetween(receipts, range.from, range.to);
  final totalAmount = filtered.fold(0.0, (s, r) => s + r.amount);
  final totalFees = filtered.fold(0.0, (s, r) => s + r.fee);
  final amounts = filtered.map((r) => r.amount).toList()..sort();
  final curBreak = <String, CurrencyStats>{};
  final destBreak = <String, DestinationStats>{};
  for (final r in filtered) {
    curBreak.putIfAbsent(r.currency, () => const CurrencyStats(currency: '', count: 0, totalAmount: 0, totalFees: 0));
    curBreak[r.currency] = CurrencyStats(
      currency: r.currency,
      count: curBreak[r.currency]!.count + 1,
      totalAmount: curBreak[r.currency]!.totalAmount + r.amount,
      totalFees: curBreak[r.currency]!.totalFees + r.fee,
    );
    destBreak.putIfAbsent(r.destination, () => DestinationStats(destination: r.destination, count: 0, totalAmount: 0, percentage: 0));
    destBreak[r.destination] = DestinationStats(
      destination: r.destination,
      count: destBreak[r.destination]!.count + 1,
      totalAmount: destBreak[r.destination]!.totalAmount + r.amount,
      percentage: 0,
    );
  }
  return PeriodStats(
    period: 'نطاق مخصص',
    transferCount: filtered.length,
    totalAmount: totalAmount,
    totalFees: totalFees,
    totalRevenue: totalAmount + totalFees,
    averageAmount: filtered.isEmpty ? 0 : totalAmount / filtered.length,
    maxAmount: amounts.isEmpty ? 0 : amounts.last,
    minAmount: amounts.isEmpty ? 0 : amounts.first,
    currencyBreakdown: curBreak,
    destinationBreakdown: destBreak,
    dailyTotals: const [],
    activeCount: filtered.where((r) => !r.isArchived).length,
    archivedCount: filtered.where((r) => r.isArchived).length,
  );
});

// ─── إحصائيات لوحة التحكم (للشاشة الرئيسية) ─────────────────────────────────
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final receipts = await ref.watch(allReceiptsForStatsProvider.future);
  final service = ref.read(statisticsServiceProvider);
  final overall = service.computeOverallStats(receipts);
  return DashboardStats(
    todayCount: overall.todayStats.transferCount,
    todayAmount: overall.todayStats.totalRevenue,
    monthCount: overall.thisMonthStats.transferCount,
    monthAmount: overall.thisMonthStats.totalRevenue,
    totalCount: overall.totalTransfers,
    totalAmount: overall.totalRevenue,
    monthGrowth: overall.monthlyGrowthRate,
  );
});

/// بيانات لوحة التحكم المختصرة
class DashboardStats {
  const DashboardStats({
    required this.todayCount,
    required this.todayAmount,
    required this.monthCount,
    required this.monthAmount,
    required this.totalCount,
    required this.totalAmount,
    required this.monthGrowth,
  });

  final int todayCount;
  final double todayAmount;
  final int monthCount;
  final double monthAmount;
  final int totalCount;
  final double totalAmount;
  final double monthGrowth;

  bool get isPositiveGrowth => monthGrowth >= 0;
}
