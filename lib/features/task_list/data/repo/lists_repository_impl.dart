import 'package:s/features/task_list/data/datasource/lists_local_data_source.dart';
import 'package:s/features/task_list/domain/repo/lists_repository.dart';

import '../../domain/entities/task_list_entity.dart';
import '../models/task_list_model.dart';

class ListsRepositoryImpl implements ListsRepository {
  ListsRepositoryImpl(this.localDataSource);
  final ListsLocalDataSource localDataSource;

  @override
  Future<List<TaskListEntity>> getLists() async {
    return localDataSource.fetchLists();
  }

  @override
  Future<void> addList(TaskListEntity list) async {
    await localDataSource.saveList(TaskListModel.fromEntity(list));
  }

  @override
  Future<void> updateList(TaskListEntity list) async {
    await localDataSource.updateList(TaskListModel.fromEntity(list));
  }

  @override
  Future<void> deleteList(String id) async {
    await localDataSource.deleteList(id);
  }
}
