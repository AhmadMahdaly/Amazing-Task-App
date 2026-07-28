bool shouldShowFridayWidget() {
  final now = DateTime.now();

  final start = DateTime(
    now.year,
    now.month,
    now.day,
  );

  if (now.weekday == DateTime.thursday) {
    final startTime = start.add(const Duration(hours: 15));
    return now.isAfter(startTime) || now.isAtSameMomentAs(startTime);
  }

  if (now.weekday == DateTime.friday) {
    final endTime = start.add(const Duration(hours: 21));
    return now.isBefore(endTime) || now.isAtSameMomentAs(endTime);
  }

  return false;
}
