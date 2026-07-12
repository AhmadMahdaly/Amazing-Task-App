import 'package:intl/intl.dart';

class TaskFormatUtils {
  TaskFormatUtils._();

  /// 0 -> 12:00 AM
  /// 9 -> 09:00 AM
  /// 15 -> 03:00 PM
  static String formatHour(int hour) {
    final date = DateTime(2025, 1, 1, hour);
    return DateFormat('hh:mm a').format(date);
  }

  /// 9 -> 09 AM
  static String formatShortHour(int hour) {
    final date = DateTime(2025, 1, 1, hour);
    return DateFormat('hh a').format(date);
  }

  /// 9 -> 09:00
  static String format24Hour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  /// Converts minutes to readable text
  /// 30 -> 30 min
  /// 60 -> 1 h
  /// 90 -> 1 h 30 min
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (mins == 0) {
      return '$hours h';
    }

    return '$hours h $mins min';
  }

  /// Example:
  /// 09:30 AM - 10:15 AM
  static String formatTimeRange({
    required DateTime start,
    required DateTime end,
  }) {
    final formatter = DateFormat('hh:mm a');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
}
