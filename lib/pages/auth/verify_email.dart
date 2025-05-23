import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stuff_app/entities/user/user_entity.dart';
import 'package:stuff_app/services/auth/fb_auth.dart';
import 'package:stuff_app/states/constants.dart';
import 'package:stuff_app/states/user_state.dart';
import 'package:stuff_app/widgets/texts/h1_text.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding:
            screenWidth > Constants().largeScreenWidth
                ? EdgeInsets.fromLTRB(screenWidth * 0.2, screenHeight * 0.4, screenWidth * 0.2, 0)
                : EdgeInsets.fromLTRB(screenWidth * 0.1, screenHeight * 0.4, screenWidth * 0.1, 0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const H1Text(text: "Verify Your Email.\nLogout after verifying."),
              const SizedBox(height: 28),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            screenWidth > Constants().largeScreenWidth
                                ? const EdgeInsets.all(16)
                                : const EdgeInsets.all(14),
                      ),
                      onPressed: () async {
                        await FBAuth().verifyEmail(context);
                      },
                      child: Text(
                        "RESEND VERIFICATION",
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium!.copyWith(color: UIColor().darkGray),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            screenWidth > Constants().largeScreenWidth
                                ? const EdgeInsets.all(16)
                                : const EdgeInsets.all(14),
                        foregroundColor: UIColor().whiteSmoke,
                        backgroundColor: UIColor().scarlet,
                        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        UserState userState = Provider.of<UserState>(context, listen: false);
                        userState.setUserEntity(
                          newUserEntity: UserEntity(
                            id: 'NA',
                            name: 'NA',
                            bio: 'NA',
                            weight: 40,
                            height: 1.65,
                            targetCalories: 2000.0,
                            storageAllowance: 209715200.0,
                            storageUsed: 0.0,
                          ),
                        );

                        await FBAuth().logout(context);
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
