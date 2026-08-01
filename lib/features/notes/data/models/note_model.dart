import 'dart:convert';

import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/entities/note_type.dart';

class NoteModel extends NoteEntity {
  NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.type,
    required super.fontSize,
    required super.createdAt,
    required super.updatedAt,
    super.journalEntries,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      type: NoteType.fromString(map['type'] as String),
      fontSize: (map['fontSize'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      journalEntries: map['journalEntries'] != null
          ? (map['journalEntries'] as List<dynamic>)
                .map((e) => JournalEntry.fromMap(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.name,
      'fontSize': fontSize,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'journalEntries': journalEntries.map((e) => e.toMap()).toList(),
    };
  }

  static String encode(List<NoteModel> notes) => json.encode(
    notes.map<Map<String, dynamic>>((note) => note.toMap()).toList(),
  );

  static List<NoteModel> decode(String notesStr) =>
      (json.decode(notesStr) as List<dynamic>)
          .map<NoteModel>(
            (item) => NoteModel.fromMap(item as Map<String, dynamic>),
          )
          .toList();
}
