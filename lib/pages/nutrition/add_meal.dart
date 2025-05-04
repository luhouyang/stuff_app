// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:stuff_app/entities/nutrition/nutrition_entity.dart';
// import 'package:stuff_app/services/fbstore/fb_store.dart';
// import 'package:stuff_app/services/gemini/meal_service.dart';
// import 'package:stuff_app/services/image/image_service.dart';
// import 'package:stuff_app/states/constants.dart';
// import 'package:stuff_app/pages/nutrition/nutrition_card.dart';
// import 'package:stuff_app/widgets/fields/text_input.dart';
// import 'package:stuff_app/widgets/loading/loading_widget.dart';
// import 'package:stuff_app/widgets/texts/h1_text.dart';
// import 'package:stuff_app/widgets/texts/snack_bar_text.dart';
// import 'package:stuff_app/widgets/ui_color.dart';

// class AddMealPage extends StatefulWidget {
//   const AddMealPage({super.key});

//   @override
//   State<AddMealPage> createState() => _AddMealPageState();
// }

// class _AddMealPageState extends State<AddMealPage> {
//   TextInputs textInputs = TextInputs();
//   SnackBarText snackBarText = SnackBarText();
//   ImageData mealImage = ImageData();
//   final _apiForm = GlobalKey<FormState>();
//   TextEditingController apiKeyController = TextEditingController();
//   final _mealForm = GlobalKey<FormState>();
//   TextEditingController mealDescController = TextEditingController();
//   NutritionEntity? nutritionData;
//   final _addMealForm = GlobalKey<FormState>();
//   List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Supper'];
//   String mealType = 'Breakfast';

//   void _updateComponentNutrient(String componentName, String nutrientKey, double newValue) {
//     if (nutritionData?.components == null) return;

//     final componentIndex = nutritionData!.components!.indexWhere(
//       (comp) => comp[NutritionEnum.name.key] == componentName,
//     );

//     if (componentIndex != -1) {
//       final updatedComponent = Map<String, dynamic>.from(
//         nutritionData!.components![componentIndex],
//       );

//       if (updatedComponent.containsKey(nutrientKey) && updatedComponent[nutrientKey] is Map) {
//         updatedComponent[nutrientKey] = Map<String, dynamic>.from(updatedComponent[nutrientKey]);
//         updatedComponent[nutrientKey][NutritionEnum.valueKey.key] = newValue;

//         setState(() {
//           nutritionData!.components![componentIndex] = updatedComponent;
//           _updateTotals();
//         });
//       }
//     }
//   }

//   void _updateComponentName(String oldName, String newName) {
//     if (nutritionData?.components == null || oldName == newName) return;

//     final componentIndex = nutritionData!.components!.indexWhere(
//       (comp) => comp[NutritionEnum.name.key] == oldName,
//     );

//     if (componentIndex != -1) {
//       final updatedComponent = Map<String, dynamic>.from(
//         nutritionData!.components![componentIndex],
//       );

//       updatedComponent[NutritionEnum.name.key] = newName;

//       setState(() {
//         nutritionData!.components![componentIndex] = updatedComponent;
//       });
//     }
//   }

//   void _deleteComponent(String componentName) {
//     if (nutritionData?.components == null) return;

//     setState(() {
//       nutritionData!.components!.removeWhere(
//         (comp) => comp[NutritionEnum.name.key] == componentName,
//       );
//       _updateTotals();
//     });
//   }

//   void _updateTotals() {
//     if (nutritionData?.components != null) {
//       double totalCalories = 0;
//       double totalProtein = 0;
//       double totalFat = 0;
//       double totalCarbohydrates = 0;
//       double totalFiber = 0;

//       for (final component in nutritionData!.components!) {
//         totalCalories +=
//             component[NutritionEnum.calories.key]?[NutritionEnum.valueKey.key].toDouble() ?? 0.0;
//         totalProtein +=
//             component[NutritionEnum.protein.key]?[NutritionEnum.valueKey.key].toDouble() ?? 0.0;
//         totalFat += component[NutritionEnum.fat.key]?[NutritionEnum.valueKey.key].toDouble() ?? 0.0;
//         totalCarbohydrates +=
//             component[NutritionEnum.carbohydrates.key]?[NutritionEnum.valueKey.key].toDouble() ??
//             0.0;
//         totalFiber +=
//             component[NutritionEnum.fiber.key]?[NutritionEnum.valueKey.key].toDouble() ?? 0.0;
//       }

