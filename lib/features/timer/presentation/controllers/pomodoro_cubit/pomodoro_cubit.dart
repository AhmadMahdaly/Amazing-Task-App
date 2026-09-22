import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/features/timer/domian/entities/pomodoro_session_entity.dart';
import 'package:s/features/timer/domian/repository/pomodoro_repository.dart';
import 'package:uuid/uuid.dart';

part 'pomodoro_state.dart';

class PomodoroCubit extends Cubit<PomodoroState> {
  PomodoroCubit(this.repository) : super(const PomodoroState());
  final PomodoroRepository repository;
  Timer? _timer;

  Future<void> loadTaskTotalTime(String taskId) async {
    final sessions = await repository.getTaskSessions(taskId);
    var total = 0;
    for (final session in sessions) {
      total += session.actualDurationInSeconds;
    }
    emit(state.copyWith(totalPreviousSeconds: total));
  }

  void selectMode(TimerMode mode, {int? customMinutes}) {
    stopTimer();
    int? target;

    switch (mode) {
      case TimerMode.min5:
        target = 5 * 60;
      case TimerMode.min10:
        target = 10 * 60;
      case TimerMode.min25:
        target = 25 * 60;
      case TimerMode.custom:
        target = (customMinutes ?? 1) * 60;
      case TimerMode.openEnded:
        target = null;
    }

    emit(
      state.copyWith(
        selectedMode: mode,
        targetSeconds: target,
        currentSeconds: target ?? 0,
        isRunning: false,
        startTime: null,
      ),
    );
  }

  void startTimer() {
    if (state.isRunning) return;

    final startTime = state.startTime ?? DateTime.now();

    emit(state.copyWith(isRunning: true, startTime: startTime));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.selectedMode == TimerMode.openEnded) {
        emit(state.copyWith(currentSeconds: state.currentSeconds + 1));
      } else {
        if (state.currentSeconds > 0) {
          emit(state.copyWith(currentSeconds: state.currentSeconds - 1));
        } else {
          pauseTimer();
        }
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  void stopTimer() {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  Future<void> stopAndSaveSession({
    required String taskId,
    required String taskName,
    required String description,
  }) async {
    stopTimer();

    if (state.startTime == null) return;

    final session = PomodoroSessionEntity(
      id: const Uuid().v4(),
      taskId: taskId,
      taskName: taskName,
      description: description,
      startTime: state.startTime!,
      endTime: DateTime.now(),
      mode: state.selectedMode,
      targetDurationInSeconds: state.targetSeconds,
    );

    await repository.saveSession(session);

    await loadTaskTotalTime(taskId);
    selectMode(
      state.selectedMode,
      customMinutes: state.targetSeconds != null
          ? state.targetSeconds! ~/ 60
          : null,
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
