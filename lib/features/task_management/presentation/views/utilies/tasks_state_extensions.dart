import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

extension TasksStateExtensions on TasksState {
  TaskFilter? get currentFilter =>
      this is TasksLoaded ? (this as TasksLoaded).currentFilter : null;

  String? get currentListId =>
      this is TasksLoaded ? (this as TasksLoaded).currentListId : null;
}
