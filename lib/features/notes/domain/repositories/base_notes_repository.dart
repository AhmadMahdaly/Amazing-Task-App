import 'package:dartz/dartz.dart';

import '../entities/note_entity.dart';

abstract class BaseNotesRepository {
  Future<Either<String, List<NoteEntity>>> getNotes();
  Future<Either<String, void>> addNote(NoteEntity note);
  Future<Either<String, void>> updateNote(NoteEntity note);
  Future<Either<String, void>> deleteNote(String noteId);
}
