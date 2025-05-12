import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class BalanceLineChart extends StatelessWidget {
  final List<FlSpot> dailyBalance; // For plotting daily net balance
  final DateTime startDate;
  final DateTime endDate;
  final String mode; // 'Day', 'Month', 'Year'

  const BalanceLineChart({
    super.key,
    required this.dailyBalance,
    required this.startDate,
    required this.endDate,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    // Determine min/max Y values for the chart
    double minY = 0;
    double maxY = 0;

    if (dailyBalance.isNotEmpty) {
      minY = dailyBalance.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
      maxY = dailyBalance.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    }

    // Add some padding to the Y axis
    minY -=
        (minY * 0.1).abs(); // Add 10% below min (if min is negative, this will decrease it further)
    if (minY > 0) minY = 0; // Ensure Y-axis starts at 0 or below if balances are negative

    maxY += (maxY * 0.1).abs(); // Add 10% above max
    if (maxY < 0) maxY = 0; // Ensure Y-axis ends at 0 or above if balances are negative

    // Ensure a minimum range if all values are near zero
    if ((maxY - minY).abs() < 100) {
      maxY = 100;
      minY = -100;
    }

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
                  horizontalInterval: _calculateYInterval(minY, maxY),
                  verticalInterval: _calculateXInterval(),
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
                      interval: _calculateXInterval(),
                      getTitlesWidget: (value, _) {
                        final interval = _calculateXInterval();
                        if (value.toInt() % interval == 0) {
                          if (mode == 'Year') {
                            // For year mode, value represents day of the year (0-364)
                            final date = startDate.add(Duration(days: value.toInt()));
                            return Text(
                              DateFormat('MMM').format(date), // Show month names
                              style: const TextStyle(fontSize: 8),
                            );
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
                    axisNameWidget: const Text('Balance (\$)', style: TextStyle(fontSize: 12)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _calculateYInterval(minY, maxY),
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
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: dailyBalance,
                    isCurved: false,
                    color: UIColor().celeste, // Or a neutral color
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Line for 0 balance
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 0),
                      FlSpot(endDate.difference(startDate).inDays.toDouble(), 0),
                    ],
                    isCurved: false,
                    color: Colors.grey,
                    barWidth: 1,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                    dashArray: const [2, 2],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateXInterval() {
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

  double _calculateYInterval(double minY, double maxY) {
    double range = maxY - minY;
    if (range <= 500) {
      return 50;
    } else if (range <= 1000) {
      return 100;
    } else if (range <= 5000) {
      return 500;
    } else if (range <= 10000) {
      return 1000;
    } else {
      return 5000;
    }
  }
}
