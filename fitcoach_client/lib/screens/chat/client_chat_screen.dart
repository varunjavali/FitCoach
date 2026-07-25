import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_constants.dart';
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
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  List<ChatModel> messages = [];

  String trainerId = "";
  String clientId = "";

  bool _isRecording = false;
  bool _isUploading = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();

    // Rebuilds the send/mic icon in MessageInput as the user types.
    messageController.addListener(() => setState(() {}));

    socket.connect();

    socket.onConnected(() async {
      await loadConversation();
    });

    socket.listen((data) {
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

    socket.sendMessage(
      trainerId: trainerId,
      clientId: clientId,
      sender: "client",
      text: messageController.text.trim(),
      type: "text",
    );

    messageController.clear();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("clientToken");
  }

  Future<void> _sendMediaFile(File file, String type) async {
    final token = await _getToken();
    if (token == null) return;

    setState(() => _isUploading = true);

    try {
      final relativeUrl =
          await chatService.uploadMedia(token, file.path);

      final fullUrl =
          "${ApiConstants.mediaBaseUrl}$relativeUrl";

      socket.sendMessage(
        trainerId: trainerId,
        clientId: clientId,
        sender: "client",
        type: type,
        mediaUrl: fullUrl,
      );

      scrollBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send: ${e.toString()}"),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (file == null) return;
    await _sendMediaFile(File(file.path), "image");
  }

  Future<void> _pickAndSendVideo(ImageSource source) async {
    final XFile? file = await _picker.pickVideo(source: source);
    if (file == null) return;
    await _sendMediaFile(File(file.path), "video");
  }

  void _showAttachmentSheet() {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Photo/video sending isn't supported in the web preview. Run on Android/iOS to use it.",
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Photo from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text("Video from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendVideo(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRecording() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Voice messages aren't supported in the web preview. Run on Android/iOS to use it.",
          ),
        ),
      );
      return;
    }

    if (_isRecording) {
      final path = await _audioRecorder.stop();
      _recordingTimer?.cancel();

      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });

      if (path != null) {
        await _sendMediaFile(File(path), "audio");
      }
    } else {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Microphone permission is required"),
            ),
          );
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final filePath =
          "${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a";

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      _recordingTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
        },
      );
    }
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
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Trainer"),
      ),
      body: Column(
        children: [
          if (_isUploading)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text("No messages"),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding:
                        const EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final msg =
                          messages[index];

                      return ChatBubble(
                        type: msg.type,
                        message: msg.text,
                        mediaUrl: msg.mediaUrl,
                        isMe:
                            msg.sender == "client",
                      );
                    },
                  ),
          ),
          MessageInput(
            controller: messageController,
            onSend: sendMessage,
            onAttachmentTap: _showAttachmentSheet,
            onMicTap: _toggleRecording,
            isRecording: _isRecording,
            recordingDuration: _recordingDuration,
          ),
        ],
      ),
    );
  }
}
