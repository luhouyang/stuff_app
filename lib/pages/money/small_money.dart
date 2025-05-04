import 'package:flutter/material.dart';
import 'package:stuff_app/widgets/texts/h1_text.dart';

class SmallMoneyPage extends StatefulWidget {
  const SmallMoneyPage({super.key});

  @override
  State<SmallMoneyPage> createState() => _SmallMoneyPageState();
}

class _SmallMoneyPageState extends State<SmallMoneyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      // SingleChildScrollView(
      //   child: Center(
      //     child: Text('UPCOMING!'),
      //   ),
      // ),
      Center(child: H1Text(text: 'UPCOMING!')),
    );
  }
}
