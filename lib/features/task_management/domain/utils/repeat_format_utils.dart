import 'package:s/core/resources/app_text.dart';

String buildCustomRepeatMode({
  required int count,
  required String unit,
  required List<int> weekdays,
}) {
  if (unit == 'weeks') {
    final days = List<int>.from(weekdays)..sort();
    return 'custom:$count:weeks:${days.join(',')}';
  }
  return 'custom:$count:$unit';
}

String formatRepeatMode(String? mode) {
  if (mode == null || mode.isEmpty) return '';

  if (mode.startsWith('custom:')) {
    final parts = mode.split(':');
    if (parts.length < 3) return AppTexts.custom;

    final count = int.tryParse(parts[1]) ?? 1;
    final unit = parts[2];

    if (unit == 'weeks' && parts.length > 3 && parts[3].isNotEmpty) {
      final dayLabels = parts[3]
          .split(',')
          .map(_weekdayShortLabel)
          .where((l) => l.isNotEmpty)
          .join(', ');
      if (count == 1) {
        return '$dayLabels';
      }
      return '${AppTexts.repeatEvery} $count ${AppTexts.weeks}: $dayLabels';
    }

    final unitLabel = _unitLabel(unit);
    if (count == 1) {
      return unitLabel;
    }
    return '${AppTexts.repeatEvery} $count $unitLabel';
  }

  switch (mode) {
    case 'daily':
      return AppTexts.daily;
    case 'weekdays':
      return AppTexts.weekdays;
    case 'weekly':
      return AppTexts.weekly;
    case 'monthly':
      return AppTexts.monthly;
    case 'yearly':
      return AppTexts.yearly;
    default:
      return mode;
  }
}

bool isCustomRepeatMode(String? mode) =>
    mode != null && mode.startsWith('custom:');

class CustomRepeatInitialValues {
  const CustomRepeatInitialValues({
    required this.count,
    required this.unit,
    required this.weekdays,
  });

  final int count;
  final String unit;
  final List<int> weekdays;
}

CustomRepeatInitialValues? parseCustomRepeatMode(String? mode) {
  if (!isCustomRepeatMode(mode)) return null;

  final parts = mode!.split(':');
  final count = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 1;
  final unit = parts.length > 2 ? parts[2] : 'weeks';
  final weekdays = <int>[];

  if (unit == 'weeks' && parts.length > 3 && parts[3].isNotEmpty) {
    for (final part in parts[3].split(',')) {
      final day = int.tryParse(part);
      if (day != null &&
          day >= DateTime.monday &&
          day <= DateTime.sunday) {
        weekdays.add(day);
      }
    }
  }

  if (weekdays.isEmpty && unit == 'weeks') {
    weekdays.add(DateTime.now().weekday);
  }

  return CustomRepeatInitialValues(
    count: count,
    unit: unit,
    weekdays: weekdays,
  );
}

String _unitLabel(String unit) {
  switch (unit) {
    case 'days':
      return AppTexts.days;
    case 'weeks':
      return AppTexts.weeks;
    case 'months':
      return AppTexts.months;
    case 'years':
      return AppTexts.years;
    default:
      return unit;
  }
}

String _weekdayShortLabel(String value) {
  final day = int.tryParse(value);
  if (day == null) return '';
  switch (day) {
    case DateTime.sunday:
      return AppTexts.sunday;
    case DateTime.monday:
      return AppTexts.monday;
    case DateTime.tuesday:
      return AppTexts.tuesday;
    case DateTime.wednesday:
      return AppTexts.wednesday;
    case DateTime.thursday:
      return AppTexts.thursday;
    case DateTime.friday:
      return AppTexts.friday;
    case DateTime.saturday:
      return AppTexts.saturday;
    default:
      return '';
  }
}
