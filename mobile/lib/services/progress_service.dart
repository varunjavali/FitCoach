import 'package:dio/dio.dart';

import '../models/progress_model.dart';
import 'api_service.dart';

class ProgressService {
  /// Get all progress records of a client
  Future<List<ProgressModel>> getClientProgress(
    String token,
    String clientId,
  ) async {
    try {
      final response = await ApiService.dio.get(
        "/progress/client/$clientId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return (response.data as List)
          .map((e) => ProgressModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to fetch progress",
      );
    }
  }

  /// Get single progress record
  Future<ProgressModel> getProgress(
    String token,
    String progressId,
  ) async {
    try {
      final response = await ApiService.dio.get(
        "/progress/$progressId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return ProgressModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to fetch progress",
      );
    }
  }

  /// Add progress
  Future<void> addProgress(
    String token,
    ProgressModel progress,
  ) async {
    try {
      await ApiService.dio.post(
        "/progress",
        data: progress.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to add progress",
      );
    }
  }

  /// Update progress
  Future<void> updateProgress(
    String token,
    String progressId,
    ProgressModel progress,
  ) async {
    try {
      await ApiService.dio.put(
        "/progress/$progressId",
        data: progress.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to update progress",
      );
    }
  }

  /// Delete progress
  Future<void> deleteProgress(
    String token,
    String progressId,
  ) async {
    try {
      await ApiService.dio.delete(
        "/progress/$progressId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to delete progress",
      );
    }
  }
}