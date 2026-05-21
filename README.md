# apars_media

[![pub package](https://img.shields.io/pub/v/apars_media.svg)](https://pub.dev/packages/apars_media)
[![pub points](https://img.shields.io/pub/points/apars_media)](https://pub.dev/packages/apars_media/score)
[![license](https://img.shields.io/github/license/Maheyan/Teachstack)](LICENSE)

Student-side Flutter SDK for [Apars Media](https://pub.dev/packages/apars_media) live classes.
Supports HLS playback, real-time chat, and viewer tracking out of the box.

## Features

- **HLS live stream playback** via `AparsMediaPlayerWidget` (wraps `video_player` with 15-retry exponential backoff)
- **Real-time chat** — send and receive messages over Socket.IO v4
- **Viewer tracking** — automatic start/stop heartbeats
- **Typed event stream** — Dart 3 sealed `RoomEvent` classes, exhaustive switch support
- **Multi-server** — connect one app to multiple Apars Media servers simultaneously

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  apars_media: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Permissions

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** — `ios/Runner/Info.plist` (needed by `video_player`):
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

## Quick start

### 1. Initialize

Call once from `main()` before `runApp()`:

```dart
void main() {
  AparsMediaSDK.init(
    baseUrl:  'https://your-apars-media-server.com',
    clientId: 'your_client_id',
    authKey:  'your_auth_key',
  );
  runApp(const MyApp());
}
```

### 2. Join a room

```dart
final room = await AparsMediaSDK.instance.joinRoom(
  roomId:   'room_abc123',
  userId:   currentUser.id,
  userName: currentUser.displayName,
);
```

### 3. Show the player

```dart
AparsMediaPlayerWidget(room: room)
```

### 4. Listen for events

```dart
final sub = room.events.listen((event) {
  switch (event) {
    case ChatMessageReceived(:final message):
      setState(() => messages.add(message));
    case ViewerCountUpdated(:final count):
      setState(() => viewers = count);
    case RoomEnded():
      Navigator.pop(context);
    default:
      break;
  }
});
```

### 5. Send a chat message

```dart
room.sendChatMessage('Hello!');
```

### 6. Clean up

```dart
@override
void dispose() {
  sub.cancel();
  room.leave();
  super.dispose();
}
```

## Multi-server support

Construct one `AparsMediaSDK` instance per server instead of using the singleton:

```dart
final schoolA = AparsMediaSDK(
  baseUrl:  'https://school-a.com',
  clientId: 'id_a',
  authKey:  'key_a',
);
final schoolB = AparsMediaSDK(
  baseUrl:  'https://school-b.com',
  clientId: 'id_b',
  authKey:  'key_b',
);
```

## RoomEvent types

| Event | Description |
|-------|-------------|
| `RoomConnected` | Socket connected successfully |
| `RoomDisconnected` | Socket disconnected (auto-reconnects) |
| `ConnectionWarning` | High latency detected |
| `ChatMessageReceived` | New chat message |
| `ChatToggled` | Chat enabled/disabled by teacher |
| `SlowModeToggled` | Slow mode changed |
| `MessagePinned` | Message pinned/unpinned |
| `MessageDeleted` | Message removed |
| `UserBanned` | User banned from chat |
| `ViewerCountUpdated` | Live viewer count changed |
| `TeacherVideoToggled` | Teacher camera on/off |
| `TeacherAudioToggled` | Teacher mic on/off |
| `TeacherReconnected` | Teacher came back after a drop |
| `RoomEnded` | Class ended by teacher |
| `SessionKicked` | Duplicate login detected |

## Requirements

| Platform | Minimum |
|----------|---------|
| Flutter  | 3.10+   |
| Dart     | 3.0+    |
| iOS      | 12+     |
| Android  | API 21+ |

## License

MIT
