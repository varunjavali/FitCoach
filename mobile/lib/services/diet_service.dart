import 'package:dio/dio.dart';
import 'package:fit_coach/models/diet_model.dart' show DietModel;


import 'api_service.dart';

class DietService {
  Future<List<DietModel>> getClientDiets(
    String token,
    String clientId,
  ) async {
    try {
      final response = await ApiService.dio.get(
        "/diets/client/$clientId",
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
            "Failed to fetch diets",
      );
    }
  }

  Future<void> addDiet(
    String token,
    DietModel diet,
  ) async {
    try {
      await ApiService.dio.post(
        "/diets",
        data: diet.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to add diet",
      );
    }
  }

  Future<void> updateDiet(
    String token,
    String dietId,
    DietModel diet,
  ) async {
    try {
      await ApiService.dio.put(
        "/diets/$dietId",
        data: diet.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to update diet",
      );
    }
  }

  Future<void> deleteDiet(
    String token,
    String dietId,
  ) async {
    try {
      await ApiService.dio.delete(
        "/diets/$dietId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to delete diet",
      );
    }
  }

  Future<DietModel> getDiet(
    String token,
    String dietId,
  ) async {
    try {
      final response = await ApiService.dio.get(
        "/diets/$dietId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return DietModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to fetch diet",
      );
    }
  }
}