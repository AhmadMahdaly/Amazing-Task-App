class SurahEntity {
  SurahEntity({
    required this.number,
    required this.name,

    required this.numberOfAyahs,
    required this.revelationType,
    required this.startPage,
  });
  final int number;
  final String name;

  final int numberOfAyahs;
  final String revelationType;
  final int startPage;
}
