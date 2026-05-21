import 'models.dart';

/// Base class for all real-time room events emitted on [AparsMediaRoom.events].
///
/// Use a `switch` expression with Dart 3 pattern matching for exhaustive
/// handling:
/// ```dart
/// room.events.listen((event) {
///   switch (event) {
///     case ChatMessageReceived(:final message): ...
///     case RoomEnded(): ...
///     default: break;
///   }
/// });
/// ```
sealed class RoomEvent {
  const RoomEvent();
}

/// The Socket.IO connection was established successfully.
final class RoomConnected extends RoomEvent {
  const RoomConnected();
}

/// The Socket.IO connection was lost. The SDK reconnects automatically.
final class RoomDisconnected extends RoomEvent {
  const RoomDisconnected();
}

/// The server detected an unusually high-latency connection.
final class ConnectionWarning extends RoomEvent {
  /// Human-readable description of the warning.
  final String message;

  /// Round-trip latency in milliseconds.
  final int latencyMs;

  const ConnectionWarning(this.message, this.latencyMs);
}

/// A new chat message was received from the server.
final class ChatMessageReceived extends RoomEvent {
  /// The received message.
  final ChatMessage message;

  const ChatMessageReceived(this.message);
}

/// Chat was enabled or disabled by the teacher.
final class ChatToggled extends RoomEvent {
  /// `true` if chat is now enabled.
  final bool enabled;

  const ChatToggled(this.enabled);
}

/// Slow-mode setting was changed by the teacher.
final class SlowModeToggled extends RoomEvent {
  /// `true` if slow-mode is now active.
  final bool enabled;

  /// Minimum seconds between messages while slow-mode is on.
  final int intervalSeconds;

  const SlowModeToggled(this.enabled, this.intervalSeconds);
}

/// A message was pinned or unpinned.
final class MessagePinned extends RoomEvent {
  /// ID of the affected message.
  final String messageId;

  /// `true` if the message is now pinned.
  final bool pinned;

  const MessagePinned(this.messageId, this.pinned);
}

/// A message was deleted by a moderator.
final class MessageDeleted extends RoomEvent {
  /// ID of the deleted message.
  final String messageId;

  const MessageDeleted(this.messageId);
}

/// A user was banned from the room.
///
/// If [userId] matches the current student's ID, navigate away from the class.
final class UserBanned extends RoomEvent {
  /// ID of the banned user.
  final String userId;

  /// Display name of the banned user.
  final String userName;

  const UserBanned(this.userId, this.userName);
}

/// The teacher reconnected after a temporary disconnection.
final class TeacherReconnected extends RoomEvent {
  const TeacherReconnected();
}

/// The class was ended by the teacher.
final class RoomEnded extends RoomEvent {
  const RoomEnded();
}

/// This device's session was terminated because the same user ID joined from
/// another device.
final class SessionKicked extends RoomEvent {
  const SessionKicked();
}
