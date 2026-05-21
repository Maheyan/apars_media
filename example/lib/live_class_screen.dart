import 'dart:async';
import 'package:flutter/material.dart';
import 'package:apars_media/apars_media.dart';

class LiveClassScreen extends StatefulWidget {
  final AparsMediaRoom room;
  const LiveClassScreen({super.key, required this.room});

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  final _messages = <ChatMessage>[];
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  StreamSubscription<RoomEvent>? _sub;
  String _status = 'Connecting…';
  int _viewers = 0;
  bool _chatEnabled = true;

  AparsMediaRoom get room => widget.room;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _listenToEvents();
  }

  void _listenToEvents() {
    _sub = room.events.listen((event) {
      switch (event) {
        case RoomConnected():
          setState(() => _status = room.isLive ? 'Live' : 'Waiting for class');

        case RoomDisconnected():
          setState(() => _status = 'Reconnecting…');

        case ChatMessageReceived(:final message):
          setState(() => _messages.add(message));
          _scrollToBottom();

        case ViewerCountUpdated(:final count):
          setState(() => _viewers = count);

        case ChatToggled(:final enabled):
          setState(() => _chatEnabled = enabled);

        case TeacherReconnected():
          setState(() => _status = 'Live');
          _showSnack('Teacher is back!');

        case TeacherVideoToggled(:final enabled):
          if (!enabled) setState(() => _status = 'Teacher camera off');

        case RoomEnded():
          setState(() => _status = 'Class ended');
          _showSnack('The class has ended');

        case SessionKicked():
          _showSnack('Logged in from another device');
          Navigator.pop(context);

        case UserBanned(:final userId):
          if (userId == room.userId) {
            _showSnack('You have been removed from this class');
            Navigator.pop(context);
          }

        case ConnectionWarning():
          setState(() => _status = 'Weak connection');

        default:
          break;
      }
    });
  }

  Future<void> _loadHistory() async {
    try {
      final history = await room.loadChatHistory(limit: 50);
      if (!mounted) return;
      setState(() => _messages.insertAll(0, history));
      _scrollToBottom();
    } catch (_) {}
  }

  void _send() {
    final content = _msgCtrl.text.trim();
    if (content.isEmpty) return;
    room.sendChatMessage(content);
    _msgCtrl.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _sub?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    room.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Player ────────────────────────────────────────────────────
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: room.hlsUrl != null
                      ? AparsMediaPlayerWidget(room: room)
                      : const Center(
                          child: Text(
                            'Waiting for stream…',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                ),
                // Overlay: status + viewers
                Positioned(
                  top: 8,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _status,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const Spacer(),
                      if (_viewers > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$_viewers watching',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Chat ──────────────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _ChatBubble(message: _messages[i]),
              ),
            ),

            // ── Input ─────────────────────────────────────────────────────
            Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      enabled: _chatEnabled,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: _chatEnabled ? 'Message…' : 'Chat disabled',
                        hintStyle: const TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF4F8EF7)),
                    onPressed: _chatEnabled ? _send : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${message.senderName}  ',
              style: const TextStyle(
                color: Color(0xFF4F8EF7),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            TextSpan(
              text: message.content,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
