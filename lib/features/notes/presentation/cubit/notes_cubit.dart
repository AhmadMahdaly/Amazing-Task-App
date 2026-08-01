import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/features/notes/domain/entities/journal_entry.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/entities/note_type.dart';
import '../../domain/repositories/base_notes_repository.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this.notesRepository) : super(NotesInitial());
  final BaseNotesRepository notesRepository;

  List<NoteEntity> _notes = [];

  Future<void> getAllNotes() async {
    emit(NotesLoading());
    final result = await notesRepository.getNotes();

    result.fold(
      (failureMessage) => emit(NotesError(failureMessage)),
      (notes) {
        _notes = List<NoteEntity>.from(notes);

        _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        emit(NotesLoaded(List.from(_notes)));
      },
    );
  }

  Future<void> saveJournalEntry(
    NoteEntity oldNote,
    JournalEntry entry, {
    required bool isNew,
  }) async {
    final entries = List<JournalEntry>.from(oldNote.journalEntries);

    if (isNew) {
      entries.add(entry);
    } else {
      final index = entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        entries[index] = entry;
      }
    }

    final updatedNote = NoteEntity(
      id: oldNote.id,
      title: oldNote.title,
      content: oldNote.content,
      type: oldNote.type,
      fontSize: oldNote.fontSize,
      createdAt: oldNote.createdAt,
      updatedAt: DateTime.now(),
      journalEntries: entries,
    );

    await _executeNoteUpdate(updatedNote);
  }

  Future<void> deleteJournalEntry(NoteEntity oldNote, String entryId) async {
    final entries = List<JournalEntry>.from(oldNote.journalEntries);
    entries.removeWhere((e) => e.id == entryId);

    final updatedNote = NoteEntity(
      id: oldNote.id,
      title: oldNote.title,
      content: oldNote.content,
      type: oldNote.type,
      fontSize: oldNote.fontSize,
      createdAt: oldNote.createdAt,
      updatedAt: DateTime.now(),
      journalEntries: entries,
    );

    await _executeNoteUpdate(updatedNote);
  }

  Future<NoteEntity?> addNote({
    required String title,
    required String content,
    required NoteType type,
    double fontSize = 16.0,
  }) async {
    final newNote = NoteEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      type: type,
      fontSize: fontSize,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      journalEntries: const [],
    );

    final result = await notesRepository.addNote(newNote);

    return result.fold(
      (failureMessage) {
        emit(NotesError(failureMessage));
        return null;
      },
      (_) {
        getAllNotes();
        return newNote;
      },
    );
  }

  Future<void> updateRegularNote(
    NoteEntity oldNote,
    String newTitle,
    String newContent,
    double newFontSize,
  ) async {
    final updatedNote = NoteEntity(
      id: oldNote.id,
      title: newTitle,
      content: newContent,
      type: oldNote.type,
      fontSize: newFontSize,
      createdAt: oldNote.createdAt,
      updatedAt: DateTime.now(),
      journalEntries: oldNote.journalEntries,
    );

    await _executeNoteUpdate(updatedNote);
  }

  Future<void> _executeNoteUpdate(NoteEntity updatedNote) async {
    final result = await notesRepository.updateNote(updatedNote);

    result.fold(
      (failureMessage) => emit(NotesError(failureMessage)),
      (_) {
        final index = _notes.indexWhere((note) => note.id == updatedNote.id);
        if (index != -1) {
          _notes[index] = updatedNote;

          _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          emit(NotesLoaded(List.from(_notes)));
        }
      },
    );
  }

  Future<void> deleteNote(String noteId) async {
    final result = await notesRepository.deleteNote(noteId);

    result.fold(
      (failureMessage) => emit(NotesError(failureMessage)),
      (_) {
        _notes.removeWhere((note) => note.id == noteId);
        emit(NotesLoaded(List.from(_notes)));
      },
    );
  }
}
