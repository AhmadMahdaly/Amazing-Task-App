import 'package:s/features/task_management/domain/entities/task_entity.dart';

abstract class TasksRepository {
  Future<List<TaskEntity>> getTasks({String? filter});
  Future<void> addTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
}
