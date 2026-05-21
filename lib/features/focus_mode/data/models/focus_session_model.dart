import 'dart:convert';

class FocusSessionModel {
  FocusSessionModel({
    required this.id,
    required this.taskId,
    required this.startTime,
    required this.endTime,
    required this.durationInSeconds,
  });

  factory FocusSessionModel.fromMap(Map<String, dynamic> map) {
    return FocusSessionModel(
      id: map['id'] as String,
      taskId: map['taskId'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      durationInSeconds: map['durationInSeconds'] as int,
    );
  }

  factory FocusSessionModel.fromJson(String source) =>
      FocusSessionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final String id;
  final String taskId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationInSeconds;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationInSeconds': durationInSeconds,
    };
  }

  String toJson() => json.encode(toMap());
}
