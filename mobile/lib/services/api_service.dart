import 'package:dio/dio.dart';
import '../config/api_constants.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  static Options authOptions(String token) {
    return Options(
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }
}