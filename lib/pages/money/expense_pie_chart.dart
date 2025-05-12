import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class ExpensePieChart extends StatefulWidget {
  final Map<String, double> categoryAmounts; // Map of category name to total amount

  const ExpensePieChart({super.key, required this.categoryAmounts});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int _touchedSectionIndex = -1;

  // A simple color palette for categories
  final List<Color> _categoryColors = [
    UIColor().scarlet,
    UIColor().celeste,
    UIColor().springGreen,
    UIColor().lightCanary,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.indigo,
    Colors.pink,
  ];

  Color _getColorForCategory(String categoryName) {
    int index = categoryName.hashCode % _categoryColors.length;
    return _categoryColors[index];
  }

  Widget _buildIndicator(Color color, String text, double amount, bool isSquare) {
    const double size = 16;
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$text (\$${amount.toStringAsFixed(2)})',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Material(
      color: color,
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(color: UIColor().darkGray, fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalExpenses = widget.categoryAmounts.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    if (totalExpenses == 0) {
      return const SizedBox.shrink();
    }

    List<PieChartSectionData> sections = [];
    int currentIndex = 0;

    const double baseBadgeOffset = 1.0;
    const double touchedBadgeOffset = 1.1;

    widget.categoryAmounts.forEach((category, amount) {
      if (amount > 0) {
        final Color sectionColor = _getColorForCategory(category);
        sections.add(
          PieChartSectionData(
            color: sectionColor,
            value: amount,
            title: '${(amount / totalExpenses * 100).toStringAsFixed(0)}%',
            radius: _touchedSectionIndex == currentIndex ? 60 : 50,
            titleStyle: TextStyle(
              fontSize: _touchedSectionIndex == currentIndex ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: UIColor().darkGray,
              shadows:
                  _touchedSectionIndex == currentIndex
                      ? [Shadow(color: UIColor().darkGray, blurRadius: 2)]
                      : null,
            ),
            badgeWidget:
                _touchedSectionIndex == currentIndex
                    ? _buildBadge('$category: \$${amount.toStringAsFixed(2)}', sectionColor)
                    : null,
            badgePositionPercentageOffset:
                _touchedSectionIndex == currentIndex ? touchedBadgeOffset : baseBadgeOffset,
          ),
        );
        currentIndex++;
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedSectionIndex = -1;
                      return;
                    }
                    _touchedSectionIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                widget.categoryAmounts.entries.where((entry) => entry.value > 0).map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: _buildIndicator(
                      _getColorForCategory(entry.key),
                      entry.key,
                      entry.value,
                      true,
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
