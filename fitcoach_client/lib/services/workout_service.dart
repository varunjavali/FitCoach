import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/workout_model.dart';

class WorkoutService {
  Future<List<WorkoutModel>> getMyWorkouts(
    String token,
  ) async {
    try {
      final response = await ApiService.dio.get(
        "/clients/workouts",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return (response.data as List)
          .map((e) => WorkoutModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to load workouts",
      );
    }
  }
}