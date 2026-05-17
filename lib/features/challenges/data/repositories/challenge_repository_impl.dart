import 'package:s/features/challenges/data/datasource/challenges_local_datasource.dart';
import 'package:s/features/challenges/data/models/challenge_model.dart';
import 'package:s/features/challenges/domain/repositories/challenge_repository.dart';

class ChallengeRepositoryImpl implements ChallengeRepository {
  ChallengeRepositoryImpl(this.localDataSource);
  final ChallengeLocalDataSource localDataSource;

  @override
  Future<List<ChallengeModel>> getAllChallenges() {
    return localDataSource.getAllChallenges();
  }

  @override
  Future<void> addChallenge(ChallengeModel challenge) {
    return localDataSource.addChallenge(challenge);
  }

  @override
  Future<void> updateChallenge(ChallengeModel challenge) {
    return localDataSource.updateChallenge(challenge);
  }
}
