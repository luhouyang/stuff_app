import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stuff_app/pages/auth/verify_email.dart';
import 'package:stuff_app/pages/navigator/route_navigator.dart';
import 'package:stuff_app/services/fbstore/fb_store.dart';
import 'package:stuff_app/states/constants.dart';
import 'package:stuff_app/states/user_state.dart';
import 'package:stuff_app/widgets/loading/loading_widget_large.dart';

class RouteLoginPage extends StatefulWidget {
  const RouteLoginPage({super.key});

  @override
  State<RouteLoginPage> createState() => _RouteLoginPageState();
}

class _RouteLoginPageState extends State<RouteLoginPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > Constants().largeScreenWidth) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }

    UserState userState = Provider.of<UserState>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const RouteNavigator();
          }

          if (!snapshot.data!.emailVerified) {
            return const VerifyEmailPage();
          }

          if (userState.userEntity.id == 'NA') {
            return FutureBuilder(
              future: FBStore().getUser(context, snapshot.data!.uid, userState),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const LoadingWidgetLarge();
                } else if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const RouteNavigator();
                }

                return const RouteNavigator();
              },
            );
          }

          return const RouteNavigator();
        },
      ),
    );
  }
}
