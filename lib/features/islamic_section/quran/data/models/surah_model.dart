import 'package:s/features/islamic_section/quran/domain/entities/surah_entity.dart';

class SurahModel extends SurahEntity {
  SurahModel({
    required super.number,
    required super.name,
    required super.numberOfAyahs,
    required super.revelationType,
    required super.startPage,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] as int,
      name: json['name'] as String,
      numberOfAyahs: json['numberOfAyahs'] as int,
      revelationType: json['revelationType'] as String,
      startPage: json['startPage'] as int,
    );
  }
}
