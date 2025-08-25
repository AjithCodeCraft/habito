import '../config/api_config.dart';
import '../models/models.dart';
import 'http_service.dart';

class AuthService {
  // Register new user
  static Future<User> register(UserCredentials credentials) async {
    return await HttpService.post<User>(
      endpoint: ApiConfig.register,
      fromJson: (json) => User.fromJson(json),
      body: credentials.toJson(),
    );
  }

  // Login user
  static Future<AuthTokens> login(LoginCredentials credentials) async {
    return await HttpService.post<AuthTokens>(
      endpoint: ApiConfig.login,
      fromJson: (json) => AuthTokens.fromJson(json),
      body: credentials.toJson(),
    );
  }

  // Logout user
  static Future<void> logout() async {
    try {
      await HttpService.post<Map<String, dynamic>>(
        endpoint: ApiConfig.logout,
        fromJson: (json) => json,
        requiresAuth: true,
      );
    } finally {
      // Always clear tokens, even if the request fails
      await HttpService.clearTokens();
    }
  }

  // Refresh access token
  static Future<AuthTokens> refreshToken() async {
    final refreshToken = await HttpService.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    return await HttpService.post<AuthTokens>(
      endpoint: ApiConfig.refreshToken,
      fromJson: (json) => AuthTokens.fromJson(json),
      body: {'refresh_token': refreshToken},
    );
  }

  // Request password reset
  static Future<void> requestPasswordReset(String email) async {
    await HttpService.post<Map<String, dynamic>>(
      endpoint: ApiConfig.resetPassword,
      fromJson: (json) => json,
      body: {'email': email},
    );
  }

  // Confirm password reset
  static Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    await HttpService.post<Map<String, dynamic>>(
      endpoint: ApiConfig.resetPasswordConfirm,
      fromJson: (json) => json,
      body: {
        'token': token,
        'new_password': newPassword,
      },
    );
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await HttpService.getAccessToken();
    return token != null;
  }

  // Check if user is authenticated by checking token
  static Future<User?> getCurrentUser() async {
    final token = await HttpService.getAccessToken();
    if (token == null) return null;
    
    // Return a basic user object - we have the token so user is authenticated
    return User(
      id: 'current-user',
      username: 'user',
      email: 'user@example.com',
      isActive: true,
      isVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}