import 'package:finxl/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell renders tabs and opens transaction composer', (tester) async {
    await tester.pumpWidget(const FinXL());
    await tester.pumpAndSettle();

    expect(find.text('TOTAL BALANCE'), findsOneWidget);
    expect(find.text('INSIGHTS'), findsOneWidget);

    await tester.tap(find.text('INSIGHTS'));
    await tester.pumpAndSettle();

    expect(find.text('Category Distribution'), findsOneWidget);

    await tester.tap(find.text('HOME'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add transaction'));
    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsWidgets);
    expect(find.text('Payment Method'), findsOneWidget);
  });
}
