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
    super.listId,
    super.myDayDate,
    super.position,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isImportant: json['isImportant'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      completedSteps: json['completedSteps'] as int? ?? 0,
      totalSteps: json['totalSteps'] as int? ?? 0,
      reminderDate: json['reminderDate'] != null
          ? DateTime.parse(json['reminderDate'] as String)
          : null,
      repeatMode: json['repeatMode'] as String?,
      listId: json['listId'] as String?,
      myDayDate: json['myDayDate'] as String?,
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
      listId: entity.listId,
      myDayDate: entity.myDayDate,
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
      'listId': listId,
      'myDayDate': myDayDate,
      'position': position,
    };
  }
}
