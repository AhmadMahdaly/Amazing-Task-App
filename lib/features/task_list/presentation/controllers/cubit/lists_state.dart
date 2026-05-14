part of 'lists_cubit.dart';

abstract class ListsState {}

class ListsInitial extends ListsState {}

class ListsLoading extends ListsState {}

class ListsLoaded extends ListsState {
  ListsLoaded(this.lists);
  final List<TaskListEntity> lists;
}

class ListsError extends ListsState {
  ListsError(this.message);
  final String message;
}
