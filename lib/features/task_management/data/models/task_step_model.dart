import 'package:s/features/task_management/domain/entities/task_step.dart';

class TaskStepModel extends TaskStep {
  const TaskStepModel({
    required super.id,
    required super.title,
    super.isCompleted,
  });

  factory TaskStepModel.fromJson(Map<String, dynamic> json) {
    return TaskStepModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };
}
