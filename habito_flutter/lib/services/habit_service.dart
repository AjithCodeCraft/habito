import '../config/api_config.dart';
import '../models/models.dart';
import 'http_service.dart';

class HabitService {
  // Get habits with optional filters
  static Future<List<Habit>> getHabits({bool? isActive}) async {
    final queryParams = <String, String>{};
    if (isActive != null) queryParams['is_active'] = isActive.toString();

    return await HttpService.getList<Habit>(
      endpoint: ApiConfig.habits,
      fromJson: (json) => Habit.fromJson(json),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      requiresAuth: true,
    );
  }

  // Create new habit
  static Future<Habit> createHabit(CreateHabit habit) async {
    return await HttpService.post<Habit>(
      endpoint: ApiConfig.habits,
      fromJson: (json) => Habit.fromJson(json),
      body: habit.toJson(),
      requiresAuth: true,
    );
  }

  // Get specific habit
  static Future<Habit> getHabit(String id) async {
    return await HttpService.get<Habit>(
      endpoint: '${ApiConfig.habits}/$id',
      fromJson: (json) => Habit.fromJson(json),
      requiresAuth: true,
    );
  }

  // Update habit
  static Future<Habit> updateHabit(String id, CreateHabit habit) async {
    return await HttpService.put<Habit>(
      endpoint: '${ApiConfig.habits}/$id',
      fromJson: (json) => Habit.fromJson(json),
      body: habit.toJson(),
      requiresAuth: true,
    );
  }

  // Delete habit
  static Future<void> deleteHabit(String id) async {
    await HttpService.delete(
      endpoint: '${ApiConfig.habits}/$id',
      requiresAuth: true,
    );
  }

  // Mark habit as complete
  static Future<HabitCompletion> completeHabit(String habitId, {DateTime? date}) async {
    final body = <String, dynamic>{
      'habit_id': habitId,
    };
    
    if (date != null) {
      body['completion_date'] = date.toIso8601String().split('T')[0];
    }

    return await HttpService.post<HabitCompletion>(
      endpoint: '${ApiConfig.habits}/$habitId/complete',
      fromJson: (json) => HabitCompletion.fromJson(json),
      body: body,
      requiresAuth: true,
    );
  }

  // Remove habit completion
  static Future<void> uncompleteHabit(String habitId, {DateTime? date}) async {
    String endpoint = '${ApiConfig.habits}/$habitId/complete';
    
    if (date != null) {
      final dateStr = date.toIso8601String().split('T')[0];
      endpoint += '?completion_date=$dateStr';
    }

    await HttpService.delete(
      endpoint: endpoint,
      requiresAuth: true,
    );
  }

  // Get active habits
  static Future<List<Habit>> getActiveHabits() async {
    return await getHabits(isActive: true);
  }

  // Get inactive habits
  static Future<List<Habit>> getInactiveHabits() async {
    return await getHabits(isActive: false);
  }

  // Toggle habit completion for today
  static Future<Habit> toggleHabitCompletion(Habit habit) async {
    if (habit.isCompletedToday == true) {
      await uncompleteHabit(habit.id);
      return habit.copyWith(isCompletedToday: false);
    } else {
      await completeHabit(habit.id);
      return habit.copyWith(
        isCompletedToday: true,
        currentStreak: habit.currentStreak + 1,
      );
    }
  }

  // Activate/Deactivate habit
  static Future<Habit> toggleHabitActive(String habitId, bool isActive) async {
    return await HttpService.put<Habit>(
      endpoint: '${ApiConfig.habits}/$habitId',
      fromJson: (json) => Habit.fromJson(json),
      body: {'is_active': isActive},
      requiresAuth: true,
    );
  }

  // Get habits completion statistics
  static Future<Map<String, dynamic>> getHabitStatistics(String habitId) async {
    // Note: This would require additional backend endpoints for statistics
    // For now, we'll calculate basic stats from the habit data
    final habit = await getHabit(habitId);
    
    return {
      'currentStreak': habit.currentStreak,
      'longestStreak': habit.longestStreak,
      'isCompletedToday': habit.isCompletedToday ?? false,
      'isActive': habit.isActive,
    };
  }

  // Check if user can create more habits (max 3 active)
  static Future<bool> canCreateMoreHabits() async {
    final activeHabits = await getActiveHabits();
    return activeHabits.length < 3;
  }

  // Get habit completion rate (would need additional backend support)
  static Future<double> getHabitCompletionRate(String habitId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // This is a placeholder - would need backend support for detailed completion history
    final habit = await getHabit(habitId);
    
    // Simple calculation based on current streak vs days since creation
    final daysSinceCreation = DateTime.now().difference(habit.createdAt).inDays + 1;
    if (daysSinceCreation <= 0) return 0.0;
    
    return habit.currentStreak / daysSinceCreation;
  }
}