class HizbEntity {
  const HizbEntity({
    required this.id,
    required this.number,
    required this.name,
    required this.juz,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
  });

  final int id;
  final int number;
  final String name;
  final int juz;

  final int startSurah;
  final int startAyah;

  final int endSurah;
  final int endAyah;
}
