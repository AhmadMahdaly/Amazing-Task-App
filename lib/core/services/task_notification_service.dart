// ignore_for_file: prefer_constructors_over_static_methods, use_setters_to_change_properties

import 'dart:async';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/services/notification_action_handler.dart';
import 'package:s/core/services/notification_permission_helper.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/task_format_utils.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String actionUnpin = 'unpin';
const String actionDelete = 'delete';

@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  await NotificationActionHandler.handle(response);
}

typedef TaskNotificationActionHandler =
    Future<void> Function(
      String taskId,
      String? actionId,
    );

class TaskNotificationService {
  TaskNotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  TaskNotificationActionHandler? _actionHandler;
  final Set<int> _activeNotificationIds = {};
  var _initialized = false;

  static const _channelId = 'pinned_tasks';
  static const _channelName = 'Pinned Tasks';
  static const _scheduledChannelId = 'scheduled_tasks';
  static const _scheduledChannelName = 'Scheduled Tasks';
  static TaskNotificationService? _instance;
  static TaskNotificationService get instance {
    return _instance ??= TaskNotificationService();
  }

  void registerActionHandler(TaskNotificationActionHandler handler) {
    _actionHandler = handler;
  }

  /// Initializes the plugin and notification channel (no permission dialog).
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    try {
      // 1. الحصول على كائن المنطقة الزمنية
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();

      // 2. استخراج النص الصحيح باستخدام identifier
      final timeZoneName = timezoneInfo.identifier;

      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // حل بديل آمن لمنع انهيار التطبيق إذا فشل جلب التوقيت المحلي
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    }
    const androidSettings = AndroidInitializationSettings(
      '@drawable/image',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: false,
      defaultPresentSound: false,
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

    await _createAndroidChannel();
    await _createScheduledAndroidChannel();
    _initialized = true;
  }

  Future<void> _createAndroidChannel() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    final channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      enableVibration: false,
      playSound: false,
      description: AppTexts.pinnedTasksChannelDesc,
      importance: Importance.defaultImportance,
    );

    await androidPlugin.createNotificationChannel(channel);
  }

  /// Requests notification permission when the user opts in to pin a task.
  Future<NotificationPermissionResult> ensurePermission() {
    return NotificationPermissionHelper.ensureGranted();
  }

  Future<bool> hasPermission() => NotificationPermissionHelper.isGranted();

  void _onNotificationResponse(NotificationResponse response) {
    unawaited(_handleResponse(response));
  }

  Future<void> _handleResponse(NotificationResponse response) async {
    final taskId = response.payload;
    if (taskId == null || taskId.isEmpty) return;

    final handler = _actionHandler;
    if (handler != null) {
      await handler(taskId, response.actionId);
      return;
    }

    await NotificationActionHandler.handle(response);
  }

  int notificationIdFor(String taskId) =>
      taskId.hashCode.abs() % 2147483646 + 1;

  Future<void> syncAll(List<TaskEntity> tasks) async {
    if (!await hasPermission()) return;

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

  Future<bool> showPinned(TaskEntity task) async {
    if (!await hasPermission()) return false;

    final id = notificationIdFor(task.id);
    final body = _buildBody(task);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: AppTexts.pinnedTasksChannelDesc,
      color: const Color(0xFF2E7D32),
      colorized: true,

      importance: Importance.high,
      priority: Priority.high,

      ongoing: true,
      autoCancel: false,
      silent: true,
      onlyAlertOnce: true,

      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,

      showWhen: true,

      showProgress: task.hasSteps,
      maxProgress: task.totalSteps,
      progress: task.completedSteps,

      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: task.title,
        summaryText: AppTexts.pinnedTaskLabel,
      ),

      actions: [
        AndroidNotificationAction(
          actionUnpin,
          AppTexts.unpin,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          actionDelete,
          AppTexts.delete,
          showsUserInterface: true,

          cancelNotification: true,
        ),
      ],
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: false,
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
    return true;
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

  Future<void> _createScheduledAndroidChannel() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;

    const channel = AndroidNotificationChannel(
      _scheduledChannelId,
      _scheduledChannelName,
      description: 'Notifications for scheduled reminders',
      importance: Importance.high,
      playSound: true,
    );
    await androidPlugin.createNotificationChannel(channel);
  }

  // نحتاج إلى ID مختلف للإشعارات المجدولة حتى لا تتعارض مع الإشعارات المثبتة (Pinned)
  int scheduledNotificationIdFor(String taskId) =>
      (taskId.hashCode.abs() % 2147483646) + 100000;

  /// جدولة إشعار لتاريخ ووقت معين
  Future<void> scheduleReminder(TaskEntity task, DateTime scheduledTime) async {
    if (!await hasPermission()) return;

    // لا تقم بجدولة إشعار في الماضي
    if (scheduledTime.isBefore(DateTime.now())) return;

    final id = scheduledNotificationIdFor(task.id);

    const androidDetails = AndroidNotificationDetails(
      _scheduledChannelId,
      _scheduledChannelName,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: task.title,
      body: task.note ?? AppTexts.taskReminder, // أو أي نص تفضله
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );
  }

  /// إلغاء الإشعار المجدول (مثلاً عند حذف المهمة أو اكتمالها)
  Future<void> cancelScheduledReminder(String taskId) async {
    final id = scheduledNotificationIdFor(taskId);
    await _plugin.cancel(id: id);
  }
}
