String formatNumber(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final integerPart = parts[0];
  final decimalPart = parts[1];

  final formattedInteger = integerPart.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );

  if (decimalPart == '00') {
    return formattedInteger;
  }

  return '$formattedInteger,$decimalPart';
}
