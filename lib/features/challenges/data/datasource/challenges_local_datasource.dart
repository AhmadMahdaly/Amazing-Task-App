import 'dart:convert';

import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/features/challenges/data/models/challenge_model.dart';

abstract class ChallengeLocalDataSource {
  Future<List<ChallengeModel>> getAllChallenges();
  Future<void> addChallenge(ChallengeModel challenge);
  Future<void> updateChallenge(ChallengeModel challenge);
  Future<void> deleteChallenge(String challengeId);
}

class ChallengeLocalDataSourceImpl implements ChallengeLocalDataSource {
  static const String _challengeCacheKey = CacheKeys.cachedChallenges;

  @override
  Future<List<ChallengeModel>> getAllChallenges() async {
    final cachedData = CacheHelper.getData(_challengeCacheKey);

    if (cachedData != null && cachedData is List) {
      try {
        return cachedData
            .map(
              (challengeJsonString) => ChallengeModel.fromJson(
                jsonDecode(challengeJsonString as String)
                        as Map<String, dynamic>? ??
                    {},
              ),
            )
            .toList();
      } catch (e) {
        return [];
      }
    }

    return [];
  }

  @override
  Future<void> addChallenge(
    ChallengeModel challenge,
  ) async {
    final challenges = await getAllChallenges();

    challenges.add(challenge);

    await _saveChallengesToCache(challenges);
  }

  @override
  Future<void> updateChallenge(
    ChallengeModel challenge,
  ) async {
    final challenges = await getAllChallenges();

    final index = challenges.indexWhere(
      (element) => element.id == challenge.id,
    );

    if (index != -1) {
      challenges[index] = challenge;

      await _saveChallengesToCache(challenges);
    }
  }

  @override
  Future<void> deleteChallenge(String challengeId) async {
    final challenges = await getAllChallenges();

    challenges.removeWhere(
      (element) => element.id == challengeId,
    );

    await _saveChallengesToCache(challenges);
  }

  Future<void> _saveChallengesToCache(
    List<ChallengeModel> challenges,
  ) async {
    final stringChallenges = challenges
        .map(
          (challengeModel) => jsonEncode(challengeModel.toJson()),
        )
        .toList();

    await CacheHelper.saveData(
      key: _challengeCacheKey,
      value: stringChallenges,
    );
  }
}
