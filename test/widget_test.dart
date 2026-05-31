import 'package:finxl/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(
      envString: '''
SUPABASE_URL=https://localhost.test
SUPABASE_ANON_KEY=test
GOOGLE_WEB_CLIENT_ID=test-web-client
GOOGLE_IOS_CLIENT_ID=test-ios-client
''',
    );
    await Supabase.initialize(
      url: 'https://localhost.test',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIn0.'
          'test-signature',
    );
  });

  testWidgets('unauthenticated app shows welcome screen', (tester) async {
    await tester.pumpWidget(const FinXL(initialThemeMode: ThemeMode.system));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Track smarter. Spend wiser.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
