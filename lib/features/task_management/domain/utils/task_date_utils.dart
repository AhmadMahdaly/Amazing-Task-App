import 'package:s/features/task_management/domain/entities/task_entity.dart';

DateTime calendarDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool isSameCalendarDay(DateTime a, DateTime b) {
  final ca = calendarDate(a);
  final cb = calendarDate(b);
  return ca == cb;
}

bool isDateInMonth(DateTime date, int year, int month) =>
    date.year == year && date.month == month;

/// Task ids are millisecond timestamps from creation time.
DateTime? taskCreatedAt(TaskEntity task) {
  final ms = int.tryParse(task.id);
  if (ms == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(ms);
}
