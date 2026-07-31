import '../models/note_model.dart';

abstract class BaseNoteLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<void> saveNotes(List<NoteModel> notes);
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String noteId);
}
