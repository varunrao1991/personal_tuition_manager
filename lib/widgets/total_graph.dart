import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TotalGraph extends StatelessWidget {
  final Map<int, double> arrayToDisplay;

  const TotalGraph({super.key, required this.arrayToDisplay});

  @override
  Widget build(BuildContext context) {

    final sortedDailyTotals = arrayToDisplay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sortedDailyTotals.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    final maxY = (arrayToDisplay.values.isNotEmpty)
        ? (arrayToDisplay.values.reduce((a, b) => a > b ? a : b) / 1000)
                .ceil() *
            1000.0
        : 1000.0;

    final interval = maxY / 5;

    // Access themed colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: colorScheme.primary,
              barWidth: 2,
              belowBarData: BarAreaData(
                show: true,
                color: colorScheme.secondary.withOpacity(0.3),
              ),
            ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: interval,
            verticalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.onSurface.withOpacity(0.2),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: colorScheme.onSurface.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 4,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      value.toInt().toString(),
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value >= 1000
                        ? '${(value / 1000).toStringAsFixed(1)}k'
                        : value.toInt().toString(),
                    style: theme.textTheme.bodySmall,
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
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: colorScheme.onSurface.withOpacity(0.5),
              width: 1,
            ),
          ),
          minX: 1,
          maxX: 31,
          minY: 0,
          maxY: maxY,
        ),
      ),
    );
  }
}
