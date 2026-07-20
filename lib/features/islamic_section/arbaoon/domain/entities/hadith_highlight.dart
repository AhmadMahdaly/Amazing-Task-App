class HadithHighlight {
  const HadithHighlight({
    required this.hadithId,
    required this.paragraphIndex,
    required this.text,
    required this.color,
    this.note,
  });

  factory HadithHighlight.fromJson(Map<String, dynamic> json) {
    return HadithHighlight(
      hadithId: json['hadithId'] as int,
      paragraphIndex: json['paragraphIndex'] as int,
      text: json['text'] as String,
      note: json['note'] as String,
      color: json['color'] as int,
    );
  }
  final int hadithId;

  final int paragraphIndex;

  final String text;

  final String? note;

  final int color;

  Map<String, dynamic> toJson() => {
    'hadithId': hadithId,
    'paragraphIndex': paragraphIndex,
    'text': text,
    'note': note,
    'color': color,
  };
}
