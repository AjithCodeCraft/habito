import '../config/api_config.dart';
import '../models/models.dart';
import 'http_service.dart';

class FoodService {
  // Get food entries with optional filters
  static Future<List<FoodEntry>> getFoodEntries({
    String? dateFrom,
    String? dateTo,
    MealCategory? mealCategory,
    int skip = 0,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };

    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;
    if (mealCategory != null) queryParams['meal_category'] = mealCategory.value;

    return await HttpService.getList<FoodEntry>(
      endpoint: ApiConfig.foodEntries,
      fromJson: (json) => FoodEntry.fromJson(json),
      queryParams: queryParams,
      requiresAuth: true,
    );
  }

  // Create new food entry
  static Future<FoodEntry> createFoodEntry(CreateFoodEntry entry) async {
    return await HttpService.post<FoodEntry>(
      endpoint: ApiConfig.foodEntries,
      fromJson: (json) => FoodEntry.fromJson(json),
      body: entry.toJson(),
      requiresAuth: true,
    );
  }

  // Get specific food entry
  static Future<FoodEntry> getFoodEntry(String id) async {
    return await HttpService.get<FoodEntry>(
      endpoint: '${ApiConfig.foodEntries}/$id',
      fromJson: (json) => FoodEntry.fromJson(json),
      requiresAuth: true,
    );
  }

  // Update food entry
  static Future<FoodEntry> updateFoodEntry(String id, CreateFoodEntry entry) async {
    return await HttpService.put<FoodEntry>(
      endpoint: '${ApiConfig.foodEntries}/$id',
      fromJson: (json) => FoodEntry.fromJson(json),
      body: entry.toJson(),
      requiresAuth: true,
    );
  }

  // Delete food entry
  static Future<void> deleteFoodEntry(String id) async {
    await HttpService.delete(
      endpoint: '${ApiConfig.foodEntries}/$id',
      requiresAuth: true,
    );
  }

  // Get daily summary
  static Future<DailySummary> getDailySummary({String? date}) async {
    final queryParams = <String, String>{};
    if (date != null) queryParams['target_date'] = date;

    return await HttpService.get<DailySummary>(
      endpoint: ApiConfig.foodDailySummary,
      fromJson: (json) => DailySummary.fromJson(json),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      requiresAuth: true,
    );
  }

  // Search food database
  static Future<List<Map<String, dynamic>>> searchFood(String query) async {
    final response = await HttpService.get<Map<String, dynamic>>(
      endpoint: ApiConfig.foodSearch,
      fromJson: (json) => json,
      queryParams: {'query': query},
      requiresAuth: true,
    );

    return List<Map<String, dynamic>>.from(response['results'] ?? []);
  }

  // Get food entries for a specific date
  static Future<List<FoodEntry>> getFoodEntriesForDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0]; // Get date part only
    return await getFoodEntries(
      dateFrom: dateStr,
      dateTo: dateStr,
    );
  }

  // Get food entries grouped by meal category for a date
  static Future<Map<MealCategory, List<FoodEntry>>> getFoodEntriesByMealCategory(DateTime date) async {
    final entries = await getFoodEntriesForDate(date);
    final grouped = <MealCategory, List<FoodEntry>>{};

    for (final category in MealCategory.values) {
      grouped[category] = entries.where((entry) => entry.mealCategory == category).toList();
    }

    return grouped;
  }

  // Get total calories for a date
  static Future<int> getTotalCaloriesForDate(DateTime date) async {
    final entries = await getFoodEntriesForDate(date);
    return entries.fold<int>(0, (total, entry) => total + entry.calories);
  }
}