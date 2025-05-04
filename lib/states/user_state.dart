import 'package:flutter/material.dart';
import 'package:stuff_app/entities/user/user_entity.dart';

class UserState extends ChangeNotifier {
  UserEntity userEntity = UserEntity(
    id: 'NA',
    name: 'NA',
    bio: 'NA',
    weight: 50.0,
    height: 1.65,
    targetCalories: 2000.0,
  );

  void setUserEntity({required UserEntity newUserEntity}) {
    userEntity = newUserEntity;
    notifyListeners();
  }

  void clearUserEntity() {
    userEntity = UserEntity(
      id: 'NA',
      name: 'NA',
      bio: 'NA',
      weight: 50.0,
      height: 1.65,
      targetCalories: 2000.0,
    );
    notifyListeners();
  }
}
