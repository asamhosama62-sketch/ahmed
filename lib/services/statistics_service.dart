// =============================================================================
// خدمة الإحصائيات - تطبيق العكابي للحوالات المالية
// =============================================================================

import '../data/models/transfer_receipt.dart';

/// يمثل إحصائيات فترة زمنية محددة
class PeriodStats {
  const PeriodStats({
    required this.period,
    required this.transferCount,
    required this.totalAmount,
    required this.totalFees,
    required this.totalRevenue,
    required this.averageAmount,
    required this.maxAmount,
    required this.minAmount,
    required this.currencyBreakdown,
    required this.destinationBreakdown,
    required this.dailyTotals,
    required this.activeCount,
    required this.archivedCount,
  });

  final String period;
  final int transferCount;
  final double totalAmount;
  final double totalFees;
  final double totalRevenue; // amount + fees
  final double averageAmount;
  final double maxAmount;
  final double minAmount;
  final Map<String, CurrencyStats> currencyBreakdown;
  final Map<String, DestinationStats> destinationBreakdown;
  final List<DailyTotal> dailyTotals;
  final int activeCount;
  final int archivedCount;

  bool get isEmpty => transferCount == 0;

  /// نسبة الزيادة/النقصان مقارنة بفترة سابقة
  double growthRate(PeriodStats? previous) {
    if (previous == null || previous.totalRevenue == 0) return 0;
    return ((totalRevenue - previous.totalRevenue) / previous.totalRevenue) * 100;
  }

  static PeriodStats empty(String period) {
    return PeriodStats(
      period: period,
      transferCount: 0,
      totalAmount: 0,
      totalFees: 0,
      totalRevenue: 0,
      averageAmount: 0,
      maxAmount: 0,
      minAmount: 0,
      currencyBreakdown: {},
      destinationBreakdown: {},
      dailyTotals: [],
      activeCount: 0,
      archivedCount: 0,
    );
  }
}

/// إحصائيات عملة معينة
class CurrencyStats {
  const CurrencyStats({
    required this.currency,
    required this.count,
    required this.totalAmount,
    required this.totalFees,
  });

  final String currency;
  final int count;
  final double totalAmount;
  final double totalFees;
  double get totalRevenue => totalAmount + totalFees;
  double get percentage => 0; // يُحسب من الخارج
}

/// إحصائيات وجهة معينة
class DestinationStats {
  const DestinationStats({
    required this.destination,
    required this.count,
    required this.totalAmount,
    required this.percentage,
  });

  final String destination;
  final int count;
  final double totalAmount;
  final double percentage;
}

/// إجمالي يومي
class DailyTotal {
  const DailyTotal({
    required this.date,
    required this.count,
    required this.totalAmount,
    required this.totalFees,
  });

  final DateTime date;
  final int count;
  final double totalAmount;
  final double totalFees;
  double get totalRevenue => totalAmount + totalFees;
}

/// إحصائيات عامة شاملة
class OverallStats {
  const OverallStats({
    required this.totalTransfers,
    required this.activeTransfers,
    required this.archivedTransfers,
    required this.totalRevenue,
    required this.totalAmount,
    required this.totalFees,
    required this.todayStats,
    required this.thisWeekStats,
    required this.thisMonthStats,
    required this.thisYearStats,
    required this.lastMonthStats,
    required this.topDestinations,
    required this.topCurrencies,
    required this.monthlyTotals,
    required this.averageDailyTransfers,
    required this.peakDayCount,
    required this.peakDayDate,
  });

  final int totalTransfers;
  final int activeTransfers;
  final int archivedTransfers;
  final double totalRevenue;
  final double totalAmount;
  final double totalFees;
  final PeriodStats todayStats;
  final PeriodStats thisWeekStats;
  final PeriodStats thisMonthStats;
  final PeriodStats thisYearStats;
  final PeriodStats lastMonthStats;
  final List<DestinationStats> topDestinations;
  final List<CurrencyStats> topCurrencies;
  final List<MonthlyTotal> monthlyTotals;
  final double averageDailyTransfers;
  final int peakDayCount;
  final DateTime? peakDayDate;

