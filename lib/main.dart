import 'package:finxl/app.dart';
import 'package:finxl/core/notifications/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = true;

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await LocalNotificationService.instance.initialize();

  ThemeMode initialThemeMode = ThemeMode.light;
  try {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('theme_mode');
    if (modeIndex != null && modeIndex >= 0 && modeIndex < ThemeMode.values.length) {
      initialThemeMode = ThemeMode.values[modeIndex];
    }
  } catch (_) {
    // Fail silently, default to light
  }

  runApp(FinXL(initialThemeMode: initialThemeMode));
}
