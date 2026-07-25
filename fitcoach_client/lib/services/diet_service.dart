import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/diet_model.dart';

class DietService {
  Future<List<DietModel>> getMyDiets(
    String token,
  ) async {
    try {
      final response = await ApiService.dio.get(
        "/clients/diets",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return (response.data as List)
          .map((e) => DietModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to load diets",
      );
    }
  }
}