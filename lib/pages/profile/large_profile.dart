import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stuff_app/pages/auth/large_login.dart';
import 'package:stuff_app/services/image/image_service.dart';
import 'package:stuff_app/states/app_state.dart';
import 'package:stuff_app/states/user_state.dart';

class LargeProfilePage extends StatefulWidget {
  const LargeProfilePage({super.key});

  @override
  State<LargeProfilePage> createState() => _LargeProfilePageState();
}

class _LargeProfilePageState extends State<LargeProfilePage> {
  ImageData imageData = ImageData();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, UserState>(
      builder: (context, appState, userState, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                ImageService(parentContext: context, imageData: imageData),
                LargeLoginPage(),
              ],
            ),
          ),
        );
      },
    );
  }
}
