import '../models/client_model.dart';
import '../models/membership_model.dart';
import 'api_service.dart';

class MembershipService {
  Future<ClientModel> renewMembership({
    required String token,
    required String clientId,
    required MembershipModel membership,
  }) async {
    final response = await ApiService.dio.post(
      "/memberships/renew/$clientId",
      data: membership.toJson(),
      options: ApiService.authOptions(token),
    );

    return ClientModel.fromJson(response.data["client"]);
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