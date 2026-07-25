import 'package:dio/dio.dart';

import '../models/chat_model.dart';
import 'api_service.dart';

class ChatService {
  Future<List<ChatModel>> getConversation(
    String token,
  ) async {
    try {
      final response = await ApiService.dio.get(
        "/chat/client",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      final List<dynamic> data =
          response.data["messages"] ?? [];

      return data
          .map((e) => ChatModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to load conversation",
      );
    }
  }

  /// Uploads a media file (image/audio/video) and returns the
  /// relative URL (e.g. "/uploads/chat/xyz.jpg") returned by the
  /// backend. Combine with ApiConstants.mediaBaseUrl to get a full,
  /// playable URL.
  Future<String> uploadMedia(
    String token,
    String filePath,
  ) async {
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
            "Failed to upload file",
      );
    }
  }
}