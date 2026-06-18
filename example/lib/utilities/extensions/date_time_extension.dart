import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Formats a date range between this date and [end] accurately:
  /// - Same month: 12 - 14 Nov 2026
  /// - Different month, same year: 12 Nov - 14 Dec 2026
  /// - Different year: 12 Nov 2025 - 14 Jan 2026
  String formatRange(DateTime? end, String locale) {
    if (end == null) {
      return DateFormat('dd MMM yyyy', locale).format(this);
    }

    if (year != end.year) {
      // Different years
      final startStr = DateFormat('dd MMM yyyy', locale).format(this);
      final endStr = DateFormat('dd MMM yyyy', locale).format(end);
      return '$startStr - $endStr';
    } else if (month != end.month) {
      // Same year, different months
      final startStr = DateFormat('dd MMM', locale).format(this);
      final endStr = DateFormat('dd MMM yyyy', locale).format(end);
      return '$startStr - $endStr';
    } else {
      // Same month, same year
      final startStr = DateFormat('dd', locale).format(this);
      final endStr = DateFormat('dd MMM yyyy', locale).format(end);
      return '$startStr - $endStr';
    }
  }
}
