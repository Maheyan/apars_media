// Data models mirroring the Apars Media server API.

/// HLS and other playback URLs for a live room.
class PlaybackUrls {
  /// HLS `.m3u8` playlist URL, or `null` if the stream has not started.
  final String? hls;
  const PlaybackUrls({this.hls});
  factory PlaybackUrls.fromJson(Map<String, dynamic> j) =>
      PlaybackUrls(hls: j['hls'] as String?);
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

  /// Optional profile photo URL.
  final String? photoUrl;

  /// ISO 8601 timestamp when this user joined.
  final String? joinedAt;

  const Participant({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    this.photoUrl,
    this.joinedAt,
  });
  factory Participant.fromJson(Map<String, dynamic> j) => Participant(
        id: j['id'] as String,
        userId: j['userId'] as String,
        userName: j['userName'] as String,
        role: j['role'] as String,
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

  /// Playback URLs. Use [PlaybackUrls.hls] for the `.m3u8` stream URL.
  final PlaybackUrls? playbackUrls;

  /// Current participants in the room.
  final List<Participant> participants;

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
    this.playbackUrls,
    this.participants = const [],
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
        playbackUrls: j['playbackUrls'] != null
            ? PlaybackUrls.fromJson(j['playbackUrls'] as Map<String, dynamic>)
            : null,
        participants: (j['participants'] as List<dynamic>? ?? [])
            .map((e) => Participant.fromJson(e as Map<String, dynamic>))
            .toList(),
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

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.content,
    required this.timestamp,
    this.pinned = false,
  });
  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        senderId: j['senderId'] as String,
        senderName: j['senderName'] as String,
        senderPhotoUrl: j['senderPhotoUrl'] as String?,
        content: j['content'] as String,
        timestamp: j['timestamp'] as String,
        pinned: j['pinned'] as bool? ?? false,
      );
}

// Internal response wrappers — not part of the public API.

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
