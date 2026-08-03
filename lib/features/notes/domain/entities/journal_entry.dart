class JournalEntry {
  JournalEntry({
    required this.isBold,
    required this.id,
    required this.date,
    required this.text,
    this.title = '',
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      isBold: map['isBold'] as bool? ?? false,
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      text: map['text'] as String,
    );
  }
  final String id;
  final String title;
  final DateTime date;
  final String text;
  final bool isBold;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'text': text,
      'isBold': isBold,
    };
  }
}
