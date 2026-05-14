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

  Future<void> addList(TaskListEntity list) async {
    try {
      await listsRepository.addList(list);
      await loadLists();
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }

  Future<void> deleteList(String id) async {
    try {
      await listsRepository.deleteList(id);
      await loadLists();
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }
}
