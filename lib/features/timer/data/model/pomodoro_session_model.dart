import 'package:s/features/timer/domian/entities/pomodoro_session_entity.dart';

class PomodoroSessionModel extends PomodoroSessionEntity {
  const PomodoroSessionModel({
    required super.id,
    required super.taskId,
    required super.description,
    required super.startTime,
    required super.mode,
    super.endTime,
    super.targetDurationInSeconds,
    super.taskName,
  });

  factory PomodoroSessionModel.fromJson(Map<String, dynamic> json) {
    return PomodoroSessionModel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      description: json['description'] as String,
      taskName: json['taskName'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,

      mode: TimerMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => TimerMode.openEnded,
      ),
      targetDurationInSeconds: json['targetDurationInSeconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'description': description,
      'taskName': taskName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'mode': mode.name,
      'targetDurationInSeconds': targetDurationInSeconds,
    };
  }
}
