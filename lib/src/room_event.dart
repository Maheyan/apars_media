import 'models.dart';

/// Base class for all real-time room events emitted on [AparsMediaRoom.events].
sealed class RoomEvent {
  const RoomEvent();
}

final class RoomConnected extends RoomEvent {
  const RoomConnected();
}

final class RoomDisconnected extends RoomEvent {
  const RoomDisconnected();
}

final class ConnectionWarning extends RoomEvent {
  final String message;
  final int latencyMs;
  const ConnectionWarning(this.message, this.latencyMs);
}

final class ChatMessageReceived extends RoomEvent {
  final ChatMessage message;
  const ChatMessageReceived(this.message);
}

final class ChatToggled extends RoomEvent {
  final bool enabled;
  const ChatToggled(this.enabled);
}

final class SlowModeToggled extends RoomEvent {
  final bool enabled;
  final int intervalSeconds;
  const SlowModeToggled(this.enabled, this.intervalSeconds);
}

final class MessagePinned extends RoomEvent {
  final String messageId;
  final bool pinned;
  const MessagePinned(this.messageId, this.pinned);
}

final class MessageDeleted extends RoomEvent {
  final String messageId;
  const MessageDeleted(this.messageId);
}

final class UserBanned extends RoomEvent {
  final String userId;
  final String userName;
  const UserBanned(this.userId, this.userName);
}

final class ViewerCountUpdated extends RoomEvent {
  final int count;
  const ViewerCountUpdated(this.count);
}

final class TeacherVideoToggled extends RoomEvent {
  final bool enabled;
  const TeacherVideoToggled(this.enabled);
}

final class TeacherAudioToggled extends RoomEvent {
  final bool enabled;
  const TeacherAudioToggled(this.enabled);
}

final class TeacherReconnected extends RoomEvent {
  const TeacherReconnected();
}

final class RoomEnded extends RoomEvent {
  const RoomEnded();
}

final class SessionKicked extends RoomEvent {
  const SessionKicked();
}
