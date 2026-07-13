import 'package:s/features/islamic_section/missed_prayers/domain/entities/missed_prayers_entity.dart';

class MissedPrayersModel extends MissedPrayersEntity {
  const MissedPrayersModel({
    required super.totalTargetPerPrayer,
    required super.fajrLeft,
    required super.dhuhrLeft,
    required super.asrLeft,
    required super.maghribLeft,
    required super.ishaLeft,
    required super.birthDate,
    required super.commitmentDate,
    required super.doubtMonths,
  });

  factory MissedPrayersModel.fromJson(Map<String, dynamic> json) {
    return MissedPrayersModel(
      totalTargetPerPrayer: json['totalTargetPerPrayer'] as int? ?? 0,
      fajrLeft: json['fajrLeft'] as int? ?? 0,
      dhuhrLeft: json['dhuhrLeft'] as int? ?? 0,
      asrLeft: json['asrLeft'] as int? ?? 0,
      maghribLeft: json['maghribLeft'] as int? ?? 0,
      ishaLeft: json['ishaLeft'] as int? ?? 0,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : DateTime.now(),
      commitmentDate: json['commitmentDate'] != null
          ? DateTime.parse(json['commitmentDate'] as String)
          : DateTime.now(),
      doubtMonths: json['doubtMonths'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTargetPerPrayer': totalTargetPerPrayer,
      'fajrLeft': fajrLeft,
      'dhuhrLeft': dhuhrLeft,
      'asrLeft': asrLeft,
      'maghribLeft': maghribLeft,
      'ishaLeft': ishaLeft,
      // حفظ التواريخ والشهور في الكاش
      'birthDate': birthDate.toIso8601String(),
      'commitmentDate': commitmentDate.toIso8601String(),
      'doubtMonths': doubtMonths,
    };
  }
}
