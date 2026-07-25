import 'package:dio/dio.dart';
import 'api_service.dart';

class AuthService {
  /// Client Login
  Future<Map<String, dynamic>> login(
    String email,
    String password,
    
  ) async {
    try {
      final response = await ApiService.dio.post(
  "/auth/client-login",
        data: {
          "email": email,
          "password": password,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Login failed",
      );
    }
  }

  /// Change Password
  Future<Map<String, dynamic>> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await ApiService.dio.put(
        "/client-auth/change-password",
        data: {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to change password",
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    // Backend doesn't need logout because JWT is stateless.
    // We'll clear SharedPreferences in the app.
  }
}