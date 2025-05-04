import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stuff_app/services/auth/fb_auth.dart';
import 'package:stuff_app/states/user_state.dart';
import 'package:stuff_app/widgets/fields/text_input.dart';
import 'package:stuff_app/widgets/loading/loading_widget.dart';
import 'package:stuff_app/widgets/texts/snack_bar_text.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class LargeLoginPage extends StatefulWidget {
  const LargeLoginPage({super.key});

  @override
  State<LargeLoginPage> createState() => _LargeLoginPageState();
}

class _LargeLoginPageState extends State<LargeLoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  TextInputs textInputs = TextInputs();
  FBAuth fbAuth = FBAuth();
  SnackBarText snackBarText = SnackBarText();

  TextEditingController inEmailTextController = TextEditingController();
  TextEditingController inPassTextController = TextEditingController();

  TextEditingController upEmailTextController = TextEditingController();
  TextEditingController upPassTextController = TextEditingController();

  bool _isLogin = true;
  bool _hidePassword = true;

  void setShowPasword() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  bool getShowPassword() {
    return _hidePassword;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
      builder: (context, userState, child) {
        bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child:
                isLoggedIn
                    ? Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(16))),
                            onPressed: () async {
                              snackBarText.showBanner(msg: "Logout", context: context);

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return LoadingWidget().circularLoadingWidget(context);
                                },
                              );

                              inEmailTextController.clear();
                              inPassTextController.clear();
                              upEmailTextController.clear();
                              upPassTextController.clear();

                              await fbAuth.logout(context);

                              if (context.mounted) {
                                Navigator.of(context).pop();

                                userState.clearUserEntity();

                                setState(() {});
                              }
                            },
                            child: Text(
                              "LOGOUT",
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium!.copyWith(color: UIColor().darkGray),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _isLogin
                            ? Form(
                              key: _loginFormKey,
                              child: Column(
                                children: [
                                  textInputs.inputTextWidget(
                                    hint: "email",
                                    validator: textInputs.emailVerify,
                                    controller: inEmailTextController,
                                  ),
                                  textInputs.obscureInputTextWidget(
                                    hint: "password",
                                    validator: textInputs.passwordVerify,
                                    controller: inPassTextController,
                                    getFunc: getShowPassword,
                                    setFunc: setShowPasword,
                                  ),
                                  forgotPasswordWidget(),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
                                          ),
                                          onPressed: () async {
                                            if (_loginFormKey.currentState!.validate()) {
                                              snackBarText.showBanner(
                                                msg: "Logging In",
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

                                              await fbAuth.signIn(
                                                context,
                                                inEmailTextController.text.trim(),
                                                inPassTextController.text.trim(),
                                              );

                                              inEmailTextController.clear();
                                              inPassTextController.clear();
                                              upEmailTextController.clear();
                                              upPassTextController.clear();

                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                                setState(() {});
                                              }
                                            }
                                          },
                                          child: Text(
                                            "LOGIN",
                                            style: Theme.of(context).textTheme.headlineMedium!
                                                .copyWith(color: UIColor().darkGray),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  createNewAccountText(),
                                ],
                              ),
                            )
                            : Form(
                              key: _signUpFormKey,
                              child: Column(
                                children: [
                                  textInputs.inputTextWidget(
                                    hint: "email",
                                    validator: textInputs.emailVerify,
                                    controller: upEmailTextController,
                                  ),
                                  textInputs.obscureInputTextWidget(
                                    hint: "password",
                                    validator: textInputs.passwordVerify,
                                    controller: upPassTextController,
                                    getFunc: getShowPassword,
                                    setFunc: setShowPasword,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
                                          ),
                                          onPressed: () async {
                                            if (_signUpFormKey.currentState!.validate()) {
                                              snackBarText.showBanner(
                                                msg: "Creating Account",
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
                                              bool successful = false;

                                              await fbAuth
                                                  .signUp(
                                                    context,
                                                    upEmailTextController.text.trim(),
                                                    upPassTextController.text.trim(),
                                                  )
                                                  .then((value) {
                                                    successful = value;
                                                  });

                                              inEmailTextController.clear();
                                              inPassTextController.clear();
                                              upEmailTextController.clear();
                                              upPassTextController.clear();

                                              if (context.mounted) {
                                                Navigator.of(context).pop();

                                                if (successful) {
                                                  fbAuth.verifyEmail(context);
                                                }

                                                setState(() {});
                                              }
                                            }
                                          },
                                          child: Text(
                                            "SIGN UP",
                                            style: Theme.of(context).textTheme.headlineMedium!
                                                .copyWith(color: UIColor().darkGray),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  loginWithAccountText(),
                                ],
                              ),
                            ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Widget forgotPasswordWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RichText(
            text: TextSpan(
              text: "forgot password?",
              style: Theme.of(context).textTheme.labelLarge,
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () async {
                      if (inEmailTextController.text.isNotEmpty) {
                        fbAuth.forgotPassword(context, inEmailTextController.text.trim());
                      } else {
                        snackBarText.showBanner(msg: "Enter your email", context: context);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget createNewAccountText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: <TextSpan>[
            TextSpan(text: "Create a new account ", style: Theme.of(context).textTheme.bodyMedium),
            TextSpan(
              text: "Here",
              style: Theme.of(context).textTheme.labelLarge,
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () {
                      _isLogin = !_isLogin;
                      setState(() {});
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget loginWithAccountText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: <TextSpan>[
            TextSpan(
              text: "Already have an account? ",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextSpan(
              text: "Login",
              style: Theme.of(context).textTheme.labelLarge,
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () {
                      _isLogin = !_isLogin;
                      setState(() {});
                    },
            ),
          ],
        ),
      ),
    );
  }
}
