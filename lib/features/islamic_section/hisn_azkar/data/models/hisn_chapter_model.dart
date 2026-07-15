import 'package:s/features/islamic_section/hisn_azkar/domain/entities/hisn_chapter_entity.dart';

class HisnChapterModel extends HisnChapterEntity {
  HisnChapterModel({
    required super.title,
    required super.texts,
    required super.footnotes,
  });

  factory HisnChapterModel.fromJson(String title, Map<String, dynamic> json) {
    return HisnChapterModel(
      title: title,
      texts: List<String>.from(json['text'] as List? ?? []),
      footnotes: List<String>.from(json['footnote'] as List? ?? []),
    );
  }
}
