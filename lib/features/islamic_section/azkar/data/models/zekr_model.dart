import 'package:s/features/islamic_section/azkar/domain/entities/zekr_entity.dart';

class ZekrModel extends ZekrEntity {
  ZekrModel({
    required super.id,
    required super.zekr,
    required super.count,
    required super.benefit,
  });

  factory ZekrModel.fromJson(Map<String, dynamic> json) {
    return ZekrModel(
      id: json['id'] as int,
      zekr: json['zekr'] as String,
      count: json['count'] as int,
      benefit: json['benefit'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zekr': zekr,
      'count': count,
      'benefit': benefit,
    };
  }
}
