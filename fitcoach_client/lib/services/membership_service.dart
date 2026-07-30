import 'package:dio/dio.dart';

import '../config/api_constants.dart';
import '../models/membership_model.dart';

class MembershipService {
  final Dio _dio = Dio();

  Future<MembershipModel> getCurrentMembership(String token) async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}/client-membership/current",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return MembershipModel.fromJson(response.data);
  }
}