import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stuff_app/widgets/texts/snack_bar_text.dart';

class FBAuth {
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<bool> signUp(BuildContext context, String email, String password) async {
    try {
      return await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
            return true;
          });
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(msg: "Error during create user: $e", context: context)
          : debugPrint("Error during create user: $e");
      return false;
    }
  }

  Future<void> signIn(BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(msg: "Error during sign-in: $e", context: context)
          : debugPrint("Error during sign-in: $e");
    }
  }

  Future<void> forgotPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(msg: "Error during send reset email: $e", context: context)
          : debugPrint("Error during send reset email: $e");
    }
  }

  Future<void> verifyEmail(BuildContext context) async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(
            msg: "Error during send verification email: $e",
            context: context,
          )
          : debugPrint("Error during send verification email: $e");
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      firebaseAuth.signOut();
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(msg: "Error during sign out: $e", context: context)
          : debugPrint("Error during sign out: $e");
    }
  }
}
