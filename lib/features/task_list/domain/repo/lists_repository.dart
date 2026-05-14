import 'package:s/features/task_list/domain/entities/task_list_entity.dart';

abstract class ListsRepository {
  Future<List<TaskListEntity>> getLists();
  Future<void> addList(TaskListEntity list);
  Future<void> updateList(TaskListEntity list);
  Future<void> deleteList(String id);
}
