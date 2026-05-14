import '../../domain/entities/task_list_entity.dart';

class TaskListModel extends TaskListEntity {
  TaskListModel({
    required super.id,
    required super.title,
    super.position,
  });

  factory TaskListModel.fromEntity(TaskListEntity entity) {
    return TaskListModel(
      id: entity.id,
      title: entity.title,
      position: entity.position,
    );
  }

  factory TaskListModel.fromJson(Map<String, dynamic> json) {
    return TaskListModel(
      id: json['id'] as String,
      title: json['title'] as String,
      position: json['position'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'position': position,
    };
  }
}
