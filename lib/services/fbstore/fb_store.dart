import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stuff_app/entities/finance/balance_entity.dart';
import 'package:stuff_app/entities/finance/transaction_entity.dart';
import 'package:stuff_app/entities/nutrition/nutrition_entity.dart';
import 'package:stuff_app/entities/user/user_entity.dart';
import 'package:stuff_app/states/user_state.dart';
import 'package:stuff_app/widgets/texts/snack_bar_text.dart';

class FBStore {
  // USER
  Future<UserEntity> getUser(BuildContext context, String id, UserState userState) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot doc = await firestore.collection('users').doc(id).get();

      if (doc.exists) {
        UserEntity userEntity = UserEntity.fromMap(doc.data() as Map<String, dynamic>);

        userState.setUserEntity(newUserEntity: userEntity);

        return userEntity;
      } else {
        UserEntity userEntity = UserEntity(
          id: id,
          name: 'username',
          bio: 'Add your bio',
          weight: 50.0,
          height: 1.65,
          targetCalories: 2000.0,
          storageAllowance: 209715200.0,
          storageUsed: 0.0,
        );

        try {
          await firestore.collection('users').doc(id).set(userEntity.toMap());

          userState.setUserEntity(newUserEntity: userEntity);

          return userEntity;
        } catch (e) {
          context.mounted
              ? SnackBarText().showBanner(msg: e.toString(), context: context)
              : debugPrint(e.toString());
        }
      }
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(msg: e.toString(), context: context)
          : debugPrint(e.toString());
    }

    return UserEntity(
      id: 'NOID',
      name: 'NONAME',
      bio: 'NOBIO',
      weight: 50.0,
      height: 1.65,
      targetCalories: 2000.0,
      storageAllowance: 209715200.0,
      storageUsed: 0.0,
    );
  }

  Future<void> updateUserEntity(BuildContext context, UserEntity userEntity) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('users').doc(userEntity.id).update(userEntity.toMap());
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(msg: e.toString(), context: context)
          : debugPrint('Error updating user data: $e');
      rethrow; // Re-throw the error to be caught in the UI
    }
  }

  // MEALS
  Future<void> addMeal(BuildContext context, NutritionEntity nutritionEntity, String uid) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      String id = firestore.collection('users').doc(uid).collection('meals').doc().id;
      nutritionEntity.id = id;

      await firestore
          .collection('users')
          .doc(uid)
          .collection('meals')
          .doc(id)
          .set(nutritionEntity.toMap());
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(msg: e.toString(), context: context)
          : debugPrint(e.toString());
    }
  }

  Future<void> deleteMeal(BuildContext context, String uid, String mealId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Construct the document path for the specific meal
      DocumentReference mealRef = firestore
          .collection('users')
          .doc(uid)
          .collection('meals')
          .doc(mealId);

      // Delete the document
      await mealRef.delete();

      // Optionally, show a success message
      if (context.mounted) {
        SnackBarText().showBanner(msg: 'Meal deleted successfully', context: context);
      }
    } catch (e) {
      // Handle any errors during deletion
      debugPrint('Error deleting meal $mealId: $e');
      if (context.mounted) {
        SnackBarText().showBanner(msg: 'Failed to delete meal: ${e.toString()}', context: context);
      }
    }
  }

  Future<void> addTransaction(
    BuildContext context,
    TransactionEntity transactionEntity,
    BalanceEntity balanceEntity,
    String uid,
  ) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    try {
      String id = firestore.collection('users').doc(uid).collection('transactions').doc().id;
      transactionEntity.id = id; // Assign generated ID

      if (transactionEntity.type == 'expense') {
        balanceEntity.amount -= transactionEntity.amount;
      } else {
        balanceEntity.amount += transactionEntity.amount;
      }

      batch.set(
        firestore.collection('users').doc(uid).collection('transactions').doc(id),
        transactionEntity.toMap(),
      );

      batch.update(
        firestore.collection('users').doc(uid).collection('balance').doc('balance'),
        balanceEntity.toMap(),
      );

      await batch.commit();
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(msg: e.toString(), context: context)
          : debugPrint(e.toString());
    }
  }

  Future<void> deleteTransaction(
    BuildContext context,
    String uid,
    String transactionId,
    BalanceEntity balanceEntity,
  ) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    try {
      DocumentReference transactionRef = firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(transactionId);

      DocumentSnapshot transaction = await transactionRef.get();
      TransactionEntity transactionEntity = TransactionEntity.fromMap(
        transaction.data() as Map<String, dynamic>,
      );
      if (transactionEntity.type == 'expense') {
        balanceEntity.amount += transactionEntity.amount;
      } else {
        balanceEntity.amount -= transactionEntity.amount;
      }

      batch.delete(transactionRef);
      batch.update(
        firestore.collection('users').doc(uid).collection('balance').doc('balance'),
        balanceEntity.toMap(),
      );

      await batch.commit();

      if (context.mounted) {
        SnackBarText().showBanner(msg: 'Transaction deleted successfully', context: context);
      }
    } catch (e) {
      debugPrint('Error deleting transaction $transactionId: $e');
      if (context.mounted) {
        SnackBarText().showBanner(
          msg: 'Failed to delete transaction: ${e.toString()}',
          context: context,
        );
      }
    }
  }

  Future<BalanceEntity> getBalance(BuildContext context, String uid) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot doc =
          await firestore.collection('users').doc(uid).collection('balance').doc('balance').get();

      if (doc.exists) {
        return BalanceEntity.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        QuerySnapshot<Map<String, dynamic>> snapshot =
            await firestore.collection('users').doc(uid).collection('transactions').get();

        double totalIncome = 0;
        double totalExpenses = 0;
        if (snapshot.size != 0) {
          for (final doc in snapshot.docs) {
            final transactionData = doc.data();
            final transactionEntity = TransactionEntity.fromMap(transactionData);

            if (transactionEntity.type == 'income') {
              totalIncome += transactionEntity.amount;
            } else {
              totalExpenses += transactionEntity.amount;
            }
          }
        }

        final double netBalance = totalIncome - totalExpenses;

        BalanceEntity balanceEntity = BalanceEntity(id: 'balance', amount: netBalance);

        await firestore
            .collection('users')
            .doc(uid)
            .collection('balance')
            .doc('balance')
            .set(balanceEntity.toMap());

        return balanceEntity;
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarText().showBanner(msg: 'Failed to get balance: ${e.toString()}', context: context);
      }
    }

    return BalanceEntity(id: 'balance', amount: 0.0);
  }
}
