import 'package:intl/intl.dart';

String formatDate(String? dateStr, {String pattern = 'MMM d, yyyy'}) {
  if (dateStr == null) return '';
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat(pattern).format(date);
  } catch (e) {
    return dateStr;
  }
} 