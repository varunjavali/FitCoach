import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.greenAccent,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(.5),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(.06),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(.15),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(.15),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Colors.greenAccent.withOpacity(.6),
                  ),
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 24,
            backgroundColor: hasText
                ? Colors.greenAccent.shade400
                : Colors.white.withOpacity(.1),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: hasText ? Colors.black : Colors.white38,
              ),
              onPressed: hasText ? onSend : null,
            ),
          ),
        ],
      ),
    );
  }
}