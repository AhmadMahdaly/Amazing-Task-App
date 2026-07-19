import 'package:s/features/islamic_section/tafsir/domain/entities/tafsir_entity.dart';

class TafsirModel extends TafsirEntity {
  TafsirModel({
    required super.id,
    required super.suraNumber,
    required super.ayaNumber,
    required super.tafsirText,
  });

  factory TafsirModel.fromJson(Map<String, dynamic> json) {
    return TafsirModel(
      id: json['id'] as int? ?? 0,
      suraNumber: json['sura'] as int? ?? 0,
      ayaNumber: json['aya'] as int? ?? 0,
      tafsirText: json['text'] as String? ?? '',
    );
  }
}
