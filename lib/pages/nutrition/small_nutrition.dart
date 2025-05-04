import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';
import 'package:stuff_app/entities/nutrition/nutrition_entity.dart';
import 'package:stuff_app/pages/nutrition/add_meal.dart';
import 'package:stuff_app/pages/nutrition/calorie_line_chart.dart';
import 'package:stuff_app/pages/nutrition/expandable_meal_card.dart';
import 'package:stuff_app/pages/nutrition/nutrition_pie_chart.dart';
import 'package:stuff_app/states/user_state.dart';
import 'package:stuff_app/widgets/loading/loading_widget_large.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class SmallNutritionPage extends StatefulWidget {
  const SmallNutritionPage({super.key});

  @override
  State<SmallNutritionPage> createState() => _SmallNutritionPageState();
}

class _SmallNutritionPageState extends State<SmallNutritionPage> {
  String _filterType = 'Day';
  DateTime _selectedDate = DateTime.now();
  final List<NutritionEntity> _fetchedMeals = [];

  // Options for the filter dropdown
  final List<String> _filterOptions = ['Day', 'Month', 'Year'];

  // Function to build the Firestore query based on the filter
  Query<Map<String, dynamic>> _buildQuery() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('meals');

    if (_filterType == 'Day') {
      query = query
          .where('year', isEqualTo: _selectedDate.year)
          .where('month', isEqualTo: _selectedDate.month)
          .where('day', isEqualTo: _selectedDate.day);
    } else if (_filterType == 'Month') {
      query = query
          .where('year', isEqualTo: _selectedDate.year)
          .where('month', isEqualTo: _selectedDate.month);
    } else if (_filterType == 'Year') {
      query = query.where('year', isEqualTo: _selectedDate.year);
    }

