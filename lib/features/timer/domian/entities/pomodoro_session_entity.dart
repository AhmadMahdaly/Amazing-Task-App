enum TimerMode {
  min5,
  min10,
  min25,
  custom,
  openEnded,
}

class PomodoroSessionEntity {
  const PomodoroSessionEntity({
    required this.id,
    required this.taskId,
    required this.description,
    required this.startTime,
    required this.mode,
    this.endTime,
    this.targetDurationInSeconds,
    this.taskName = '',
  });
  final String id;
  final String taskId;
  final String taskName;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final TimerMode mode;
  final int? targetDurationInSeconds;

  int get actualDurationInSeconds {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inSeconds;
  }
}
