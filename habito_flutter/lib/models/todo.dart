import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final int priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Todo({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.priority,
    required this.isCompleted,
    this.completedAt,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: json['priority'] as int,
      isCompleted: json['is_completed'] as bool,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'priority': priority,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Todo copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    int? priority,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get priorityText {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isDueSoon {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return dueDate!.isBefore(tomorrow) && dueDate!.isAfter(now);
  }

  @override
  List<Object?> get props => [
    id, userId, title, description, priority, isCompleted,
    completedAt, dueDate, createdAt, updatedAt
  ];
}

class CreateTodo extends Equatable {
  final String title;
  final String? description;
  final int priority;
  final DateTime? dueDate;

  const CreateTodo({
    required this.title,
    this.description,
    required this.priority,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [title, description, priority, dueDate];
}

class UpdateTodo extends Equatable {
  final String? title;
  final String? description;
  final int? priority;
  final bool? isCompleted;
  final DateTime? dueDate;

  const UpdateTodo({
    this.title,
    this.description,
    this.priority,
    this.isCompleted,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (priority != null) json['priority'] = priority;
    if (isCompleted != null) json['is_completed'] = isCompleted;
    if (dueDate != null) json['due_date'] = dueDate!.toIso8601String();
    return json;
  }

  @override
  List<Object?> get props => [title, description, priority, isCompleted, dueDate];
}