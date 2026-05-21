// Data models mirroring the Apars Media server API.

/// HLS and other playback URLs for a live room.
class PlaybackUrls {
  /// HLS `.m3u8` playlist URL, or `null` if the stream has not started.
  final String? hls;
  const PlaybackUrls({this.hls});
  factory PlaybackUrls.fromJson(Map<String, dynamic> j) =>
      PlaybackUrls(hls: j['hls'] as String?);
}

/// Feature flags configured for a room.
class RoomFeatures {
  /// Whether chat is enabled.
  final bool chat;

  /// Whether slow-mode is active.
  final bool chatSlowMode;

  /// Minimum seconds between messages when slow-mode is on.
  final int chatSlowModeInterval;

  /// Whether the session is being recorded.
  final bool recording;

  const RoomFeatures({
    this.chat = true,
    this.chatSlowMode = false,
    this.chatSlowModeInterval = 5,
    this.recording = false,
  });
  factory RoomFeatures.fromJson(Map<String, dynamic> j) => RoomFeatures(
        chat: j['chat'] as bool? ?? true,
        chatSlowMode: j['chatSlowMode'] as bool? ?? false,
        chatSlowModeInterval: j['chatSlowModeInterval'] as int? ?? 5,
        recording: j['recording'] as bool? ?? false,
      );
}

/// Teacher disconnection grace period state.
///
/// When [active] is `true` the teacher has temporarily disconnected but the
/// room is still open. [endsAt] indicates when the server will auto-close.
class GracePeriod {
  /// Whether a grace period is currently active.
  final bool active;

  /// Human-readable reason for the disconnection.
  final String? reason;

  /// ISO 8601 timestamp when the grace period started.
  final String? startAt;

  /// ISO 8601 timestamp when the grace period will end.
  final String? endsAt;

  /// Duration in milliseconds.
  final int? durationMs;

  const GracePeriod({
    required this.active,
    this.reason,
    this.startAt,
    this.endsAt,
    this.durationMs,
  });
  factory GracePeriod.fromJson(Map<String, dynamic> j) => GracePeriod(
        active: j['active'] as bool? ?? false,
        reason: j['reason'] as String?,
        startAt: j['startAt'] as String?,
        endsAt: j['endsAt'] as String?,
        durationMs: j['durationMs'] as int?,
      );
}

/// A participant currently in the room.
class Participant {
  /// Internal participant document ID.
  final String id;

  /// The user's application-level ID.
  final String userId;

  /// The user's display name.
  final String userName;

  /// Role: `"host"`, `"co-teacher"`, or `"student"`.
  final String role;

  /// Whether this participant has admin privileges.
  final bool isAdmin;

  /// Optional profile photo URL.
  final String? photoUrl;

  /// ISO 8601 timestamp when this user joined.
  final String? joinedAt;

  const Participant({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    this.isAdmin = false,
    this.photoUrl,
    this.joinedAt,
  });
  factory Participant.fromJson(Map<String, dynamic> j) => Participant(
        id: j['id'] as String,
        userId: j['userId'] as String,
        userName: j['userName'] as String,
        role: j['role'] as String,
        isAdmin: j['isAdmin'] as bool? ?? false,
        photoUrl: j['photoUrl'] as String?,
        joinedAt: j['joinedAt'] as String?,
      );
}

/// Metadata for a live class room.
class RoomInfo {
  /// Server-assigned room ID.
  final String id;

  /// Short alphanumeric code for the room.
  final String? code;

  /// Human-readable room name.
  final String? name;

  /// Current status: `"waiting"`, `"live"`, or `"ended"`.
  final String status;

  /// User ID of the teacher / host.
  final String? hostId;

  /// Display name of the teacher.
  final String? hostName;

  /// Profile photo URL of the teacher.
  final String? hostPhoto;

  /// AntMedia stream ID used to build HLS URLs.
  final String? streamId;

  /// Playback URLs (HLS, etc.).
  final PlaybackUrls? playbackUrls;

  /// Room feature flags.
  final RoomFeatures? features;

  /// Grace period state when the teacher has temporarily disconnected.
  final GracePeriod? gracePeriod;

  /// Current participants in the room.
  final List<Participant> participants;

