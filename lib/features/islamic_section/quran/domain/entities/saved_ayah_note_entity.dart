import 'dart:convert';

class SavedAyahNote {
  SavedAyahNote({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.note,
  });

  factory SavedAyahNote.fromMap(Map<String, dynamic> map) {
    return SavedAyahNote(
      id: map['id'] as String,
      surahNumber: map['surahNumber'] as int,
      surahName: map['surahName'] as String,
      ayahNumber: map['ayahNumber'] as int,
      ayahText: map['ayahText'] as String,
      note: map['note'] as String,
    );
  }
  final String id;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final String note;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'note': note,
    };
  }

  static String encode(List<SavedAyahNote> notes) => json.encode(
    notes.map<Map<String, dynamic>>((n) => n.toMap()).toList(),
  );

  static List<SavedAyahNote> decode(String notesStr) =>
      (json.decode(notesStr) as List<dynamic>)
          .map<SavedAyahNote>(
            (item) => SavedAyahNote.fromMap(item as Map<String, dynamic>),
          )
          .toList();
}
