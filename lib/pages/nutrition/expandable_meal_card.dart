import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stuff_app/entities/nutrition/nutrition_entity.dart'; // Assuming NutritionEntity is here
import 'package:stuff_app/services/fbstore/fb_store.dart';
import 'package:stuff_app/pages/nutrition/nutrition_card.dart';
import 'package:stuff_app/widgets/texts/snack_bar_text.dart';
import 'package:stuff_app/widgets/ui_color.dart'; // Assuming NutritionCard is here

// This is a new Stateful widget for a single expandable meal card
class ExpandableMealCard extends StatefulWidget {
  final NutritionEntity meal;
  // You might want to pass a callback if updating individual
  // components directly from NutritionCard needs a parent action
  // final Function(String mealId, String componentId, String key, dynamic newValue) onNutrientUpdated;

  const ExpandableMealCard({
    super.key,
    required this.meal,
    // this.onNutrientUpdated,
  });

  @override
  State<ExpandableMealCard> createState() => _ExpandableMealCardState();
}

class _ExpandableMealCardState extends State<ExpandableMealCard> {
  // State specific to this single card's expansion
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final nutritionEntity = widget.meal;
    final mealId = nutritionEntity.id;
    final timeOfMeal = nutritionEntity.createdAt;
    final components = nutritionEntity.components;
    final mealType = nutritionEntity.meal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            // Toggle the expansion state for THIS card only
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 8.0, // Reduced horizontal margin for list items
              vertical: 4.0,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$mealType ${DateFormat('MM-dd HH:mm').format(timeOfMeal.toDate())}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                  // Add a delete button here
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: UIColor().scarlet, // Optional: make delete icon red
                    onPressed: () async {
                      // Show a confirmation dialog
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
                                  'Are you sure you want to delete this meal? This action cannot be undone.',
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
                        // Get the current user's ID
                        final userId = FirebaseAuth.instance.currentUser?.uid;

                        if (userId != null && context.mounted) {
                          // Call the delete function from FBStore only if confirmed and user is logged in
                          await FBStore().deleteMeal(context, userId, mealId);
                          // Firestore stream will automatically update the UI
                          // after deletion, so no manual setState is needed here
                        } else {
                          debugPrint('User not logged in, cannot delete meal.');
                          // Optionally show a message to the user indicating they need to log in
                          if (context.mounted) {
                            SnackBarText().showBanner(
                              msg: 'You must be logged in to delete meals.',
                              context: context,
                            );
                          }
                        }
                      }
                      // If confirmDelete is false, do nothing.
                    },
                  ),
                  Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        // Only build components if the card is expanded
        if (_isExpanded && components != null && components.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: UIColor().gray,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.only(left: 8, right: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ), // Adjusted padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...components.map(
                    (component) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: NutritionCard(
                        component: component,
                        // The update logic here should update the specific
                        // component within Firestore. It might need the mealId
                        // and component ID.
                        onNutrientChanged: (key, newValue) {
                          debugPrint('Meal ID: $mealId, Nutrient $key changed to $newValue');
                          // Implement Firestore update for this specific component
                          // Example (you'll need the component ID and structure):
                          // FirebaseFirestore.instance
                          //     .collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
                          //     .collection('meals').doc(mealId)
                          //     .update({
                          //       'components.${component.id}.nutrients.$key': newValue, // Adjust path as needed
                          //     });
                          // Note: Updating Firestore WILL trigger the StreamBuilder
                          // in the parent, but that's correct behaviour when data changes.
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Add a small separator if the list is expanded
        if (_isExpanded && components != null && components.isNotEmpty) const SizedBox(height: 8.0),
      ],
    );
  }
}
