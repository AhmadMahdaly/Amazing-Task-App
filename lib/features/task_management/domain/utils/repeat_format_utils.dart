import 'package:s/core/resources/app_text.dart';

String buildCustomRepeatMode({
  required int count,
  required String unit,
  required List<int> weekdays,
  int? monthDay,
  int? yearMonth,
  int? yearDay,
}) {
  if (unit == 'weeks') {
    final days = List<int>.from(weekdays)..sort();
    return 'custom:$count:weeks:${days.join(',')}';
  } else if (unit == 'months') {
    return 'custom:$count:months:${monthDay ?? 1}';
  } else if (unit == 'years') {
    return 'custom:$count:years:${yearMonth ?? 1}-${yearDay ?? 1}';
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
      final daysStr = parts[3];
      final days = daysStr.split(',').map((e) => int.tryParse(e) ?? 0).toList()
        ..sort();
      final dStr = days.join(',');

      final dayLabels = daysStr
          .split(',')
          .map(_weekdayShortLabel)
          .where((l) => l.isNotEmpty)
          .join(', ');

      if (count == 1) {
        if (dStr == '1,2,3,4,5' || dStr == '1,2,3,4,7') {
          return AppTexts.weekdays;
        }
        if (days.length == 1) return '${AppTexts.weekly} ($dayLabels)';
        return dayLabels;
      }
      return '${AppTexts.repeatEvery} $count ${AppTexts.weeks}: $dayLabels';
    } else if (unit == 'months' && parts.length > 3 && parts[3].isNotEmpty) {
      final day = parts[3];
      if (count == 1) return '${AppTexts.monthly} (يوم $day)';
      return '${AppTexts.repeatEvery} $count ${_unitLabel(unit)}: يوم $day';
    } else if (unit == 'years' && parts.length > 3 && parts[3].isNotEmpty) {
      final md = parts[3].split('-');
      if (md.length == 2) {
        if (count == 1) return '${AppTexts.yearly} (${md[1]}/${md[0]})';
        return '${AppTexts.repeatEvery} $count ${_unitLabel(unit)}: ${md[1]}/${md[0]}';
      }
    }

    final unitLabel = _unitLabel(unit);
    if (count == 1) return unitLabel;
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
    required this.monthDay,
    required this.yearMonth,
    required this.yearDay,
  });

  final int count;
  final String unit;
  final List<int> weekdays;
  final int monthDay;
  final int yearMonth;
  final int yearDay;
}

CustomRepeatInitialValues? parseCustomRepeatMode(String? mode) {
  if (!isCustomRepeatMode(mode)) return null;

  final parts = mode!.split(':');
  final count = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 1;
  final unit = parts.length > 2 ? parts[2] : 'weeks';
  final weekdays = <int>[];
  var monthDay = DateTime.now().day;
  var yearMonth = DateTime.now().month;
  var yearDay = DateTime.now().day;

  if (unit == 'weeks' && parts.length > 3 && parts[3].isNotEmpty) {
    for (final part in parts[3].split(',')) {
      final day = int.tryParse(part);
      if (day != null && day >= DateTime.monday && day <= DateTime.sunday) {
        weekdays.add(day);
      }
    }
  } else if (unit == 'months' && parts.length > 3 && parts[3].isNotEmpty) {
    monthDay = int.tryParse(parts[3]) ?? DateTime.now().day;
  } else if (unit == 'years' && parts.length > 3 && parts[3].isNotEmpty) {
    final md = parts[3].split('-');
    if (md.length == 2) {
      yearMonth = int.tryParse(md[0]) ?? DateTime.now().month;
      yearDay = int.tryParse(md[1]) ?? DateTime.now().day;
    }
  }

  if (weekdays.isEmpty && unit == 'weeks') weekdays.add(DateTime.now().weekday);

  return CustomRepeatInitialValues(
    count: count,
    unit: unit,
    weekdays: weekdays,
    monthDay: monthDay,
    yearMonth: yearMonth,
    yearDay: yearDay,
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
