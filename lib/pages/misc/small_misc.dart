import 'package:flutter/material.dart';
import 'package:stuff_app/pages/misc/miniapps/counter_v2.dart';
import 'package:stuff_app/pages/misc/miniapps/lock_in_timer.dart';
import 'package:stuff_app/pages/misc/miniapps/qrgen.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class SmallMiscPage extends StatefulWidget {
  const SmallMiscPage({super.key});

  @override
  State<SmallMiscPage> createState() => _SmallMiscPageState();
}

class _SmallMiscPageState extends State<SmallMiscPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            children: [
              InkWell(
                onTap:
                    () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => CounterScreen())),
                onHover: (value) {},
                child: Container(
                  decoration: BoxDecoration(
                    color: UIColor().springGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.punch_clock_outlined, color: UIColor().darkGray, size: 50),
                      Text('COUNTER', style: TextStyle(color: UIColor().darkGray)),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap:
                    () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => LockInTimerScreen())),
                onHover: (value) {},
                child: Container(
                  decoration: BoxDecoration(
                    color: UIColor().springGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove_red_eye_outlined, color: UIColor().darkGray, size: 50),
                      Text('LOCK IN', style: TextStyle(color: UIColor().darkGray)),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap:
                    () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => QRGeneratorPage())),
                onHover: (value) {},
                child: Container(
                  decoration: BoxDecoration(
                    color: UIColor().springGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_outlined, color: UIColor().darkGray, size: 50),
                      Text('QR GEN', style: TextStyle(color: UIColor().darkGray)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
