part of 'pomodoro_history_cubit.dart';

abstract class PomodoroHistoryState {}

class PomodoroHistoryInitial extends PomodoroHistoryState {}

class PomodoroHistoryLoading extends PomodoroHistoryState {}

class PomodoroHistoryLoaded extends PomodoroHistoryState {
  PomodoroHistoryLoaded(this.sessions);
  final List<PomodoroSessionEntity> sessions;
}

class PomodoroHistoryError extends PomodoroHistoryState {
  PomodoroHistoryError(this.message);
  final String message;
}
