import 'package:dio/dio.dart';
import 'api_service.dart';

class DashboardService {
  final Dio _dio = ApiService.dio;

  Future<Map<String, dynamic>> getDashboard(String token) async {
    try {
      final response = await _dio.get(
        "/dashboard",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data["message"] ?? "Failed to load dashboard",
        );
      } else {
        throw Exception("Unable to connect to server");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}