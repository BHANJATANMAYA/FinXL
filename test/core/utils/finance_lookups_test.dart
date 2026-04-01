import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('billSectionLabel marks past dates as overdue', () {
    final label = FinanceLookups.billSectionLabel(
      DateTime(2026, 4, 1),
      DateTime(2026, 4, 3),
    );

    expect(label, 'Overdue');
  });

  test('shortWeekdayLabel follows the supplied date', () {
    final label = FinanceLookups.shortWeekdayLabel(
      DateTime(2026, 4, 1),
      uppercase: true,
    );

    expect(label, 'WED');
  });
}
