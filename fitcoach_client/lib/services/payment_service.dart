import 'package:dio/dio.dart';

import '../config/api_constants.dart';
import '../models/payment_model.dart';

class PaymentService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<Map<String, dynamic>> getPaymentHistory(String token) async {
    try {
      final response = await _dio.get(
        "/client-payments/history",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      final data = response.data;

      final List<PaymentModel> payments =
          (data["payments"] as List)
              .map((e) => PaymentModel.fromJson(e))
              .toList();

      return {
        "summary": data["summary"],
        "payments": payments,
      };
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to load payment history.",
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}