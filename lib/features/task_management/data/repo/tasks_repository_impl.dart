import 'package:s/features/task_management/data/datasource/tasks_local_data_source.dart';
import 'package:s/features/task_management/data/models/task_model.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/repo/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl(this.localDataSource);
  final TasksLocalDataSource localDataSource;

  @override
  Future<List<TaskEntity>> getTasks({String? filter}) async {
    return localDataSource.fetchTasks();
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task);
    await localDataSource.saveTask(taskModel);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task);
    await localDataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(String id) async {
    final taskModel = TaskModel(id: id, title: '');
    await localDataSource.deleteTask(taskModel);
  }

  @override
  Future<void> deleteTasksWhereListId(String listId) async {
    await localDataSource.deleteTasksWhereListId(listId);
  }
}
