class ApiConstants {
  // IMPORTANT: "localhost" only works when running on an emulator on the
  // SAME machine as the backend. On a real device, "localhost" refers to
  // the phone itself, not your PC — the backend is unreachable and every
  // request (including login) will silently fail as a connection error.
  //
  // Replace with your computer's LAN IP address instead, e.g.:
  //   static const String baseUrl = "http://192.168.1.42:5000/api";
  //
  // Find your IP on Windows with: ipconfig  (look for "IPv4 Address")
  // Your phone and PC must be on the same Wi-Fi network, and the backend
  // must be started with `node server.js` (not just left as localhost-only).
  static const String baseUrl = "http://localhost:5000/api";

  // Same host as baseUrl but without the /api suffix — used to build
  // full URLs for chat media returned as relative paths, e.g.
  // "/uploads/chat/xyz.jpg".
  static const String mediaBaseUrl = "http://localhost:5000";
}