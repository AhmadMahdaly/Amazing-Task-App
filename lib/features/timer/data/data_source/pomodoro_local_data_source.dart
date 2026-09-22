import 'dart:convert';

import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/features/timer/data/model/pomodoro_session_model.dart';

abstract class PomodoroLocalDataSource {
  Future<void> saveSession(PomodoroSessionModel session);
  Future<List<PomodoroSessionModel>> getAllSessions();
  Future<List<PomodoroSessionModel>> getTaskSessions(String taskId);
}

class PomodoroLocalDataSourceImpl implements PomodoroLocalDataSource {
  static const String _sessionsKey = 'POMODORO_SESSIONS';

  @override
  Future<List<PomodoroSessionModel>> getAllSessions() async {
    final data = CacheHelper.getData(_sessionsKey);

    if (data != null && data is List<dynamic>) {
      final stringList = data.cast<String>();

      return stringList
          .map(
            (jsonString) => PomodoroSessionModel.fromJson(
              json.decode(jsonString) as Map<String, dynamic>,
            ),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<List<PomodoroSessionModel>> getTaskSessions(String taskId) async {
    final allSessions = await getAllSessions();
    return allSessions.where((session) => session.taskId == taskId).toList();
  }

  @override
  Future<void> saveSession(PomodoroSessionModel session) async {
    final sessions = await getAllSessions();

    final existingIndex = sessions.indexWhere((s) => s.id == session.id);

    if (existingIndex >= 0) {
      sessions[existingIndex] = session;
    } else {
      sessions.add(session);
    }

    final stringList = sessions.map((s) => json.encode(s.toJson())).toList();

    await CacheHelper.saveData(key: _sessionsKey, value: stringList);
  }
}
