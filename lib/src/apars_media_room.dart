import 'api/api_client.dart';
import 'models.dart';
import 'room_event.dart';
import 'socket/room_socket_manager.dart';

/// An active room session returned by [AparsMediaSDK.joinRoom].
///
/// Listen to [events] for real-time updates, send messages with
/// [sendChatMessage], and always call [leave] in your widget's `dispose`.
class AparsMediaRoom {
  /// The ID of the joined room.
  final String roomId;

  /// The student's user ID.
  final String userId;

  /// The student's display name.
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

  /// HLS stream URL, or `null` if the room is not yet live.
  String? get hlsUrl => info?.playbackUrls?.hls;

  /// Whether the room status is `"live"`.
  bool get isLive => info?.status == 'live';

  // ── Chat ──────────────────────────────────────────────────────────────────

  /// Send a chat message instantly via Socket.IO (fire-and-forget).
  void sendChatMessage(String content) => _socket.sendMessage(content);

  /// Send a chat message via HTTP for delivery confirmation.
  Future<ChatMessage> sendChatMessageHttp(String content) =>
      _apiClient.sendMessage(roomId, _token, content);

  /// Fetch recent chat history.
  ///
  /// [before] is an ISO 8601 timestamp — pass it to page backwards.
  Future<List<ChatMessage>> loadChatHistory({
    int limit = 50,
    String? before,
  }) =>
      _apiClient.getMessages(roomId, _token, limit: limit, before: before);

  // ── Room info ─────────────────────────────────────────────────────────────

  /// Re-fetch [info] from the server and return the updated value.
  Future<RoomInfo> refreshInfo() async {
    info = await _apiClient.getRoomInfo(roomId, _token);
    return info!;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Leave the room: emits `viewer:stop`, closes the socket, calls the leave
  /// endpoint. Always call this in your widget's `dispose`.
  Future<void> leave() async {
    _socket.disconnect();
    await _apiClient.leaveRoom(roomId, _token);
  }
}
