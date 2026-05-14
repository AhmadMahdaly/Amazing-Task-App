import 'dart:convert';

import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/features/task_list/data/models/task_list_model.dart';

abstract class ListsLocalDataSource {
  Future<List<TaskListModel>> fetchLists();
  Future<void> saveList(TaskListModel list);
  Future<void> updateList(TaskListModel list);
  Future<void> deleteList(String id);
}

class ListsLocalDataSourceImpl implements ListsLocalDataSource {
  static const String _listsCacheKey = CacheKeys.cachedLists;

  @override
  Future<List<TaskListModel>> fetchLists() async {
    final cachedData = CacheHelper.getData(_listsCacheKey);
    if (cachedData != null && cachedData is List) {
      try {
        return cachedData
            .map(
              (jsonString) => TaskListModel.fromJson(
                jsonDecode(jsonString as String) as Map<String, dynamic>? ?? {},
              ),
            )
            .toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> saveList(TaskListModel list) async {
    final lists = await fetchLists();
    lists.add(list);
    await _saveToCache(lists);
  }

  @override
  Future<void> updateList(TaskListModel list) async {
    final lists = await fetchLists();
    final index = lists.indexWhere((element) => element.id == list.id);
    if (index != -1) {
      lists[index] = list;
      await _saveToCache(lists);
    }
  }

  @override
  Future<void> deleteList(String id) async {
    final lists = await fetchLists();
    lists.removeWhere((element) => element.id == id);
    await _saveToCache(lists);
  }

  Future<void> _saveToCache(List<TaskListModel> lists) async {
    final stringLists = lists.map((list) => jsonEncode(list.toJson())).toList();
    await CacheHelper.saveData(key: _listsCacheKey, value: stringLists);
  }
}
