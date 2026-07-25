import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttachmentTap;
  final VoidCallback onMicTap;
  final bool isRecording;
  final Duration recordingDuration;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttachmentTap,
    required this.onMicTap,
    this.isRecording = false,
    this.recordingDuration = Duration.zero,
  });

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        child: Row(
          children: [
            if (!isRecording)
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: onAttachmentTap,
              ),

            Expanded(
              child: isRecording
                  ? Row(
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Recording ${_formatDuration(recordingDuration)}",
                        ),
                      ],
                    )
                  : TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                      ),
                    ),
            ),

            const SizedBox(width: 10),

            CircleAvatar(
              radius: 25,
              backgroundColor: isRecording ? Colors.red : null,
              child: IconButton(
                icon: Icon(
                  isRecording
                      ? Icons.stop
                      : (hasText ? Icons.send : Icons.mic),
                ),
                onPressed: isRecording
                    ? onMicTap
                    : (hasText ? onSend : onMicTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
