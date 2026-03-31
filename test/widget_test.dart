import 'package:finxl/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell exposes bottom navigation and add action', (
    tester,
  ) async {
    await tester.pumpWidget(const FinXL());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('INSIGHTS'), findsOneWidget);
    expect(find.text('GOALS'), findsOneWidget);
    expect(find.text('BUDGET'), findsOneWidget);
    expect(find.text('BILLS'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
