import 'package:dio/dio.dart';

import '../models/dashboard_model.dart';
import 'api_service.dart';

class DashboardService {
  Future<DashboardModel> getDashboard(
    String token,
  ) async {
   final response = await ApiService.dio.get(
  "/client-dashboard",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return DashboardModel.fromJson(response.data);
  }
}