// ignore_for_file: discarded_futures

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/features/challenges/data/models/challenge_model.dart';
import 'package:s/features/challenges/domain/repositories/challenge_repository.dart';

part 'challenge_state.dart';

class ChallengeCubit extends Cubit<ChallengeState> {
  ChallengeCubit(this._challengeRepository) : super(ChallengeInitial()) {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkExpiredChallenges();
    });
  }
  final ChallengeRepository _challengeRepository;
  Timer? _timer;

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> loadChallenges() async {
    try {
      emit(ChallengeLoading());
      final challenges = await _challengeRepository.getAllChallenges();

      _updateStatuses(challenges);
      emit(ChallengeLoaded(challenges));
    } catch (e) {
      emit(ChallengeError(AppTexts.failedToLoadChallenges));
    }
  }

  Future<void> addChallenge(ChallengeModel challenge) async {
    if (state is ChallengeLoaded) {
      final currentState = state as ChallengeLoaded;
      try {
        await _challengeRepository.addChallenge(challenge);
        final updatedList = List<ChallengeModel>.from(currentState.challenges)
          ..add(challenge);
        emit(ChallengeLoaded(updatedList));
      } catch (e) {
        emit(ChallengeError(AppTexts.failedToAddChallenge));
      }
    }
  }

  Future<void> updateChallengeStatus(String id, ChallengeStatus status) async {
    if (state is ChallengeLoaded) {
      final currentState = state as ChallengeLoaded;
      final challenges = List<ChallengeModel>.from(currentState.challenges);
      final index = challenges.indexWhere((c) => c.id == id);

      if (index != -1) {
        final challengeToUpdate = challenges[index].copyWith(
          status: status,
          completionDate: DateTime.now(),
        );
        challenges[index] = challengeToUpdate;

        try {
          await _challengeRepository.updateChallenge(challengeToUpdate);
          emit(ChallengeLoaded(challenges));
        } catch (e) {
          emit(ChallengeError(AppTexts.failedToUpdateChallengeStatus));
        }
      }
    }
  }

  void _checkExpiredChallenges() {
    if (state is ChallengeLoaded) {
      final currentState = state as ChallengeLoaded;
      final challenges = List<ChallengeModel>.from(currentState.challenges);
      final listChanged = _updateStatuses(challenges);

      if (listChanged) {
        emit(ChallengeLoaded(challenges));
      }
    }
  }

  bool _updateStatuses(List<ChallengeModel> challenges) {
    var hasChanged = false;
    final now = DateTime.now();
    for (var i = 0; i < challenges.length; i++) {
      final challenge = challenges[i];
      if (challenge.status == ChallengeStatus.active &&
          now.isAfter(challenge.endDate)) {
        final updatedChallenge = challenge.copyWith(
          status: ChallengeStatus.failed,
        );
        challenges[i] = updatedChallenge;
        _challengeRepository.updateChallenge(updatedChallenge);
        hasChanged = true;
      }
    }
    return hasChanged;
  }
}
