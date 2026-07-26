import 'package:s/features/islamic_section/quran/domain/entities/hizb_entity.dart';

class HizbModel extends HizbEntity {
  const HizbModel({
    required super.id,
    required super.number,
    required super.name,
    required super.juz,
    required super.startSurah,
    required super.startAyah,
    required super.endSurah,
    required super.endAyah,
  });

  factory HizbModel.fromJson(Map<String, dynamic> json) {
    return HizbModel(
      id: json['id'] as int,
      number: json['number'] as int,
      name: json['name'] as String,
      juz: json['juz'] as int,
      startSurah: json['startSurah'] as int,
      startAyah: json['startAyah'] as int,
      endSurah: json['endSurah'] as int,
      endAyah: json['endAyah'] as int,
    );
  }
}
