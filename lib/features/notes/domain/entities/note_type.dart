enum NoteType {
  regular,
  journal;

  // دوال مساعدة للتحويل من وإلى String لتسهيل الحفظ في الـ Local Storage
  static NoteType fromString(String type) {
    return NoteType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NoteType.regular,
    );
  }
}
