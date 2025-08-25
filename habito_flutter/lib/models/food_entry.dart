import 'package:equatable/equatable.dart';

enum MealCategory {
  breakfast('BREAKFAST'),
  lunch('LUNCH'),
  dinner('DINNER'),
  snack('SNACK');

  const MealCategory(this.value);
  final String value;

  static MealCategory fromString(String value) {
    return MealCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => MealCategory.breakfast,
    );
  }

  String get displayName {
    switch (this) {
      case MealCategory.breakfast:
        return 'Breakfast';
      case MealCategory.lunch:
        return 'Lunch';
      case MealCategory.dinner:
        return 'Dinner';
      case MealCategory.snack:
        return 'Snack';
    }
  }
}

class NutritionalInfo extends Equatable {
  final double? carbs;
  final double? protein;
  final double? fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;

  const NutritionalInfo({
    this.carbs,
    this.protein,
    this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
  });

  factory NutritionalInfo.fromJson(Map<String, dynamic> json) {
    return NutritionalInfo(
      carbs: json['carbs']?.toDouble(),
      protein: json['protein']?.toDouble(),
      fat: json['fat']?.toDouble(),
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
    };
  }

  @override
  List<Object?> get props => [carbs, protein, fat, fiber, sugar, sodium];
}

class FoodEntry extends Equatable {
  final String id;
  final String userId;
  final String foodName;
  final double quantity;
  final int calories;
  final MealCategory mealCategory;
  final NutritionalInfo? nutritionalInfo;
  final DateTime loggedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodEntry({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.quantity,
    required this.calories,
    required this.mealCategory,
    this.nutritionalInfo,
    required this.loggedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      foodName: json['food_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      calories: json['calories'] as int,
      mealCategory: MealCategory.fromString(json['meal_category'] as String),
      nutritionalInfo: json['nutritional_info'] != null
          ? NutritionalInfo.fromJson(json['nutritional_info'] as Map<String, dynamic>)
          : null,
      loggedAt: DateTime.parse(json['logged_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'food_name': foodName,
      'quantity': quantity,
      'calories': calories,
      'meal_category': mealCategory.value,
      'nutritional_info': nutritionalInfo?.toJson(),
      'logged_at': loggedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id, userId, foodName, quantity, calories, mealCategory,
    nutritionalInfo, loggedAt, createdAt, updatedAt
  ];
}

class CreateFoodEntry extends Equatable {
  final String foodName;
  final double quantity;
  final int calories;
  final MealCategory mealCategory;
  final NutritionalInfo? nutritionalInfo;
  final DateTime? loggedAt;

  const CreateFoodEntry({
    required this.foodName,
    required this.quantity,
    required this.calories,
    required this.mealCategory,
    this.nutritionalInfo,
    this.loggedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'quantity': quantity,
      'calories': calories,
      'meal_category': mealCategory.value,
      'nutritional_info': nutritionalInfo?.toJson(),
      'logged_at': loggedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [foodName, quantity, calories, mealCategory, nutritionalInfo, loggedAt];
}

class DailySummary extends Equatable {
  final String date;
  final int totalCalories;
  final Map<String, int> mealBreakdown;
  final int entriesCount;
  final Map<String, double> nutritionalSummary;

  const DailySummary({
    required this.date,
    required this.totalCalories,
    required this.mealBreakdown,
    required this.entriesCount,
    required this.nutritionalSummary,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: json['date'] as String,
      totalCalories: json['total_calories'] as int,
      mealBreakdown: Map<String, int>.from(json['meal_breakdown'] as Map),
      entriesCount: json['entries_count'] as int,
      nutritionalSummary: Map<String, double>.from(
        (json['nutritional_summary'] as Map).map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
    );
  }

  @override
  List<Object?> get props => [date, totalCalories, mealBreakdown, entriesCount, nutritionalSummary];
}