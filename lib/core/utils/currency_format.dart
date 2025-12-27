import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  return NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}
