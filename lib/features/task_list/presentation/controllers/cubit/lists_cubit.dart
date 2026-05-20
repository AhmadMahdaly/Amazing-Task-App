import 'package:bloc/bloc.dart';
import 'package:s/features/task_list/domain/entities/task_list_entity.dart';
import 'package:s/features/task_list/domain/repo/lists_repository.dart';

part 'lists_state.dart';

class ListsCubit extends Cubit<ListsState> {
  ListsCubit(this.listsRepository) : super(ListsInitial());
  final ListsRepository listsRepository;

  Future<void> loadLists() async {
    emit(ListsLoading());
    try {
      final lists = await listsRepository.getLists();

      lists.sort((a, b) => a.position.compareTo(b.position));
      emit(ListsLoaded(lists));
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }

  Future<bool> addList(TaskListEntity list) async {
    try {
      final existing = await listsRepository.getLists();
      final listWithPosition = TaskListEntity(
        id: list.id,
        title: list.title,
        position: _nextListPosition(existing),
        iconCode: list.iconCode,
      );
      await listsRepository.addList(listWithPosition);
      await _emitLoadedLists();
      return true;
    } catch (e) {
      emit(ListsError(e.toString()));
      return false;
    }
  }

  Future<void> _emitLoadedLists() async {
    final lists = await listsRepository.getLists();
    lists.sort((a, b) => a.position.compareTo(b.position));
    emit(ListsLoaded(lists));
  }

  /// Next position from persisted lists, not UI cubit state (avoids 0 while loading).
  int _nextListPosition(List<TaskListEntity> existing) {
    if (existing.isEmpty) return 0;
    var maxPosition = existing.first.position;
    for (final item in existing) {
      if (item.position > maxPosition) {
        maxPosition = item.position;
      }
    }
    return maxPosition + 1;
  }

  Future<void> deleteList(String id) async {
    try {
      await listsRepository.deleteList(id);
      await loadLists();
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }

  Future<bool> updateList(TaskListEntity list) async {
    try {
      await listsRepository.updateList(list);
      await _emitLoadedLists();
      return true;
    } catch (e) {
      emit(ListsError(e.toString()));
      return false;
    }
  }
}
