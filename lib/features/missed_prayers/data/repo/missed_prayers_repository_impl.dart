import 'package:s/features/missed_prayers/data/datasource/missed_prayers_local_data_source.dart';
import 'package:s/features/missed_prayers/domain/repo/missed_prayers_repository.dart';

import '../../domain/entities/missed_prayers_entity.dart';
import '../models/missed_prayers_model.dart';

class MissedPrayersRepositoryImpl implements MissedPrayersRepository {
  MissedPrayersRepositoryImpl(this.localDataSource);
  final MissedPrayersLocalDataSource localDataSource;
  @override
  Future<void> saveMissedPrayers(MissedPrayersEntity entity) async {
    try {
      final model = MissedPrayersModel(
        totalTargetPerPrayer: entity.totalTargetPerPrayer,
        fajrLeft: entity.fajrLeft,
        dhuhrLeft: entity.dhuhrLeft,
        asrLeft: entity.asrLeft,
        maghribLeft: entity.maghribLeft,
        ishaLeft: entity.ishaLeft,
        birthDate: entity.birthDate,
        commitmentDate: entity.commitmentDate,
        doubtMonths: entity.doubtMonths,
      );

      await localDataSource.cachePrayersData(model);
    } catch (e) {
      throw Exception('Failed to save missed prayers data: $e');
    }
  }

  @override
  Future<MissedPrayersEntity?> getMissedPrayers() async {
    try {
      final model = await localDataSource.getCachedPrayersData();

      return model;
    } catch (e) {
      throw Exception('Failed to load missed prayers data: $e');
    }
  }
}
