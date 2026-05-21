import 'api/api_client.dart';
import 'models.dart';
import 'room_event.dart';
import 'socket/room_socket_manager.dart';

/// An active room session returned by [AparsMediaSDK.join].
///
/// - [hlsUrl] — raw `.m3u8` URL, pass this to your video player.
/// - [events] — real-time stream of [RoomEvent]s (chat, room ended, etc.).
/// - [sendChatMessage] — send a chat message.
/// - [leave] — always call this in your widget's `dispose`.
class AparsMediaRoom {
  /// The ID of the joined room.
  final String roomId;

  /// The user's application-level ID.
  final String userId;

  /// The user's display name.
  final String userName;

  /// Latest room metadata. Refreshed via [refreshInfo].
  RoomInfo? info;

  final ApiClient _apiClient;
  final String _token;
  final RoomSocketManager _socket;

  AparsMediaRoom.create({
    required ApiClient apiClient,
    required String serverUrl,
    required this.roomId,
    required this.userId,
    required this.userName,
    required String token,
    required this.info,
  })  : _apiClient = apiClient,
        _token = token,
        _socket = RoomSocketManager(
          serverUrl: serverUrl,
          token: token,
          roomId: roomId,
          userId: userId,
          userName: userName,
        ) {
    _socket.connect();
  }

  /// Stream of real-time [RoomEvent]s. Broadcast — multiple listeners allowed.
  Stream<RoomEvent> get events => _socket.events;

  /// HLS `.m3u8` stream URL, or `null` if the stream has not started yet.
  ///
  /// Pass this URL directly to your video player (e.g. `video_player`,
  /// `better_player`, `chewie`, `media_kit`).
  /// Poll via [refreshInfo] if this is `null` on join.
  String? get hlsUrl => info?.playbackUrls?.hls;

  /// Whether the room status is `"live"`.
  bool get isLive => info?.status == 'live';

  // ── Chat ──────────────────────────────────────────────────────────────────

  /// Send a chat message via Socket.IO (fire-and-forget).
  void sendChatMessage(String content) => _socket.sendMessage(content);

  /// Fetch recent chat history.
  ///
  /// Pass [before] (ISO 8601 timestamp) to page backwards through history.
  Future<List<ChatMessage>> loadChatHistory({
    int limit = 50,
    String? before,
  }) =>
      _apiClient.getMessages(roomId, _token, limit: limit, before: before);

  // ── Room info ─────────────────────────────────────────────────────────────

  /// Re-fetch [info] from the server and return the updated value.
  ///
  /// Call this to get [hlsUrl] after the stream goes live.
  Future<RoomInfo> refreshInfo() async {
    info = await _apiClient.getRoomInfo(roomId, _token);
    return info!;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Leave the room: closes the socket and notifies the server.
  ///
  /// Always call this in your widget's `dispose`.
  Future<void> leave() async {
    _socket.disconnect();
    await _apiClient.leaveRoom(roomId, _token);
  }
}
