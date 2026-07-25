import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService._internal();

  static final SocketService _instance =
      SocketService._internal();

  factory SocketService() => _instance;

  late IO.Socket socket;

  bool connected = false;

  void connect() {
    if (connected) return;

    socket = IO.io(
      "http://localhost:5000",
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      connected = true;
      print("✅ Socket Connected");
    });

    socket.onDisconnect((_) {
      connected = false;
      print("❌ Socket Disconnected");
    });

    socket.onConnectError((data) {
      print("❌ Connect Error: $data");
    });

    socket.onError((data) {
      print("❌ Socket Error: $data");
    });

    socket.connect();
  }

  void onConnected(VoidCallback callback) {
    if (connected) {
      callback();
      return;
    }

    socket.onConnect((_) {
      connected = true;
      callback();
    });
  }

  void joinConversation(
    String trainerId,
    String clientId,
  ) {
    print("Joining Room...");
    print("Trainer : $trainerId");
    print("Client  : $clientId");

    socket.emit(
      "joinConversation",
      {
        "trainerId": trainerId,
        "clientId": clientId,
      },
    );
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

  void listen(Function(dynamic data) callback) {
  socket.off("newMessage");

  socket.on("newMessage", (data) {
    print("📩 NEW MESSAGE RECEIVED");
    print(data);

    callback(data);
  });
}

  void disconnect() {
    socket.disconnect();
    connected = false;
  }
}