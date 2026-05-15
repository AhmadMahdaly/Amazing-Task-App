import 'package:s/features/task_management/domain/entities/task_entity.dart';

/// Whether [task] belongs on My Day for [referenceDate] (defaults to now).
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

  if (task.repeatMode != null && !task.isCompleted) {
    return _isRecurringOccurrenceOnDate(task, today);
  }

  return false;
}

bool _isRecurringOccurrenceOnDate(TaskEntity task, DateTime today) {
  final anchor = task.dueDate != null
      ? _calendarDate(task.dueDate!)
      : _parseMyDayDate(task.myDayDate);
  if (anchor == null || today.isBefore(anchor)) {
    return false;
  }

  final mode = task.repeatMode!;
  if (mode.startsWith('custom:')) {
    return _isCustomRepeatOnDate(mode, anchor, today);
  }

  switch (mode) {
    case 'daily':
      return true;
    case 'weekdays':
      return today.weekday >= DateTime.monday &&
          today.weekday <= DateTime.friday;
    case 'weekly':
      return today.difference(anchor).inDays % 7 == 0;
    case 'monthly':
      return today.day == anchor.day &&
          !_isBeforeMonth(today, anchor);
    case 'yearly':
      return today.month == anchor.month &&
          today.day == anchor.day &&
          today.year >= anchor.year;
    default:
      return false;
  }
}

bool _isCustomRepeatOnDate(String mode, DateTime anchor, DateTime today) {
  final parts = mode.split(':');
  final count = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 1;
  final unit = parts.length > 2 ? parts[2] : 'days';

  switch (unit) {
    case 'days':
      final diff = today.difference(anchor).inDays;
      return diff >= 0 && diff % count == 0;
    case 'weeks':
      final daysStr = parts.length > 3 ? parts[3] : '';
      if (daysStr.isEmpty) {
        final diff = today.difference(anchor).inDays;
        return diff >= 0 && diff % (count * 7) == 0;
      }
      final weekdays = daysStr
          .split(',')
          .map((e) => int.tryParse(e) ?? -1)
          .where((d) => d >= DateTime.monday && d <= DateTime.sunday)
          .toList();
      if (!weekdays.contains(today.weekday)) {
        return false;
      }
      final weeksSince = today.difference(anchor).inDays ~/ 7;
      return weeksSince >= 0 && weeksSince % count == 0;
    case 'months':
      if (today.day != anchor.day) return false;
      final monthsSince =
          (today.year - anchor.year) * 12 + (today.month - anchor.month);
      return monthsSince >= 0 && monthsSince % count == 0;
    case 'years':
      if (today.month != anchor.month || today.day != anchor.day) {
        return false;
      }
      final yearsSince = today.year - anchor.year;
      return yearsSince >= 0 && yearsSince % count == 0;
    default:
      return false;
  }
}

bool _isBeforeMonth(DateTime a, DateTime b) {
  if (a.year != b.year) return a.year < b.year;
  return a.month < b.month;
}

DateTime _calendarDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool _isSameCalendarDay(DateTime a, DateTime b) {
  final ca = _calendarDate(a);
  final cb = _calendarDate(b);
  return ca == cb;
}

DateTime? _parseMyDayDate(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  } catch (_) {
    return null;
  }
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// ISO date string (yyyy-MM-dd) for [date].
String formatMyDayDate(DateTime date) => _formatDate(_calendarDate(date));
