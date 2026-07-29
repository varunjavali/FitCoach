
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config/api_constants.dart';

class SocketService {
  SocketService._internal();

  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  late IO.Socket socket;

  bool connected = false;

  void connect() {
    if (connected) return;

    socket = IO.io(
      ApiConstants.mediaBaseUrl,
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      connected = true;
      print("✅ Socket Connected");
    });

    socket.connect();
  }

  void onConnected(void Function() callback) {
    socket.onConnect((_) => callback());
  }

  void joinConversation(String trainerId, String clientId) {
    socket.emit("joinConversation", {
      "trainerId": trainerId,
      "clientId": clientId,
    });
  }

  void sendMessage({
    required String trainerId,
    required String clientId,
    required String sender,
    String text = "",
    String type = "text",
    String? mediaUrl,
  }) {
    socket.emit(
      "sendMessage",
      {
        "trainerId": trainerId,
        "clientId": clientId,
        "sender": sender,
        "text": text,
        "type": type,
        "mediaUrl": mediaUrl,
      },
    );
  }

  void listen(void Function(dynamic data) callback) {
    socket.on("newMessage", (data) => callback(data));
  }

  void disconnect() {
    socket.disconnect();
    connected = false;
  }
}