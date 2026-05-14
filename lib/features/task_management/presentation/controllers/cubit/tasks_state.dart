part of 'tasks_cubit.dart';

enum TaskFilter { myDay, allTasks, planned, customList, completed, important }

abstract class TasksState {}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  TasksLoaded({
    required this.tasks,
    required this.allTasks,
    required this.title,
    required this.currentFilter,
    this.currentListId,
  });
  final List<TaskEntity> tasks;
  final List<TaskEntity> allTasks;
  final String title;
  final TaskFilter currentFilter;
  final String? currentListId;
}

class TasksError extends TasksState {
  TasksError(this.message);
  final String message;
}
