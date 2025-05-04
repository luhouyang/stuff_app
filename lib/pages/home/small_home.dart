import 'package:flutter/material.dart';
import 'package:stuff_app/widgets/texts/h1_text.dart';

class SmallHomePage extends StatefulWidget {
  const SmallHomePage({super.key});

  @override
  State<SmallHomePage> createState() => _SmallHomePageState();
}

class _SmallHomePageState extends State<SmallHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      // SingleChildScrollView(
      //   child: Column(
      //     children: [Text('All In One App')],
      //   ),
      // ),
      Center(child: H1Text(text: 'All In One App')),
    );
  }
}
