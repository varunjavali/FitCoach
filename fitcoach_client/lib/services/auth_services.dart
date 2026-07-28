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
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          "Could not reach the server. Check your internet "
          "connection, or the backend may be waking up from "
          "sleep (free Render instances take ~30-60s to start "
          "after being idle) — try again in a moment.",
        );
      }

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

  
  Future<void> logout() async {
    
  }
}