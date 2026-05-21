## 1.0.3
* Security Updated

## 1.0.2
* License Updated

## 1.0.1
* Bugs Fix

## 1.0.0

* Initial release.
* HLS live stream playback via `AparsMediaPlayerWidget` (wraps `video_player`, 15-retry exponential backoff).
* Real-time chat and viewer tracking via Socket.IO v4.
* `Stream<RoomEvent>` API using Dart 3 sealed classes for exhaustive event handling.
* Multi-server support — construct separate `AparsMediaSDK` instances per server.
* Singleton convenience (`AparsMediaSDK.init` / `AparsMediaSDK.instance`) for single-server apps.