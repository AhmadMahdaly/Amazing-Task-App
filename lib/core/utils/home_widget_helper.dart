import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/di.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/repo/tasks_repository.dart';

class HomeWidgetHelper {
  static const String androidWidgetName = 'TaskAppWidgetProvider';

  static Future<void> syncTasksToWidget(List<TaskEntity> activeTasks) async {
    final List<Map<String, dynamic>> tasksList = activeTasks
        .map(
          (t) => {
            'id': t.id,
            'title': t.title,
            'listId': t.listId ?? '',
            'isCompleted': t.isCompleted,
          },
        )
        .toList();

    final tasksJson = jsonEncode(tasksList);

    await HomeWidget.saveWidgetData<String>('tasks_data', tasksJson);

    await HomeWidget.updateWidget(
      androidName: androidWidgetName,
    );
  }

  static Future<void> initialize() async {
    await HomeWidget.registerInteractivityCallback(interactiveCallback);
  }
}

@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? uri) async {
  if (uri != null && uri.host == 'completetask') {
    final taskId = uri.queryParameters['id'];
    if (taskId != null) {
      WidgetsFlutterBinding.ensureInitialized();

      if (!getIt.isRegistered<TasksRepository>()) {
        await CacheHelper.init();
        await setupGetIt();
      }

      try {
        final repo = getIt<TasksRepository>();
        final tasks = await repo.getTasks();

        final index = tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          final task = tasks[index];

          await repo.updateTask(
            task.copyWith(
              isCompleted: true,
              completedAt: DateTime.now(),
            ),
          );

          final updatedTasks = await repo.getTasks();
          final activeTasks = updatedTasks
              .where((t) => !t.isCompleted)
              .toList();

          await HomeWidgetHelper.syncTasksToWidget(activeTasks);
        }
      } catch (e) {
        debugPrint('Widget Background Error: $e');
      }
    }
  }
}
