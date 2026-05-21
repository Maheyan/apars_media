import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'apars_media_room.dart';

/// A Flutter widget that plays the HLS stream from a [AparsMediaRoom].
///
/// Handles initialization, auto-play, buffering state, and retries
/// (up to 15 attempts with exponential back-off).
///
/// ```dart
/// AparsMediaPlayerWidget(room: room)
/// ```
///
/// For full UI control, supply a [builder] that receives the initialized
/// [VideoPlayerController]:
/// ```dart
/// AparsMediaPlayerWidget(
///   room: room,
///   builder: (context, controller) => Chewie(controller: chewieController),
/// )
/// ```
class AparsMediaPlayerWidget extends StatefulWidget {
  final AparsMediaRoom? room;
  final String? hlsUrl;

  /// Optional builder for custom player UI. When null, a minimal built-in
  /// player with a play/pause overlay is shown.
  final Widget Function(BuildContext context, VideoPlayerController controller)?
      builder;

  /// Called when the stream is ready and playing.
  final VoidCallback? onReady;

  /// Called after all retries are exhausted.
  final void Function(Object error)? onError;

  const AparsMediaPlayerWidget({
    super.key,
    required AparsMediaRoom room,
    this.builder,
    this.onReady,
    this.onError,
  // ignore: prefer_initializing_formals — field is AparsMediaRoom? but param is non-null
  })  : room = room,
        hlsUrl = null;

  const AparsMediaPlayerWidget.fromUrl({
    super.key,
    required String hlsUrl,
    this.builder,
    this.onReady,
    this.onError,
  // ignore: prefer_initializing_formals — field is String? but param is non-null
  })  : hlsUrl = hlsUrl,
        room = null;

  @override
  State<AparsMediaPlayerWidget> createState() => _AparsMediaPlayerWidgetState();
}

class _AparsMediaPlayerWidgetState extends State<AparsMediaPlayerWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _buffering = false;
  Object? _error;
  int _retryCount = 0;

  static const int _maxRetries = 15;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AparsMediaPlayerWidget old) {
    super.didUpdateWidget(old);
    final newUrl = _resolveUrl();
    final oldUrl = old.room?.hlsUrl ?? old.hlsUrl;
    if (newUrl != null && newUrl != oldUrl) {
      _retryCount = 0;
      _load();
    }
  }

  String? _resolveUrl() => widget.room?.hlsUrl ?? widget.hlsUrl;

  Future<void> _load() async {
    final url = _resolveUrl();
    if (url == null || !mounted) return;

    setState(() => _error = null);

    try {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(url));

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      controller.addListener(_onControllerUpdate);
      await controller.play();

      setState(() {
        _controller?.removeListener(_onControllerUpdate);
        _controller?.dispose();
        _controller = controller;
        _initialized = true;
        _retryCount = 0;
      });

      widget.onReady?.call();
    } catch (e) {
      if (!mounted) return;
      if (_retryCount < _maxRetries) {
        _retryCount++;
        final delay = Duration(seconds: _retryCount.clamp(1, 30));
        await Future.delayed(delay);
        if (mounted) _load();
      } else {
        setState(() => _error = e);
        widget.onError?.call(e);
      }
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final buffering = _controller?.value.isBuffering ?? false;
    if (buffering != _buffering) {
      setState(() => _buffering = buffering);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorView(
        onRetry: () {
          setState(() {
            _error = null;
            _retryCount = 0;
          });
          _load();
        },
      );
    }

    if (!_initialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final playerWidget = widget.builder != null
        ? widget.builder!(context, _controller!)
        : _DefaultPlayer(controller: _controller!, buffering: _buffering);

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: playerWidget,
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }
}

class _DefaultPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  final bool buffering;
  const _DefaultPlayer({required this.controller, required this.buffering});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(controller),
        if (buffering)
          const CircularProgressIndicator(color: Colors.white)
        else
          GestureDetector(
            onTap: () {
              controller.value.isPlaying
                  ? controller.pause()
                  : controller.play();
            },
            child: AnimatedOpacity(
              opacity: controller.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
              ),
            ),
          ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.signal_wifi_off, color: Colors.white54, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Stream unavailable',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
