import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TotalGraph extends StatelessWidget {
  final Map<int, double> arrayToDisplay;

  const TotalGraph({super.key, required this.arrayToDisplay});

  @override
  Widget build(BuildContext context) {
    if (arrayToDisplay.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Sort arrayToDisplay by date
    final sortedDailyTotals = arrayToDisplay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sortedDailyTotals.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    final maxY = (arrayToDisplay.values.isNotEmpty)
        ? (arrayToDisplay.values.reduce((a, b) => a > b ? a : b) / 1000)
                .ceil() *
            1000.0
        : 1000.0; // Default to 1000 if no values

    final interval = maxY / 5; // Five intervals for better visibility

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
            horizontalInterval: interval, // Using the calculated interval
            verticalInterval: 2, // Show all vertical lines
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5, // Change this to 5 for labeling as 5, 10, 15
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: interval, // Using calculated interval for Y axis
                getTitlesWidget: (value, meta) {
                  return Text(
                    value >= 1000
                        ? '${(value / 1000).toStringAsFixed(1)}k'
                        : value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
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
