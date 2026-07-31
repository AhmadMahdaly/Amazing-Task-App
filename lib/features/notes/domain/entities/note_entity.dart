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
  });
  final String id;
  final String title;
  final String content;
  final NoteType type;
  final double fontSize; // للتحكم في حجم الخط كما طلبت
  final DateTime createdAt;
  final DateTime updatedAt;
}