//       if (nutritionData?.data[NutritionEnum.data.key] is Map) {
//         nutritionData!.data[NutritionEnum.data.key][NutritionEnum.totals.key] = {
//           NutritionEnum.calories.key: {
//             NutritionEnum.valueKey.key: totalCalories,
//             NutritionEnum.unit.key: 'kcal',
//             NutritionEnum.type.key: 'double',
//           },
//           NutritionEnum.protein.key: {
//             NutritionEnum.valueKey.key: totalProtein,
//             NutritionEnum.unit.key: 'grams',
//             NutritionEnum.type.key: 'double',
//           },
//           NutritionEnum.fat.key: {
//             NutritionEnum.valueKey.key: totalFat,
//             NutritionEnum.unit.key: 'grams',
//             NutritionEnum.type.key: 'double',
//           },
//           NutritionEnum.carbohydrates.key: {
//             NutritionEnum.valueKey.key: totalCarbohydrates,
//             NutritionEnum.unit.key: 'grams',
//             NutritionEnum.type.key: 'double',
//           },
//           NutritionEnum.fiber.key: {
//             NutritionEnum.valueKey.key: totalFiber,
//             NutritionEnum.unit.key: 'grams',
//             NutritionEnum.type.key: 'double',
//           },
//         };
//       }
//     }
//   }

//   String webApiKey = '';

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     bool isLargeScreen = screenWidth > Constants().largeScreenWidth;
//     double ebPadding = isLargeScreen ? 16 : 0;

