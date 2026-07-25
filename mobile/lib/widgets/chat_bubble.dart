import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String type; // "text" | "image" | "audio" | "video"
  final String? mediaUrl;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.type = "text",
    this.mediaUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        isMe ? Colors.green.shade600 : Colors.grey.shade300;
    final textColor = isMe ? Colors.white : Colors.black87;

    Widget content;

    switch (type) {
      case "image":
        content = _ImageBubble(
          url: mediaUrl ?? "",
          caption: message,
          textColor: textColor,
        );
        break;
      case "video":
        content = _VideoBubble(url: mediaUrl ?? "");
        break;
      case "audio":
        content = _AudioBubble(url: mediaUrl ?? "", isMe: isMe);
        break;
      default:
        content = Text(
          message,
          style: TextStyle(color: textColor, fontSize: 16),
        );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 10,
        ),
        padding: type == "image"
            ? const EdgeInsets.all(4)
            : const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      ),
    );
  }
}

class _ImageBubble extends StatelessWidget {
  final String url;
  final String caption;
  final Color textColor;

  const _ImageBubble({
    required this.url,
    required this.caption,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(backgroundColor: Colors.black),
                  body: Center(
                    child: InteractiveViewer(
                      child: Image.network(url),
                    ),
                  ),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: 220,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  width: 220,
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 220,
                height: 150,
                child: Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
        ),
        if (caption.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            caption,
            style: TextStyle(color: textColor, fontSize: 15),
          ),
        ],
      ],
    );
  }
}

class _VideoBubble extends StatefulWidget {
  final String url;
  const _VideoBubble({required this.url});

  @override
  State<_VideoBubble> createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<_VideoBubble> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    )..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 220,
        height: _initialized
            ? 220 / _controller.value.aspectRatio
            : 150,
        child: _initialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      size: 42,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _AudioBubble extends StatefulWidget {
  final String url;
  final bool isMe;
  const _AudioBubble({required this.url, required this.isMe});

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(widget.url));
    }
    if (mounted) setState(() => _isPlaying = !_isPlaying);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isMe ? Colors.white : Colors.black87;
    final total = _duration.inMilliseconds > 0
        ? _duration.inMilliseconds.toDouble()
        : 1.0;
    final current =
        _position.inMilliseconds.clamp(0, total.toInt()).toDouble();

    return SizedBox(
      width: 200,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: color,
              size: 32,
            ),
            onPressed: _toggle,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
              ),
              child: Slider(
                value: current,
                max: total,
                onChanged: (v) async {
                  await _player.seek(
                    Duration(milliseconds: v.toInt()),
                  );
                },
                activeColor: color,
                inactiveColor: color.withOpacity(0.3),
              ),
            ),
          ),
          Text(
            _fmt(_duration),
            style: TextStyle(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
