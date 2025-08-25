import '../config/api_config.dart';
import '../models/models.dart';
import 'http_service.dart';

class SleepService {
  // Get sleep entries with optional filters
  static Future<List<SleepEntry>> getSleepEntries({
    String? dateFrom,
    String? dateTo,
    int skip = 0,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };

    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;

    return await HttpService.getList<SleepEntry>(
      endpoint: ApiConfig.sleepEntries,
      fromJson: (json) => SleepEntry.fromJson(json),
      queryParams: queryParams,
      requiresAuth: true,
    );
  }

  // Create new sleep entry
  static Future<SleepEntry> createSleepEntry(CreateSleepEntry entry) async {
    return await HttpService.post<SleepEntry>(
      endpoint: ApiConfig.sleepEntries,
      fromJson: (json) => SleepEntry.fromJson(json),
      body: entry.toJson(),
      requiresAuth: true,
    );
  }

  // Get specific sleep entry
  static Future<SleepEntry> getSleepEntry(String id) async {
    return await HttpService.get<SleepEntry>(
      endpoint: '${ApiConfig.sleepEntries}/$id',
      fromJson: (json) => SleepEntry.fromJson(json),
      requiresAuth: true,
    );
  }

  // Update sleep entry
  static Future<SleepEntry> updateSleepEntry(String id, CreateSleepEntry entry) async {
    return await HttpService.put<SleepEntry>(
      endpoint: '${ApiConfig.sleepEntries}/$id',
      fromJson: (json) => SleepEntry.fromJson(json),
      body: entry.toJson(),
      requiresAuth: true,
    );
  }

  // Delete sleep entry
  static Future<void> deleteSleepEntry(String id) async {
    await HttpService.delete(
      endpoint: '${ApiConfig.sleepEntries}/$id',
      requiresAuth: true,
    );
  }

  // Get weekly summary
  static Future<WeeklySummary> getWeeklySummary({String? startDate}) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate;

    return await HttpService.get<WeeklySummary>(
      endpoint: ApiConfig.sleepWeeklySummary,
      fromJson: (json) => WeeklySummary.fromJson(json),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      requiresAuth: true,
    );
  }

  // Get sleep entry for a specific date
  static Future<SleepEntry?> getSleepEntryForDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final entries = await getSleepEntries(
      dateFrom: dateStr,
      dateTo: dateStr,
    );
    
    return entries.isNotEmpty ? entries.first : null;
  }

  // Get sleep entries for date range
  static Future<List<SleepEntry>> getSleepEntriesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];
    
    return await getSleepEntries(
      dateFrom: startDateStr,
      dateTo: endDateStr,
    );
  }

  // Get current week sleep data
  static Future<List<SleepEntry>> getCurrentWeekSleepData() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return await getSleepEntriesForDateRange(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
  }

  // Calculate average sleep duration for a period
  static Future<double> getAverageSleepDuration({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final entries = await getSleepEntriesForDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    if (entries.isEmpty) return 0.0;

    final totalHours = entries.fold(0.0, (sum, entry) => sum + entry.durationHours);
    return totalHours / entries.length;
  }

  // Get sleep quality trends
  static Future<Map<String, dynamic>> getSleepQualityTrends({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final entries = await getSleepEntriesForDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    final entriesWithQuality = entries.where((e) => e.qualityRating != null).toList();
    
    if (entriesWithQuality.isEmpty) {
      return {
        'averageQuality': null,
        'qualityTrend': [],
        'totalEntries': entries.length,
      };
    }

    final totalQuality = entriesWithQuality.fold(0, (sum, entry) => sum + entry.qualityRating!);
    final averageQuality = totalQuality / entriesWithQuality.length;

    return {
      'averageQuality': averageQuality,
      'qualityTrend': entriesWithQuality.map((e) => {
        'date': e.date.toIso8601String().split('T')[0],
        'quality': e.qualityRating,
      }).toList(),
      'totalEntries': entries.length,
    };
  }
}