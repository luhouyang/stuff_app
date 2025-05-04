import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class CalorieLineChart extends StatelessWidget {
  final List<FlSpot> dailyCalories;
  final List<FlSpot> averageCalories;
  final double dailyAverageLine;
  final double targetCalories;
  final DateTime startDate;
  final DateTime endDate;
  final String mode;

  const CalorieLineChart({
    super.key,
    required this.dailyCalories,
    required this.averageCalories,
    required this.dailyAverageLine, // Receive the new data
    required this.targetCalories,
    required this.startDate,
    required this.endDate,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.7,
          child: Padding(
            padding: const EdgeInsets.only(right: 8, left: 8, top: 24, bottom: 12),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 500,
                  verticalInterval: mode == 'Month' ? 2 : 15,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color:
                          AdaptiveTheme.of(context).isDefault
                              ? UIColor().gray.withValues(alpha: 32)
                              : UIColor().mediumGray,
                      strokeWidth: 0.5,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color:
                          AdaptiveTheme.of(context).isDefault
                              ? UIColor().gray.withValues(alpha: 32)
                              : UIColor().mediumGray,
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    axisNameSize: 16,
                    axisNameWidget: const Text('Date', style: TextStyle(fontSize: 12)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _calculateInterval(),
                      getTitlesWidget: (value, _) {
                        final interval = _calculateInterval();
                        if (value.toInt() % interval == 0) {
                          if (mode == 'Year') {
                            return Text('${value.toInt()}', style: const TextStyle(fontSize: 8));
                          } else {
                            final date = startDate.add(Duration(days: value.toInt()));
                            return Text(
                              DateFormat('d MMM').format(date),
                              style: const TextStyle(fontSize: 8),
                            );
                          }
                        }
                        return const Text('', style: TextStyle(fontSize: 8));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameSize: 16,
                    axisNameWidget: const Text('Calories', style: TextStyle(fontSize: 12)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500,
                      getTitlesWidget: (value, _) {
                        return Text(value.toInt().toString(), style: const TextStyle(fontSize: 8));
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    drawBelowEverything: false,
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    drawBelowEverything: false,
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                minX: 0,
                maxX: endDate.difference(startDate).inDays.toDouble(),
                minY: 0,
                maxY: (_calculateMaxY() - _calculateMaxY() % 500) + 500,
                lineBarsData: [
                  LineChartBarData(
                    spots: dailyCalories,
                    isCurved: false,
                    color: UIColor().springGreen,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                    dashArray: const [2, 2],
                  ),
                  // LineChartBarData(
                  //   spots: averageCalories,
                  //   isCurved: false,
                  //   color: UIColor().darkGray,
                  //   barWidth: 2,
                  //   isStrokeCapRound: true,
                  //   dotData: const FlDotData(show: false),
                  //   belowBarData: BarAreaData(show: false),
                  // ),
                  LineChartBarData(
                    spots: [
                      FlSpot(0, dailyAverageLine),
                      FlSpot(endDate.difference(startDate).inDays.toDouble(), dailyAverageLine),
                    ],
                    isCurved: false,
                    color: UIColor().lightCanary,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: [
                      FlSpot(0, targetCalories),
                      FlSpot(endDate.difference(startDate).inDays.toDouble(), targetCalories),
                    ],
                    isCurved: false,
                    color: UIColor().scarlet,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Target: ${targetCalories.toInt()} kcal', style: const TextStyle(fontSize: 12)),
              Text(
                'Daily Average: ${dailyAverageLine.toStringAsFixed(1)} kcal',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateMaxY() {
    double maxY = targetCalories;
    for (final spot in dailyCalories) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }
    for (final spot in averageCalories) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }
    return maxY + (maxY * 0.1); // Add 10% of maxY as padding
  }

  double _calculateInterval() {
    final days = endDate.difference(startDate).inDays;
    if (days <= 7) {
      return 1; // Show every day
    } else if (days <= 30) {
      return 3; // Show every 3 days
    } else if (days <= 90) {
      return 7; // Show weekly
    } else if (days <= 365) {
      return 30; // Show monthly (approximately)
    } else {
      return 90; // Show quarterly (approximately)
    }
  }
}
