part of 'challenge_cubit.dart';

abstract class ChallengeState extends Equatable {
  const ChallengeState();

  @override
  List<Object> get props => [];
}

class ChallengeInitial extends ChallengeState {}

class ChallengeLoading extends ChallengeState {}

class ChallengeLoaded extends ChallengeState {
  const ChallengeLoaded(this.challenges);
  final List<ChallengeModel> challenges;

  @override
  List<Object> get props => [challenges, DateTime.now()];
}

class ChallengeError extends ChallengeState {
  const ChallengeError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
