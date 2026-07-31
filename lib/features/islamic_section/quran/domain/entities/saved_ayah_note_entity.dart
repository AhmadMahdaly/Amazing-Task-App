import 'dart:convert';

class SavedAyahNote {
  SavedAyahNote({
    required this.isStarred,
    required this.endAyahNumber,
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.note,
  });

  factory SavedAyahNote.fromMap(Map<String, dynamic> map) {
    return SavedAyahNote(
      isStarred: map['isStarred'] as bool? ?? false,
      id: map['id'] as String,
      surahNumber: map['surahNumber'] as int,
      surahName: map['surahName'] as String,
      ayahNumber: map['ayahNumber'] as int,
      ayahText: map['ayahText'] as String,
      note: map['note'] as String,
      endAyahNumber: map['endAyahNumber'] as int? ?? map['ayahNumber'] as int,
    );
  }
  final String id;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final String note;
  final int? endAyahNumber;
  final bool isStarred;

  Map<String, dynamic> toMap() {
    return {
      'isStarred': isStarred,
      'id': id,
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'note': note,
      'endAyahNumber': endAyahNumber ?? ayahNumber,
    };
  }

  SavedAyahNote copyWith({
    String? id,
    int? surahNumber,
    int? endAyahNumber,
    String? surahName,
    int? ayahNumber,
    String? ayahText,
    String? note,
    bool? isStarred,
  }) {
    return SavedAyahNote(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      endAyahNumber: endAyahNumber ?? this.endAyahNumber,
      surahName: surahName ?? this.surahName,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      ayahText: ayahText ?? this.ayahText,
      note: note ?? this.note,
      isStarred: isStarred ?? this.isStarred,
    );
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
