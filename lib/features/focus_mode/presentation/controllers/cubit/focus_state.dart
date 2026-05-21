part of 'focus_cubit.dart';

abstract class FocusState {}

class FocusInitial extends FocusState {}

class FocusReady extends FocusState {
  FocusReady({required this.task, required this.secondsRemaining});
  final TaskEntity task;
  final int secondsRemaining;
}

class FocusRunning extends FocusState {
  FocusRunning({required this.task, required this.secondsRemaining});
  final TaskEntity task;
  final int secondsRemaining;
}

class FocusPaused extends FocusState {
  FocusPaused({required this.task, required this.secondsRemaining});
  final TaskEntity task;
  final int secondsRemaining;
}

class FocusCompleted extends FocusState {
  FocusCompleted({required this.task, required this.actualDurationSaved});
  final TaskEntity task;
  final int actualDurationSaved;
}
