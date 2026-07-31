import 'package:s/core/cache_helper/cache_helper.dart';

import '../models/note_model.dart';
import 'base_note_local_data_source.dart';

class NoteLocalDataSourceImpl implements BaseNoteLocalDataSource {
  static const String _notesCacheKey = 'cached_app_notes';

  @override
  Future<List<NoteModel>> getNotes() async {
    final cachedNotesStr = CacheHelper.getData(_notesCacheKey) as String?;

    if (cachedNotesStr != null && cachedNotesStr.isNotEmpty) {
      return NoteModel.decode(cachedNotesStr);
    } else {
      return [];
    }
  }

  @override
  Future<void> saveNotes(List<NoteModel> notes) async {
    await CacheHelper.saveData(
      key: _notesCacheKey,
      value: NoteModel.encode(notes),
    );
  }

  @override
  Future<void> addNote(NoteModel note) async {
    final notes = await getNotes();
    notes.add(note);
    await saveNotes(notes);
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);

    if (index != -1) {
      notes[index] = note;
      await saveNotes(notes);
    }
  }

  @override
  Future<void> deleteNote(String noteId) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == noteId);
    await saveNotes(notes);
  }
}
