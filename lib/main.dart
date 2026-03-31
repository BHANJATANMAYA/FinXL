import 'package:finxl/app.dart';
import 'package:finxl/core/notifications/local_notification_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.instance.initialize();
  runApp(const FinXL());
}
