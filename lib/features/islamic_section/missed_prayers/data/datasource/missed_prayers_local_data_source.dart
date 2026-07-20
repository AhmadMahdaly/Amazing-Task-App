import 'dart:convert';

import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/features/islamic_section/missed_prayers/data/models/missed_prayers_model.dart';

class MissedPrayersLocalDataSource {
  MissedPrayersLocalDataSource();

  static const String _cacheKey = CacheKeys.missedPrayersData;

  Future<void> cachePrayersData(MissedPrayersModel model) async {
    final jsonString = json.encode(model.toJson());
    await CacheHelper.saveData(key: _cacheKey, value: jsonString);
  }

  Future<MissedPrayersModel?> getCachedPrayersData() async {
    final jsonString = CacheHelper.getData(_cacheKey);
    if (jsonString != null) {
      return MissedPrayersModel.fromJson(
        json.decode(jsonString as String) as Map<String, dynamic>,
      );
    }
    return null;
  }
}
