import 'package:s/features/islamic_section/azkar/data/models/zekr_model.dart';
import 'package:s/features/islamic_section/azkar/domain/entities/azkar_category_entity.dart';

class AzkarCategoryModel extends AzkarCategoryEntity {
  AzkarCategoryModel({
    required super.title,
    required super.items,
  });

  factory AzkarCategoryModel.fromJson(Map<String, dynamic> json) {
    return AzkarCategoryModel(
      title: json['title'] as String,
      items: List<ZekrModel>.from(
        (json['items'] as List).map(
          (x) => ZekrModel.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'items': items.map((x) => (x as ZekrModel).toJson()).toList(),
    };
  }
}
