// ignore_for_file: cascade_invocations, discarded_futures

import 'dart:math';

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
        final notes = savedNotesStr != null
            ? SavedAyahNote.decode(savedNotesStr)
            : <SavedAyahNote>[];

        notes.sort((a, b) {
          final surahCompare = a.surahNumber.compareTo(b.surahNumber);
          if (surahCompare != 0) return surahCompare;

          return a.ayahNumber.compareTo(b.ayahNumber);
        });

        return notes;

      case NotesSectionType.asmaa:
        return _getSortedHighlights('asmaa_highlights_');
      case NotesSectionType.arbaoon:
        return _getSortedHighlights('arbaoon_highlights_');
      case NotesSectionType.tabeen:
        return _getSortedHighlights('tabeen_highlights_');
    }
  }

  List<Highlight> _getSortedHighlights(String keyPrefix) {
    final temp = <Highlight>[];
    for (var i = 1; i <= 99; i++) {
      final savedData = CacheHelper.getData('$keyPrefix$i') as String?;
      if (savedData != null) {
        temp.addAll(Highlight.decode(savedData));
      }
    }

    temp.sort((a, b) {
      final lessonCompare = a.lessonId.compareTo(b.lessonId);
      if (lessonCompare != 0) return lessonCompare;
      return a.startOffset.compareTo(b.startOffset);
    });
    return temp;
  }

  Future<void> saveAyahNote(SavedAyahNote newAyah) async {
    final notes = await getNotes(NotesSectionType.quran) as List<SavedAyahNote>;

    var merged = false;
    for (var i = 0; i < notes.length; i++) {
      final existingAyah = notes[i];

      if (existingAyah.surahNumber == newAyah.surahNumber) {
        if (newAyah.ayahNumber == existingAyah.endAyahNumber! + 1) {
          notes[i] = SavedAyahNote(
            id: existingAyah.id,
            surahNumber: existingAyah.surahNumber,
            surahName: existingAyah.surahName,
            ayahNumber: existingAyah.ayahNumber,
            endAyahNumber: newAyah.endAyahNumber,
            ayahText: '${existingAyah.ayahText} ۝ ${newAyah.ayahText}',
            note: existingAyah.note.isNotEmpty
                ? existingAyah.note
                : newAyah.note,
          );
          merged = true;
          break;
        } else if (newAyah.ayahNumber == existingAyah.ayahNumber - 1) {
          notes[i] = SavedAyahNote(
            id: existingAyah.id,
            surahNumber: existingAyah.surahNumber,
            surahName: existingAyah.surahName,
            ayahNumber: newAyah.ayahNumber,
            endAyahNumber: existingAyah.endAyahNumber,
            ayahText: '${newAyah.ayahText} ۝ ${existingAyah.ayahText}',
            note: existingAyah.note.isNotEmpty
                ? existingAyah.note
                : newAyah.note,
          );
          merged = true;
          break;
        }
      }
    }

    if (!merged) {
      notes.add(newAyah);
    }

    await CacheHelper.saveData(
      key: CacheKeys.savedAyahsNotes,
      value: SavedAyahNote.encode(notes),
    );
  }

  Future<void> saveHighlight(
    Highlight newHighlight,
    NotesSectionType type,
  ) async {
    final keyPrefix = type == NotesSectionType.asmaa
        ? 'asmaa_highlights_'
        : type == NotesSectionType.arbaoon
        ? 'arbaoon_highlights_'
        : 'tabeen_highlights_';

    final allHighlights = await getNotes(type) as List<Highlight>;
    final lessonHighlights = allHighlights
        .where((h) => h.lessonId == newHighlight.lessonId)
        .toList();

    var merged = false;

    for (var i = 0; i < lessonHighlights.length; i++) {
      final existing = lessonHighlights[i];

      if (newHighlight.startOffset <= existing.endOffset &&
          newHighlight.endOffset >= existing.startOffset) {
        lessonHighlights[i] = Highlight(
          id: existing.id,
          lessonId: existing.lessonId,
          startOffset: min(existing.startOffset, newHighlight.startOffset),
          endOffset: max(existing.endOffset, newHighlight.endOffset),

          selectedText:
              '${existing.selectedText} ... ${newHighlight.selectedText}',
          colorValue: newHighlight.colorValue,
          note: existing.note.isNotEmpty ? existing.note : newHighlight.note,
        );
        merged = true;
        break;
      }
    }

    if (!merged) {
      lessonHighlights.add(newHighlight);
    }

    _saveHighlightsForLesson(
      newHighlight.lessonId,
      lessonHighlights,
      keyPrefix,
    );
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
      final highlight = note as Highlight;
      final keyPrefix = type == NotesSectionType.asmaa
          ? 'asmaa_highlights_'
          : type == NotesSectionType.arbaoon
          ? 'arbaoon_highlights_'
          : 'tabeen_highlights_';

      final allHighlights = await getNotes(type) as List<Highlight>;
      allHighlights.removeWhere((element) => element.id == highlight.id);
      _saveHighlightsForLesson(highlight.lessonId, allHighlights, keyPrefix);
    }
  }

  Future<void> updateHighlight(
    Highlight updatedHighlight,
    NotesSectionType type,
  ) async {
    final keyPrefix = type == NotesSectionType.asmaa
        ? 'asmaa_highlights_'
        : type == NotesSectionType.arbaoon
        ? 'arbaoon_highlights_'
        : 'tabeen_highlights_';

    final allHighlights = await getNotes(type) as List<Highlight>;
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

  void _saveHighlightsForLesson(
    int lessonId,
    List<Highlight> allHighlights,
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
        value: Highlight.encode(lessonHighlights),
      );
    }
  }
}
