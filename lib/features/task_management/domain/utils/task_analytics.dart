import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/my_day_utils.dart';
import 'package:s/features/task_management/domain/utils/task_date_utils.dart';

class DayTaskStats {
  const DayTaskStats({
    required this.date,
    required this.scheduledCount,
    required this.completedCount,
    required this.createdCount,
  });

  final DateTime date;
  final int scheduledCount;
  final int completedCount;
  final int createdCount;

  double get completionRate =>
      scheduledCount > 0 ? completedCount / scheduledCount : 0;
}

class MonthTaskStats {
  const MonthTaskStats({
    required this.year,
    required this.month,
    required this.scheduledCount,
    required this.completedCount,
    required this.createdCount,
    required this.pendingCount,
  });

  final int year;
  final int month;
  final int scheduledCount;
  final int completedCount;
  final int createdCount;
  final int pendingCount;

  double get completionRate =>
      scheduledCount > 0 ? completedCount / scheduledCount : 0;
}

class ListTaskStats {
  const ListTaskStats({
    required this.listId,
    required this.title,
    required this.totalTasks,
    required this.completedTasks,
  });

  final String listId;
  final String title;
  final int totalTasks;
  final int completedTasks;

  double get completionRate =>
      totalTasks > 0 ? completedTasks / totalTasks : 0;
}

class TaskAnalyticsSummary {
  const TaskAnalyticsSummary({
    required this.totalTasks,
    required this.completedTasks,
    required this.importantTasks,
    required this.recurringTasks,
    required this.todayScheduled,
    required this.todayCompleted,
    required this.overdueCount,
  });

  final int totalTasks;
  final int completedTasks;
  final int importantTasks;
  final int recurringTasks;
  final int todayScheduled;
  final int todayCompleted;
  final int overdueCount;

  double get overallCompletionRate =>
      totalTasks > 0 ? completedTasks / totalTasks : 0;

  double get todayCompletionRate =>
      todayScheduled > 0 ? todayCompleted / todayScheduled : 0;
}

/// Tasks scheduled for [day] (My Day rules + due date on that day).
int countScheduledOnDay(List<TaskEntity> tasks, DateTime day) {
  return tasks.where((t) => isTaskInMyDay(t, referenceDate: day)).length;
}

/// Tasks marked completed on the given day via completedAt.
int countCompletedOnDay(List<TaskEntity> tasks, DateTime day) {
  return tasks
      .where(
        (t) =>
            t.completedAt != null &&
            isSameCalendarDay(t.completedAt!, day),
      )
      .length;
}

/// Tasks created on [day] (from task id timestamp).
int countCreatedOnDay(List<TaskEntity> tasks, DateTime day) {
  return tasks.where((t) {
    final created = taskCreatedAt(t);
    return created != null && isSameCalendarDay(created, day);
  }).length;
}

List<DayTaskStats> computeDailyStats(
  List<TaskEntity> tasks, {
  int dayCount = 14,
  DateTime? referenceDate,
}) {
  final today = calendarDate(referenceDate ?? DateTime.now());
  final stats = <DayTaskStats>[];

  for (var i = dayCount - 1; i >= 0; i--) {
    final day = today.subtract(Duration(days: i));
    stats.add(
      DayTaskStats(
        date: day,
        scheduledCount: countScheduledOnDay(tasks, day),
        completedCount: countCompletedOnDay(tasks, day),
        createdCount: countCreatedOnDay(tasks, day),
      ),
    );
  }

  return stats;
}

List<MonthTaskStats> computeMonthlyStats(
  List<TaskEntity> tasks, {
  int monthCount = 6,
  DateTime? referenceDate,
}) {
  final now = referenceDate ?? DateTime.now();
  final stats = <MonthTaskStats>[];

  for (var i = monthCount - 1; i >= 0; i--) {
    final monthDate = DateTime(now.year, now.month - i, 1);
    final year = monthDate.year;
    final month = monthDate.month;
    final lastDay = DateTime(year, month + 1, 0).day;

    var scheduled = 0;
    for (var day = 1; day <= lastDay; day++) {
      scheduled += countScheduledOnDay(
        tasks,
        DateTime(year, month, day),
      );
    }

    final completed = tasks
        .where(
          (t) =>
              t.completedAt != null &&
              isDateInMonth(t.completedAt!, year, month),
        )
        .length;

    final created = tasks.where((t) {
      final createdAt = taskCreatedAt(t);
      return createdAt != null && isDateInMonth(createdAt, year, month);
    }).length;

    final pending = tasks
        .where(
          (t) =>
              !t.isCompleted &&
              t.dueDate != null &&
              isDateInMonth(t.dueDate!, year, month),
        )
        .length;

    stats.add(
      MonthTaskStats(
        year: year,
        month: month,
        scheduledCount: scheduled,
        completedCount: completed,
        createdCount: created,
        pendingCount: pending,
      ),
    );
  }

  return stats;
}

TaskAnalyticsSummary computeSummary(List<TaskEntity> tasks) {
  final today = calendarDate(DateTime.now());
  final todayScheduled = countScheduledOnDay(tasks, today);
  final todayCompleted = countCompletedOnDay(tasks, today);

  final overdueCount = tasks.where((t) {
    if (t.isCompleted || t.dueDate == null) return false;
    return calendarDate(t.dueDate!).isBefore(today);
  }).length;

  return TaskAnalyticsSummary(
    totalTasks: tasks.length,
    completedTasks: tasks.where((t) => t.isCompleted).length,
    importantTasks: tasks.where((t) => t.isImportant).length,
    recurringTasks: tasks.where((t) => t.repeatMode != null).length,
    todayScheduled: todayScheduled,
    todayCompleted: todayCompleted,
    overdueCount: overdueCount,
  );
}

List<ListTaskStats> computeListStats(
  List<TaskEntity> tasks,
  Map<String, String> listTitles,
) {
  final byList = <String, List<TaskEntity>>{};

  for (final task in tasks) {
    final key = task.listId ?? '';
    byList.putIfAbsent(key, () => []).add(task);
  }

  return byList.entries.map((entry) {
    final listId = entry.key;
    final listTasks = entry.value;
    return ListTaskStats(
      listId: listId,
      title: listId.isEmpty
          ? ''
          : (listTitles[listId] ?? ''),
      totalTasks: listTasks.length,
      completedTasks: listTasks.where((t) => t.isCompleted).length,
    );
  }).toList()
    ..sort((a, b) => b.totalTasks.compareTo(a.totalTasks));
}
