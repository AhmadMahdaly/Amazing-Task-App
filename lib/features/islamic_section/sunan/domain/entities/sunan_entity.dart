class SunanDataEntity {
  SunanDataEntity({
    required this.typesOfSunan,
    required this.sectionsOfSunnah,
    required this.divineSunan,
  });
  final Map<String, dynamic> typesOfSunan;
  final List<dynamic> sectionsOfSunnah;
  final Map<String, dynamic> divineSunan;
}
