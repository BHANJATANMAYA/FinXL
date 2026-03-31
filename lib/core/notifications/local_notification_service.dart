import 'package:finxl/core/models/bill.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings: settings);
    await requestPermissions();
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    final macPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> syncBillReminder(Bill bill) async {
    await initialize();

    final billId = bill.id;
    if (billId == null) return;

    if (!bill.isActive || bill.isPaid) {
      await cancelBillReminder(billId);
      return;
    }

    final now = DateTime.now();
    final scheduledAt = bill.dueDate.subtract(const Duration(hours: 48));
    final effectiveDate = scheduledAt.isAfter(now)
        ? scheduledAt
        : now.add(const Duration(minutes: 1));

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'finxl_reminders',
        'FinXL Reminders',
        channelDescription: 'Upcoming bill and subscription reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: billId,
      title: bill.title,
      body:
          '₹${bill.amount.toStringAsFixed(2)} due on ${bill.dueDate.day}/${bill.dueDate.month}.',
      scheduledDate: tz.TZDateTime.from(effectiveDate, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: billId.toString(),
    );
  }

  Future<void> cancelBillReminder(int id) async {
    await _plugin.cancel(id: id);
  }
}
