import 'package:fit_coach/services/api_service.dart' show ApiService;

import 'api_service.dart';
import '../models/membership_model.dart';

class MembershipService {
  Future<void> renewMembership({
    required String token,
    required String clientId,
    required MembershipModel membership,
  }) async {
    await ApiService.dio.post(
      "/memberships/renew/$clientId",
      data: membership.toJson(),
      options: ApiService.authOptions(token),
    );
  }

  Future<List<MembershipModel>> getHistory(
    String token,
    String clientId,
  ) async {
    final response = await ApiService.dio.get(
      "/memberships/history/$clientId",
      options: ApiService.authOptions(token),
    );

    return (response.data as List)
        .map((e) => MembershipModel.fromJson(e))
        .toList();
  }

  Future<MembershipModel> getCurrent(
    String token,
    String clientId,
  ) async {
    final response = await ApiService.dio.get(
      "/memberships/current/$clientId",
      options: ApiService.authOptions(token),
    );

    return MembershipModel.fromJson(response.data);
  }
}