    return query;
  }

  // Function to sort meals by date client-side
  void _sortMealsByDate() {
    _fetchedMeals.sort((a, b) {
      final timestampA = a.createdAt;
      final timestampB = b.createdAt;

      return timestampA.compareTo(timestampB);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    ThemeData theme = Theme.of(context);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: theme.cardTheme.color,
              headerForegroundColor: theme.primaryColor,
              dayForegroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.cardTheme.color,
                ~WidgetState.disabled: theme.primaryColor,
              }),
              dayBackgroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.primaryColor,
              }),
              dayOverlayColor: WidgetStatePropertyAll(theme.primaryColor),
              todayBackgroundColor: WidgetStatePropertyAll(theme.cardTheme.color),
              todayForegroundColor: WidgetStatePropertyAll(theme.primaryColor),
              surfaceTintColor: theme.primaryColor,
              yearForegroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.cardTheme.color,
                ~WidgetState.disabled: theme.primaryColor,
              }),
              yearBackgroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.primaryColor,
              }),
              yearOverlayColor: WidgetStatePropertyAll(theme.primaryColor),
              yearStyle: TextStyle(color: theme.primaryColor),
              weekdayStyle: TextStyle(color: theme.primaryColor),
              dayStyle: TextStyle(color: theme.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              cancelButtonStyle: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(UIColor().scarlet),
              ),
              inputDecorationTheme: theme.inputDecorationTheme,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildDatePickerButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: ElevatedButton(
          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(12))),
          onPressed: () => _selectDate(context),
          child: Text(
            DateFormat(
              _filterType == 'Day'
                  ? 'yyyy-MM-dd'
                  : _filterType == 'Month'
                  ? 'yyyy-MM'
                  : 'yyyy',
            ).format(_selectedDate),
            style: TextStyle(color: UIColor().darkGray, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField2<String>(
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        contentPadding: const EdgeInsets.all(8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      hint: const Text('Filter by'),
                      value: _filterType,
                      items:
                          _filterOptions
                              .map(
                                (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _filterType = value ?? 'Day';
                          _selectedDate = DateTime.now();
                        });
                      },
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  _buildDatePickerButton(),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('StreamBuilder Error: ${snapshot.error}');
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidgetLarge();
                }

                _fetchedMeals.clear(); // Clear previous fetched meals
                double totalCalories = 0;
                double totalProteinGrams = 0;
                double totalFatGrams = 0;
                double totalFiberGrams = 0;
                double totalCarbohydratesGrams = 0;
                int numberOfMealDays = 0;
                Set<String> uniqueDays = {};

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  for (final doc in snapshot.data!.docs) {
                    final mealData = doc.data();
                    final nutritionEntity = NutritionEntity.fromMap(mealData);
                    _fetchedMeals.add(nutritionEntity);
                    totalCalories += nutritionEntity.totalCalories ?? 0.0;
                    totalProteinGrams += nutritionEntity.totalProtein ?? 0.0;
                    totalFatGrams += nutritionEntity.totalFat ?? 0.0;
                    totalCarbohydratesGrams += nutritionEntity.totalCarbohydrates ?? 0.0;
                    totalFiberGrams += nutritionEntity.totalFiber ?? 0.0;

                    // Count unique days for month and year averages
                    if (_filterType == 'Month' || _filterType == 'Year') {
                      final dayString =
                          '${nutritionEntity.year}-${nutritionEntity.month}-${nutritionEntity.day}';
                      uniqueDays.add(dayString);
                    }
                  }
                  _sortMealsByDate();
                  numberOfMealDays = uniqueDays.length;
                }

                // Calculate average data if month or year is selected
                if ((_filterType == 'Month' || _filterType == 'Year') && numberOfMealDays > 0) {
                  totalCalories /= numberOfMealDays;
                  totalProteinGrams /= numberOfMealDays;
                  totalFatGrams /= numberOfMealDays;
                  totalCarbohydratesGrams /= numberOfMealDays;
                  totalFiberGrams /= numberOfMealDays;
                }

                UserState userState = Provider.of(context, listen: false);

                // Prepare data for the line chart
                List<FlSpot> dailyCaloriesData = [];
                List<FlSpot> averageCaloriesData = [];
                DateTime chartStartDate = _selectedDate;
                DateTime chartEndDate = _selectedDate;

                if (_filterType == 'Day' && _fetchedMeals.isNotEmpty) {
                  dailyCaloriesData =
                      _fetchedMeals
                          .map(
                            (meal) => FlSpot(
                              meal.createdAt.millisecondsSinceEpoch.toDouble(),
                              meal.totalCalories?.toDouble() ?? 0,
                            ),
                          )
                          .toList();
                  averageCaloriesData =
                      dailyCaloriesData; // For a single day, daily and average are the same
                  chartStartDate = _fetchedMeals.first.createdAt.toDate();
                  chartEndDate = _fetchedMeals.last.createdAt.toDate();
                } else if (_filterType == 'Month' && _fetchedMeals.isNotEmpty) {
                  // Group by day and calculate daily totals
                  Map<String, double> dailyTotals = {};
                  for (var meal in _fetchedMeals) {
                    final dayKey = DateFormat(
                      'yyyy-MM-dd',
                    ).format(DateTime(meal.year, meal.month, meal.day));
                    dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + (meal.totalCalories ?? 0);
                  }
                  dailyCaloriesData =
                      dailyTotals.entries.map((e) {
                        final date = DateTime.parse(e.key);
                        return FlSpot(
                          date
                              .difference(
                                _selectedDate.subtract(Duration(days: _selectedDate.day - 1)),
                              )
                              .inDays
                              .toDouble(),
                          e.value,
                        );
                      }).toList();
                  // Calculate monthly average (already done in the StreamBuilder)
                  // The averageCaloriesData will be generated using the totalCalories calculated in the StreamBuilder
                  chartStartDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
                  chartEndDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
                } else if (_filterType == 'Year' && _fetchedMeals.isNotEmpty) {
                  // Group by day and calculate daily totals for the entire year
                  Map<String, double> dailyTotals = {};
                  DateTime firstDayOfYear = DateTime(_selectedDate.year, 1, 1);
                  DateTime lastDayOfYear = DateTime(_selectedDate.year, 12, 31);

                  for (var meal in _fetchedMeals) {
                    final dayKey = DateFormat(
                      'yyyy-MM-dd',
                    ).format(DateTime(meal.year, meal.month, meal.day));
                    dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + (meal.totalCalories ?? 0);
                  }

                  // Create a list of FlSpots only for the days with data
                  dailyCaloriesData =
                      dailyTotals.entries.map((entry) {
                        final date = DateTime.parse(entry.key);
                        return FlSpot(
                          date.difference(firstDayOfYear).inDays.toDouble(),
                          entry.value,
                        );
                      }).toList();

                  // Ensure the chart starts and ends at the beginning and end of the year
                  chartStartDate = firstDayOfYear;
                  chartEndDate = lastDayOfYear;

                  // If there's no data for the entire year, ensure the lists are empty
                  if (dailyCaloriesData.isEmpty) {
                    chartStartDate = _selectedDate;
                    chartEndDate = _selectedDate;
                  } else {
                    // Sort the data by date to ensure correct plotting order
                    dailyCaloriesData.sort((a, b) => a.x.compareTo(b.x));
                  }
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Total Calories ($_filterType${': ${DateFormat(_filterType == 'Day'
                            ? 'yyyy-MM-dd'
                            : _filterType == 'Month'
                            ? 'yyyy-MM'
                            : 'yyyy').format(_selectedDate)}'}):\n${totalCalories.toStringAsFixed(0)} kcal${(_filterType == 'Month' || _filterType == 'Year') && numberOfMealDays > 0 ? ' (Average per day)' : ''}',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    InteractiveNutritionPieChart(
                      proteinGrams: totalProteinGrams,
                      fatGrams: totalFatGrams,
                      carbGrams: totalCarbohydratesGrams,
                      fiberGrams: totalFiberGrams,
                    ),
                    if (_filterType != 'Day' && dailyCaloriesData.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                        child: CalorieLineChart(
                          dailyCalories: dailyCaloriesData,
                          averageCalories: averageCaloriesData,
                          targetCalories: userState.userEntity.targetCalories,
                          startDate: chartStartDate,
                          endDate: chartEndDate,
                          dailyAverageLine: totalCalories,
                          mode: _filterType,
                        ),
                      ),
                    if (_fetchedMeals.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No meals added for this period.'),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _fetchedMeals.length,
                          itemBuilder: (context, index) {
                            final nutritionEntity = _fetchedMeals[index];
                            return ExpandableMealCard(meal: nutritionEntity);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: (context) => const AddMealPage())),
                      child: Text(
                        'Add Meal',
                        style: TextStyle(
                          color: UIColor().darkGray,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
