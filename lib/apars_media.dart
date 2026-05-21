/// AparsMedia student-side Flutter SDK.
///
/// Import this single file to access all public types:
/// ```dart
/// import 'package:apars_media/apars_media.dart';
/// ```
library apars_media;

export 'src/apars_media_sdk.dart';
export 'src/apars_media_room.dart';
export 'src/apars_media_player_widget.dart';
export 'src/room_event.dart';
export 'src/models.dart'
    show
        RoomInfo,
        ChatMessage,
        Participant,
        RoomFeatures,
        GracePeriod,
        PlaybackUrls,
        AparsMediaException;
