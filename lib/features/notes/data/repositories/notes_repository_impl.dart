import 'package:dartz/dartz.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/base_notes_repository.dart';
import '../datasources/base_note_local_data_source.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements BaseNotesRepository {
  NotesRepositoryImpl(this.baseLocalDataSource);
  final BaseNoteLocalDataSource baseLocalDataSource;

  @override
  Future<Either<String, List<NoteEntity>>> getNotes() async {
    try {
      final result = await baseLocalDataSource.getNotes();
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> addNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel(
        id: note.id,
        title: note.title,
        content: note.content,
        type: note.type,
        fontSize: note.fontSize,
        createdAt: note.createdAt,
        updatedAt: note.updatedAt,
        journalEntries: note.journalEntries,
      );
      await baseLocalDataSource.addNote(noteModel);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel(
        id: note.id,
        title: note.title,
        content: note.content,
        type: note.type,
        fontSize: note.fontSize,
        createdAt: note.createdAt,
        updatedAt: note.updatedAt,
        journalEntries: note.journalEntries,
      );
      await baseLocalDataSource.updateNote(noteModel);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteNote(String noteId) async {
    try {
      await baseLocalDataSource.deleteNote(noteId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
