class ApiConstants {
  // Deployed backend (Render) — reachable from any device, anywhere.
  static const String baseUrl =
      "https://fitcoach-backend-e9bp.onrender.com/api";

  // Same host as baseUrl but without the /api suffix — used to build
  // full URLs for chat media returned as relative paths, e.g.
  // "/uploads/chat/xyz.jpg", and for the socket.io connection.
  static const String mediaBaseUrl =
      "https://fitcoach-backend-e9bp.onrender.com";
}

// class ApiConstants {
//   static const String baseUrl =
//       "http://localhost:5000/api";

//   static const String mediaBaseUrl =
//       "http://localhost:5000";
//hi }