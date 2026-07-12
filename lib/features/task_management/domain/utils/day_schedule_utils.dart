import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/my_day_utils.dart';

const int dayStartHour = 4;

List<int> getOrderedDayHours() {
  return List.generate(24, (index) => (dayStartHour + index) % 24);
}

DateTime logicalScheduleDate(DateTime reference) {
  if (reference.hour < dayStartHour) {
    return DateTime(
      reference.year,
      reference.month,
      reference.day,
    ).subtract(const Duration(days: 1));
  }
  return DateTime(reference.year, reference.month, reference.day);
}

bool isCurrentHourSlot(int hour, DateTime reference) {
  return reference.hour == hour;
}

String formatHourLabel(int hour) {
  if (hour == 0) return '12:00 AM';
  if (hour < 12) return '$hour:00 AM';
  if (hour == 12) return '12:00 PM';
  return '${hour - 12}:00 PM';
}

List<TaskEntity> todayActiveTasks(List<TaskEntity> allTasks) {
  return allTasks
      .where(isTaskInMyDay)
      .where((task) => !task.isCompleted)
      .toList();
}

List<TaskEntity> unscheduledTasks(List<TaskEntity> tasks) {
  return tasks.where((task) => task.scheduledHour == null).toList()
    ..sort((a, b) => a.position.compareTo(b.position));
}

List<TaskEntity> tasksForHour(List<TaskEntity> tasks, int hour) {
  return tasks.where((task) => task.scheduledHour == hour).toList()
    ..sort((a, b) => a.position.compareTo(b.position));
}

int hourSlotIndex(int hour) {
  return getOrderedDayHours().indexOf(hour);
}