  /// ISO 8601 timestamp when the room was created.
  final String? createdAt;

  /// ISO 8601 timestamp when the stream started.
  final String? startedAt;

  /// ISO 8601 timestamp when the room ended.
  final String? endedAt;

  const RoomInfo({
    required this.id,
    this.code,
    this.name,
    required this.status,
    this.hostId,
    this.hostName,
    this.hostPhoto,
    this.streamId,
    this.playbackUrls,
    this.features,
    this.gracePeriod,
    this.participants = const [],
    this.createdAt,
    this.startedAt,
    this.endedAt,
  });
  factory RoomInfo.fromJson(Map<String, dynamic> j) => RoomInfo(
        id: j['id'] as String,
        code: j['code'] as String?,
        name: j['name'] as String?,
        status: j['status'] as String? ?? 'waiting',
        hostId: j['hostId'] as String?,
        hostName: j['hostName'] as String?,
        hostPhoto: j['hostPhoto'] as String?,
        streamId: j['streamId'] as String?,
        playbackUrls: j['playbackUrls'] != null
            ? PlaybackUrls.fromJson(j['playbackUrls'] as Map<String, dynamic>)
            : null,
        features: j['features'] != null
            ? RoomFeatures.fromJson(j['features'] as Map<String, dynamic>)
            : null,
        gracePeriod: j['gracePeriod'] != null
            ? GracePeriod.fromJson(j['gracePeriod'] as Map<String, dynamic>)
            : null,
        participants: (j['participants'] as List<dynamic>? ?? [])
            .map((e) => Participant.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: j['createdAt'] as String?,
        startedAt: j['startedAt'] as String?,
        endedAt: j['endedAt'] as String?,
      );
}

/// A chat message received in or sent to a room.
class ChatMessage {
  /// Unique message ID.
  final String id;

  /// Sender's user ID.
  final String senderId;

  /// Sender's display name.
  final String senderName;

  /// Sender's profile photo URL, if available.
  final String? senderPhotoUrl;

  /// Text content of the message.
  final String content;

  /// ISO 8601 timestamp when the message was sent.
  final String timestamp;

  /// Whether this message is currently pinned.
  final bool pinned;

  /// User ID of whoever pinned this message.
  final String? pinnedBy;

  /// ISO 8601 timestamp when the message was pinned.
  final String? pinnedAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.content,
    required this.timestamp,
    this.pinned = false,
    this.pinnedBy,
    this.pinnedAt,
  });
  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        senderId: j['senderId'] as String,
        senderName: j['senderName'] as String,
        senderPhotoUrl: j['senderPhotoUrl'] as String?,
        content: j['content'] as String,
        timestamp: j['timestamp'] as String,
        pinned: j['pinned'] as bool? ?? false,
        pinnedBy: j['pinnedBy'] as String?,
        pinnedAt: j['pinnedAt'] as String?,
      );
}

// Internal response wrappers — not part of the public API.

class EmbedTokenResponse {
  final String token;
  final String roomId;
  final String userId;
  const EmbedTokenResponse({
    required this.token,
    required this.roomId,
    required this.userId,
  });
  factory EmbedTokenResponse.fromJson(Map<String, dynamic> j) =>
      EmbedTokenResponse(
        token: j['token'] as String,
        roomId: j['room_id'] as String,
        userId: j['user_id'] as String,
      );
}

class JoinRoomResponse {
  final RoomInfo? room;
  final Participant? participant;
  const JoinRoomResponse({this.room, this.participant});
  factory JoinRoomResponse.fromJson(Map<String, dynamic> j) => JoinRoomResponse(
        room: j['room'] != null
            ? RoomInfo.fromJson(j['room'] as Map<String, dynamic>)
            : null,
        participant: j['participant'] != null
            ? Participant.fromJson(j['participant'] as Map<String, dynamic>)
            : null,
      );
}

/// Thrown by [AparsMediaSDK] methods when a network or server error occurs.
class AparsMediaException implements Exception {
  /// Human-readable error description.
  final String message;

  /// Creates an [AparsMediaException] with the given [message].
  const AparsMediaException(this.message);

  @override
  String toString() => 'AparsMediaException: $message';
}
