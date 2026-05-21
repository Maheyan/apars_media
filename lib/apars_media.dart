/// AparsMedia Flutter SDK — HLS stream URL + real-time chat for students
/// and co-teachers.
///
/// Import this single file to access all public types:
/// ```dart
/// import 'package:apars_media/apars_media.dart';
/// ```
library apars_media;

export 'src/apars_media_sdk.dart';
export 'src/apars_media_room.dart';
export 'src/room_event.dart';
export 'src/models.dart'
    show
        RoomInfo,
        ChatMessage,
        Participant,
        PlaybackUrls,
        AparsMediaException;
