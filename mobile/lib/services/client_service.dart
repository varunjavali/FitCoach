import 'package:dio/dio.dart';

import '../models/client_model.dart';
import 'api_service.dart';

class ClientService {
  /// Get all clients
  Future<List<ClientModel>> getClients(String token) async {
    try {
      final response = await ApiService.dio.get(
        "/clients",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return (response.data as List)
          .map((e) => ClientModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to fetch clients",
      );
    }
  }

  /// Get single client
  Future<ClientModel> getClient(
    String token,
    String id,
  ) async {
    try {
      final response = await ApiService.dio.get(
        "/clients/$id",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return ClientModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to fetch client",
      );
    }
  }

  /// Add client
  Future<void> addClient(
    String token,
    ClientModel client,
  ) async {
    try {
      await ApiService.dio.post(
        "/clients",
        data: client.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to add client",
      );
    }
  }

  /// Update client
  Future<ClientModel> updateClient(
  String token,
  String id,
  ClientModel client,
) async {
  try {
    final response = await ApiService.dio.put(
      "/clients/$id",
      data: client.toJson(),
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    // Return what the SERVER computed (correct balanceDue), not the
    // locally-built object the caller sent — the backend recalculates
    // balanceDue from totalFees/amountPaid and that's the source of
    // truth.
    return ClientModel.fromJson(response.data["client"]);
  } on DioException catch (e) {
    throw Exception(
      e.response?.data["message"] ?? "Failed to update client",
    );
  }
}

  /// Update Balance
  Future<ClientModel> updateBalance(
    String token,
    String clientId,
    double amount,
  ) async {
    try {
      final response = await ApiService.dio.put(
        "/clients/$clientId/update-balance",
        data: {
          "amount": amount,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return ClientModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to update balance",
      );
    }
  }

  /// Delete client
  Future<void> deleteClient(
    String token,
    String id,
  ) async {
    try {
      await ApiService.dio.delete(
        "/clients/$id",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to delete client",
      );
    }
  }
}