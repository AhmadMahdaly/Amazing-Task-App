import 'package:s/features/challenges/data/models/challenge_model.dart';

abstract class ChallengeRepository {
  Future<List<ChallengeModel>> getAllChallenges();
  Future<void> addChallenge(ChallengeModel challenge);
  Future<void> updateChallenge(ChallengeModel challenge);
}
