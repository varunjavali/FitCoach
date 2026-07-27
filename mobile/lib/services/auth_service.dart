import 'package:dio/dio.dart';

import 'api_service.dart';

class AuthService {
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await ApiService.dio.post(
        "/auth/login",
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
}