import 'package:s/features/islamic_section/azkar/domain/entities/zekr_entity.dart';

class AzkarCategoryEntity {
  AzkarCategoryEntity({
    required this.title,
    required this.items,
  });
  final String title;
  final List<ZekrEntity> items;
}
