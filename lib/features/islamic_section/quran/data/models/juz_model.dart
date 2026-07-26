import 'package:s/features/islamic_section/quran/domain/entities/juz_entity.dart';

class JuzModel extends JuzEntity {
  const JuzModel({
    required super.id,
    required super.number,
    required super.name,
    required super.startSurah,
    required super.startAyah,
    required super.endSurah,
    required super.endAyah,
  });

  factory JuzModel.fromJson(Map<String, dynamic> json) {
    return JuzModel(
      id: json['id'] as int,
      number: json['number'] as int,
      name: json['name'] as String,
      startSurah: json['startSurah'] as int,
      startAyah: json['startAyah'] as int,
      endSurah: json['endSurah'] as int,
      endAyah: json['endAyah'] as int,
    );
  }
}
