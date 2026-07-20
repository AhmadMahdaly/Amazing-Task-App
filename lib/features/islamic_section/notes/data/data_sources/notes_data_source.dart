// ignore_for_file: cascade_invocations, discarded_futures

import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_highlight.dart';
import 'package:s/features/islamic_section/notes/presentation/utils/notes_section_type.dart';
import 'package:s/features/islamic_section/quran/domain/entities/saved_ayah_note_entity.dart';

class NotesDataSource {
  Future<List<dynamic>> getNotes(NotesSectionType type) async {
    switch (type) {
      case NotesSectionType.quran:
        final savedNotesStr =
            CacheHelper.getData(CacheKeys.savedAyahsNotes) as String?;
        return savedNotesStr != null ? SavedAyahNote.decode(savedNotesStr) : [];
      case NotesSectionType.asmaa:
        return _getHighlights('asmaa_highlights_');
      case NotesSectionType.arbaoon:
        return _getHighlights('arbaoon_highlights_');
    }
  }

  Future<void> deleteNote(dynamic note, NotesSectionType type) async {
    if (type == NotesSectionType.quran) {
      final notes = await getNotes(type) as List<SavedAyahNote>;
      notes.removeWhere((element) => element.id == (note as SavedAyahNote).id);
      await CacheHelper.saveData(
        key: CacheKeys.savedAyahsNotes,
        value: SavedAyahNote.encode(notes),
      );
    } else {
      final highlight = note as AsmaaHighlight;
      final keyPrefix = type == NotesSectionType.asmaa
          ? 'asmaa_highlights_'
          : 'arbaoon_highlights_';

      final allHighlights = await getNotes(type) as List<AsmaaHighlight>;
      allHighlights.removeWhere((element) => element.id == highlight.id);

      _saveHighlightsForLesson(highlight.lessonId, allHighlights, keyPrefix);
    }
  }

  Future<void> updateHighlight(
    AsmaaHighlight updatedHighlight,
    NotesSectionType type,
  ) async {
    final keyPrefix = type == NotesSectionType.asmaa
        ? 'asmaa_highlights_'
        : 'arbaoon_highlights_';

    final allHighlights = await getNotes(type) as List<AsmaaHighlight>;
    final index = allHighlights.indexWhere(
      (element) => element.id == updatedHighlight.id,
    );

    if (index != -1) {
      allHighlights[index] = updatedHighlight;
      _saveHighlightsForLesson(
        updatedHighlight.lessonId,
        allHighlights,
        keyPrefix,
      );
    }
  }

  List<AsmaaHighlight> _getHighlights(String keyPrefix) {
    final temp = <AsmaaHighlight>[];
    for (var i = 1; i <= 99; i++) {
      final savedData = CacheHelper.getData('$keyPrefix$i') as String?;
      if (savedData != null) {
        temp.addAll(AsmaaHighlight.decode(savedData));
      }
    }
    return temp;
  }

  void _saveHighlightsForLesson(
    int lessonId,
    List<AsmaaHighlight> allHighlights,
    String keyPrefix,
  ) {
    final lessonHighlights = allHighlights
        .where((h) => h.lessonId == lessonId)
        .toList();

    if (lessonHighlights.isEmpty) {
      CacheHelper.removeData('$keyPrefix$lessonId');
    } else {
      CacheHelper.saveData(
        key: '$keyPrefix$lessonId',
        value: AsmaaHighlight.encode(lessonHighlights),
      );
    }
  }
}
