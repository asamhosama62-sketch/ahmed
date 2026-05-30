// =============================================================================
// شاشة الإحصائيات الرئيسية - تطبيق العكابي للحوالات المالية
// =============================================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/utils/arabic_formatters.dart';
import '../../services/statistics_service.dart';
import '../providers/statistics_providers.dart';
import '../widgets/common/shared_widgets.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 130,
              floating: false,
              pinned: true,
              backgroundColor: scheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 16,
                  bottom: 56,
                ),
                title: Text(
                  'الإحصائيات والتقارير',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        scheme.primary.withValues(alpha: 0.08),
                        scheme.surface,
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                indicatorColor: scheme.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard_rounded), text: 'الملخص'),
                  Tab(icon: Icon(Icons.calendar_today_rounded), text: 'شهري'),
                  Tab(icon: Icon(Icons.bar_chart_rounded), text: 'التفاصيل'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: const [_SummaryTab(), _MonthlyTab(), _DetailsTab()],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// تاب الملخص العام
// =============================================================================
class _SummaryTab extends ConsumerWidget {
  const _SummaryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(overallStatsProvider);

    return statsAsync.when(
      loading: () => const LoadingWidget(message: 'جارٍ تحميل الإحصائيات...'),
      error: (e, _) => EmptyStateWidget(
        icon: Icons.error_outline,
        message: 'حدث خطأ في التحميل',
        subtitle: e.toString(),
      ),
      data: (stats) => _SummaryContent(stats: stats),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.stats});

  final OverallStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ─── البطاقات الرئيسية الأربع ────────────────────────────────
          const SectionHeader(
            title: 'نظرة عامة',
            icon: Icons.insights_rounded,
            subtitle: 'إجمالي النشاط منذ البداية',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                StatCard(
                  title: 'إجمالي الحوالات',
                  value: ArabicFormatters.toArabicDigits(
                    stats.totalTransfers.toString(),
                  ),
                  icon: Icons.receipt_long_rounded,
                  iconColor: scheme.primary,
                  subtitle:
                      '${ArabicFormatters.toArabicDigits(stats.activeTransfers.toString())} نشطة',
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary.withValues(alpha: 0.12),
                      scheme.primaryContainer.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                StatCard(
                  title: 'إجمالي المبالغ',
                  value: _formatCompact(stats.totalAmount),
                  icon: Icons.payments_rounded,
                  iconColor: Colors.green.shade700,
                  subtitle: 'الرسوم: ${_formatCompact(stats.totalFees)}',
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.08),
                      Colors.green.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                StatCard(
                  title: 'حوالات اليوم',
                  value: ArabicFormatters.toArabicDigits(
                    stats.todayStats.transferCount.toString(),
                  ),
                  icon: Icons.today_rounded,
                  iconColor: Colors.orange.shade700,
                  subtitle: _formatCompact(stats.todayStats.totalRevenue),
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withValues(alpha: 0.08),
                      Colors.orange.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                StatCard(
                  title: 'حوالات الشهر',
                  value: ArabicFormatters.toArabicDigits(
                    stats.thisMonthStats.transferCount.toString(),
                  ),
                  icon: Icons.date_range_rounded,
                  iconColor: Colors.purple.shade700,
                  subtitle: _formatCompact(stats.thisMonthStats.totalRevenue),
                  trend: stats.monthlyGrowthRate >= 0
                      ? '+${ArabicFormatters.toArabicDigits(stats.monthlyGrowthRate.toStringAsFixed(1))}%'
                      : '${ArabicFormatters.toArabicDigits(stats.monthlyGrowthRate.toStringAsFixed(1))}%',
                  trendPositive: stats.monthlyGrowthRate >= 0,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withValues(alpha: 0.08),
                      Colors.purple.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ],
            ),
          ),

          // ─── مخطط الأشهر الـ 12 ──────────────────────────────────────
          if (stats.monthlyTotals.isNotEmpty) ...[
            const SectionHeader(
              title: 'الحوالات الشهرية',
              icon: Icons.bar_chart_rounded,
              subtitle: 'توزيع الحوالات على مدار الأشهر',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GradientCard(
                color: scheme.surfaceContainerLow,
                border: true,
                shadow: true,
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'عدد الحوالات',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: _MonthlyBarChart(
                        monthlyTotals: stats.monthlyTotals,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ─── إحصائيات الأسبوع والشهر ─────────────────────────────────
          const SectionHeader(
            title: 'الفترات الزمنية',
            icon: Icons.timeline_rounded,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _PeriodRow(
                  label: 'اليوم',
                  icon: Icons.wb_sunny_rounded,
                  color: Colors.amber,
                  count: stats.todayStats.transferCount,
                  amount: stats.todayStats.totalRevenue,
                ),
                const SizedBox(height: 8),
                _PeriodRow(
                  label: 'هذا الأسبوع',
                  icon: Icons.view_week_rounded,
                  color: Colors.teal,
                  count: stats.thisWeekStats.transferCount,
                  amount: stats.thisWeekStats.totalRevenue,
                ),
                const SizedBox(height: 8),
                _PeriodRow(
                  label: 'هذا الشهر',
                  icon: Icons.calendar_month_rounded,
                  color: Colors.indigo,
                  count: stats.thisMonthStats.transferCount,
                  amount: stats.thisMonthStats.totalRevenue,
                ),
                const SizedBox(height: 8),
                _PeriodRow(
                  label: 'الشهر الماضي',
                  icon: Icons.history_rounded,
                  color: Colors.blueGrey,
                  count: stats.lastMonthStats.transferCount,
                  amount: stats.lastMonthStats.totalRevenue,
                ),
                const SizedBox(height: 8),
                _PeriodRow(
                  label: 'هذه السنة',
                  icon: Icons.calendar_today_rounded,
                  color: Colors.deepPurple,
                  count: stats.thisYearStats.transferCount,
                  amount: stats.thisYearStats.totalRevenue,
                ),
              ],
            ),
          ),

          // ─── أعلى الوجهات ─────────────────────────────────────────────
          if (stats.topDestinations.isNotEmpty) ...[
            const SectionHeader(
              title: 'أعلى الوجهات',
              icon: Icons.place_rounded,
              subtitle: 'الوجهات الأكثر طلباً',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GradientCard(
                color: scheme.surfaceContainerLow,
                border: true,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: stats.topDestinations.take(6).map((dest) {
                    final maxCount = stats.topDestinations.first.count;
                    final progress = maxCount > 0 ? dest.count / maxCount : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DestinationBar(
                        destination: dest,
                        progress: progress,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],

          // ─── بطاقات ذروة النشاط ───────────────────────────────────────
          if (stats.peakDayDate != null) ...[
            const SectionHeader(
              title: 'أرقام قياسية',
              icon: Icons.emoji_events_rounded,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'ذروة النشاط اليومي',
                      value: ArabicFormatters.toArabicDigits(
                        stats.peakDayCount.toString(),
                      ),
                      icon: Icons.trending_up_rounded,
                      iconColor: Colors.orange,
                      subtitle: ArabicFormatters.formatDate(stats.peakDayDate!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'متوسط الحوالات اليومي',
                      value: ArabicFormatters.toArabicDigits(
                        stats.averageDailyTransfers.toStringAsFixed(1),
                      ),
                      icon: Icons.equalizer_rounded,
                      iconColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return ArabicFormatters.toArabicDigits(
        '${(value / 1000000).toStringAsFixed(1)}م',
      );
    }
    if (value >= 1000) {
      return ArabicFormatters.toArabicDigits(
        '${(value / 1000).toStringAsFixed(1)}ك',
      );
    }
    return ArabicFormatters.toArabicDigits(value.toStringAsFixed(0));
  }
}

// =============================================================================
// مخطط الأعمدة الشهرية
// =============================================================================
class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart({required this.monthlyTotals});

  final List<MonthlyTotal> monthlyTotals;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final recent = monthlyTotals.length > 12
        ? monthlyTotals.sublist(monthlyTotals.length - 12)
        : monthlyTotals;

    final maxCount = recent.isEmpty
        ? 1
        : recent.map((m) => m.count).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxCount * 1.3).toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final m = recent[groupIndex];
              return BarTooltipItem(
                '${m.count} حوالة\n${ArabicFormatters.toArabicDigits(m.totalRevenue.toStringAsFixed(0))}',
                TextStyle(
                  color: scheme.onInverseSurface,
                  fontSize: 10,
                  fontFamily: 'Cairo',
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  ArabicFormatters.toArabicDigits(value.toInt().toString()),
                  style: TextStyle(
                    fontSize: 9,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontFamily: 'Cairo',
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= recent.length) {
                  return const SizedBox.shrink();
                }
                final m = recent[index];
                const monthsShort = [
                  '',
                  'يناير',
                  'فبر',
                  'مارس',
                  'أبريل',
                  'مايو',
                  'يونيو',
                  'يوليو',
                  'أغسطس',
                  'سبتمبر',
                  'أكتوبر',
                  'نوف',
                  'ديس',
                ];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    monthsShort[m.month],
                    style: TextStyle(
                      fontSize: 8,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                      fontFamily: 'Cairo',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 0.8,
          ),
        ),
        barGroups: recent.asMap().entries.map((e) {
          final index = e.key;
          final m = e.value;
          final isLatest = index == recent.length - 1;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: m.count.toDouble(),
                color: isLatest
                    ? scheme.primary
                    : scheme.primary.withValues(alpha: 0.5),
                width: 14,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// =============================================================================
// صف الفترة الزمنية
// =============================================================================
class _PeriodRow extends StatelessWidget {
  const _PeriodRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.count,
    required this.amount,
  });

  final String label;
  final IconData icon;
  final Color color;
  final int count;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GradientCard(
      color: scheme.surfaceContainerLow,
      border: true,
      shadow: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${ArabicFormatters.toArabicDigits(count.toString())} حوالة',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                ArabicFormatters.formatAmount(amount),
                style: textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// شريط الوجهة
// =============================================================================
class _DestinationBar extends StatelessWidget {
  const _DestinationBar({required this.destination, required this.progress});

  final DestinationStats destination;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                destination.destination,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Text(
              '${ArabicFormatters.toArabicDigits(destination.count.toString())} (${ArabicFormatters.toArabicDigits(destination.percentage.toStringAsFixed(0))}%)',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              scheme.primary.withValues(alpha: 0.7),
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// تاب الإحصائيات الشهرية التفصيلية
// =============================================================================
class _MonthlyTab extends ConsumerStatefulWidget {
  const _MonthlyTab();

  @override
  ConsumerState<_MonthlyTab> createState() => _MonthlyTabState();
}

class _MonthlyTabState extends ConsumerState<_MonthlyTab> {
  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedMonthProvider);
    final monthStatsAsync = ref.watch(monthStatsProvider);
    final dailyTotalsAsync = ref.watch(monthDailyTotalsProvider);
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // ─── منتقي الشهر ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              // زر الشهر السابق
              IconButton.outlined(
                onPressed: () {
                  final prev = selected.month == 1
                      ? (year: selected.year - 1, month: 12)
                      : (year: selected.year, month: selected.month - 1);
                  ref.read(selectedMonthProvider.notifier).state = prev;
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _monthLabel(selected.year, selected.month),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              // زر الشهر التالي
              IconButton.outlined(
                onPressed: () {
                  final now = DateTime.now();
                  if (selected.year < now.year ||
                      (selected.year == now.year &&
                          selected.month < now.month)) {
                    final next = selected.month == 12
                        ? (year: selected.year + 1, month: 1)
                        : (year: selected.year, month: selected.month + 1);
                    ref.read(selectedMonthProvider.notifier).state = next;
                  }
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ],
          ),
        ),

        // ─── بطاقات ملخص الشهر ────────────────────────────────────────
        monthStatsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(40),
            child: LoadingWidget(),
          ),
          error: (e, _) => EmptyStateWidget(
            message: 'خطأ في تحميل البيانات',
            subtitle: e.toString(),
          ),
          data: (stats) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                if (stats.isEmpty)
                  const EmptyStateWidget(
                    message: 'لا توجد حوالات في هذا الشهر',
                    icon: Icons.event_busy_rounded,
                  )
                else ...[
                  // بطاقة المجموع الرئيسية
                  GradientCard(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary,
                        scheme.primary.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إجمالي الشهر',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ArabicFormatters.formatAmount(
                                  stats.totalRevenue,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'مبلغ: ${ArabicFormatters.formatAmount(stats.totalAmount)}  رسوم: ${ArabicFormatters.formatAmount(stats.totalFees)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              ArabicFormatters.toArabicDigits(
                                stats.transferCount.toString(),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'حوالة',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // بطاقات صغيرة
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'المتوسط اليومي',
                          value: ArabicFormatters.formatAmount(
                            stats.transferCount > 0
                                ? stats.totalRevenue / 30
                                : 0,
                          ),
                          icon: Icons.equalizer_rounded,
                          iconColor: Colors.teal,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          title: 'متوسط الحوالة',
                          value: ArabicFormatters.formatAmount(
                            stats.averageAmount,
                          ),
                          icon: Icons.calculate_rounded,
                          iconColor: Colors.blue,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'أعلى حوالة',
                          value: ArabicFormatters.formatAmount(stats.maxAmount),
                          icon: Icons.arrow_upward_rounded,
                          iconColor: Colors.green,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          title: 'أدنى حوالة',
                          value: ArabicFormatters.formatAmount(stats.minAmount),
                          icon: Icons.arrow_downward_rounded,
                          iconColor: Colors.red,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // ─── مخطط الأيام اليومي ───────────────────────────────────────
        const SectionHeader(
          title: 'التوزيع اليومي',
          icon: Icons.show_chart_rounded,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: dailyTotalsAsync.when(
            loading: () => const LoadingWidget(),
            error: (e, _) => const SizedBox.shrink(),
            data: (dailyTotals) => GradientCard(
              color: scheme.surfaceContainerLow,
              border: true,
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
              child: SizedBox(
                height: 180,
                child: _DailyLineChart(dailyTotals: dailyTotals),
              ),
            ),
          ),
        ),

        // ─── قائمة الأيام ─────────────────────────────────────────────
        monthStatsAsync.maybeWhen(
          data: (stats) {
            if (stats.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'التفاصيل اليومية',
                  icon: Icons.list_alt_rounded,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GradientCard(
                    color: scheme.surfaceContainerLow,
                    border: true,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: stats.dailyTotals
                          .where((d) => d.count > 0)
                          .map((day) => _DayRow(daily: day))
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _monthLabel(int year, int month) {
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
    return '${months[month]} ${ArabicFormatters.toArabicDigits(year.toString())}';
  }
}

// مخطط خطي يومي
class _DailyLineChart extends StatelessWidget {
  const _DailyLineChart({required this.dailyTotals});

  final List<DailyTotal> dailyTotals;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nonZero = dailyTotals.where((d) => d.count > 0).toList();
    if (nonZero.isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    final maxRevenue = dailyTotals
        .map((d) => d.totalRevenue)
        .reduce((a, b) => a > b ? a : b);

    final spots = dailyTotals.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.totalRevenue);
    }).toList();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItems: (spots) => spots.map((spot) {
              final day = dailyTotals[spot.x.toInt()];
              return LineTooltipItem(
                'يوم ${ArabicFormatters.toArabicDigits(day.date.day.toString())}\n${day.count} حوالة\n${ArabicFormatters.formatAmount(day.totalRevenue)}',
                TextStyle(
                  color: scheme.onInverseSurface,
                  fontSize: 10,
                  fontFamily: 'Cairo',
                ),
              );
            }).toList(),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 0.8,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 5,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= dailyTotals.length) {
                  return const SizedBox.shrink();
                }
                final day = dailyTotals[index];
                return Text(
                  ArabicFormatters.toArabicDigits(day.date.day.toString()),
                  style: TextStyle(
                    fontSize: 9,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontFamily: 'Cairo',
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxRevenue * 1.3,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: scheme.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: spot.y > 0 ? 4 : 0,
                  color: scheme.primary,
                  strokeWidth: 2,
                  strokeColor: scheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.2),
                  scheme.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// صف اليوم في القائمة
class _DayRow extends StatelessWidget {
  const _DayRow({required this.daily});

  final DailyTotal daily;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isToday = _isSameDay(daily.date, DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isToday ? scheme.primaryContainer.withValues(alpha: 0.2) : null,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isToday ? scheme.primary : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              ArabicFormatters.toArabicDigits(daily.date.day.toString()),
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: isToday ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              DateFormat('EEEE', 'ar').format(daily.date),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${ArabicFormatters.toArabicDigits(daily.count.toString())} حوالة',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ArabicFormatters.formatAmount(daily.totalRevenue),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// =============================================================================
// تاب التفاصيل والمقارنات
// =============================================================================
class _DetailsTab extends ConsumerWidget {
  const _DetailsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(overallStatsProvider);
    final scheme = Theme.of(context).colorScheme;

    return statsAsync.when(
      loading: () => const LoadingWidget(message: 'جارٍ التحميل...'),
      error: (e, _) =>
          EmptyStateWidget(message: 'خطأ في التحميل', subtitle: e.toString()),
      data: (stats) => ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ─── مخطط دائري للعملات ────────────────────────────────────
          if (stats.topCurrencies.isNotEmpty) ...[
            const SectionHeader(
              title: 'توزيع العملات',
              icon: Icons.currency_exchange_rounded,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GradientCard(
                color: scheme.surfaceContainerLow,
                border: true,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: _CurrencyPieChart(currencies: stats.topCurrencies),
                    ),
                    const SizedBox(height: 12),
                    ...stats.topCurrencies.take(5).map((c) {
                      final total = stats.topCurrencies.fold(
                        0.0,
                        (s, cur) => s + cur.totalRevenue,
                      );
                      final pct = total > 0
                          ? (c.totalRevenue / total * 100)
                          : 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.currency,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '${ArabicFormatters.toArabicDigits(c.count.toString())} حوالة',
                              style: TextStyle(
                                color: scheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${ArabicFormatters.toArabicDigits(pct.toStringAsFixed(1))}%',
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],

          // ─── جدول المقارنة الشهرية ──────────────────────────────────
          if (stats.monthlyTotals.length >= 2) ...[
            const SectionHeader(
              title: 'مقارنة الأشهر',
              icon: Icons.compare_arrows_rounded,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GradientCard(
                color: scheme.surfaceContainerLow,
                border: true,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // رأس الجدول
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'الشهر',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'الحوالات',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'الإجمالي',
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...stats.monthlyTotals.reversed.take(12).map((m) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: scheme.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                m.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                ArabicFormatters.toArabicDigits(
                                  m.count.toString(),
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                ArabicFormatters.formatAmount(m.totalRevenue),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// مخطط دائري للعملات
class _CurrencyPieChart extends StatefulWidget {
  const _CurrencyPieChart({required this.currencies});

  final List<CurrencyStats> currencies;

  @override
  State<_CurrencyPieChart> createState() => _CurrencyPieChartState();
}

class _CurrencyPieChartState extends State<_CurrencyPieChart> {
  int _touchedIndex = -1;

  static const _colors = [
    Color(0xFF1A4B8B),
    Color(0xFF2E86AB),
    Color(0xFF48A999),
    Color(0xFFF6AE2D),
    Color(0xFFF26419),
    Color(0xFF7B2D8B),
  ];

  @override
  Widget build(BuildContext context) {
    final total = widget.currencies.fold(0.0, (s, c) => s + c.totalRevenue);

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = response.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sections: widget.currencies.asMap().entries.take(6).map((e) {
          final index = e.key;
          final c = e.value;
          final isTouched = index == _touchedIndex;
          final pct = total > 0 ? (c.totalRevenue / total * 100) : 0;
          final color = _colors[index % _colors.length];

          return PieChartSectionData(
            color: color,
            value: c.totalRevenue,
            title: isTouched
                ? '${c.currency}\n${pct.toStringAsFixed(1)}%'
                : '${pct.toStringAsFixed(0)}%',
            radius: isTouched ? 75 : 60,
            titleStyle: TextStyle(
              color: Colors.white,
              fontSize: isTouched ? 12 : 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          );
        }).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
}
