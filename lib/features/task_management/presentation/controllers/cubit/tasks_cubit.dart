// ignore_for_file: parameter_assignments

import 'package:bloc/bloc.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/services/notification_action_handler.dart';
import 'package:s/core/services/notification_permission_helper.dart';
import 'package:s/core/services/task_notification_service.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/repo/tasks_repository.dart';
import 'package:s/features/task_management/domain/utils/my_day_utils.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit(this.tasksRepository, this.notificationService)
      : super(TasksInitial()) {
    notificationService.registerActionHandler(handleNotificationAction);
  }

  final TasksRepository tasksRepository;
  final TaskNotificationService notificationService;

  TaskFilter _currentFilter = TaskFilter.myDay;
  String _currentTitle = AppTexts.myDay;
  String? _currentListId;

  double get todayProgress {
    if (state is! TasksLoaded) return 0;
    final allTasks = (state as TasksLoaded).allTasks;
    final todayTasks = allTasks.where(isTaskInMyDay).toList();
    if (todayTasks.isEmpty) return 0;
    final completedCount = todayTasks.where((task) => task.isCompleted).length;
    return completedCount / todayTasks.length;
  }

  Future<void> handleNotificationAction(
    String taskId,
    String? actionId,
  ) async {
    await NotificationActionHandler.handleAction(taskId, actionId);
    await loadTasks();
  }

  Future<void> loadTasks({
    TaskFilter? filter,
    String? title,
    String? customListId,
  }) async {
    emit(TasksLoading());
    try {
      if (filter != null) {
        _currentFilter = filter;
        if (filter != TaskFilter.customList) {
          _currentListId = null;
        }
      }
      if (title != null) _currentTitle = title;
      if (customListId != null) _currentListId = customListId;

      final allTasks = await tasksRepository.getTasks();
      var filteredTasks = <TaskEntity>[];

      switch (_currentFilter) {
        case TaskFilter.allTasks:
          filteredTasks = allTasks;
        case TaskFilter.planned:
          filteredTasks = allTasks
              .where((task) => task.dueDate != null)
              .toList();
        case TaskFilter.customList:
          filteredTasks = allTasks
              .where((task) => task.listId == _currentListId)
              .toList();
        case TaskFilter.myDay:
          filteredTasks = allTasks.where(isTaskInMyDay).toList();
        case TaskFilter.completed:
          filteredTasks = allTasks.where((task) => task.isCompleted).toList();
        case TaskFilter.important:
          filteredTasks = allTasks.where((task) => task.isImportant).toList();
      }

      filteredTasks.sort((a, b) => a.position.compareTo(b.position));

      await notificationService.syncAll(allTasks);

      emit(
        TasksLoaded(
          tasks: filteredTasks,
          title: _currentTitle,
          currentFilter: _currentFilter,
          currentListId: _currentListId,
          allTasks: allTasks,
        ),
      );
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> toggleTaskCompletion(TaskEntity task) async {
    final isNowCompleted = !task.isCompleted;

    if (isNowCompleted && task.repeatMode != null) {
      final nextDueDate = _calculateNextDueDate(
        task.dueDate ?? DateTime.now(),
        task.repeatMode!,
      );

      final wasInMyDay = isTaskInMyDay(task);
      final nextTask = TaskEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: task.title,
        listId: task.listId,
        dueDate: nextDueDate,
        repeatMode: task.repeatMode,
        myDayDate: wasInMyDay ? formatMyDayDate(nextDueDate) : null,
        position: task.position,
        isImportant: task.isImportant,
      );

      await tasksRepository.addTask(nextTask);

      await tasksRepository.updateTask(
        task.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
          clearPin: true,
        ),
      );
    } else {
      var updated = task.copyWith(
        isCompleted: isNowCompleted,
        completedAt: isNowCompleted ? DateTime.now() : null,
        clearCompletedAt: !isNowCompleted,
      );
      if (isNowCompleted) {
        updated = updated.copyWith(clearPin: true);
      }
      await tasksRepository.updateTask(updated);
    }

    await loadTasks();
  }

  DateTime _calculateNextDueDate(DateTime baseDate, String repeatMode) {
    if (repeatMode.startsWith('custom:')) {
      final parts = repeatMode.split(':');
      final count = int.tryParse(parts[1]) ?? 1;
      final unit = parts[2];

      if (unit == 'days') return baseDate.add(Duration(days: count));
      if (unit == 'months') {
        return DateTime(baseDate.year, baseDate.month + count, baseDate.day);
      }
      if (unit == 'years') {
        return DateTime(baseDate.year + count, baseDate.month, baseDate.day);
      }

      if (unit == 'weeks') {
        final daysStr = parts.length > 3 ? parts[3] : '';
        if (daysStr.isEmpty) return baseDate.add(Duration(days: count * 7));

        final days =
            daysStr.split(',').map((e) => int.tryParse(e) ?? 1).toList()
              ..sort();

        final currentDay = baseDate.weekday;
        int? nextDay;

        for (final d in days) {
          if (d > currentDay) {
            nextDay = d;
            break;
          }
        }

        if (nextDay != null) {
          return baseDate.add(Duration(days: nextDay - currentDay));
        } else {
          final firstDay = days.first;
          final daysToNextFirstDay = (7 - currentDay) + firstDay;
          final extraWeeksDays = (count - 1) * 7;
          return baseDate.add(
            Duration(days: daysToNextFirstDay + extraWeeksDays),
          );
        }
      }
    }

    switch (repeatMode) {
      case 'daily':
        return baseDate.add(const Duration(days: 1));
      case 'weekdays':
        var addDays = 1;
        if (baseDate.weekday == DateTime.thursday) addDays = 3;
        if (baseDate.weekday == DateTime.friday) addDays = 2;
        return baseDate.add(Duration(days: addDays));
      case 'weekly':
        return baseDate.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(baseDate.year, baseDate.month + 1, baseDate.day);
      case 'yearly':
        return DateTime(baseDate.year + 1, baseDate.month, baseDate.day);
      default:
        return baseDate.add(const Duration(days: 1));
    }
  }

  Future<void> addToMyDay(TaskEntity task) async {
    await updateTask(
      task.copyWith(myDayDate: formatMyDayDate(DateTime.now())),
    );
  }

  Future<void> postponeToTomorrow(TaskEntity task) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await updateTask(
      task.copyWith(
        clearMyDayDate: true,
        dueDate: tomorrow,
      ),
    );
  }

  Future<void> removeFromMyDay(TaskEntity task) async {
    await updateTask(task.copyWith(clearMyDayDate: true));
  }

  Future<void> reorderTasks(
    int oldIndex,
    int newIndex,
    List<TaskEntity> currentTasks,
  ) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final task = currentTasks.removeAt(oldIndex);
    currentTasks.insert(newIndex, task);

    for (var i = 0; i < currentTasks.length; i++) {
      await tasksRepository.updateTask(
        currentTasks[i].copyWith(position: i),
      );
    }

    emit(
      TasksLoaded(
        tasks: currentTasks,
        title: _currentTitle,
        currentFilter: _currentFilter,
        currentListId: _currentListId,
        allTasks: (state as TasksLoaded).allTasks,
      ),
    );
  }

  Future<void> addTask(TaskEntity task) async {
    try {
      await tasksRepository.addTask(task);
      await loadTasks();
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    try {
      await tasksRepository.updateTask(task);
      await loadTasks();
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await notificationService.cancelPinned(id);
      await tasksRepository.deleteTask(id);
      await loadTasks();
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  /// Removes tasks whose [listId] matches (e.g. when a custom list is deleted).
  Future<void> deleteTasksForList(String listId) async {
    try {
      final all = await tasksRepository.getTasks();
      for (final t in all) {
        if (t.listId == listId) {
          await notificationService.cancelPinned(t.id);
        }
      }
      await tasksRepository.deleteTasksWhereListId(listId);
      await loadTasks();
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  /// Recreates an accidentally deleted task (same id).
  Future<void> restoreTask(TaskEntity task) async {
    await addTask(task);
  }

  /// Returns a permission result when pinning was blocked; `null` on success.
  Future<NotificationPermissionResult?> setPinnedToNotification(
    TaskEntity task, {
    required bool pinned,
  }) async {
    if (pinned) {
      final permission = await notificationService.ensurePermission();
      if (permission != NotificationPermissionResult.granted) {
        return permission;
      }
    }

    final updated = pinned
        ? task.copyWith(isPinnedToNotification: true)
        : task.copyWith(clearPin: true);
    await updateTask(updated);
    return null;
  }
}