  double get monthlyGrowthRate =>
      thisMonthStats.growthRate(lastMonthStats);
}

/// إجمالي شهري
class MonthlyTotal {
  const MonthlyTotal({
    required this.year,
    required this.month,
    required this.count,
    required this.totalAmount,
    required this.totalFees,
  });

  final int year;
  final int month;
  final int count;
  final double totalAmount;
  final double totalFees;
  double get totalRevenue => totalAmount + totalFees;

  String get label {
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${months[month]} $year';
  }
}

/// خدمة الإحصائيات - تحسب وتجمع البيانات
class StatisticsService {
  const StatisticsService();

  // ─── الإحصائيات الشاملة ──────────────────────────────────────────────────

  /// حساب الإحصائيات الشاملة من جميع الحوالات
  OverallStats computeOverallStats(List<TransferReceipt> allReceipts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = thisMonthStart.subtract(const Duration(days: 1));
    final thisYearStart = DateTime(now.year, 1, 1);

    final active = allReceipts.where((r) => !r.isArchived).toList();
    final archived = allReceipts.where((r) => r.isArchived).toList();

    final todayReceipts =
        allReceipts
            .where((r) => _isSameDay(r.createdAt, today))
            .toList();
    final thisWeekReceipts =
        allReceipts
            .where(
              (r) =>
                  r.createdAt.isAfter(thisWeekStart) ||
                  _isSameDay(r.createdAt, thisWeekStart),
            )
            .toList();
    final thisMonthReceipts =
        allReceipts
            .where(
              (r) =>
                  r.createdAt.isAfter(thisMonthStart) ||
                  _isSameDay(r.createdAt, thisMonthStart),
            )
            .toList();
    final lastMonthReceipts =
        allReceipts
            .where(
              (r) =>
                  (r.createdAt.isAfter(lastMonthStart) ||
                      _isSameDay(r.createdAt, lastMonthStart)) &&
                  (r.createdAt.isBefore(lastMonthEnd) ||
                      _isSameDay(r.createdAt, lastMonthEnd)),
            )
            .toList();
    final thisYearReceipts =
        allReceipts
            .where(
              (r) =>
                  r.createdAt.isAfter(thisYearStart) ||
                  _isSameDay(r.createdAt, thisYearStart),
            )
            .toList();

    // حساب الأيام الفريدة للمتوسط
    final uniqueDays =
        allReceipts
            .map(
              (r) =>
                  DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day),
            )
            .toSet();

    final averageDaily =
        uniqueDays.isEmpty
            ? 0.0
            : allReceipts.length / uniqueDays.length.toDouble();

    // إيجاد ذروة اليوم
    DateTime? peakDate;
    int peakCount = 0;
    final dayGroups = <DateTime, int>{};
    for (final r in allReceipts) {
      final day = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
      dayGroups[day] = (dayGroups[day] ?? 0) + 1;
    }
    for (final entry in dayGroups.entries) {
      if (entry.value > peakCount) {
        peakCount = entry.value;
        peakDate = entry.key;
      }
    }

    final monthlyTotals = _computeMonthlyTotals(allReceipts);
    final topDestinations = _computeDestinationStats(allReceipts);
    final topCurrencies = _computeCurrencyStats(allReceipts);

    final totalAmount =
        allReceipts.fold(0.0, (sum, r) => sum + r.amount);
    final totalFees = allReceipts.fold(0.0, (sum, r) => sum + r.fee);

