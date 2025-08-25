import 'package:equatable/equatable.dart';

class SleepEntry extends Equatable {
  final String id;
  final String userId;
  final DateTime bedtime;
  final DateTime wakeTime;
  final double durationHours;
  final int? qualityRating;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SleepEntry({
    required this.id,
    required this.userId,
    required this.bedtime,
    required this.wakeTime,
    required this.durationHours,
    this.qualityRating,
    this.notes,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SleepEntry.fromJson(Map<String, dynamic> json) {
    return SleepEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bedtime: DateTime.parse(json['bedtime'] as String),
      wakeTime: DateTime.parse(json['wake_time'] as String),
      durationHours: (json['duration_hours'] as num).toDouble(),
      qualityRating: json['quality_rating'] as int?,
      notes: json['notes'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bedtime': bedtime.toIso8601String(),
      'wake_time': wakeTime.toIso8601String(),
      'duration_hours': durationHours,
      'quality_rating': qualityRating,
      'notes': notes,
      'date': date.toIso8601String().split('T')[0], // Date only
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    final hours = durationHours.floor();
    final minutes = ((durationHours - hours) * 60).round();
    return '${hours}h ${minutes}m';
  }

  String get qualityText {
    if (qualityRating == null) return 'Not rated';
    if (qualityRating! >= 8) return 'Excellent';
    if (qualityRating! >= 6) return 'Good';
    if (qualityRating! >= 4) return 'Fair';
    return 'Poor';
  }

  @override
  List<Object?> get props => [
    id, userId, bedtime, wakeTime, durationHours, qualityRating,
    notes, date, createdAt, updatedAt
  ];
}

class CreateSleepEntry extends Equatable {
  final DateTime bedtime;
  final DateTime wakeTime;
  final int? qualityRating;
  final String? notes;

  const CreateSleepEntry({
    required this.bedtime,
    required this.wakeTime,
    this.qualityRating,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'bedtime': bedtime.toIso8601String(),
      'wake_time': wakeTime.toIso8601String(),
      'quality_rating': qualityRating,
      'notes': notes,
    };
  }

  double get calculatedDuration {
    final duration = wakeTime.difference(bedtime);
    if (duration.isNegative) {
      // Handle case where wake time is next day
      final nextDay = wakeTime.add(const Duration(days: 1));
      return nextDay.difference(bedtime).inMinutes / 60.0;
    }
    return duration.inMinutes / 60.0;
  }

  @override
  List<Object?> get props => [bedtime, wakeTime, qualityRating, notes];
}

class WeeklySummary extends Equatable {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double averageDuration;
  final double? averageQuality;
  final int totalEntries;
  final List<Map<String, dynamic>> dailyData;

  const WeeklySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.averageDuration,
    this.averageQuality,
    required this.totalEntries,
    required this.dailyData,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      weekStart: DateTime.parse(json['week_start'] as String),
      weekEnd: DateTime.parse(json['week_end'] as String),
      averageDuration: (json['average_duration'] as num).toDouble(),
      averageQuality: json['average_quality'] != null
          ? (json['average_quality'] as num).toDouble()
          : null,
      totalEntries: json['total_entries'] as int,
      dailyData: List<Map<String, dynamic>>.from(json['daily_data'] as List),
    );
  }

  String get formattedAverageDuration {
    final hours = averageDuration.floor();
    final minutes = ((averageDuration - hours) * 60).round();
    return '${hours}h ${minutes}m';
  }

  @override
  List<Object?> get props => [
    weekStart, weekEnd, averageDuration, averageQuality, totalEntries, dailyData
  ];
}