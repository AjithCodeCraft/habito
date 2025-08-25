import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final int currentStreak;
  final int longestStreak;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? isCompletedToday;

  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.currentStreak,
    required this.longestStreak,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.isCompletedToday,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      currentStreak: json['current_streak'] as int,
      longestStreak: json['longest_streak'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isCompletedToday: json['is_completed_today'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_completed_today': isCompletedToday,
    };
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    int? currentStreak,
    int? longestStreak,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompletedToday,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }

  String get streakText {
    if (currentStreak == 0) return 'No streak';
    if (currentStreak == 1) return '1 day streak';
    return '$currentStreak day streak';
  }

  @override
  List<Object?> get props => [
    id, userId, name, description, currentStreak, longestStreak,
    isActive, createdAt, updatedAt, isCompletedToday
  ];
}

class CreateHabit extends Equatable {
  final String name;
  final String? description;

  const CreateHabit({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [name, description];
}

class HabitCompletion extends Equatable {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completionDate;
  final DateTime createdAt;

  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completionDate,
    required this.createdAt,
  });

  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      completionDate: DateTime.parse(json['completion_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'completion_date': completionDate.toIso8601String().split('T')[0], // Date only
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, habitId, userId, completionDate, createdAt];
}