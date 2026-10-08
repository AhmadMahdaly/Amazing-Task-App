part of 'pomodoro_cubit.dart';

class PomodoroState {
  const PomodoroState({
    this.currentSeconds = 0,
    this.isRunning = false,
    this.selectedMode = TimerMode.openEnded,
    this.targetSeconds = 25 * 60,
    this.totalPreviousSeconds = 0,
    this.startTime,
  });
  final int currentSeconds;
  final bool isRunning;
  final TimerMode selectedMode;
  final int? targetSeconds;
  final int totalPreviousSeconds;
  final DateTime? startTime;

  int get actualSessionTime {
    if (startTime == null) return 0;

    if (selectedMode == TimerMode.openEnded) {
      return currentSeconds;
    } else {
      return (targetSeconds ?? 0) - currentSeconds;
    }
  }

  PomodoroState copyWith({
    int? currentSeconds,
    bool? isRunning,
    TimerMode? selectedMode,
    int? targetSeconds,
    int? totalPreviousSeconds,
    DateTime? startTime,
  }) {
    return PomodoroState(
      currentSeconds: currentSeconds ?? this.currentSeconds,
      isRunning: isRunning ?? this.isRunning,
      selectedMode: selectedMode ?? this.selectedMode,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      totalPreviousSeconds: totalPreviousSeconds ?? this.totalPreviousSeconds,
      startTime: startTime ?? this.startTime,
    );
  }
}
