import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../../services/socket_service.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/message_input.dart';

class ClientChatScreen extends StatefulWidget {
  const ClientChatScreen({super.key});

  @override
  State<ClientChatScreen> createState() =>
      _ClientChatScreenState();
}

class _ClientChatScreenState
    extends State<ClientChatScreen> {
  final SocketService socket = SocketService();
  final ChatService chatService = ChatService();

  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  List<ChatModel> messages = [];

  String trainerId = "";
  String clientId = "";

 
  static const _bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff0F2027),
      Color(0xff203A43),
      Color(0xff2C5364),
    ],
  );

  static final _accent = Colors.greenAccent.shade400;

  @override
  void initState() {
    super.initState();

    messageController.addListener(() => setState(() {}));

    socket.connect();

    socket.onConnected(() async {
      await loadConversation();
    });

    socket.listen((data) {
      if (data["sender"] == "client") return;
      setState(() {
        messages.add(ChatModel.fromJson(data));
      });

      scrollBottom();
    });
  }

  Future<void> loadConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("clientToken");

      trainerId =
          prefs.getString("trainerId") ?? "";

      clientId =
          prefs.getString("clientId") ?? "";

      if (token == null) return;

      final chats =
          await chatService.getConversation(
        token,
      );

      setState(() {
        messages = chats;
      });

      socket.joinConversation(
        trainerId,
        clientId,
      );

      scrollBottom();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    final text = messageController.text.trim();

    // Optimistic UI: show the message immediately, don't wait for
    // the server round-trip.
    setState(() {
      messages.add(
        ChatModel(
          sender: "client",
          type: "text",
          text: text,
          createdAt: DateTime.now(),
          isRead: false,
        ),
      );
    });

    socket.sendMessage(
      trainerId: trainerId,
      clientId: clientId,
      sender: "client",
      text: text,
      type: "text",
    );

    messageController.clear();
    scrollBottom();
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";

    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return "${months[local.month - 1]} ${local.day}, ${local.year}";
  }

  List<Widget> _buildTimeline() {
    final widgets = <Widget>[];
    DateTime? lastDate;

    for (final msg in messages) {
      final local = msg.createdAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);

      if (lastDate == null || day != lastDate) {
        widgets.add(
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(.15)),
              ),
              child: Text(
                _dateLabel(msg.createdAt),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
        lastDate = day;
      }

      widgets.add(
        ChatBubble(
          type: msg.type,
          message: msg.text,
          mediaUrl: msg.mediaUrl,
          isMe: msg.sender == "client",
          createdAt: msg.createdAt,
          isRead: msg.isRead,
        ),
      );
    }

    return widgets;
  }

  void scrollBottom() {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if (!scrollController.hasClients) {
          return;
        }

        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration:
              const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      //-------------------------------------------------
      // Glass AppBar
      //-------------------------------------------------

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(.08),
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Chat with Trainer",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Stack(
        children: [

          //-------------------------------------------------
          // Background gradient + soft decorative glow
          //-------------------------------------------------

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: _bgGradient),
          ),

          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          //-------------------------------------------------
          // Chat content
          //-------------------------------------------------

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: kToolbarHeight - 8),

                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(.08),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.white54,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                "No messages yet",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(10),
                          children: _buildTimeline(),
                        ),
                ),

                //-------------------------------------------------
                // Glass input bar wrapper
                //-------------------------------------------------

                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.06),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withOpacity(.12),
                          ),
                        ),
                      ),
                      child: MessageInput(
                        controller: messageController,
                        onSend: sendMessage,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}