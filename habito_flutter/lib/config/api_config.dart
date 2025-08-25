class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = '/api/v1';
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  // Authentication endpoints
  static const String register = '$apiBaseUrl/auth/register';
  static const String login = '$apiBaseUrl/auth/login';
  static const String refreshToken = '$apiBaseUrl/auth/refresh-token';
  static const String logout = '$apiBaseUrl/auth/logout';
  static const String resetPassword = '$apiBaseUrl/auth/reset-password';
  static const String resetPasswordConfirm = '$apiBaseUrl/auth/reset-password/confirm';

  // Food tracking endpoints
  static const String foodEntries = '$apiBaseUrl/food/entries';
  static const String foodSearch = '$apiBaseUrl/food/search';
  static const String foodDailySummary = '$apiBaseUrl/food/daily-summary';

  // Sleep tracking endpoints
  static const String sleepEntries = '$apiBaseUrl/sleep/entries';
  static const String sleepWeeklySummary = '$apiBaseUrl/sleep/weekly-summary';

  // Habits endpoints
  static const String habits = '$apiBaseUrl/habits';

  // Todos endpoints
  static const String todos = '$apiBaseUrl/todos';

  // Request timeout
  static const Duration timeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}