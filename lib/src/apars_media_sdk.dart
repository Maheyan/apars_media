import 'api/api_client.dart';
import 'apars_media_room.dart';

/// Entry point for the AparsMedia SDK.
///
/// Your backend issues a short-lived embed token — pass it directly here.
/// **Never embed server credentials (`clientId` / `authKey`) in the mobile app.**
///
/// ```dart
/// // 1. Fetch a token from YOUR backend
/// final token = await myApi.getClassToken(roomId: id, userId: uid);
///
/// // 2. Join the room
/// final room = await AparsMediaSDK.join(
///   serverUrl: 'https://your-server.com',
///   roomId:    id,
///   userId:    uid,
///   userName:  name,
///   token:     token,
/// );
///
/// // 3. Use the raw .m3u8 URL with any video player
/// final hlsUrl = room.hlsUrl; // null if stream hasn't started yet
///
/// // 4. Listen for real-time events (chat, room ended, etc.)
/// room.events.listen((event) { ... });
///
/// // 5. Clean up when done
/// await room.leave();
/// ```
class AparsMediaSDK {
  // Static-only class — no instances needed.
  AparsMediaSDK._();

  /// Join a live class room using a pre-issued embed token.
  ///
  /// The [token] must be fetched from your own backend server, which holds
  /// the `clientId` and `authKey` credentials securely.
  ///
  /// Throws [AparsMediaException] if the network request fails.
  static Future<AparsMediaRoom> join({
    required String serverUrl,
    required String roomId,
    required String userId,
    required String userName,
    required String token,
    String? photoUrl,
  }) async {
    final url = serverUrl.replaceAll(RegExp(r'/+$'), '');
    final apiClient = ApiClient(baseUrl: url);

    final joinRes = await apiClient.joinRoom(
      roomId,
      token,
      photoUrl: photoUrl,
    );

    return AparsMediaRoom.create(
      apiClient: apiClient,
      serverUrl: url,
      roomId: roomId,
      userId: userId,
      userName: userName,
      token: token,
      info: joinRes.room,
    );
  }
}
