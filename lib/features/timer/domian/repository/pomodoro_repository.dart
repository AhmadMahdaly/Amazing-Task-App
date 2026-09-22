import 'package:s/features/timer/domian/entities/pomodoro_session_entity.dart';

abstract class PomodoroRepository {
  Future<void> saveSession(PomodoroSessionEntity session);
  Future<List<PomodoroSessionEntity>> getAllSessions();
  Future<List<PomodoroSessionEntity>> getTaskSessions(String taskId);
}
