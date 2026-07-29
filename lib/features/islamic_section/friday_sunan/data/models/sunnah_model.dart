import 'package:s/features/islamic_section/friday_sunan/domain/entities/sunnah_entity.dart';

class SunnahModel extends SunnahEntity {
  const SunnahModel({
    required super.id,
    required super.title,
    required super.description,
    super.source,
  });

  factory SunnahModel.fromJson(Map<String, dynamic> json) {
    return SunnahModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'source': source,
    };
  }
}
