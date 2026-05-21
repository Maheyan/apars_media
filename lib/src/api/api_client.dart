import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _http;

  ApiClient({required this.baseUrl}) : _http = http.Client();

  Map<String, String> _bearerHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Uri _uri(String path, [Map<String, String>? params]) {
    final uri = Uri.parse('$baseUrl$path');
    return params != null ? uri.replace(queryParameters: params) : uri;
  }

  Future<RoomInfo> getRoomInfo(String roomId, String token) async {
    final res = await _http.get(
      _uri('/api/embed/public/room/$roomId'),
      headers: _bearerHeaders(token),
    );
    _assertSuccess(res, 'Get room');
    return RoomInfo.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<JoinRoomResponse> joinRoom(
    String roomId,
    String token, {
    String? photoUrl,
  }) async {
    final res = await _http.post(
      _uri('/api/embed/public/room/$roomId/join'),
      headers: _bearerHeaders(token),
      body: jsonEncode({'photo': photoUrl}),
    );
    _assertSuccess(res, 'Join room');
    return JoinRoomResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> leaveRoom(String roomId, String token) async {
    await _http.post(
      _uri('/api/embed/public/room/$roomId/leave'),
      headers: _bearerHeaders(token),
      body: '{}',
    );
  }

  Future<List<ChatMessage>> getMessages(
    String roomId,
    String token, {
    int limit = 50,
    String? before,
  }) async {
    final params = <String, String>{'limit': '$limit'};
    if (before != null) params['before'] = before;

    final res = await _http.get(
      _uri('/api/embed/public/room/$roomId/messages', params),
      headers: _bearerHeaders(token),
    );
    _assertSuccess(res, 'Get messages');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _assertSuccess(http.Response res, String operation) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String detail = '';
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        detail = body['message'] as String? ?? res.body;
      } catch (_) {
        detail = res.body;
      }
      throw AparsMediaException('$operation failed (${res.statusCode}): $detail');
    }
  }

  void dispose() => _http.close();
}
