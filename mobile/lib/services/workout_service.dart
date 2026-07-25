import 'package:dio/dio.dart';

import '../models/workout_model.dart';
import 'api_service.dart';

class WorkoutService {
  /// Get all workouts for a client
  Future<List<WorkoutModel>> getClientWorkouts(
    String token,
    String clientId,
  ) async {
    try {
      final response = await ApiService.dio.get(
        "/workouts/client/$clientId",
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
            "Failed to fetch workouts",
      );
    }
  }

  /// Get a single workout
  Future<WorkoutModel> getWorkout(
    String token,
    String workoutId,
  ) async {
    try {
      final response = await ApiService.dio.get(
        "/workouts/$workoutId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return WorkoutModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to fetch workout",
      );
    }
  }

  /// Add a new workout
  Future<void> addWorkout(
    String token,
    WorkoutModel workout,
  ) async {
    try {
      await ApiService.dio.post(
        "/workouts",
        data: workout.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to add workout",
      );
    }
  }

  /// Update an existing workout
  Future<void> updateWorkout(
    String token,
    String workoutId,
    WorkoutModel workout,
  ) async {
    try {
      await ApiService.dio.put(
        "/workouts/$workoutId",
        data: workout.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to update workout",
      );
    }
  }

  /// Delete a workout
  Future<void> deleteWorkout(
    String token,
    String workoutId,
  ) async {
    try {
      await ApiService.dio.delete(
        "/workouts/$workoutId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to delete workout",
      );
    }
  }
}