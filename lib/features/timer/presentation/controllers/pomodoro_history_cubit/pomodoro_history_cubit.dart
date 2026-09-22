// ignore_for_file: cascade_invocations

import 'package:bloc/bloc.dart';
import 'package:s/features/timer/domian/entities/pomodoro_session_entity.dart';
import 'package:s/features/timer/domian/repository/pomodoro_repository.dart';

part 'pomodoro_history_state.dart';

class PomodoroHistoryCubit extends Cubit<PomodoroHistoryState> {
  PomodoroHistoryCubit(this.repository) : super(PomodoroHistoryInitial());
  final PomodoroRepository repository;

  Future<void> loadHistory({String? taskId}) async {
    emit(PomodoroHistoryLoading());
    try {
      final sessions = taskId != null
          ? await repository.getTaskSessions(taskId)
          : await repository.getAllSessions();

      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));

      emit(PomodoroHistoryLoaded(sessions));
    } catch (e) {
      emit(PomodoroHistoryError(e.toString()));
    }
  }
}
