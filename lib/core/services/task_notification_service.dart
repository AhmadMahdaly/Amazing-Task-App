import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/task_format_utils.dart';

const String actionUnpin = 'unpin';
const String actionDelete = 'delete';

@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  TaskNotificationService.handleBackgroundResponse(response);
}

typedef TaskNotificationActionHandler = Future<void> Function(
  String taskId,
  String? actionId,
);

class TaskNotificationService {
  TaskNotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  TaskNotificationActionHandler? _actionHandler;
  final Set<int> _activeNotificationIds = {};

  static const _channelId = 'pinned_tasks';
  static const _channelName = 'Pinned Tasks';

  static TaskNotificationService? _instance;

  static TaskNotificationService get instance {
    return _instance ??= TaskNotificationService();
  }

  static void handleBackgroundResponse(NotificationResponse response) {
    final taskId = response.payload;
    if (taskId == null || taskId.isEmpty) return;
    unawaited(
      instance._dispatchAction(taskId, response.actionId),
    );
  }

  void registerActionHandler(TaskNotificationActionHandler handler) {
    _actionHandler = handler;
  }

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  void _onNotificationResponse(NotificationResponse response) {
    final taskId = response.payload;
    if (taskId == null || taskId.isEmpty) return;
    unawaited(_dispatchAction(taskId, response.actionId));
  }

  Future<void> _dispatchAction(String taskId, String? actionId) async {
    final handler = _actionHandler;
    if (handler == null) return;
    await handler(taskId, actionId);
  }

  int notificationIdFor(String taskId) => taskId.hashCode.abs() % 2147483646 + 1;

  Future<void> syncAll(List<TaskEntity> tasks) async {
    final pinnedActive = tasks
        .where((t) => t.isPinnedToNotification && !t.isCompleted)
        .toList();
    final keepIds = pinnedActive.map((t) => notificationIdFor(t.id)).toSet();

    for (final task in pinnedActive) {
      await showPinned(task);
    }

    final staleIds = _activeNotificationIds.difference(keepIds).toList();
    for (final id in staleIds) {
      await _plugin.cancel(id: id);
      _activeNotificationIds.remove(id);
    }
  }

  Future<void> syncTask(TaskEntity task) async {
    if (task.isPinnedToNotification && !task.isCompleted) {
      await showPinned(task);
    } else {
      await cancelPinned(task.id);
    }
  }

  Future<void> showPinned(TaskEntity task) async {
    final id = notificationIdFor(task.id);
    final body = _buildBody(task);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: AppTexts.pinnedTasksChannelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: true,
      autoCancel: false,
      category: AndroidNotificationCategory.status,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          actionUnpin,
          AppTexts.unpin,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          actionDelete,
          AppTexts.delete,
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    await _plugin.show(
      id: id,
      title: task.title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      ),
      payload: task.id,
    );
    _activeNotificationIds.add(id);
  }

  Future<void> cancelPinned(String taskId) async {
    final id = notificationIdFor(taskId);
    await _plugin.cancel(id: id);
    _activeNotificationIds.remove(id);
  }

  String _buildBody(TaskEntity task) {
    final parts = <String>[AppTexts.pinnedTaskLabel];
    if (task.dueDate != null) {
      parts.add('${AppTexts.dueDate}: ${formatTaskDate(task.dueDate)}');
    }
    if (task.hasSteps) {
      parts.add('${task.completedSteps}/${task.totalSteps} ${AppTexts.steps}');
    }
    return parts.join(' • ');
  }
}
