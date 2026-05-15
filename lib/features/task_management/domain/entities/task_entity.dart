import 'package:s/features/task_management/domain/entities/task_step.dart';

class TaskEntity {
  TaskEntity({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isImportant = false,
    this.dueDate,
    this.reminderDate,
    this.repeatMode,
    this.completedSteps = 0,
    this.totalSteps = 0,
    this.steps = const [],
    this.listId,
    this.myDayDate,
    this.completedAt,
    this.isPinnedToNotification = false,
    this.position = 0,
  });
  final String id;
  final String title;
  final bool isCompleted;
  final bool isImportant;
  final DateTime? dueDate;
  final DateTime? reminderDate;
  final String? repeatMode;
  final int completedSteps;
  final int totalSteps;
  final List<TaskStep> steps;
  final String? listId;
  final String? myDayDate;
  final DateTime? completedAt;
  final bool isPinnedToNotification;
  final int position;

  bool get hasSteps => steps.isNotEmpty;

  TaskEntity copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    bool? isImportant,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? reminderDate,
    String? repeatMode,
    bool clearRepeatMode = false,
    int? completedSteps,
    int? totalSteps,
    List<TaskStep>? steps,
    String? listId,
    bool clearListId = false,
    String? myDayDate,
    bool clearMyDayDate = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    bool? isPinnedToNotification,
    bool clearPin = false,
    int? position,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      reminderDate: reminderDate ?? this.reminderDate,
      repeatMode: clearRepeatMode ? null : (repeatMode ?? this.repeatMode),
      completedSteps: completedSteps ?? this.completedSteps,
      totalSteps: totalSteps ?? this.totalSteps,
      steps: steps ?? this.steps,
      listId: clearListId ? null : (listId ?? this.listId),
      myDayDate: clearMyDayDate ? null : (myDayDate ?? this.myDayDate),
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      isPinnedToNotification: clearPin
          ? false
          : (isPinnedToNotification ?? this.isPinnedToNotification),
      position: position ?? this.position,
    );
  }
}
