import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stuff_app/widgets/ui_color.dart';

// This is a new Stateful widget for the interactive Pie Chart with Legend and Gram Amounts
class InteractiveNutritionPieChart extends StatefulWidget {
  final double proteinGrams;
  final double fatGrams;
  final double carbGrams;
  final double fiberGrams;

  const InteractiveNutritionPieChart({
    super.key,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbGrams,
    required this.fiberGrams,
  });

  @override
  State<InteractiveNutritionPieChart> createState() => _InteractiveNutritionPieChartState();
}

class _InteractiveNutritionPieChartState extends State<InteractiveNutritionPieChart> {
  int _touchedSectionIndex = -1;

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
          '$text (${amount.toStringAsFixed(1)}g)',
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
    final double totalGrams =
        widget.proteinGrams + widget.fatGrams + widget.carbGrams + widget.fiberGrams;

    if (totalGrams == 0) {
      return const SizedBox.shrink();
    }

    final proteinColor = UIColor().lightCanary;
    final fatColor = UIColor().scarlet;
    final carbColor = UIColor().celeste;
    final fiberColor = UIColor().springGreen;

    List<PieChartSectionData> sections = [];
    int currentIndex = 0;

    const double baseBadgeOffset = 1.0;
    const double touchedBadgeOffset = 1.1;

    if (widget.proteinGrams > 0) {
      sections.add(
        PieChartSectionData(
          color: proteinColor,
          value: widget.proteinGrams,
          title: '${(widget.proteinGrams / totalGrams * 100).toStringAsFixed(0)}%',
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
                  ? _buildBadge('Protein: ${widget.proteinGrams.toStringAsFixed(1)}g', proteinColor)
                  : null,
          badgePositionPercentageOffset:
              _touchedSectionIndex == currentIndex ? touchedBadgeOffset : baseBadgeOffset,
        ),
      );
      currentIndex++;
    }

    if (widget.fatGrams > 0) {
      sections.add(
        PieChartSectionData(
          color: fatColor,
          value: widget.fatGrams,
          title: '${(widget.fatGrams / totalGrams * 100).toStringAsFixed(0)}%',
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
                  ? _buildBadge('Fat: ${widget.fatGrams.toStringAsFixed(1)}g', fatColor)
                  : null,
          badgePositionPercentageOffset:
              _touchedSectionIndex == currentIndex ? touchedBadgeOffset : baseBadgeOffset,
        ),
      );
      currentIndex++;
    }

    if (widget.carbGrams > 0) {
      sections.add(
        PieChartSectionData(
          color: carbColor,
          value: widget.carbGrams,
          title: '${(widget.carbGrams / totalGrams * 100).toStringAsFixed(0)}%',
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
                  ? _buildBadge('Carbs: ${widget.carbGrams.toStringAsFixed(1)}g', carbColor)
                  : null,
          badgePositionPercentageOffset:
              _touchedSectionIndex == currentIndex ? touchedBadgeOffset : baseBadgeOffset,
        ),
      );
      currentIndex++;
    }

    if (widget.fiberGrams > 0) {
      sections.add(
        PieChartSectionData(
          color: fiberColor,
          value: widget.fiberGrams,
          title: '${(widget.fiberGrams / totalGrams * 100).toStringAsFixed(0)}%',
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
                  ? _buildBadge('Fiber: ${widget.fiberGrams.toStringAsFixed(1)}g', fiberColor)
                  : null,
          badgePositionPercentageOffset:
              _touchedSectionIndex == currentIndex ? touchedBadgeOffset : baseBadgeOffset,
        ),
      );
    }

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
            children: <Widget>[
              if (widget.proteinGrams > 0)
                _buildIndicator(proteinColor, 'Protein', widget.proteinGrams, true),
              if (widget.fatGrams > 0) const SizedBox(height: 4),
              if (widget.fatGrams > 0) _buildIndicator(fatColor, 'Fat', widget.fatGrams, true),
              if (widget.carbGrams > 0) const SizedBox(height: 4),
              if (widget.carbGrams > 0) _buildIndicator(carbColor, 'Carbs', widget.carbGrams, true),
              if (widget.fiberGrams > 0) const SizedBox(height: 4),
              if (widget.fiberGrams > 0)
                _buildIndicator(fiberColor, 'Fiber', widget.fiberGrams, true),
            ],
          ),
        ),
      ],
    );
  }
}
