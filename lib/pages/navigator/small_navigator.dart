import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stuff_app/pages/about/small_about.dart';
import 'package:stuff_app/pages/home/small_home.dart';
import 'package:stuff_app/pages/misc/small_misc.dart';
import 'package:stuff_app/pages/money/small_money.dart';
import 'package:stuff_app/pages/nutrition/small_nutrition.dart';
import 'package:stuff_app/pages/profile/small_profile.dart';
import 'package:stuff_app/states/app_state.dart';
import 'package:stuff_app/states/user_state.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class SmallNavigatorPage extends StatefulWidget {
  const SmallNavigatorPage({super.key});

  @override
  State<SmallNavigatorPage> createState() => _SmallNavigatorPageState();
}

class _SmallNavigatorPageState extends State<SmallNavigatorPage> {
  final iconListAuth = <IconData>[
    Icons.home_outlined,
    Icons.miscellaneous_services_outlined,
    Icons.person_outline,
    Icons.food_bank_outlined,
    Icons.attach_money_outlined,
  ];

  final iconListNormal = <IconData>[
    Icons.home_outlined,
    Icons.miscellaneous_services_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, UserState>(
      builder: (context, appState, userState, child) {
        bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

        List<IconData> iconList = isLoggedIn ? iconListAuth : iconListNormal;

        Widget getPage(int index) {
          if (isLoggedIn) {
            if (index == 0) {
              return const SmallHomePage();
            } else if (index == 1) {
              return const SmallMiscPage();
            } else if (index == 2) {
              return const SmallProfilePage();
            } else if (index == 3) {
              return const SmallNutritionPage();
            } else if (index == 4) {
              return const SmallMoneyPage();
            }
          } else {
            if (index == 0) {
              return const SmallHomePage();
            } else if (index == 1) {
              return const SmallMiscPage();
            } else if (index == 2) {
              return const SmallProfilePage();
            }
          }
          return const SmallHomePage();
        }

        return Scaffold(
          body: Column(
            children: [
              if (!kIsWeb) const SizedBox(height: 36),
              SizedBox(
                height: 54,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      Image.asset('assets/profile_placeholder.jpg'),
                      const SizedBox(width: 12),
                      Text("Stuff App", style: Theme.of(context).textTheme.displayMedium),
                      const Expanded(child: SizedBox()),
                      appState.isDarkMode
                          ? IconButton(
                            onPressed: () {
                              AdaptiveTheme.of(context).setLight();
                              appState.setDarkMode(false);
                            },
                            icon: const Icon(Icons.light_mode_outlined),
                          )
                          : IconButton(
                            onPressed: () {
                              AdaptiveTheme.of(context).setDark();
                              setState(() {
                                appState.setDarkMode(true);
                              });
                            },
                            icon: const Icon(Icons.dark_mode_outlined),
                          ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: (context) => SmallAboutPage()));
                        },
                        icon: const Icon(Icons.info_outline),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: getPage(appState.bottomNavIndex)),
            ],
          ),
          bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            itemCount: iconList.length,
            tabBuilder: (int index, bool isActive) {
              final color = isActive ? Theme.of(context).iconTheme.color : UIColor().gray;

              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(iconList[index], size: 24, color: color)],
              );
            },
            backgroundColor: UIColor().mediumGray,
            activeIndex: appState.bottomNavIndex,
            splashColor: UIColor().celeste,
            gapLocation: GapLocation.none,
            onTap: (index) => appState.setBottomNavIndex(index),
          ),
        );
      },
    );
  }
}
