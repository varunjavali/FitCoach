import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String type; // "text" | "image" | "audio" | "video"
  final String? mediaUrl;
  final DateTime? createdAt;
  final bool isRead;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.type = "text",
    this.mediaUrl,
    this.createdAt,
    this.isRead = false,
  });

  String _formatTime(DateTime? dt) {
    if (dt == null) return "";
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  Widget _statusTicks(Color color) {
    if (!isMe) return const SizedBox.shrink();

    return Icon(
      isRead ? Icons.done_all : Icons.done,
      size: 15,
      color: isRead ? Colors.lightBlueAccent : color,
    );
  }

  Widget _metaRow(Color color, {bool overlay = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(createdAt),
            style: TextStyle(
              color: overlay ? Colors.white70 : color,
              fontSize: 11,
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 4),
            _statusTicks(overlay ? Colors.white70 : color),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        isMe ? Colors.green.shade600 : Colors.grey.shade300;
    final textColor = isMe ? Colors.white : Colors.black87;
    final metaColor = isMe ? Colors.white70 : Colors.black45;

    Widget content;

    switch (type) {
      case "image":
        content = _ImageBubble(
          url: mediaUrl ?? "",
          caption: message,
          textColor: textColor,
          metaRow: _metaRow(Colors.white70, overlay: true),
        );
        break;
      case "video":
        content = _VideoBubble(
          url: mediaUrl ?? "",
          metaRow: _metaRow(Colors.white70, overlay: true),
        );
        break;
      case "audio":
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _AudioBubble(url: mediaUrl ?? "", isMe: isMe),
            _metaRow(metaColor),
          ],
        );
        break;
      default:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            _metaRow(metaColor),
          ],
        );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 10,
        ),
        padding: (type == "image" || type == "video")
            ? const EdgeInsets.all(4)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
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
  final Widget metaRow;

  const _ImageBubble({
    required this.url,
    required this.caption,
    required this.textColor,
    required this.metaRow,
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
                      child: CachedNetworkImage(imageUrl: url),
                    ),
                  ),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: url,
                  width: 220,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(
                    width: 220,
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 220,
                    height: 150,
                    color: Colors.black12,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey, size: 28),
                        SizedBox(height: 6),
                        Text(
                          "Photo no longer available",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: metaRow,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (caption.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              caption,
              style: TextStyle(color: textColor, fontSize: 15),
            ),
          ),
        ],
      ],
    );
  }
}

class _VideoBubble extends StatefulWidget {
  final String url;
  final Widget metaRow;
  const _VideoBubble({required this.url, required this.metaRow});

  @override
  State<_VideoBubble> createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<_VideoBubble> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );
    _controller = controller;
    controller.initialize().then((_) {
      if (mounted) setState(() => _initialized = true);
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 220,
          height: 150,
          color: Colors.black12,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off_outlined,
                  color: Colors.grey, size: 28),
              SizedBox(height: 6),
              Text(
                "Video no longer available",
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 220,
        height: _initialized
            ? 220 / _controller!.value.aspectRatio
            : 150,
        child: _initialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller!),
                  IconButton(
                    icon: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      size: 42,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller!.value.isPlaying
                            ? _controller!.pause()
                            : _controller!.play();
                      });
                    },
                  ),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: widget.metaRow,
                    ),
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
  bool _failed = false;
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
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play(UrlSource(widget.url));
      }
      if (mounted) setState(() => _isPlaying = !_isPlaying);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isMe ? Colors.white : Colors.black87;

    if (_failed) {
      return SizedBox(
        width: 200,
        child: Row(
          children: [
            Icon(Icons.mic_off_outlined, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              "Voice note unavailable",
              style: TextStyle(color: color, fontSize: 13),
            ),
          ],
        ),
      );
    }

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
