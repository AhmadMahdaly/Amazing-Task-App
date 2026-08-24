import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/di.dart';
import 'package:s/core/services/task_notification_service.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/repo/tasks_repository.dart';

/// Handles notification actions in foreground and background isolates.
class NotificationActionHandler {
  static Future<void> ensureInitialized() async {
    WidgetsFlutterBinding.ensureInitialized();
    await CacheHelper.init();
    if (!GetIt.instance.isRegistered<TasksRepository>()) {
      await setupGetIt();
    }
  }

  static Future<void> handleAction(String taskId, String? actionId) async {
    await handle(
      NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: actionId,
        payload: taskId,
      ),
    );
  }

  static Future<void> handle(NotificationResponse response) async {
    final taskId = response.payload;
    if (taskId == null || taskId.isEmpty) return;

    await ensureInitialized();

    final repository = getIt<TasksRepository>();
    final notifications = getIt<TaskNotificationService>();
    final actionId = response.actionId;

    TaskEntity? task;
    final tasks = await repository.getTasks();
    for (final item in tasks) {
      if (item.id == taskId) {
        task = item;
        break;
      }
    }

    if (actionId == actionDelete) {
      await notifications.cancelPinned(taskId);
      await repository.deleteTask(taskId);
      return;
    }

    if (task == null) return;

    if (actionId == actionUnpin) {
      await notifications.cancelPinned(taskId);
      await repository.updateTask(task.copyWith(clearPin: true));
    }
  }
}
