import 'api/api_client.dart';
import 'models.dart';
import 'apars_media_room.dart';

/// Entry point for the AparsMedia student SDK.
///
/// **Single-client apps** — use the static helpers:
/// ```dart
/// AparsMediaSDK.init(baseUrl: '...', clientId: '...', authKey: '...');
/// final room = await AparsMediaSDK.instance.joinRoom(...);
/// ```
///
/// **Multi-client apps** — construct independent instances, one per server:
/// ```dart
/// final schoolA = AparsMediaSDK(baseUrl: '...', clientId: idA, authKey: keyA);
/// final schoolB = AparsMediaSDK(baseUrl: '...', clientId: idB, authKey: keyB);
/// ```
class AparsMediaSDK {
  /// The base URL of this server instance, with any trailing slash stripped.
  final String baseUrl;

  final ApiClient _apiClient;

  AparsMediaSDK({
    required String baseUrl,
    required String clientId,
    required String authKey,
  })  : baseUrl = baseUrl.trimRight('/'),
        _apiClient = ApiClient(
          baseUrl: baseUrl.trimRight('/'),
          clientId: clientId,
          authKey: authKey,
        );

  // ── Singleton helpers (single-client convenience) ─────────────────────────

  static AparsMediaSDK? _instance;

  /// Initialize the default instance. Safe to call multiple times — subsequent
  /// calls replace the previous instance.
  static AparsMediaSDK init({
    required String baseUrl,
    required String clientId,
    required String authKey,
  }) {
    _instance = AparsMediaSDK(
      baseUrl: baseUrl,
      clientId: clientId,
      authKey: authKey,
    );
    return _instance!;
  }

  /// The default instance created by [init].
  /// Throws [StateError] if [init] has not been called.
  static AparsMediaSDK get instance {
    if (_instance == null) {
      throw StateError(
        'AparsMediaSDK not initialized. Call AparsMediaSDK.init() first.',
      );
    }
    return _instance!;
  }

  // ── Core API ──────────────────────────────────────────────────────────────

  /// Join a live class room as a student.
  ///
  /// Internally this:
  /// 1. Generates a short-lived embed JWT via `POST /api/embed/token`
  /// 2. Registers the student via `POST /api/embed/public/room/:id/join`
  /// 3. Opens a Socket.IO connection and emits `chat:join` + `viewer:start`
  ///
  /// Throws [AparsMediaException] if any network call fails.
  Future<AparsMediaRoom> joinRoom({
    required String roomId,
    required String userId,
    required String userName,
    String? photoUrl,
  }) async {
    final tokenRes = await _apiClient.generateEmbedToken(
      roomId: roomId,
      userId: userId,
      userName: userName,
    );

    final joinRes = await _apiClient.joinRoom(
      roomId,
      tokenRes.token,
      photoUrl: photoUrl,
    );

    return AparsMediaRoom._(
      sdk: this,
      roomId: roomId,
      userId: userId,
      userName: userName,
      token: tokenRes.token,
      info: joinRes.room,
    );
  }

  /// Release HTTP resources. Call when the SDK instance is no longer needed.
  void dispose() => _apiClient.dispose();
}
