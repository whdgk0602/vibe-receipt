import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _streakChannelId = 'vibe_streak';
  static const _streakNotificationId = 1;

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// 매일 저녁 8시에 스트릭 알림을 예약한다.
  /// 오늘 이미 측정했으면 호출하지 않는다.
  static Future<void> scheduleStreakReminder() async {
    await _plugin.cancel(_streakNotificationId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20, // 오후 8시
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _streakChannelId,
        '스트릭 알림',
        channelDescription: '연속 측정 스트릭 유지를 위한 알림',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _plugin.zonedSchedule(
      _streakNotificationId,
      '오늘 바이브, 아직 측정 안 했어요 🔥',
      '스트릭이 끊기기 전에 지금 공간의 무드를 기록해봐요',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 오늘 측정 완료 → 내일 알림으로 재예약
  static Future<void> onMeasuredToday() async {
    await scheduleStreakReminder();
  }

  static Future<void> cancel() async {
    await _plugin.cancel(_streakNotificationId);
  }
}
