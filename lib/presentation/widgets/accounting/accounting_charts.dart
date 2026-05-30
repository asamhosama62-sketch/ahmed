import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/arabic_formatters.dart';
import '../../../data/models/accounting/journal_entry.dart';

class RevenueBarChart extends StatelessWidget {
  final List<JournalEntry> entries;

  const RevenueBarChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final feeEntries = entries
        .where((e) => e.creditAccountId == 'acc_fees')
        .toList();

    if (feeEntries.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات إيرادات',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }

    final grouped = <String, double>{};
    for (final e in feeEntries) {
      final key = DateFormat('MM/yyyy', 'ar').format(e.date);
      grouped.update(key, (v) => v + e.amount, ifAbsent: () => e.amount);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final partsA = a.split('/');
        final partsB = b.split('/');
        final dateA = DateTime(int.parse(partsA[1]), int.parse(partsA[0]));
        final dateB = DateTime(int.parse(partsB[1]), int.parse(partsB[0]));
        return dateA.compareTo(dateB);
      });

    final maxY = grouped.values.reduce((a, b) => a > b ? a : b);

    final barData = sortedKeys.asMap().entries.map((entry) {
      final amount = grouped[entry.value] ?? 0.0;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: scheme.primary,
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final month = sortedKeys[group.x];
              return BarTooltipItem(
                '$month\n${ArabicFormatters.formatAmount(rod.toY)}',
                TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedKeys.length) {
                  return const SizedBox.shrink();
                }
                final label = sortedKeys[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  ArabicFormatters.compactNumber(value),
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barData,
      ),
    );
  }
}

class AccountingPieChart extends StatelessWidget {
  final Map<String, double> data;

  const AccountingPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = [
      scheme.primary,
      scheme.tertiary,
      scheme.secondary,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];

    if (data.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }

    final total = data.values.fold(0.0, (a, b) => a + b);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: data.entries.toList().asMap().entries.map((e) {
                  final percentage =
                      total > 0 ? (e.value.value / total) * 100 : 0;
                  return PieChartSectionData(
                    value: e.value.value,
                    title: '${percentage.toStringAsFixed(1)}%',
                    color: colors[e.key % colors.length],
                    radius: 50,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries.toList().asMap().entries.map((e) {
            final percentage =
                total > 0 ? (e.value.value / total) * 100 : 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[e.key % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${e.value.key}: ${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
