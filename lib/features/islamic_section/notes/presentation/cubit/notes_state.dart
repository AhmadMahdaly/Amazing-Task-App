part of 'notes_cubit.dart';

abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  NotesLoaded(this.notes);
  final List<dynamic> notes;
}

class NotesError extends NotesState {
  NotesError(this.message);
  final String message;
}

class NotesActionSuccess extends NotesState {
  NotesActionSuccess(this.message);
  final String message;
}
