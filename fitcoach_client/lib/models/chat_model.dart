class ChatModel {
  final String sender;
  final String type; // "text" | "image" | "audio" | "video"
  final String text;
  final String? mediaUrl;
  final DateTime createdAt;
  final bool isRead;

  ChatModel({
    required this.sender,
    this.type = "text",
    required this.text,
    this.mediaUrl,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      sender: json["sender"],
      type: json["type"] ?? "text",
      text: json["text"] ?? "",
      mediaUrl: json["mediaUrl"],
      createdAt: DateTime.parse(json["createdAt"]),
      isRead: json["isRead"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sender": sender,
      "type": type,
      "text": text,
      "mediaUrl": mediaUrl,
      "createdAt": createdAt.toIso8601String(),
      "isRead": isRead,
    };
  }
}
