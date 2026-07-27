import 'package:dio/dio.dart';

import 'api_service.dart';
import '../models/progress_model.dart';

class ProgressService {
  Future<List<ProgressModel>> getMyProgress(String token) async {
    try {
      final response = await ApiService.dio.get(
        "/clients/progress",
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
            "Failed to load progress",
      );
    }
  }

  Future<ProgressModel> addProgress(
    String token,
    ProgressModel entry,
  ) async {
    try {
      final response = await ApiService.dio.post(
        "/clients/progress",
        data: entry.toRequestBody(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return ProgressModel.fromJson(response.data["progress"]);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to save progress",
      );
    }
  }

  /// Uploads a progress photo and returns the relative URL
  /// (e.g. "/uploads/chat/xyz.jpg") — reuses the shared chat media
  /// upload endpoint since it already accepts client tokens.
  Future<String> uploadPhoto(String token, String filePath) async {
    try {
      final fileName = filePath.split("/").last;

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await ApiService.dio.post(
        "/chat/upload",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return response.data["url"] as String;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to upload photo",
      );
    }
  }
}
