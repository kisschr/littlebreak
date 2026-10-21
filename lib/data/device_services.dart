import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Daily local reminder ("Erinnerung um 8:00 Uhr"), no server involved.
abstract class ReminderService {
  /// Schedules (or replaces) the daily reminder. Returns false when the user
  /// denied notifications or the platform has none.
  Future<bool> scheduleDaily({required int hour, required int minute, required String title, required String body});

  Future<void> cancel();
}

class LocalReminderService implements ReminderService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _id = 1;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  Future<bool> _requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) return await ios.requestPermissions(alert: true, sound: true) ?? false;
    return false;
  }

  @override
  Future<bool> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_supported) return false;
    await _init();
    if (!await _requestPermission()) return false;
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _id,
      title: title,
      body: body,
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_game',
          'Kleine Pause',
          channelDescription: 'Daily reminder',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return true;
  }

  @override
  Future<void> cancel() async {
    if (!_supported) return;
    await _init();
    await _plugin.cancel(id: _id);
  }
}

/// Reads instructions aloud in the kids profile ("Vorlesen").
abstract class SpeechService {
  Future<void> speak(String text, {required String languageCode});
  Future<void> stop();
}

class TtsSpeechService implements SpeechService {
  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    try {
      await _tts.setLanguage(languageCode == 'de' ? 'de-DE' : 'en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.speak(text);
    } catch (_) {
      // No speech engine on this device; the button simply does nothing.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

/// No-op implementations for tests and unsupported platforms.
class SilentReminderService implements ReminderService {
  @override
  Future<bool> scheduleDaily({required int hour, required int minute, required String title, required String body}) async =>
      false;

  @override
  Future<void> cancel() async {}
}

class SilentSpeechService implements SpeechService {
  final List<String> spoken = [];

  @override
  Future<void> speak(String text, {required String languageCode}) async => spoken.add(text);

  @override
  Future<void> stop() async {}
}
