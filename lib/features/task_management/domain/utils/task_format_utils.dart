import 'package:s/core/resources/app_text.dart';

String formatTaskDate(DateTime? date) {
  if (date == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final value = DateTime(date.year, date.month, date.day);
  final diff = value.difference(today).inDays;

  if (diff == 0) return AppTexts.today;
  if (diff == 1) return AppTexts.tomorrow;
  if (diff == -1) return AppTexts.yesterday;
  return '${date.day}/${date.month}/${date.year}';
}

String formatCompletedDate(DateTime? date) {
  if (date == null) return AppTexts.completedDateUnknown;
  return '${AppTexts.completedOn} ${formatTaskDate(date)} • '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String formatDateHeader(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final value = DateTime(date.year, date.month, date.day);
  final diff = value.difference(today).inDays;

  if (diff == 0) return AppTexts.today;
  if (diff == -1) return AppTexts.yesterday;
  return '${date.day}/${date.month}/${date.year}';
}
