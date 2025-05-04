import 'package:cloud_firestore/cloud_firestore.dart';

enum NutritionEnum {
  id("id"),
  data("data"), // Top-level key for the entire nutrition information
  components("components"),
  name("name"),
  quantity("quantity"),
  calories("calories"),
  protein("protein"),
  fat("fat"),
  carbohydrates("carbohydrates"),
  fiber("dietary_fiber"),
  valueKey("value"), // Renamed instance member
  unit("unit"),
  type("type"),
  totals("totals"),
  year("year"),
  month("month"),
  day("day"),
  meal("meal"),
  createdAt("createdAt");

  final String key; // Renamed to 'key' to avoid conflict
  const NutritionEnum(this.key);

  // Optional: Add a getter for clarity if you use 'value' often elsewhere
  String get value => key;
}

class NutritionEntity {
  String id;
  final Map<String, dynamic> data;
  int year;
  int month;
  int day;
  String meal;
  Timestamp createdAt;

  NutritionEntity({
    required this.id,
    required this.data,
    required this.createdAt,
    required this.meal,
    required this.year,
    required this.month,
    required this.day,
  });

  factory NutritionEntity.fromMap(Map<String, dynamic> map) {
    Timestamp timestamp = map[NutritionEnum.createdAt.key] as Timestamp? ?? Timestamp.now();
    DateTime dateTime = timestamp.toDate();

    return NutritionEntity(
      id: map[NutritionEnum.id.key] as String? ?? '',
      data: map[NutritionEnum.data.key] as Map<String, dynamic>? ?? {},
      meal: map[NutritionEnum.meal.key] as String? ?? '',
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
      createdAt: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      NutritionEnum.id.key: id,
      NutritionEnum.data.key: data,
      NutritionEnum.createdAt.key: createdAt,
      NutritionEnum.meal.key: meal,
      NutritionEnum.year.key: year,
      NutritionEnum.month.key: month,
      NutritionEnum.day.key: day,
    };
  }

  // Helper method to access specific nutrition details
  List<Map<String, dynamic>>? get components {
    final dataMap = data[NutritionEnum.data.key] as Map<String, dynamic>?;
    final componentsData = dataMap?[NutritionEnum.components.key];
    if (componentsData is List) {
      return componentsData.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Map<String, dynamic>? get totals =>
      data[NutritionEnum.data.key]?[NutritionEnum.totals.key] as Map<String, dynamic>?;

  // Helper method to get a specific component by name
  Map<String, dynamic>? getComponentByName(String name) {
    final componentList = components;
    if (componentList != null) {
      return componentList.firstWhere(
        (component) => component[NutritionEnum.name.key] == name,
        orElse: () => {},
      );
    }
    return null;
  }

  // Helper method to get the total calories
  // Helper method to get the total calories
  double? get totalCalories {
    final value = totals?[NutritionEnum.calories.key]?[NutritionEnum.valueKey.key];
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    }
    return null;
  }

  // Helper method to get the total protein
  double? get totalProtein {
    final value = totals?[NutritionEnum.protein.key]?[NutritionEnum.valueKey.key];
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    }
    return null;
  }

  // Helper method to get the total fat
  double? get totalFat {
    final value = totals?[NutritionEnum.fat.key]?[NutritionEnum.valueKey.key];
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    }
    return null;
  }

  // Helper method to get the total carbohydrates
  double? get totalCarbohydrates {
    final value = totals?[NutritionEnum.carbohydrates.key]?[NutritionEnum.valueKey.key];
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    }
    return null;
  }

  // Helper method to get the total fiber
  double? get totalFiber {
    final value = totals?[NutritionEnum.fiber.key]?[NutritionEnum.valueKey.key];
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    }
    return null;
  }

  // Helper method to get calories for a specific component
  double? getComponentCalories(String name) {
    final component = getComponentByName(name);
    if (component != null && component.isNotEmpty) {
      final value = component[NutritionEnum.calories.key]?[NutritionEnum.valueKey.key];
      if (value is int) {
        return value.toDouble();
      } else if (value is double) {
        return value;
      }
    }
    return null;
  }

  // Helper method to get protein for a specific component
  double? getComponentProtein(String name) {
    final component = getComponentByName(name);
    if (component != null && component.isNotEmpty) {
      final value = component[NutritionEnum.protein.key]?[NutritionEnum.valueKey.key];
      if (value is int) {
        return value.toDouble();
      } else if (value is double) {
        return value;
      }
    }
    return null;
  }

  // Helper method to get fat for a specific component
  double? getComponentFat(String name) {
    final component = getComponentByName(name);
    if (component != null && component.isNotEmpty) {
      final value = component[NutritionEnum.fat.key]?[NutritionEnum.valueKey.key];
      if (value is int) {
        return value.toDouble();
      } else if (value is double) {
        return value;
      }
    }
    return null;
  }

  // Helper method to get carbohydrates for a specific component
  double? getComponentCarbohydrates(String name) {
    final component = getComponentByName(name);
    if (component != null && component.isNotEmpty) {
      final value = component[NutritionEnum.carbohydrates.key]?[NutritionEnum.valueKey.key];
      if (value is int) {
        return value.toDouble();
      } else if (value is double) {
        return value;
      }
    }
    return null;
  }

  // Helper method to get fiber for a specific component
  double? getComponentFiber(String name) {
    final component = getComponentByName(name);
    if (component != null && component.isNotEmpty) {
      final value = component[NutritionEnum.fiber.key]?[NutritionEnum.valueKey.key];
      if (value is int) {
        return value.toDouble();
      } else if (value is double) {
        return value;
      }
    }
    return null;
  }
}
