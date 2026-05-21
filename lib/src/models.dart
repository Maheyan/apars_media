// Data models mirroring the AparsMedia server API

class PlaybackUrls {
  final String? hls;
  const PlaybackUrls({this.hls});
  factory PlaybackUrls.fromJson(Map<String, dynamic> j) =>
      PlaybackUrls(hls: j['hls'] as String?);
}

class RoomFeatures {
  final bool chat;
  final bool chatSlowMode;
  final int chatSlowModeInterval;
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

class GracePeriod {
  final bool active;
  final String? reason;
  final String? startAt;
  final String? endsAt;
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

class Participant {
  final String id;
  final String userId;
  final String userName;
  final String role;
  final bool isAdmin;
  final String? photoUrl;
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

class RoomInfo {
  final String id;
  final String? code;
  final String? name;
  final String status;
  final String? hostId;
  final String? hostName;
  final String? hostPhoto;
  final String? streamId;
  final PlaybackUrls? playbackUrls;
  final RoomFeatures? features;
  final GracePeriod? gracePeriod;
  final List<Participant> participants;
  final String? createdAt;
  final String? startedAt;
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

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String content;
  final String timestamp;
  final bool pinned;
  final String? pinnedBy;
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

// Internal response wrappers
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

class AparsMediaException implements Exception {
  final String message;
  const AparsMediaException(this.message);
  @override
  String toString() => 'AparsMediaException: $message';
}
