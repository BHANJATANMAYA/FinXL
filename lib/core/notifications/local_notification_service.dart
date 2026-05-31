import 'package:meta/meta.dart';
import 'package:finxl/core/models/bill.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._() : _plugin = FlutterLocalNotificationsPlugin();

  @visibleForTesting
  LocalNotificationService.internal(FlutterLocalNotificationsPlugin plugin)
      : _plugin = plugin;

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin;

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

  DateTimeComponents? _getDateTimeComponents(String recurrence) {
    return switch (recurrence.toLowerCase()) {
      'weekly' => DateTimeComponents.dayOfWeekAndTime,
      'monthly' => DateTimeComponents.dayOfMonthAndTime,
      'yearly' => DateTimeComponents.dateAndTime,
      _ => null,
    };
  }

  Future<void> syncBillReminder(Bill bill) async {
    await initialize();

    final billId = bill.id;
    if (billId == null) return;

    final baseId = billId * 10;
    
    // Always clear old ones first
    await cancelBillReminder(billId);

    if (!bill.isActive || bill.isPaid) {
      return;
    }

    final notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'finxl_reminders',
        'FinXL Reminders',
        channelDescription: 'Upcoming bill and subscription reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    final matchComponents = _getDateTimeComponents(bill.recurrence);

    final schedules = [
      (
        offsetId: 0,
        date: bill.dueDate.subtract(const Duration(days: 7)),
        message: 'Upcoming: ₹${bill.amount.toStringAsFixed(2)} due next week on ${bill.dueDate.day}/${bill.dueDate.month}.'
      ),
      (
        offsetId: 1,
        date: bill.dueDate.subtract(const Duration(days: 1)),
        message: 'Reminder: ₹${bill.amount.toStringAsFixed(2)} due tomorrow.'
      ),
      (
        offsetId: 2,
        date: bill.dueDate,
        message: 'Due Today: ₹${bill.amount.toStringAsFixed(2)}.'
      ),
    ];

    final nowTime = tz.TZDateTime.now(tz.local);

    for (final schedule in schedules) {
      tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(schedule.date, tz.local);
      
      if (scheduledTZDate.isBefore(nowTime)) {
        if (matchComponents == null) continue;
        
        // Shift date to future based on recurrence
        if (matchComponents == DateTimeComponents.dayOfWeekAndTime) {
            while(scheduledTZDate.isBefore(nowTime)) {
                scheduledTZDate = scheduledTZDate.add(const Duration(days: 7));
            }
        } else if (matchComponents == DateTimeComponents.dayOfMonthAndTime) {
            while(scheduledTZDate.isBefore(nowTime)) {
                scheduledTZDate = tz.TZDateTime(tz.local, scheduledTZDate.year, scheduledTZDate.month + 1, scheduledTZDate.day, scheduledTZDate.hour, scheduledTZDate.minute);
            }
        } else if (matchComponents == DateTimeComponents.dateAndTime) {
            while(scheduledTZDate.isBefore(nowTime)) {
                scheduledTZDate = tz.TZDateTime(tz.local, scheduledTZDate.year + 1, scheduledTZDate.month, scheduledTZDate.day, scheduledTZDate.hour, scheduledTZDate.minute);
            }
        }
      }

      await _plugin.zonedSchedule(
        id: baseId + schedule.offsetId,
        title: bill.title,
        body: schedule.message,
        scheduledDate: scheduledTZDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchComponents,
        payload: billId.toString(),
      );
    }
  }

  Future<void> cancelBillReminder(int id) async {
    final baseId = id * 10;
    for (int i = 0; i < 3; i++) {
        await _plugin.cancel(id: baseId + i);
    }
  }
}
