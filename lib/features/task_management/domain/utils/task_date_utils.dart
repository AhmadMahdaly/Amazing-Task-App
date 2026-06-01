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

DateTime? taskCreatedAt(TaskEntity task) {
  final ms = int.tryParse(task.id);
  if (ms == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(ms);
}

DateTime getStartOfWeek(DateTime date) {
  final daysToSubtract = date.weekday == DateTime.sunday ? 0 : date.weekday;
  final start = date.subtract(Duration(days: daysToSubtract));
  return DateTime(start.year, start.month, start.day);
}

DateTime getEndOfWeek(DateTime date) {
  final start = getStartOfWeek(date);
  return start.add(
    const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
  );
}

DateTime getStartOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

DateTime getEndOfMonth(DateTime date) {
  final nextMonth = DateTime(date.year, date.month + 1, 1);
  return nextMonth.subtract(const Duration(seconds: 1));
}

List<TaskEntity> filterTasksByDateRange(
  List<TaskEntity> tasks,
  DateTime start,
  DateTime end,
) {
  return tasks.where((task) {
    if (task.dueDate == null) return false;
    return task.dueDate!.isAfter(start.subtract(const Duration(seconds: 1))) &&
        task.dueDate!.isBefore(end.add(const Duration(seconds: 1)));
  }).toList();
}
