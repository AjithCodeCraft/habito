import 'package:equatable/equatable.dart';
import 'user.dart';

// Request Models
class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequest extends Equatable {
  final String username;
  final String email;
  final String password;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }

  @override
  List<Object?> get props => [username, email, password];
}

// Response Models
class AuthResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType, user];
}

class TokenRefreshResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const TokenRefreshResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType];
}