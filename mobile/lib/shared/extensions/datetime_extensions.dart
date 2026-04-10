import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String toTimestamp() => DateFormat('yyyy-MM-dd HH:mm').format(toLocal());

  String toTimeOnly() => DateFormat('HH:mm').format(toLocal());

  String toShortDate() => DateFormat('yyyy-MM-dd').format(toLocal());

  bool isExpiringSoon() =>
      difference(DateTime.now().toUtc()).inMinutes < 10 &&
      isAfter(DateTime.now().toUtc());
}
