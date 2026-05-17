import 'package:s/features/task_management/domain/entities/task_entity.dart';

bool isTaskInMyDay(TaskEntity task, {DateTime? referenceDate}) {
  referenceDate ??= DateTime.now();
  final today = _calendarDate(referenceDate);
  final todayStr = _formatDate(today);

  if (task.myDayDate == todayStr) {
    return true;
  }

  if (task.dueDate != null && _isSameCalendarDay(task.dueDate!, today)) {
    return true;
  }

  return false;
}

DateTime _calendarDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool _isSameCalendarDay(DateTime a, DateTime b) {
  final ca = _calendarDate(a);
  final cb = _calendarDate(b);
  return ca == cb;
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String formatMyDayDate(DateTime date) => _formatDate(_calendarDate(date));

String? deriveMyDayDateWhenAddingFromMyDayView({
  required DateTime reference,
  DateTime? dueDate,
  String? repeatMode,
}) {
  final tentative = TaskEntity(
    id: '_',
    title: '',
    dueDate: dueDate,
    repeatMode: repeatMode,
    position: 0,
  );

  return isTaskInMyDay(tentative, referenceDate: reference)
      ? formatMyDayDate(reference)
      : null;
}
