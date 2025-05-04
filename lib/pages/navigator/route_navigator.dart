import 'package:flutter/material.dart';
import 'package:stuff_app/pages/navigator/large_navigator.dart';
import 'package:stuff_app/pages/navigator/small_navigator.dart';
import 'package:stuff_app/states/constants.dart';

class RouteNavigator extends StatefulWidget {
  const RouteNavigator({super.key});

  @override
  State<RouteNavigator> createState() => _RouteNavigatorState();
}

class _RouteNavigatorState extends State<RouteNavigator> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return screenWidth > Constants().largeScreenWidth ? LargeNavigatorPage() : SmallNavigatorPage();
  }
}
