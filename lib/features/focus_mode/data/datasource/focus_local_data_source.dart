import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/features/focus_mode/data/models/focus_session_model.dart';

abstract class FocusLocalDataSource {
  Future<List<FocusSessionModel>> fetchSessions();
  Future<void> saveSession(FocusSessionModel session);
  Future<List<FocusSessionModel>> fetchSessionsForTask(String taskId);
}

class FocusLocalDataSourceImpl implements FocusLocalDataSource {
  static const String _focusCacheKey = CacheKeys.cachedFocusSessions;

  @override
  Future<List<FocusSessionModel>> fetchSessions() async {
    final cachedData = CacheHelper.getData(_focusCacheKey);
    if (cachedData != null && cachedData is List) {
      try {
        return cachedData
            .map(
              (jsonString) => FocusSessionModel.fromJson(jsonString as String),
            )
            .toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> saveSession(FocusSessionModel session) async {
    final sessions = await fetchSessions();
    sessions.add(session);
    final stringSessions = sessions.map((s) => s.toJson()).toList();
    await CacheHelper.saveData(key: _focusCacheKey, value: stringSessions);
  }

  @override
  Future<List<FocusSessionModel>> fetchSessionsForTask(String taskId) async {
    final all = await fetchSessions();
    return all.where((session) => session.taskId == taskId).toList();
  }
}