    return OverallStats(
      totalTransfers: allReceipts.length,
      activeTransfers: active.length,
      archivedTransfers: archived.length,
      totalRevenue: totalAmount + totalFees,
      totalAmount: totalAmount,
      totalFees: totalFees,
      todayStats: _computePeriodStats('اليوم', todayReceipts),
      thisWeekStats: _computePeriodStats('هذا الأسبوع', thisWeekReceipts),
      thisMonthStats: _computePeriodStats('هذا الشهر', thisMonthReceipts),
      thisYearStats: _computePeriodStats('هذه السنة', thisYearReceipts),
      lastMonthStats: _computePeriodStats('الشهر الماضي', lastMonthReceipts),
      topDestinations: topDestinations,
      topCurrencies: topCurrencies,
      monthlyTotals: monthlyTotals,
      averageDailyTransfers: averageDaily,
      peakDayCount: peakCount,
      peakDayDate: peakDate,
    );
  }

  // ─── الإحصائيات اليومية ───────────────────────────────────────────────────

  /// الحوالات لتاريخ محدد
  List<TransferReceipt> getReceiptsForDate(
    List<TransferReceipt> all,
    DateTime date,
  ) {
    return all.where((r) => _isSameDay(r.createdAt, date)).toList();
  }

  /// إحصائيات يوم محدد
  PeriodStats getDayStats(List<TransferReceipt> all, DateTime date) {
    final dayReceipts = getReceiptsForDate(all, date);
    return _computePeriodStats(
      '${date.year}/${date.month}/${date.day}',
      dayReceipts,
    );
  }

  // ─── الإحصائيات الشهرية ───────────────────────────────────────────────────

  /// الحوالات لشهر ومنه محددين
  List<TransferReceipt> getReceiptsForMonth(
    List<TransferReceipt> all,
    int year,
    int month,
  ) {
    return all
        .where(
          (r) => r.createdAt.year == year && r.createdAt.month == month,
        )
        .toList();
  }

  /// إحصائيات شهر محدد
  PeriodStats getMonthStats(
    List<TransferReceipt> all,
    int year,
    int month,
  ) {
    final monthReceipts = getReceiptsForMonth(all, year, month);
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return _computePeriodStats('${months[month]} $year', monthReceipts);
  }

  /// الحصول على بيانات مخطط الأيام لشهر معين
  List<DailyTotal> getMonthDailyTotals(
    List<TransferReceipt> all,
    int year,
    int month,
  ) {
    final monthReceipts = getReceiptsForMonth(all, year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final date = DateTime(year, month, day);
      final dayReceipts =
          monthReceipts.where((r) => r.createdAt.day == day).toList();
      return DailyTotal(
        date: date,
        count: dayReceipts.length,
        totalAmount: dayReceipts.fold(0.0, (sum, r) => sum + r.amount),
        totalFees: dayReceipts.fold(0.0, (sum, r) => sum + r.fee),
      );
    });
  }

  // ─── مساعدات خاصة ────────────────────────────────────────────────────────

  PeriodStats _computePeriodStats(
    String period,
    List<TransferReceipt> receipts,
  ) {
    if (receipts.isEmpty) return PeriodStats.empty(period);

    final totalAmount = receipts.fold(0.0, (sum, r) => sum + r.amount);
    final totalFees = receipts.fold(0.0, (sum, r) => sum + r.fee);
    final amounts = receipts.map((r) => r.amount).toList();

    return PeriodStats(
      period: period,
      transferCount: receipts.length,
      totalAmount: totalAmount,
      totalFees: totalFees,
      totalRevenue: totalAmount + totalFees,
      averageAmount: totalAmount / receipts.length,
      maxAmount: amounts.reduce((a, b) => a > b ? a : b),
      minAmount: amounts.reduce((a, b) => a < b ? a : b),
      currencyBreakdown: _buildCurrencyBreakdown(receipts),
      destinationBreakdown: _buildDestinationBreakdown(receipts),
      dailyTotals: _buildDailyTotals(receipts),
      activeCount: receipts.where((r) => !r.isArchived).length,
      archivedCount: receipts.where((r) => r.isArchived).length,
    );
  }

  Map<String, CurrencyStats> _buildCurrencyBreakdown(
    List<TransferReceipt> receipts,
  ) {
    final map = <String, CurrencyStats>{};
    for (final r in receipts) {
      final existing = map[r.currency];
      if (existing == null) {
        map[r.currency] = CurrencyStats(
          currency: r.currency,
          count: 1,
          totalAmount: r.amount,
          totalFees: r.fee,
        );
      } else {
        map[r.currency] = CurrencyStats(
          currency: r.currency,
          count: existing.count + 1,
          totalAmount: existing.totalAmount + r.amount,
          totalFees: existing.totalFees + r.fee,
        );
      }
    }
    return map;
  }

  Map<String, DestinationStats> _buildDestinationBreakdown(
    List<TransferReceipt> receipts,
  ) {
    final countMap = <String, int>{};
    final amountMap = <String, double>{};
    for (final r in receipts) {
      countMap[r.destination] = (countMap[r.destination] ?? 0) + 1;
      amountMap[r.destination] =
          (amountMap[r.destination] ?? 0) + r.amount;
    }
    final total = receipts.length;
    return Map.fromEntries(
      countMap.entries.map((e) {
        return MapEntry(
          e.key,
          DestinationStats(
            destination: e.key,
            count: e.value,
            totalAmount: amountMap[e.key] ?? 0,
            percentage: total > 0 ? (e.value / total) * 100 : 0,
          ),
        );
      }),
    );
  }

  List<DailyTotal> _buildDailyTotals(List<TransferReceipt> receipts) {
    final map = <DateTime, List<TransferReceipt>>{};
    for (final r in receipts) {
      final day = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
      map.putIfAbsent(day, () => []).add(r);
    }
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((e) {
      return DailyTotal(
        date: e.key,
        count: e.value.length,
        totalAmount: e.value.fold(0.0, (s, r) => s + r.amount),
        totalFees: e.value.fold(0.0, (s, r) => s + r.fee),
      );
    }).toList();
  }

  List<MonthlyTotal> _computeMonthlyTotals(List<TransferReceipt> receipts) {
    final map = <String, List<TransferReceipt>>{};
    for (final r in receipts) {
      final key = '${r.createdAt.year}-${r.createdAt.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(r);
    }
    final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((e) {
      final parts = e.key.split('-');
      return MonthlyTotal(
        year: int.parse(parts[0]),
        month: int.parse(parts[1]),
        count: e.value.length,
        totalAmount: e.value.fold(0.0, (s, r) => s + r.amount),
        totalFees: e.value.fold(0.0, (s, r) => s + r.fee),
      );
    }).toList();
  }

  List<DestinationStats> _computeDestinationStats(
    List<TransferReceipt> receipts,
  ) {
    final breakdown = _buildDestinationBreakdown(receipts);
    final sorted = breakdown.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return sorted.take(10).toList();
  }

  List<CurrencyStats> _computeCurrencyStats(List<TransferReceipt> receipts) {
    final breakdown = _buildCurrencyBreakdown(receipts);
    final sorted = breakdown.values.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    return sorted;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// حساب نسبة التغيير بين قيمتين
  double changePercentage(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  /// تصنيف الفترات الزمنية
  List<String> getAvailableMonths(List<TransferReceipt> receipts) {
    final monthSet = <String>{};
    for (final r in receipts) {
      monthSet.add('${r.createdAt.year}-${r.createdAt.month.toString().padLeft(2, '0')}');
    }
    final sorted = monthSet.toList()..sort();
    return sorted.reversed.toList();
  }

  /// الحصول على نطاق التواريخ
  (DateTime, DateTime)? getDateRange(List<TransferReceipt> receipts) {
    if (receipts.isEmpty) return null;
    final sorted = receipts.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return (sorted.first.createdAt, sorted.last.createdAt);
  }

  /// الحوالات بين تاريخين
  List<TransferReceipt> getReceiptsBetween(
    List<TransferReceipt> all,
    DateTime from,
    DateTime to,
  ) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day, 23, 59, 59);
    return all
        .where(
          (r) =>
              r.createdAt.isAfter(fromDate.subtract(const Duration(seconds: 1))) &&
              r.createdAt.isBefore(toDate.add(const Duration(seconds: 1))),
        )
        .toList();
  }
}
