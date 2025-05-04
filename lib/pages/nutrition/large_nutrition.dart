import 'package:flutter/material.dart';
import 'package:stuff_app/pages/nutrition/add_meal.dart';

class LargeNutritionPage extends StatefulWidget {
  const LargeNutritionPage({super.key});

  @override
  State<LargeNutritionPage> createState() => _LargeNutritionPageState();
}

class _LargeNutritionPageState extends State<LargeNutritionPage> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:
          () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddMealPage())),
      child: Text('add meal'),
    );
  }
}
