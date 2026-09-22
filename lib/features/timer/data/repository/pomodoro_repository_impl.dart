import 'package:s/features/timer/data/data_source/pomodoro_local_data_source.dart';
import 'package:s/features/timer/data/model/pomodoro_session_model.dart';
import 'package:s/features/timer/domian/entities/pomodoro_session_entity.dart';
import 'package:s/features/timer/domian/repository/pomodoro_repository.dart';

class PomodoroRepositoryImpl implements PomodoroRepository {
  PomodoroRepositoryImpl(this.localDataSource);
  final PomodoroLocalDataSource localDataSource;

  @override
  Future<List<PomodoroSessionEntity>> getAllSessions() async {
    return localDataSource.getAllSessions();
  }

  @override
  Future<List<PomodoroSessionEntity>> getTaskSessions(String taskId) async {
    return localDataSource.getTaskSessions(taskId);
  }

  @override
  Future<void> saveSession(PomodoroSessionEntity session) async {
    final sessionModel = PomodoroSessionModel(
      id: session.id,
      taskId: session.taskId,
      description: session.description,
      taskName: session.taskName,
      startTime: session.startTime,
      endTime: session.endTime,
      mode: session.mode,
      targetDurationInSeconds: session.targetDurationInSeconds,
    );

    await localDataSource.saveSession(sessionModel);
  }
}
