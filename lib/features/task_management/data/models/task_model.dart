import 'package:s/features/task_management/data/models/task_step_model.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    required super.id,
    required super.title,
    super.isCompleted,
    super.isImportant,
    super.dueDate,
    super.reminderDate,
    super.repeatMode,
    super.completedSteps,
    super.totalSteps,
    super.steps,
    super.listId,
    super.myDayDate,
    super.completedAt,
    super.isPinnedToNotification,
    super.position,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as List<dynamic>?;
    final steps = stepsJson != null
        ? stepsJson
            .map((e) => TaskStepModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <TaskStepModel>[];

    final completedSteps = steps.isNotEmpty
        ? steps.where((s) => s.isCompleted).length
        : (json['completedSteps'] as int? ?? 0);
    final totalSteps =
        steps.isNotEmpty ? steps.length : (json['totalSteps'] as int? ?? 0);

    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isImportant: json['isImportant'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      reminderDate: json['reminderDate'] != null
          ? DateTime.parse(json['reminderDate'] as String)
          : null,
      repeatMode: json['repeatMode'] as String?,
      completedSteps: completedSteps,
      totalSteps: totalSteps,
      steps: steps,
      listId: json['listId'] as String?,
      myDayDate: json['myDayDate'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isPinnedToNotification:
          json['isPinnedToNotification'] as bool? ?? false,
      position: json['position'] as int? ?? 0,
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
      isImportant: entity.isImportant,
      dueDate: entity.dueDate,
      reminderDate: entity.reminderDate,
      repeatMode: entity.repeatMode,
      completedSteps: entity.completedSteps,
      totalSteps: entity.totalSteps,
      steps: entity.steps,
      listId: entity.listId,
      myDayDate: entity.myDayDate,
      completedAt: entity.completedAt,
      isPinnedToNotification: entity.isPinnedToNotification,
      position: entity.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'isImportant': isImportant,
      'dueDate': dueDate?.toIso8601String(),
      'reminderDate': reminderDate?.toIso8601String(),
      'repeatMode': repeatMode,
      'completedSteps': completedSteps,
      'totalSteps': totalSteps,
      'steps': steps
          .map(
            (s) => TaskStepModel(
              id: s.id,
              title: s.title,
              isCompleted: s.isCompleted,
            ).toJson(),
          )
          .toList(),
      'listId': listId,
      'myDayDate': myDayDate,
      'completedAt': completedAt?.toIso8601String(),
      'isPinnedToNotification': isPinnedToNotification,
      'position': position,
    };
  }
}
