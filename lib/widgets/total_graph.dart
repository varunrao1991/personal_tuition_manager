import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:padmayoga/models/daily_total.dart';

class TotalGraph extends StatelessWidget {
  final List<DailyTotal> dailyTotals;

  const TotalGraph({super.key, required this.dailyTotals});

  @override
  Widget build(BuildContext context) {
    if (dailyTotals.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Sort daily totals by date
    final sortedDailyTotals = List<DailyTotal>.from(dailyTotals)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final spots = sortedDailyTotals.map((entry) {
      return FlSpot(entry.dateTime.day.toDouble(), entry.totalAmount);
    }).toList();

    // Determine the maxY dynamically based on the highest total
    final maxY =
        (dailyTotals.map((e) => e.totalAmount).reduce((a, b) => a > b ? a : b) /
                    1000)
                .ceil() *
            1000.0;

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 2,
              color: Colors.blue,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: maxY / 6,
            verticalInterval: 6,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 6,
                getTitlesWidget: (value, meta) {
                  if (value % 12 == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        value.toInt().toString(),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.blue),
                      ),
                    );
                  } else if (value % 6 == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 6,
                getTitlesWidget: (value, meta) {
                  if (value >= 1000) {
                    return Text(
                      '${(value / 1000).toStringAsFixed(1)}k',
                      style: const TextStyle(fontSize: 10),
                    );
                  } else {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
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
            border: Border.all(color: Colors.grey, width: 1),
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
