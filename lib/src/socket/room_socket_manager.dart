import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models.dart';
import '../room_event.dart';

class RoomSocketManager {
  final String serverUrl;
  final String token;
  final String roomId;
  final String userId;
  final String userName;

  io.Socket? _socket;
  final _controller = StreamController<RoomEvent>.broadcast();
  Timer? _heartbeatTimer;

  RoomSocketManager({
    required this.serverUrl,
    required this.token,
    required this.roomId,
    required this.userId,
    required this.userName,
  });

  Stream<RoomEvent> get events => _controller.stream;

  void connect() {
    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(8)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          .setTimeout(30000)
          .build(),
    );

    _socket!
      ..onConnect((_) {
        _emit(const RoomConnected());
        _socket!.emit('chat:join');
        _socket!.emit('viewer:start', {'roomId': roomId});
        _startHeartbeat();
      })
      ..onDisconnect((_) {
        _stopHeartbeat();
        _emit(const RoomDisconnected());
      })
      ..on('chat:new', (data) {
        _safe(() {
          final msg = ChatMessage.fromJson(_toMap(data));
          _emit(ChatMessageReceived(msg));
        });
      })
      ..on('chat:toggled', (data) {
        _safe(() => _emit(ChatToggled(_toMap(data)['enabled'] as bool? ?? true)));
      })
      ..on('chat:slowmode:toggled', (data) {
        _safe(() {
          final m = _toMap(data);
          _emit(SlowModeToggled(
            m['enabled'] as bool? ?? false,
            m['interval'] as int? ?? 5,
          ));
        });
      })
      ..on('message:pinned', (data) {
        _safe(() {
          final m = _toMap(data);
          _emit(MessagePinned(m['messageId'] as String, m['pinned'] as bool? ?? false));
        });
      })
      ..on('message:deleted', (data) {
        _safe(() => _emit(MessageDeleted(_toMap(data)['messageId'] as String)));
      })
      ..on('user:banned', (data) {
        _safe(() {
          final m = _toMap(data);
          _emit(UserBanned(m['userId'] as String, m['userName'] as String));
        });
      })
      ..on('teacher:reconnected', (_) => _emit(const TeacherReconnected()))
      ..on('room:ended', (_) {
        _stopHeartbeat();
        _emit(const RoomEnded());
      })
      ..on('session:kicked', (_) {
        _stopHeartbeat();
        _emit(const SessionKicked());
      })
      ..on('connection:warning', (data) {
        _safe(() {
          final m = _toMap(data);
          _emit(ConnectionWarning(
            m['message'] as String? ?? '',
            m['latencyMs'] as int? ?? 0,
          ));
        });
      })
      ..connect();
  }

  void sendMessage(String content) {
    _socket?.emit('chat:send', {
      'roomId': roomId,
      'senderId': userId,
      'senderName': userName,
      'content': content,
    });
  }

  void disconnect() {
    _stopHeartbeat();
    _socket?.emit('viewer:stop', {'roomId': roomId});
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    if (!_controller.isClosed) _controller.close();
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_socket?.connected == true) {
        _socket!.emit('heartbeat', {
          'roomId': roomId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _emit(RoomEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  void _safe(void Function() fn) {
    try {
      fn();
    } catch (_) {}
  }

  Map<String, dynamic> _toMap(dynamic data) =>
      Map<String, dynamic>.from(data as Map);
}
