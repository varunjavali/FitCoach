class ApiConstants {
  static const String baseUrl = "http://localhost:5000/api";

  // Same host as baseUrl but without the /api suffix — used to build
  // full URLs for chat media returned as relative paths, e.g.
  // "/uploads/chat/xyz.jpg".
  static const String mediaBaseUrl = "http://localhost:5000";
}