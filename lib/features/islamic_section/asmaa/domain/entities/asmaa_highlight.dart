// domain/entities/asmaa_highlight.dart
import 'dart:convert';

class Highlight {
  Highlight({
    required this.id,
    required this.lessonId,
    required this.startOffset,
    required this.endOffset,
    required this.selectedText,
    required this.colorValue,
    required this.note,
  });

  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      id: map['id'] as String,
      lessonId: map['lessonId'] as int,
      startOffset: map['startOffset'] as int,
      endOffset: map['endOffset'] as int,
      selectedText: map['selectedText'] as String,
      colorValue: map['colorValue'] as int,
      note: map['note'] as String? ?? '',
    );
  }
  final String id;
  final int lessonId;
  final int startOffset;
  final int endOffset;
  final String selectedText;
  final int colorValue;
  final String note;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lessonId': lessonId,
      'startOffset': startOffset,
      'endOffset': endOffset,
      'selectedText': selectedText,
      'colorValue': colorValue,
      'note': note,
    };
  }

  static String encode(List<Highlight> highlights) => json.encode(
    highlights.map<Map<String, dynamic>>((h) => h.toMap()).toList(),
  );

  static List<Highlight> decode(String highlightsStr) =>
      (json.decode(highlightsStr) as List<dynamic>)
          .map<Highlight>(
            (item) => Highlight.fromMap(item as Map<String, dynamic>),
          )
          .toList();
}
