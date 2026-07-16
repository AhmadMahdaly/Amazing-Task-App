import 'package:s/features/islamic_section/sunan/domain/entities/sunan_entity.dart';

class SunanDataModel extends SunanDataEntity {
  SunanDataModel({
    required super.typesOfSunan,
    required super.sectionsOfSunnah,
    required super.divineSunan,
  });

  factory SunanDataModel.fromJson(Map<String, dynamic> json) {
    return SunanDataModel(
      typesOfSunan:
          json['أهم_أنواع_السنن_في_الإسلام'] as Map<String, dynamic>? ?? {},
      sectionsOfSunnah: json['أقسام_السنة_النبوية'] as List<dynamic>? ?? [],
      divineSunan:
          json['السنن_الإلهية_في_القرآن_الكريم'] as Map<String, dynamic>? ?? {},
    );
  }
}
