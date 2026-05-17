import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Almaty'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> scheduleTrackerReminder({
    required String trackerId,
    required String title,
    required String emoji,
    required TimeOfDay time,
    required List<int> weekdays,
  }) async {
    if (!_initialized) await initialize();

    for (final weekday in weekdays) {
      final id = _generateId(trackerId, weekday);

      await _notifications.zonedSchedule(
        id,
        '$emoji $title',
        'Пора выполнить привычку!',
        _nextInstanceOfWeekday(weekday, time),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'tracker_reminders',
            'Напоминания трекеров',
            channelDescription: 'Уведомления о времени выполнения трекеров',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'flowerig',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> scheduleDeadlineReminder({
    required String trackerId,
    required String title,
    required String emoji,
    required DateTime deadline,
  }) async {
    if (!_initialized) await initialize();

    final oneDayBefore = deadline.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        _generateDeadlineId(trackerId),
        '$emoji $title',
        'Дедлайн завтра!',
        tz.TZDateTime.from(oneDayBefore, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'tracker_deadlines',
            'Дедлайны трекеров',
            channelDescription: 'Уведомления о приближающихся дедлайнах',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'flowerig',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelTrackerNotifications(String trackerId) async {
    for (int i = 1; i <= 7; i++) {
      await _notifications.cancel(_generateId(trackerId, i));
    }
    await _notifications.cancel(_generateDeadlineId(trackerId));
  }

  int _generateId(String trackerId, int weekday) {
    return (trackerId.hashCode % 100000) * 10 + weekday;
  }

  int _generateDeadlineId(String trackerId) {
    return (trackerId.hashCode % 100000) * 10 + 8;
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.weekday == weekday && scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    } else {
      while (scheduled.weekday != weekday) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    }

    return scheduled;
  }
}
