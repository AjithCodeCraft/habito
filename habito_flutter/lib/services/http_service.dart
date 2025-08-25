import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/models.dart';

class HttpService {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  static Future<http.Response> _makeRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = false,
  }) async {
    try {
      // Add auth header if required
      Map<String, String> finalHeaders = headers ?? ApiConfig.defaultHeaders;
      
      if (requiresAuth) {
        final token = await getAccessToken();
        if (token != null) {
          finalHeaders = {...finalHeaders, ...ApiConfig.getAuthHeaders(token)};
        }
      }

      final uri = Uri.parse(url);
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: finalHeaders).timeout(ApiConfig.timeout);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: finalHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(ApiConfig.timeout);
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: finalHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(ApiConfig.timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: finalHeaders).timeout(ApiConfig.timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Handle token refresh if unauthorized
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          // Retry the original request with new token
          final newToken = await getAccessToken();
          if (newToken != null) {
            finalHeaders = {...finalHeaders, ...ApiConfig.getAuthHeaders(newToken)};
            
            switch (method.toUpperCase()) {
              case 'GET':
                response = await http.get(uri, headers: finalHeaders).timeout(ApiConfig.timeout);
                break;
              case 'POST':
                response = await http.post(
                  uri,
                  headers: finalHeaders,
                  body: body != null ? jsonEncode(body) : null,
                ).timeout(ApiConfig.timeout);
                break;
              case 'PUT':
                response = await http.put(
                  uri,
                  headers: finalHeaders,
                  body: body != null ? jsonEncode(body) : null,
                ).timeout(ApiConfig.timeout);
                break;
              case 'DELETE':
                response = await http.delete(uri, headers: finalHeaders).timeout(ApiConfig.timeout);
                break;
            }
          }
        }
      }

      return response;
    } on SocketException {
      throw Exception('No Internet connection');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } on FormatException {
      throw Exception('Bad response format');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  static Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse(ApiConfig.refreshToken),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'refresh_token': refreshToken}),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokens = AuthTokens.fromJson(data);
        await saveTokens(tokens);
        return true;
      } else {
        await clearTokens();
        return false;
      }
    } catch (e) {
      await clearTokens();
      return false;
    }
  }

  // GET request
  static Future<T> get<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? queryParams,
    bool requiresAuth = false,
  }) async {
    String url = endpoint;
    if (queryParams != null && queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url += '?$query';
    }

    final response = await _makeRequest(
      method: 'GET',
      url: url,
      requiresAuth: requiresAuth,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      
      // Handle both direct data and wrapped responses
      if (data is Map<String, dynamic>) {
        // If it's a wrapped response, extract data
        if (data.containsKey('success') && data.containsKey('data')) {
          return fromJson(data);
        }
        // Otherwise, treat as direct data
        return fromJson(data);
      } else if (data is List) {
        // Handle list responses
        return fromJson({'items': data});
      }
      
      throw Exception('Invalid response format');
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? errorData['detail'] ?? 'Request failed');
    }
  }

  // GET list request
  static Future<List<T>> getList<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? queryParams,
    bool requiresAuth = false,
  }) async {
    String url = endpoint;
    if (queryParams != null && queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url += '?$query';
    }

    final response = await _makeRequest(
      method: 'GET',
      url: url,
      requiresAuth: requiresAuth,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      
      if (data is List) {
        return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
      } else if (data is Map<String, dynamic>) {
        // Handle wrapped response
        final items = data['data'] ?? data['items'] ?? [];
        if (items is List) {
          return items.map((item) => fromJson(item as Map<String, dynamic>)).toList();
        }
      }
      
      throw Exception('Invalid response format');
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? errorData['detail'] ?? 'Request failed');
    }
  }

  // POST request
  static Future<T> post<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Object? body,
    bool requiresAuth = false,
  }) async {
    final response = await _makeRequest(
      method: 'POST',
      url: endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      
      if (data is Map<String, dynamic>) {
        return fromJson(data);
      }
      
      throw Exception('Invalid response format');
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? errorData['detail'] ?? 'Request failed');
    }
  }

  // PUT request
  static Future<T> put<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Object? body,
    bool requiresAuth = false,
  }) async {
    final response = await _makeRequest(
      method: 'PUT',
      url: endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      
      if (data is Map<String, dynamic>) {
        return fromJson(data);
      }
      
      throw Exception('Invalid response format');
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? errorData['detail'] ?? 'Request failed');
    }
  }

  // DELETE request
  static Future<void> delete({
    required String endpoint,
    bool requiresAuth = false,
  }) async {
    final response = await _makeRequest(
      method: 'DELETE',
      url: endpoint,
      requiresAuth: requiresAuth,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? errorData['detail'] ?? 'Request failed');
    }
  }
}