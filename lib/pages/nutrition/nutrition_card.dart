// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:stuff_app/entities/nutrition/nutrition_entity.dart';
// import 'package:stuff_app/widgets/ui_color.dart';

// class NutritionCard extends StatelessWidget {
//   final Map<String, dynamic> component;
//   final Function(String, double)? onNutrientChanged;

//   const NutritionCard({super.key, required this.component, this.onNutrientChanged});

//   Widget _buildSliderRow({
//     required String label,
//     required String nutrientKey,
//     required double value,
//     required String unit,
//     required double max,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Expanded(flex: 2, child: Text(label)),
//           Expanded(
//             flex: 3,
//             child: Slider(
//               thumbColor: UIColor().darkGray,
//               activeColor: UIColor().springGreen,
//               inactiveColor: UIColor().gray,
//               value: value,
//               min: 0,
//               max: max,
//               label: '${value.toStringAsFixed(1)} $unit',
//               onChanged: (newValue) {
//                 onNutrientChanged?.call(nutrientKey, newValue);
//               },
//             ),
//           ),
//           Expanded(flex: 1, child: Text('${value.toStringAsFixed(1)} $unit')),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final name = component[NutritionEnum.name.key] as String?;
//     final calories = component[NutritionEnum.calories.key] as Map<String, dynamic>?;
//     final protein = component[NutritionEnum.protein.key] as Map<String, dynamic>?;
//     final fat = component[NutritionEnum.fat.key] as Map<String, dynamic>?;
//     final carbohydrates = component[NutritionEnum.carbohydrates.key] as Map<String, dynamic>?;
//     final fiber = component[NutritionEnum.fiber.key] as Map<String, dynamic>?;

//     return Card(
//       // color: UIColor().mediumGray,
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               name ?? 'Component',
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
//             ),
//             if (calories != null)
//               _buildSliderRow(
//                 label: 'Calories',
//                 nutrientKey: NutritionEnum.calories.key,
//                 value: calories[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0,
//                 unit: calories[NutritionEnum.unit.key] as String? ?? '',
//                 max: max(calories[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0, 1000),
//               ),
//             if (protein != null)
//               _buildSliderRow(
//                 label: 'Protein',
//                 nutrientKey: NutritionEnum.protein.key,
//                 value: protein[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0,
//                 unit: protein[NutritionEnum.unit.key] as String? ?? '',
//                 max: max(protein[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0, 100),
//               ),
//             if (fat != null)
//               _buildSliderRow(
//                 label: 'Fat',
//                 nutrientKey: NutritionEnum.fat.key,
//                 value: fat[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0,
//                 unit: fat[NutritionEnum.unit.key] as String? ?? '',
//                 max: max(fat[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0, 100),
//               ),
//             if (carbohydrates != null)
//               _buildSliderRow(
//                 label: 'Carbohydrates',
//                 nutrientKey: NutritionEnum.carbohydrates.key,
//                 value: carbohydrates[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0,
//                 unit: carbohydrates[NutritionEnum.unit.key] as String? ?? '',
//                 max: max(carbohydrates[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0, 100),
//               ),
//             if (fiber != null)
//               _buildSliderRow(
//                 label: 'Fiber',
//                 nutrientKey: NutritionEnum.fiber.key,
//                 value: fiber[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0,
//                 unit: fiber[NutritionEnum.unit.key] as String? ?? '',
//                 max: max(fiber[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0, 100),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// nutrition_card.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stuff_app/entities/nutrition/nutrition_entity.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class NutritionCard extends StatefulWidget {
  final Map<String, dynamic> component;
  final Function(String, double)? onNutrientChanged;
  final Function(String)? onNameChanged;
  final Function(String)? onDelete;

  const NutritionCard({
    super.key,
    required this.component,
    this.onNutrientChanged,
    this.onNameChanged,
    this.onDelete,
  });

  @override
  State<NutritionCard> createState() => _NutritionCardState();
}

