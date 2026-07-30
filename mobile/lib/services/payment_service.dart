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

  //----------------------------------------------------
  // Get All Payments
  //----------------------------------------------------

  Future<List<PaymentModel>> getPayments(
    String token,
  ) async {
    try {
      final response = await _dio.get(
        "/payments",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return (response.data as List)
          .map(
            (e) => PaymentModel.fromJson(e),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to fetch payments",
      );
    }
  }

  //----------------------------------------------------
  // Get Client Payments
  //----------------------------------------------------

  Future<List<PaymentModel>> getClientPayments(
    String token,
    String clientId,
  ) async {
    try {
      final response = await _dio.get(
        "/payments/client/$clientId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return (response.data as List)
          .map(
            (e) => PaymentModel.fromJson(e),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to fetch client payments",
      );
    }
  }

  //----------------------------------------------------
  // Get Single Payment
  //----------------------------------------------------

  Future<PaymentModel> getPayment(
    String token,
    String paymentId,
  ) async {
    try {
      final response = await _dio.get(
        "/payments/$paymentId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return PaymentModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to fetch payment",
      );
    }
  }

  //----------------------------------------------------
  // Add Payment
  //----------------------------------------------------

  Future<void> addPayment({
    required String token,
    required String clientId,
    required double amount,
    required String paymentMethod,
    required String paymentType,
    String remarks = "",
  }) async {
    try {
      await _dio.post(
        "/payments",
        data: {
          "clientId": clientId,
          "amount": amount,
          "paymentMethod": paymentMethod,
          "paymentType": paymentType,
          "remarks": remarks,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Payment failed",
      );
    }
  }

  //----------------------------------------------------
  // Delete Payment
  //----------------------------------------------------

  Future<void> deletePayment({
    required String token,
    required String paymentId,
  }) async {
    try {
      await _dio.delete(
        "/payments/$paymentId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Unable to delete payment",
      );
    }
  }
}