import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/services.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _clearError();
      _setLoading(true);

      final loginData = LoginCredentials(email: email, password: password);
      final tokens = await AuthService.login(loginData);

      await _saveTokens(tokens.accessToken, tokens.refreshToken);
      
      // Create a basic user object from login - we don't need getCurrentUser call
      _user = User(
        id: 'temp-id',
        username: 'user',
        email: email,
        isActive: true,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _isAuthenticated = true;

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _clearError();
      _setLoading(true);

      final registerData = UserCredentials(
        username: username,
        email: email,
        password: password,
      );
      _user = await AuthService.register(registerData);
      
      // Now login to get tokens
      final loginData = LoginCredentials(email: email, password: password);
      final tokens = await AuthService.login(loginData);
      await _saveTokens(tokens.accessToken, tokens.refreshToken);
      _isAuthenticated = true;

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
    } catch (e) {
      // Ignore logout errors and proceed with local cleanup
    } finally {
      await _clearTokens();
      _user = null;
      _isAuthenticated = false;
      _clearError();
      notifyListeners();
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      if (accessToken == null) {
        return false;
      }

      // Just create a basic user since token exists
      _user = User(
        id: 'temp-id',
        username: 'user',
        email: 'user@example.com',
        isActive: true,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      // Token is invalid, clear it
      await _clearTokens();
      return false;
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) {
        await logout();
        return false;
      }

      final tokens = await AuthService.refreshToken();
      await _saveTokens(tokens.accessToken, tokens.refreshToken);
      
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<void> updateProfile({
    String? username,
    String? email,
  }) async {
    // Placeholder - would need backend /me/update endpoint
    throw UnimplementedError('updateProfile not implemented yet');
  }

  void clearError() {
    _clearError();
  }
}