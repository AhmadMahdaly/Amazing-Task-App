import 'package:s/features/notes/domain/entities/journal_entry.dart';

import 'note_type.dart';

class NoteEntity {
  NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.fontSize,
    required this.createdAt,
    required this.updatedAt,
    this.journalEntries = const [],
  });
  final String id;
  final String title;
  final String content;
  final NoteType type;
  final double fontSize;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<JournalEntry> journalEntries;
}
