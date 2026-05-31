import 'package:finxl/core/models/bill.dart';
import 'package:finxl/core/notifications/local_notification_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// Fake FlutterLocalNotificationsPlugin implementation using standard Fake interface
class FakeFlutterLocalNotificationsPlugin extends Fake implements FlutterLocalNotificationsPlugin {
  final List<Map<String, dynamic>> zonedSchedules = [];
  final List<int> cancelledIds = [];
  bool isInitialized = false;
  InitializationSettings? initSettings;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback? onDidReceiveBackgroundNotificationResponse,
  }) async {
    isInitialized = true;
    initSettings = settings;
    return true;
  }

  @override
  T? resolvePlatformSpecificImplementation<T extends FlutterLocalNotificationsPlatform>() {
    // Return null to simulate safe execution without throwing on different platforms
    return null;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    zonedSchedules.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'notificationDetails': notificationDetails,
      'androidScheduleMode': androidScheduleMode,
      'matchDateTimeComponents': matchDateTimeComponents,
      'payload': payload,
    });
  }

  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelledIds.add(id);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const timezoneChannel = MethodChannel('flutter_timezone');
  final List<MethodCall> timezoneCalls = [];

  setUp(() {
    timezoneCalls.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezoneChannel, (MethodCall methodCall) async {
      timezoneCalls.add(methodCall);
      if (methodCall.method == 'getLocalTimezone') {
        return 'America/New_York';
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezoneChannel, null);
  });

  test('LocalNotificationService initialization requests permissions and registers settings', () async {
    final mockPlugin = FakeFlutterLocalNotificationsPlugin();
    // Use the custom factory constructor with dependency injection
    final service = LocalNotificationService.internal(mockPlugin);

    await service.initialize();

    // Verify method calls were invoked
    expect(timezoneCalls.any((call) => call.method == 'getLocalTimezone'), isTrue);
    expect(mockPlugin.isInitialized, isTrue);
    expect(mockPlugin.initSettings, isNotNull);
  });

  test('syncBillReminder schedules 3 notification occurrences for active unpaid bill', () async {
    final mockPlugin = FakeFlutterLocalNotificationsPlugin();
    final service = LocalNotificationService.internal(mockPlugin);
    await service.initialize();

    final bill = Bill(
      id: 42,
      title: 'Electricity Bill',
      amount: 1500.0,
      dueDate: DateTime.now().add(const Duration(days: 10)),
      isPaid: false,
      recurrence: 'monthly',
      type: 'bill',
      isActive: true,
    );

    await service.syncBillReminder(bill);

    // There should be 3 notifications scheduled (7 days before, 1 day before, and due date)
    expect(mockPlugin.zonedSchedules.length, equals(3));

    // Verify their IDs and contents
    expect(mockPlugin.zonedSchedules[0]['id'], equals(420)); // baseId + 0
    expect(mockPlugin.zonedSchedules[0]['title'], equals('Electricity Bill'));
    expect(mockPlugin.zonedSchedules[0]['body'], contains('due next week'));

    expect(mockPlugin.zonedSchedules[1]['id'], equals(421)); // baseId + 1
    expect(mockPlugin.zonedSchedules[1]['body'], contains('due tomorrow'));

    expect(mockPlugin.zonedSchedules[2]['id'], equals(422)); // baseId + 2
    expect(mockPlugin.zonedSchedules[2]['body'], contains('Due Today'));
  });

  test('syncBillReminder cancels notifications if bill is inactive or paid', () async {
    final mockPlugin = FakeFlutterLocalNotificationsPlugin();
    final service = LocalNotificationService.internal(mockPlugin);
    await service.initialize();

    final bill = Bill(
      id: 42,
      title: 'Electricity Bill',
      amount: 1500.0,
      dueDate: DateTime.now().add(const Duration(days: 10)),
      isPaid: true, // paid
      recurrence: 'monthly',
      type: 'bill',
      isActive: true,
    );

    await service.syncBillReminder(bill);

    // It should cancel existing ones (ids: 420, 421, 422) and not schedule new ones
    expect(mockPlugin.cancelledIds, containsAll([420, 421, 422]));
    expect(mockPlugin.zonedSchedules, isEmpty);
  });
}