//     return kIsWeb
//         ? Scaffold(
//           body: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child:
//                   webApiKey.isEmpty
//                       ? Form(
//                         key: _apiForm,
//                         child: Column(
//                           children: [
//                             const Text("Your API key is stored locally"),
//                             textInputs.inputTextWidget(
//                               hint: 'YOUR API_KEY',
//                               validator: textInputs.textVerify,
//                               controller: apiKeyController,
//                             ),
//                             Row(
//                               mainAxisSize: MainAxisSize.max,
//                               children: [
//                                 Expanded(
//                                   child: ElevatedButton(
//                                     style: ButtonStyle(
//                                       padding: WidgetStatePropertyAll(EdgeInsets.all(ebPadding)),
//                                     ),
//                                     onPressed: () async {
//                                       if (_apiForm.currentState!.validate()) {
//                                         snackBarText.showBanner(
//                                           msg: "Stored API key locally",
//                                           context: context,
//                                         );
//                                         showDialog(
//                                           context: context,
//                                           builder: (context) {
//                                             return LoadingWidget().circularLoadingWidget(context);
//                                           },
//                                         );
//                                         if (context.mounted) {
//                                           Navigator.of(context).pop();
//                                           setState(() {
//                                             webApiKey = apiKeyController.text;
//                                           });
//                                         }
//                                       }
//                                     },
//                                     child: Text(
//                                       "STORE",
//                                       style: Theme.of(context).textTheme.headlineMedium!.copyWith(
//                                         color: UIColor().darkGray,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       )
//                       : Form(
//                         key: _mealForm,
//                         child: Column(
//                           children: [
//                             const H1Text(text: "Meal Nutrition"),
//                             ImageService(parentContext: context, imageData: mealImage),
//                             textInputs.inputTextWidget(
//                               hint: 'short description of your meal',
//                               validator: textInputs.textVerify,
//                               controller: mealDescController,
//                             ),
//                             Row(
//                               mainAxisSize: MainAxisSize.max,
//                               children: [
//                                 Expanded(
//                                   child: ElevatedButton(
//                                     onPressed: () async {
//                                       if (_mealForm.currentState!.validate() &&
//                                           mealImage.imageBytes.isNotEmpty &&
//                                           mealImage.imageBytes.first != 0) {
//                                         snackBarText.showBanner(
//                                           msg: "Analyzing meal...",
//                                           context: context,
//                                         );
//                                         showDialog(
//                                           context: context,
//                                           builder: (context) {
//                                             return LoadingWidget().circularLoadingWidget(context);
//                                           },
//                                         );
//                                         final result = await analyzeFoodNutrition(
//                                           mealImage.imageFilePath,
//                                           mealImage.imageBytes,
//                                           webApiKey,
//                                           mealDescController.text,
//                                         );
//                                         if (context.mounted) {
//                                           Navigator.of(context).pop();
//                                           if (result != null) {
//                                             setState(() {
//                                               nutritionData = result;
//                                             });
//                                           } else {
//                                             snackBarText.showBanner(
//                                               msg: "Failed to analyze meal.",
//                                               context: context,
//                                             );
//                                           }
//                                         }
//                                       } else if (mealImage.imageBytes.isEmpty ||
//                                           mealImage.imageBytes.first == 0) {
//                                         snackBarText.showBanner(
//                                           msg: "Please select an image.",
//                                           context: context,
//                                         );
//                                       }
//                                     },
//                                     child: Text(
//                                       "EAT",
//                                       style: Theme.of(context).textTheme.headlineMedium!.copyWith(
//                                         color: UIColor().darkGray,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             if (nutritionData?.components != null &&
//                                 nutritionData!.components!.isNotEmpty)
//                               SizedBox(
//                                 child: ListView.builder(
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   shrinkWrap: true,
//                                   itemCount: nutritionData!.components!.length,
//                                   itemBuilder: (context, index) {
//                                     final component = nutritionData!.components![index];
//                                     return NutritionCard(
//                                       component: component,
//                                       onNutrientChanged: (nutrientKey, newValue) {
//                                         final componentName =
//                                             component[NutritionEnum.name.key] as String?;
//                                         if (componentName != null) {
//                                           _updateComponentNutrient(
//                                             componentName,
//                                             nutrientKey,
//                                             newValue,
//                                           );
//                                         }
//                                       },
//                                       onNameChanged: (newName) {
//                                         final oldName =
//                                             component[NutritionEnum.name.key] as String? ?? '';
//                                         if (oldName != newName) {
//                                           _updateComponentName(oldName, newName);
//                                         }
//                                       },
//                                       onDelete: (componentName) {
//                                         _deleteComponent(componentName);
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//             ),
//           ),
//         )
//         : ValueListenableBuilder(
//           valueListenable: Hive.box('geminiBox').listenable(),
//           builder: (context, box, child) {
//             String apiKey = box.get('apiKey') ?? '';
//             return Scaffold(
//               body: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child:
//                       apiKey.isEmpty
//                           ? Form(
//                             key: _apiForm,
//                             child: Column(
//                               children: [
//                                 const SizedBox(height: 24),
//                                 const Text("Your API key is stored locally"),
//                                 textInputs.inputTextWidget(
//                                   hint: 'YOUR API_KEY',
//                                   validator: textInputs.textVerify,
//                                   controller: apiKeyController,
//                                 ),
//                                 Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: [
//                                     Expanded(
//                                       child: ElevatedButton(
//                                         style: ButtonStyle(
//                                           padding: WidgetStatePropertyAll(
//                                             EdgeInsets.all(ebPadding),
//                                           ),
//                                         ),
//                                         onPressed: () async {
//                                           if (_apiForm.currentState!.validate()) {
//                                             snackBarText.showBanner(
//                                               msg: "Stored API key locally",
//                                               context: context,
//                                             );
//                                             showDialog(
//                                               context: context,
//                                               builder: (context) {
//                                                 return LoadingWidget().circularLoadingWidget(
//                                                   context,
//                                                 );
//                                               },
//                                             );
//                                             await box.put('apiKey', apiKeyController.text);
//                                             if (context.mounted) {
//                                               Navigator.of(context).pop();
//                                               setState(() {});
//                                             }
//                                           }
//                                         },
//                                         child: Text(
//                                           "STORE",
//                                           style: Theme.of(context).textTheme.headlineMedium!
//                                               .copyWith(color: UIColor().darkGray),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           )
//                           : Form(
//                             key: _mealForm,
//                             child: Column(
//                               children: [
//                                 const SizedBox(height: 16),
//                                 const H1Text(text: "Meal Nutrition"),
//                                 ImageService(parentContext: context, imageData: mealImage),
//                                 textInputs.inputTextWidget(
//                                   hint: 'short description of your meal',
//                                   validator: textInputs.textVerify,
//                                   controller: mealDescController,
//                                 ),
//                                 Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: [
//                                     Expanded(
//                                       child: ElevatedButton(
//                                         style: ButtonStyle(
//                                           padding: WidgetStatePropertyAll(
//                                             EdgeInsets.all(ebPadding),
//                                           ),
//                                         ),
//                                         onPressed: () async {
//                                           if (_mealForm.currentState!.validate() &&
//                                               mealImage.imageBytes.isNotEmpty &&
//                                               mealImage.imageBytes.first != 0) {
//                                             snackBarText.showBanner(
//                                               msg: "Analyzing meal...",
//                                               context: context,
//                                             );
//                                             showDialog(
//                                               context: context,
//                                               builder: (context) {
//                                                 return LoadingWidget().circularLoadingWidget(
//                                                   context,
//                                                 );
//                                               },
//                                             );
//                                             final result = await analyzeFoodNutrition(
//                                               mealImage.imageFilePath,
//                                               mealImage.imageBytes,
//                                               apiKey,
//                                               mealDescController.text,
//                                             );
//                                             if (context.mounted) {
//                                               Navigator.of(context).pop();
//                                               if (result != null) {
//                                                 setState(() {
//                                                   nutritionData = result;
//                                                 });
//                                               } else {
//                                                 snackBarText.showBanner(
//                                                   msg: "Failed to analyze meal.",
//                                                   context: context,
//                                                 );
//                                               }
//                                             }
//                                           } else if (mealImage.imageBytes.isEmpty ||
//                                               mealImage.imageBytes.first == 0) {
//                                             snackBarText.showBanner(
//                                               msg: "Please select an image.",
//                                               context: context,
//                                             );
//                                           }
//                                         },
//                                         child: Text(
//                                           "EAT",
//                                           style: Theme.of(context).textTheme.headlineMedium!
//                                               .copyWith(color: UIColor().darkGray),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 if (nutritionData?.components != null &&
//                                     nutritionData!.components!.isNotEmpty)
//                                   Form(
//                                     key: _addMealForm,
//                                     child: Column(
//                                       children: [
//                                         SizedBox(
//                                           child: ListView.builder(
//                                             physics: const NeverScrollableScrollPhysics(),
//                                             shrinkWrap: true,
//                                             itemCount: nutritionData!.components!.length,
//                                             itemBuilder: (context, index) {
//                                               final component = nutritionData!.components![index];
//                                               return NutritionCard(
//                                                 component: component,
//                                                 onNutrientChanged: (nutrientKey, newValue) {
//                                                   final componentName =
//                                                       component[NutritionEnum.name.key] as String?;
//                                                   if (componentName != null) {
//                                                     _updateComponentNutrient(
//                                                       componentName,
//                                                       nutrientKey,
//                                                       newValue,
//                                                     );
//                                                   }
//                                                 },
//                                                 onNameChanged: (newName) {
//                                                   final oldName =
//                                                       component[NutritionEnum.name.key]
//                                                           as String? ??
//                                                       '';
//                                                   if (oldName != newName) {
//                                                     _updateComponentName(oldName, newName);
//                                                   }
//                                                 },
//                                                 onDelete: (componentName) {
//                                                   _deleteComponent(componentName);
//                                                 },
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           child: DropdownButtonFormField2<String>(
//                                             isExpanded: true,
//                                             hint: Text(
//                                               "meal type",
//                                               style:
//                                                   Theme.of(context).inputDecorationTheme.hintStyle,
//                                             ),
//                                             decoration: InputDecoration(
//                                               focusedBorder: OutlineInputBorder(
//                                                 borderSide: BorderSide(
//                                                   color: Theme.of(context).primaryColor,
//                                                 ),
//                                               ),
//                                               contentPadding: const EdgeInsets.all(8),
//                                               border: OutlineInputBorder(
//                                                 borderRadius: BorderRadius.circular(4),
//                                               ),
//                                             ),
//                                             items:
//                                                 mealTypes.map((e) {
//                                                   return DropdownMenuItem<String>(
//                                                     value: e,
//                                                     child: Text(e),
//                                                   );
//                                                 }).toList(),
//                                             validator: (value) {
//                                               if (value == null) {
//                                                 return 'Select a meal type';
//                                               }
//                                               return null;
//                                             },
//                                             onChanged: (value) {
//                                               setState(() {
//                                                 mealType = value.toString();
//                                               });
//                                             },
//                                             onSaved: (value) {},
//                                             iconStyleData: const IconStyleData(
//                                               icon: Icon(
//                                                 Icons.arrow_drop_down,
//                                                 color: Colors.black45,
//                                               ),
//                                               iconSize: 24,
//                                             ),
//                                             dropdownStyleData: DropdownStyleData(
//                                               decoration: BoxDecoration(
//                                                 color:
//                                                     Theme.of(
//                                                       context,
//                                                     ).inputDecorationTheme.fillColor,
//                                                 borderRadius: BorderRadius.circular(4),
//                                               ),
//                                             ),
//                                             menuItemStyleData: const MenuItemStyleData(
//                                               padding: EdgeInsets.symmetric(horizontal: 8),
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Row(
//                                           mainAxisSize: MainAxisSize.max,
//                                           children: [
//                                             Expanded(
//                                               child: ElevatedButton(
//                                                 style: ButtonStyle(
//                                                   padding: WidgetStatePropertyAll(
//                                                     EdgeInsets.all(ebPadding),
//                                                   ),
//                                                 ),
//                                                 onPressed: () async {
//                                                   if (nutritionData != null &&
//                                                       _addMealForm.currentState!.validate()) {
//                                                     snackBarText.showBanner(
//                                                       msg: "Added a meal",
//                                                       context: context,
//                                                     );
//                                                     showDialog(
//                                                       context: context,
//                                                       builder: (context) {
//                                                         return LoadingWidget()
//                                                             .circularLoadingWidget(context);
//                                                       },
//                                                     );
//                                                     nutritionData!.meal = mealType;
//                                                     await FBStore().addMeal(
//                                                       context,
//                                                       nutritionData!,
//                                                       FirebaseAuth.instance.currentUser!.uid,
//                                                     );
//                                                     if (context.mounted) {
//                                                       Navigator.of(context).pop();
//                                                       setState(() {});
//                                                       Navigator.of(context).pop();
//                                                     }
//                                                   }
//                                                 },
//                                                 child: Text(
//                                                   "ADD RECORD",
//                                                   style: Theme.of(context).textTheme.headlineMedium!
//                                                       .copyWith(color: UIColor().darkGray),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 64),
//                                       ],
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                 ),
//               ),
//             );
//           },
//         );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:stuff_app/entities/nutrition/nutrition_entity.dart';
import 'package:stuff_app/services/fbstore/fb_store.dart';
import 'package:stuff_app/services/gemini/meal_service.dart';
import 'package:stuff_app/services/image/image_service.dart';
import 'package:stuff_app/states/constants.dart';
import 'package:stuff_app/pages/nutrition/nutrition_card.dart';
import 'package:stuff_app/widgets/fields/text_input.dart';
import 'package:stuff_app/widgets/loading/loading_widget.dart';
import 'package:stuff_app/widgets/texts/h1_text.dart';
import 'package:stuff_app/widgets/texts/snack_bar_text.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  // Existing variables
  TextInputs textInputs = TextInputs();
  SnackBarText snackBarText = SnackBarText();
  ImageData mealImage = ImageData();
  final _apiForm = GlobalKey<FormState>();
  TextEditingController apiKeyController = TextEditingController();
  final _mealForm = GlobalKey<FormState>();
  TextEditingController mealDescController = TextEditingController();
  NutritionEntity? nutritionData;
  final _addMealForm = GlobalKey<FormState>();
  List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Supper'];
  String mealType = 'Breakfast';

  // New Date Picker Variables
  DateTime _selectedDate = DateTime.now();
  final String _filterType = 'Day';

  void _updateComponentNutrient(String componentName, String nutrientKey, double newValue) {
    if (nutritionData?.components == null) return;

    final componentIndex = nutritionData!.components!.indexWhere(
      (comp) => comp[NutritionEnum.name.key] == componentName,
    );

    if (componentIndex != -1) {
      final updatedComponent = Map<String, dynamic>.from(
        nutritionData!.components![componentIndex],
      );

      if (updatedComponent.containsKey(nutrientKey) && updatedComponent[nutrientKey] is Map) {
        updatedComponent[nutrientKey] = Map<String, dynamic>.from(updatedComponent[nutrientKey]);
        updatedComponent[nutrientKey][NutritionEnum.valueKey.key] = newValue;

        setState(() {
          nutritionData!.components![componentIndex] = updatedComponent;
          _updateTotals();
        });
      }
    }
  }

  void _updateComponentName(String oldName, String newName) {
    if (nutritionData?.components == null || oldName == newName) return;

    final componentIndex = nutritionData!.components!.indexWhere(
      (comp) => comp[NutritionEnum.name.key] == oldName,
    );

    if (componentIndex != -1) {
      final updatedComponent = Map<String, dynamic>.from(
        nutritionData!.components![componentIndex],
      );

      updatedComponent[NutritionEnum.name.key] = newName;

      setState(() {
        nutritionData!.components![componentIndex] = updatedComponent;
      });
    }
  }

  void _deleteComponent(String componentName) {
    if (nutritionData?.components == null) return;

    setState(() {
      nutritionData!.components!.removeWhere(
        (comp) => comp[NutritionEnum.name.key] == componentName,
      );
      _updateTotals();
    });
  }

  void _updateTotals() {
    if (nutritionData?.components != null) {
      double totalCalories = 0;
      double totalProtein = 0;
      double totalFat = 0;
      double totalCarbohydrates = 0;
      double totalFiber = 0;

      for (final component in nutritionData!.components!) {
        totalCalories +=
            component[NutritionEnum.calories.key]?[NutritionEnum.valueKey.key].toDouble() ?? 0.0;
        totalProtein +=
            component[NutritionEnum.protein.key]?[NutritionEnum.valueKey.key].toDouble() ?? 0.0;
        totalFat += component[NutritionEnum.fat.key]?[NutritionEnum.valueKey.key].toDouble() ?? 0.0;
        totalCarbohydrates +=
            component[NutritionEnum.carbohydrates.key]?[NutritionEnum.valueKey.key].toDouble() ??
            0.0;
        totalFiber +=
            component[NutritionEnum.fiber.key]?[NutritionEnum.valueKey.key].toDouble() ?? 0.0;
      }

      if (nutritionData?.data[NutritionEnum.data.key] is Map) {
        nutritionData!.data[NutritionEnum.data.key][NutritionEnum.totals.key] = {
          NutritionEnum.calories.key: {
            NutritionEnum.valueKey.key: totalCalories,
            NutritionEnum.unit.key: 'kcal',
            NutritionEnum.type.key: 'double',
          },
          NutritionEnum.protein.key: {
            NutritionEnum.valueKey.key: totalProtein,
            NutritionEnum.unit.key: 'grams',
            NutritionEnum.type.key: 'double',
          },
          NutritionEnum.fat.key: {
            NutritionEnum.valueKey.key: totalFat,
            NutritionEnum.unit.key: 'grams',
            NutritionEnum.type.key: 'double',
          },
          NutritionEnum.carbohydrates.key: {
            NutritionEnum.valueKey.key: totalCarbohydrates,
            NutritionEnum.unit.key: 'grams',
            NutritionEnum.type.key: 'double',
          },
          NutritionEnum.fiber.key: {
            NutritionEnum.valueKey.key: totalFiber,
            NutritionEnum.unit.key: 'grams',
            NutritionEnum.type.key: 'double',
          },
        };
      }
    }
  }

  String webApiKey = '';

  // New Date Picker Method
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

  // New Date Picker Button Widget
  Widget _buildDatePickerButton() {
    return ElevatedButton(
      onPressed: () => _selectDate(context),
      child: Row(
        children: [
          Text(
            DateFormat(
              _filterType == 'Day'
                  ? 'yyyy-MM-dd'
                  : _filterType == 'Month'
                  ? 'yyyy-MM'
                  : 'yyyy',
            ).format(_selectedDate),
            style: TextStyle(color: UIColor().darkGray, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Icon(Icons.calendar_month_outlined),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > Constants().largeScreenWidth;
    double ebPadding = isLargeScreen ? 16 : 0;

    return kIsWeb
        ? Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child:
                  webApiKey.isEmpty
                      ? Form(
                        key: _apiForm,
                        child: Column(
                          children: [
                            const Text("Your API key is stored locally"),
                            textInputs.inputTextWidget(
                              hint: 'YOUR API_KEY',
                              validator: textInputs.textVerify,
                              controller: apiKeyController,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      padding: WidgetStatePropertyAll(EdgeInsets.all(ebPadding)),
                                    ),
                                    onPressed: () async {
                                      if (_apiForm.currentState!.validate()) {
                                        snackBarText.showBanner(
                                          msg: "Stored API key locally",
                                          context: context,
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return LoadingWidget().circularLoadingWidget(context);
                                          },
                                        );
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            webApiKey = apiKeyController.text;
                                          });
                                        }
                                      }
                                    },
                                    child: Text(
                                      "STORE",
                                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                        color: UIColor().darkGray,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                      : Form(
                        key: _mealForm,
                        child: Column(
                          children: [
                            const H1Text(text: "Meal Nutrition"),
                            ImageService(parentContext: context, imageData: mealImage),
                            textInputs.inputTextWidget(
                              hint: 'short description of your meal',
                              validator: textInputs.textVerify,
                              controller: mealDescController,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                _buildDatePickerButton(), // Added Date Picker Button
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_mealForm.currentState!.validate() &&
                                          mealImage.imageBytes.isNotEmpty &&
                                          mealImage.imageBytes.first != 0) {
                                        snackBarText.showBanner(
                                          msg: "Analyzing meal...",
                                          context: context,
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return LoadingWidget().circularLoadingWidget(context);
                                          },
                                        );
                                        final result = await analyzeFoodNutrition(
                                          mealImage.imageFilePath,
                                          mealImage.imageBytes,
                                          webApiKey,
                                          mealDescController.text,
                                        );
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          if (result != null) {
                                            setState(() {
                                              nutritionData = result;
                                            });
                                          } else {
                                            snackBarText.showBanner(
                                              msg: "Failed to analyze meal.",
                                              context: context,
                                            );
                                          }
                                        }
                                      } else if (mealImage.imageBytes.isEmpty ||
                                          mealImage.imageBytes.first == 0) {
                                        snackBarText.showBanner(
                                          msg: "Please select an image.",
                                          context: context,
                                        );
                                      }
                                    },
                                    child: Text(
                                      "EAT",
                                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                        color: UIColor().darkGray,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (nutritionData?.components != null &&
                                nutritionData!.components!.isNotEmpty)
                              SizedBox(
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: nutritionData!.components!.length,
                                  itemBuilder: (context, index) {
                                    final component = nutritionData!.components![index];
                                    return NutritionCard(
                                      component: component,
                                      onNutrientChanged: (nutrientKey, newValue) {
                                        final componentName =
                                            component[NutritionEnum.name.key] as String?;
                                        if (componentName != null) {
                                          _updateComponentNutrient(
                                            componentName,
                                            nutrientKey,
                                            newValue,
                                          );
                                        }
                                      },
                                      onNameChanged: (newName) {
                                        final oldName =
                                            component[NutritionEnum.name.key] as String? ?? '';
                                        if (oldName != newName) {
                                          _updateComponentName(oldName, newName);
                                        }
                                      },
                                      onDelete: (componentName) {
                                        _deleteComponent(componentName);
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
            ),
          ),
        )
        : ValueListenableBuilder(
          valueListenable: Hive.box('geminiBox').listenable(),
          builder: (context, box, child) {
            String apiKey = box.get('apiKey') ?? '';
            return Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child:
                      apiKey.isEmpty
                          ? Form(
                            key: _apiForm,
                            child: Column(
                              children: [
                                const SizedBox(height: 36),
                                const Text("Your API key is stored locally"),
                                textInputs.inputTextWidget(
                                  hint: 'YOUR API_KEY',
                                  validator: textInputs.textVerify,
                                  controller: apiKeyController,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          padding: WidgetStatePropertyAll(
                                            EdgeInsets.all(ebPadding),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (_apiForm.currentState!.validate()) {
                                            snackBarText.showBanner(
                                              msg: "Stored API key locally",
                                              context: context,
                                            );
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return LoadingWidget().circularLoadingWidget(
                                                  context,
                                                );
                                              },
                                            );
                                            await box.put('apiKey', apiKeyController.text);
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                              setState(() {});
                                            }
                                          }
                                        },
                                        child: Text(
                                          "STORE",
                                          style: Theme.of(context).textTheme.headlineMedium!
                                              .copyWith(color: UIColor().darkGray),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                          : Form(
                            key: _mealForm,
                            child: Column(
                              children: [
                                const SizedBox(height: 24),
                                const H1Text(text: "Meal Nutrition"),
                                ImageService(parentContext: context, imageData: mealImage),
                                textInputs.inputTextWidget(
                                  hint: 'short description of your meal',
                                  validator: textInputs.textVerify,
                                  controller: mealDescController,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildDatePickerButton(),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                          EdgeInsets.fromLTRB(56, ebPadding, 56, ebPadding),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (_mealForm.currentState!.validate() &&
                                            mealImage.imageBytes.isNotEmpty &&
                                            mealImage.imageBytes.first != 0) {
                                          snackBarText.showBanner(
                                            msg: "Analyzing meal...",
                                            context: context,
                                          );
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return LoadingWidget().circularLoadingWidget(context);
                                            },
                                          );
                                          final result = await analyzeFoodNutrition(
                                            mealImage.imageFilePath,
                                            mealImage.imageBytes,
                                            apiKey,
                                            mealDescController.text,
                                          );
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                            if (result != null) {
                                              setState(() {
                                                nutritionData = result;
                                              });
                                            } else {
                                              snackBarText.showBanner(
                                                msg: "Failed to analyze meal.",
                                                context: context,
                                              );
                                            }
                                          }
                                        } else if (mealImage.imageBytes.isEmpty ||
                                            mealImage.imageBytes.first == 0) {
                                          snackBarText.showBanner(
                                            msg: "Please select an image.",
                                            context: context,
                                          );
                                        }
                                      },
                                      child: Text(
                                        "EAT",
                                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                          color: UIColor().darkGray,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (nutritionData?.components != null &&
                                    nutritionData!.components!.isNotEmpty)
                                  Form(
                                    key: _addMealForm,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          child: ListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: nutritionData!.components!.length,
                                            itemBuilder: (context, index) {
                                              final component = nutritionData!.components![index];
                                              return NutritionCard(
                                                component: component,
                                                onNutrientChanged: (nutrientKey, newValue) {
                                                  final componentName =
                                                      component[NutritionEnum.name.key] as String?;
                                                  if (componentName != null) {
                                                    _updateComponentNutrient(
                                                      componentName,
                                                      nutrientKey,
                                                      newValue,
                                                    );
                                                  }
                                                },
                                                onNameChanged: (newName) {
                                                  final oldName =
                                                      component[NutritionEnum.name.key]
                                                          as String? ??
                                                      '';
                                                  if (oldName != newName) {
                                                    _updateComponentName(oldName, newName);
                                                  }
                                                },
                                                onDelete: (componentName) {
                                                  _deleteComponent(componentName);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          child: DropdownButtonFormField2<String>(
                                            isExpanded: true,
                                            hint: Text(
                                              "meal type",
                                              style:
                                                  Theme.of(context).inputDecorationTheme.hintStyle,
                                            ),
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                              contentPadding: const EdgeInsets.all(8),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                            items:
                                                mealTypes.map((e) {
                                                  return DropdownMenuItem<String>(
                                                    value: e,
                                                    child: Text(e),
                                                  );
                                                }).toList(),
                                            validator: (value) {
                                              if (value == null) {
                                                return 'Select a meal type';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              setState(() {
                                                mealType = value.toString();
                                              });
                                            },
                                            onSaved: (value) {},
                                            iconStyleData: const IconStyleData(
                                              icon: Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.black45,
                                              ),
                                              iconSize: 24,
                                            ),
                                            dropdownStyleData: DropdownStyleData(
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).inputDecorationTheme.fillColor,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                            menuItemStyleData: const MenuItemStyleData(
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  padding: WidgetStatePropertyAll(
                                                    EdgeInsets.all(ebPadding),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  if (nutritionData != null &&
                                                      _addMealForm.currentState!.validate()) {
                                                    snackBarText.showBanner(
                                                      msg: "Added a meal",
                                                      context: context,
                                                    );
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return LoadingWidget()
                                                            .circularLoadingWidget(context);
                                                      },
                                                    );
                                                    nutritionData!.meal = mealType;
                                                    nutritionData!.createdAt = Timestamp.fromDate(
                                                      _selectedDate,
                                                    );
                                                    nutritionData!.year = _selectedDate.year;
                                                    nutritionData!.month = _selectedDate.month;
                                                    nutritionData!.day = _selectedDate.day;

                                                    await FBStore().addMeal(
                                                      context,
                                                      nutritionData!,
                                                      FirebaseAuth.instance.currentUser!.uid,
                                                    );
                                                    if (context.mounted) {
                                                      Navigator.of(context).pop();
                                                      setState(() {});
                                                      Navigator.of(context).pop();
                                                    }
                                                  }
                                                },
                                                child: Text(
                                                  "ADD RECORD",
                                                  style: Theme.of(context).textTheme.headlineMedium!
                                                      .copyWith(color: UIColor().darkGray),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 64),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                ),
              ),
            );
          },
        );
  }
}
