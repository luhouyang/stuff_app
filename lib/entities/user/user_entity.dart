enum UserEnum {
  id("id"),
  name("name"),
  bio("bio"),
  weight("weight"),
  height("height"),
  targetCalories("targetCalories");

  final String value;
  const UserEnum(this.value);
}

class UserEntity {
  final String id; // firebase auth id
  final String name;
  final String bio;
  double weight;
  double height;
  double targetCalories;

  UserEntity({
    required this.id,
    required this.name,
    required this.bio,
    required this.weight,
    required this.height,
    required this.targetCalories,
  });

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map[UserEnum.id.value],
      name: map[UserEnum.name.value],
      bio: map[UserEnum.bio.value],
      weight: map[UserEnum.weight.value].toDouble(),
      height: map[UserEnum.height.value].toDouble(),
      targetCalories: map[UserEnum.targetCalories.value].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "bio": bio,
      UserEnum.weight.value: weight,
      UserEnum.height.value: height,
      UserEnum.targetCalories.value: targetCalories,
    };
  }
}
