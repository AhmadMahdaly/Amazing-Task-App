import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:s/features/focus_mode/data/datasource/focus_local_data_source.dart';
import 'package:s/features/focus_mode/data/models/focus_session_model.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';

part 'focus_state.dart';

class FocusCubit extends Cubit<FocusState> {
  FocusCubit(this.dataSource) : super(FocusInitial());

  final FocusLocalDataSource dataSource;
  Timer? _timer;

  TaskEntity? _currentTask;
  DateTime? _sessionStartTime;

  int _focusDurationInSeconds = 25 * 60;
  int _secondsRemaining = 25 * 60;

  void setupSession(TaskEntity task, {int minutes = 25}) {
    _currentTask = task;
    _focusDurationInSeconds = minutes * 60;
    _secondsRemaining = _focusDurationInSeconds;
    emit(FocusReady(task: task, secondsRemaining: _secondsRemaining));
  }

  void startTimer() {
    if (_currentTask == null) return;

    _sessionStartTime ??= DateTime.now();

    emit(
      FocusRunning(task: _currentTask!, secondsRemaining: _secondsRemaining),
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        emit(
          FocusRunning(
            task: _currentTask!,
            secondsRemaining: _secondsRemaining,
          ),
        );
      } else {
        unawaited(_finishAndSaveSession());
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    if (_currentTask != null) {
      emit(
        FocusPaused(task: _currentTask!, secondsRemaining: _secondsRemaining),
      );
    }
  }

  void stopAndSaveEarly() {
    _timer?.cancel();
    if (_sessionStartTime != null) {
      unawaited(_finishAndSaveSession());
    } else {
      emit(FocusInitial());
    }
  }

  Future<void> _finishAndSaveSession() async {
    _timer?.cancel();
    if (_currentTask == null || _sessionStartTime == null) {
      return;
    }

    final endTime = DateTime.now();
    final actualDuration = _focusDurationInSeconds - _secondsRemaining;

    if (actualDuration > 60) {
      final session = FocusSessionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: _currentTask!.id,
        startTime: _sessionStartTime!,
        endTime: endTime,
        durationInSeconds: actualDuration,
      );

      await dataSource.saveSession(session);
    } else {}

    emit(
      FocusCompleted(task: _currentTask!, actualDurationSaved: actualDuration),
    );
    _sessionStartTime = null;
    _currentTask = null;
  }

  Future<List<FocusSessionModel>> getSessionHistory() async {
    return dataSource.fetchSessions();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
