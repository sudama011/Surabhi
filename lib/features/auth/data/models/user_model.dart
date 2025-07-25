// lib/features/auth/data/models/user_model.dart
class UserModel {
  final int id;
  final String email;
  final String role;

  UserModel({required this.id, required this.email, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }
}

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String userRole; // Role sent back by the server on login

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userRole,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      userRole: json['user_role'],
    );
  }
}