class _NutritionCardState extends State<NutritionCard> {
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.component[NutritionEnum.name.key] as String? ?? '',
    );
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
    if (!_isEditing) {
      widget.onNameChanged?.call(_nameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.component[NutritionEnum.name.key] as String?;
    final calories = widget.component[NutritionEnum.calories.key] as Map<String, dynamic>?;
    final protein = widget.component[NutritionEnum.protein.key] as Map<String, dynamic>?;
    final fat = widget.component[NutritionEnum.fat.key] as Map<String, dynamic>?;
    final carbohydrates =
        widget.component[NutritionEnum.carbohydrates.key] as Map<String, dynamic>?;
    final fiber = widget.component[NutritionEnum.fiber.key] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleEdit,
                    child:
                        _isEditing
                            ? TextField(
                              controller: _nameController,
                              onSubmitted: (value) => _toggleEdit(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            )
                            : Text(
                              name ?? 'Component',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete, color: UIColor().scarlet),
                    // onPressed: () => widget.onDelete?.call(name ?? ''),
                    onPressed: () async {
                      final bool confirmDelete =
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: UIColor().whiteSmoke,
                                title: Text(
                                  'Confirm Deletion',
                                  style: TextStyle(color: UIColor().darkGray),
                                ),
                                content: Text(
                                  'Are you sure you want to delete this ingredient? This action cannot be undone.',
                                  style: TextStyle(color: UIColor().darkGray),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false); // Return false if cancelled
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true); // Return true if confirmed
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: UIColor().scarlet, // Make delete text red
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          ) ??
                          false; // Use ?? false to handle case where dialog is dismissed

                      // Check if the user confirmed the deletion
                      if (confirmDelete) {
                        widget.onDelete?.call(name ?? '');
                      }
                    },
                  ),
              ],
            ),
            if (calories != null)
              _buildSliderRow(
                label: 'Calories',
                nutrientKey: NutritionEnum.calories.key,
                value: calories[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0,
                unit: calories[NutritionEnum.unit.key] as String? ?? '',
                max: max(calories[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0, 1000),
              ),
            if (protein != null)
              _buildSliderRow(
                label: 'Protein',
                nutrientKey: NutritionEnum.protein.key,
                value: protein[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0,
                unit: protein[NutritionEnum.unit.key] as String? ?? '',
                max: max(protein[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0, 100),
              ),
            if (fat != null)
              _buildSliderRow(
                label: 'Fat',
                nutrientKey: NutritionEnum.fat.key,
                value: fat[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0,
                unit: fat[NutritionEnum.unit.key] as String? ?? '',
                max: max(fat[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0, 100),
              ),
            if (carbohydrates != null)
              _buildSliderRow(
                label: 'Carbohydrates',
                nutrientKey: NutritionEnum.carbohydrates.key,
                value: carbohydrates[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0,
                unit: carbohydrates[NutritionEnum.unit.key] as String? ?? '',
                max: max(carbohydrates[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0, 100),
              ),
            if (fiber != null)
              _buildSliderRow(
                label: 'Fiber',
                nutrientKey: NutritionEnum.fiber.key,
                value: fiber[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0,
                unit: fiber[NutritionEnum.unit.key] as String? ?? '',
                max: max(fiber[NutritionEnum.valueKey.key]?.toDouble() ?? 0.0, 100),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required String nutrientKey,
    required double value,
    required String unit,
    required double max,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(
            flex: 3,
            child: Slider(
              thumbColor: UIColor().darkGray,
              activeColor: UIColor().springGreen,
              inactiveColor: UIColor().gray,
              value: value,
              min: 0,
              max: max,
              label: '${value.toStringAsFixed(1)} $unit',
              onChanged: (newValue) {
                widget.onNutrientChanged?.call(nutrientKey, newValue);
              },
            ),
          ),
          Expanded(flex: 1, child: Text('${value.toStringAsFixed(1)} $unit')),
        ],
      ),
    );
  }
}
