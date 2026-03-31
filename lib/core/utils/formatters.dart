String formatCurrency(num amount, {String symbol = '₹', int decimals = 0}) {
  final fixed = amount.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final integer = parts.first;
  final decimalPart = parts.length > 1 && decimals > 0 ? '.${parts.last}' : '';

  String grouped;
  if (integer.length <= 3) {
    grouped = integer;
  } else {
    final lastThree = integer.substring(integer.length - 3);
    var leading = integer.substring(0, integer.length - 3);
    final groups = <String>[];

    while (leading.length > 2) {
      groups.insert(0, leading.substring(leading.length - 2));
      leading = leading.substring(0, leading.length - 2);
    }

    if (leading.isNotEmpty) {
      groups.insert(0, leading);
    }

    grouped = '${groups.join(',')},$lastThree';
  }

  final prefix = amount.isNegative ? '-' : '';
  return '$prefix$symbol$grouped$decimalPart';
}

String formatPercent(num value) => '${value.toStringAsFixed(0)}%';
