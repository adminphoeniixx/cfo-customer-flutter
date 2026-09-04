import 'package:intl/intl.dart';

final _inrFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final _inrFormatDecimal = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

/// ₹1,299 style formatting used throughout the app. Uses two decimals only
/// when the amount actually carries paise (tax-inclusive totals do).
String formatInr(num amount) {
  final isWhole = amount == amount.roundToDouble();
  return isWhole ? _inrFormat.format(amount) : _inrFormatDecimal.format(amount);
}

String formatDate(DateTime? dt) {
  if (dt == null) return '';
  return DateFormat('d MMM yyyy').format(dt.toLocal());
}

String formatDateTime(DateTime? dt) {
  if (dt == null) return '';
  return DateFormat('d MMM, h:mm a').format(dt.toLocal());
}
