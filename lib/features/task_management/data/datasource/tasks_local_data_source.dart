import 'dart:convert';

import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/features/task_management/data/models/task_model.dart';

abstract class TasksLocalDataSource {
  Future<List<TaskModel>> fetchTasks();
  Future<void> saveTask(TaskModel task);
  Future<void> deleteTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTasksWhereListId(String listId);
}

class TasksLocalDataSourceImpl implements TasksLocalDataSource {
  static const String _tasksCacheKey = CacheKeys.cachedTasks;

  @override
  Future<List<TaskModel>> fetchTasks() async {
    final cachedData = CacheHelper.getData(_tasksCacheKey);

    if (cachedData != null && cachedData is List) {
      try {
        return cachedData
            .map(
              (taskJsonString) => TaskModel.fromJson(
                jsonDecode(taskJsonString as String) as Map<String, dynamic>? ??
                    {},
              ),
            )
            .toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    final tasks = await fetchTasks();

    tasks.add(task);

    await _saveTasksToCache(tasks);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final tasks = await fetchTasks();

    final index = tasks.indexWhere((element) => element.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _saveTasksToCache(tasks);
    }
  }

  @override
  Future<void> deleteTask(TaskModel task) async {
    final tasks = await fetchTasks();

    tasks.removeWhere((element) => element.id == task.id);

    await _saveTasksToCache(tasks);
  }

  @override
  Future<void> deleteTasksWhereListId(String listId) async {
    final tasks = await fetchTasks();
    tasks.removeWhere((element) => element.listId == listId);
    await _saveTasksToCache(tasks);
  }

  Future<void> _saveTasksToCache(List<TaskModel> tasks) async {
    final stringTasks = tasks
        .map((taskModel) => jsonEncode(taskModel.toJson()))
        .toList();

    await CacheHelper.saveData(key: _tasksCacheKey, value: stringTasks);
  }
}
