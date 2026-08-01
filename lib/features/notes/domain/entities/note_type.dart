enum NoteType {
  regular,
  journal;

  static NoteType fromString(String type) {
    return NoteType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NoteType.regular,
    );
  }
}
