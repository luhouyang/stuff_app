import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stuff_app/entities/user/user_entity.dart';
import 'package:stuff_app/pages/auth/small_login.dart';
import 'package:stuff_app/services/fbstore/fb_store.dart';
import 'package:stuff_app/services/image/image_service.dart';
import 'package:stuff_app/states/app_state.dart';
import 'package:stuff_app/states/user_state.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class SmallProfilePage extends StatefulWidget {
  const SmallProfilePage({super.key});

  @override
  State<SmallProfilePage> createState() => _SmallProfilePageState();
}

class _SmallProfilePageState extends State<SmallProfilePage> {
  ImageData imageData = ImageData();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _targetCaloriesController;

  @override
  void initState() {
    super.initState();
    UserState userState = Provider.of<UserState>(context, listen: false);
    _nameController = TextEditingController(text: userState.userEntity.name);
    _bioController = TextEditingController(text: userState.userEntity.bio);
    _weightController = TextEditingController(text: userState.userEntity.weight.toString());
    _heightController = TextEditingController(text: userState.userEntity.height.toString());
    _targetCaloriesController = TextEditingController(
      text: userState.userEntity.targetCalories.toString(),
    );
  }

  Future<void> _updateUserProfile(UserState userState) async {
    if (_formKey.currentState!.validate()) {
      UserEntity updatedUser = UserEntity(
        id: userState.userEntity.id,
        name: _nameController.text,
        bio: _bioController.text,
        weight: double.tryParse(_weightController.text) ?? userState.userEntity.weight,
        height: double.tryParse(_heightController.text) ?? userState.userEntity.height,
        targetCalories:
            double.tryParse(_targetCaloriesController.text) ?? userState.userEntity.targetCalories,
        storageAllowance: userState.userEntity.storageAllowance,
        storageUsed: userState.userEntity.storageUsed,
      );

      userState.setUserEntity(newUserEntity: updatedUser);

      try {
        await FBStore().updateUserEntity(context, updatedUser); // Call the new function
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, UserState>(
      builder: (context, appState, userState, child) {
        _nameController = TextEditingController(text: userState.userEntity.name);
        _bioController = TextEditingController(text: userState.userEntity.bio);
        _weightController = TextEditingController(text: userState.userEntity.weight.toString());
        _heightController = TextEditingController(text: userState.userEntity.height.toString());
        _targetCaloriesController = TextEditingController(
          text: userState.userEntity.targetCalories.toString(),
        );

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // const SizedBox(height: 8),
                  // ImageService(parentContext: context, imageData: imageData),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height (m)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetCaloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Calories',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your target calories';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateUserProfile(userState),
                          child: Text(
                            'Save Changes',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium!.copyWith(color: UIColor().darkGray),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 32),
                  // Text(
                  //   "Storage Allowance | ${userState.userEntity.storageUsed / userState.userEntity.storageAllowance}% of ${userState.userEntity.storageAllowance / 1024.0 / 1024.0} MB",
                  //   style: TextStyle(fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 8),
                  // LinearProgressIndicator(
                  //   value: min(
                  //     userState.userEntity.storageUsed / userState.userEntity.storageAllowance,
                  //     1.0,
                  //   ),
                  //   minHeight: 8,
                  //   backgroundColor: Colors.grey[200],
                  //   valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  // ),
                  const SizedBox(height: 16),
                  SmallLoginPage(), // Added the login page here
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
