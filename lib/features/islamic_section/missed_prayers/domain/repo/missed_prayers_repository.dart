import 'package:s/features/islamic_section/missed_prayers/domain/entities/missed_prayers_entity.dart';

abstract class MissedPrayersRepository {
  Future<void> saveMissedPrayers(MissedPrayersEntity entity);
  Future<MissedPrayersEntity?> getMissedPrayers();
}
