import 'package:bloc/bloc.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/features/ai_tracker/domain/entities/ai_tracker_entities.dart';

part 'ai_tracker_state.dart';

class AiTrackerCubit extends Cubit<AiTrackerState> {
  AiTrackerCubit() : super(AiTrackerInitial());

  List<AiPlatformEntity> _platforms = [
    AiPlatformEntity(id: '1', name: 'ChatGPT'),
    AiPlatformEntity(id: '2', name: 'Claude'),
    AiPlatformEntity(id: '3', name: 'Gemini'),
    AiPlatformEntity(id: '4', name: 'Midjourney'),
  ];

  List<EmailAccountEntity> _emails = [];

  void loadTrackerData() {
    final savedEmailsStr = CacheHelper.getData('saved_ai_emails') as String?;
    final savedPlatformsStr =
        CacheHelper.getData('saved_ai_platforms') as String?;

    if (savedEmailsStr != null) {
      _emails = EmailAccountEntity.decode(savedEmailsStr);
    }

    if (savedPlatformsStr != null) {
      _platforms = AiPlatformEntity.decode(savedPlatformsStr);
    }

    emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
  }

  Future<void> _saveEmailDataLocally() async {
    await CacheHelper.saveData(
      key: 'saved_ai_emails',
      value: EmailAccountEntity.encode(_emails),
    );
  }

  Future<void> _savePlatformDataLocally() async {
    await CacheHelper.saveData(
      key: 'saved_ai_platforms',
      value: AiPlatformEntity.encode(_platforms),
    );
  }

  void addEmailWithPlatforms(String email, List<String> platformIds) {
    final newEmail = EmailAccountEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emailAddress: email,
      quotas: platformIds
          .map(
            (pId) => PlatformQuotaEntity(
              platformId: pId,
              resetTime: DateTime.now(),
            ),
          )
          .toList(),
    );

    _emails.add(newEmail);
    _saveEmailDataLocally();

    emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
  }

  void updateResetTime(String emailId, String platformId, DateTime newTime) {
    final emailIndex = _emails.indexWhere((e) => e.id == emailId);
    if (emailIndex != -1) {
      final email = _emails[emailIndex];
      final quotaIndex = email.quotas.indexWhere(
        (q) => q.platformId == platformId,
      );

      if (quotaIndex != -1) {
        final newQuotas = List<PlatformQuotaEntity>.from(email.quotas);
        newQuotas[quotaIndex] = PlatformQuotaEntity(
          platformId: platformId,
          resetTime: newTime,
        );

        _emails[emailIndex] = EmailAccountEntity(
          id: email.id,
          emailAddress: email.emailAddress,
          quotas: newQuotas,
        );

        _saveEmailDataLocally();
        emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
      }
    }
  }

  void adjustTime(String emailId, String platformId, Duration duration) {
    final emailIndex = _emails.indexWhere((e) => e.id == emailId);
    if (emailIndex != -1) {
      final email = _emails[emailIndex];
      final quotaIndex = email.quotas.indexWhere(
        (q) => q.platformId == platformId,
      );

      if (quotaIndex != -1) {
        final currentReset = email.quotas[quotaIndex].resetTime;

        final baseTime = currentReset.isBefore(DateTime.now())
            ? DateTime.now()
            : currentReset;
        final newTime = baseTime.add(duration);

        final newQuotas = List<PlatformQuotaEntity>.from(email.quotas);
        newQuotas[quotaIndex] = PlatformQuotaEntity(
          platformId: platformId,
          resetTime: newTime,
        );

        _emails[emailIndex] = EmailAccountEntity(
          id: email.id,
          emailAddress: email.emailAddress,
          quotas: newQuotas,
        );

        _saveEmailDataLocally();
        emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
      }
    }
  }

  void setAvailableNow(String emailId, String platformId) {
    updateResetTime(
      emailId,
      platformId,
      DateTime.now().subtract(const Duration(minutes: 1)),
    );
  }

  void deleteEmail(String emailId) {
    _emails.removeWhere((e) => e.id == emailId);
    _saveEmailDataLocally();
    emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
  }

  void editEmailAddress(String emailId, String newEmailAddress) {
    final index = _emails.indexWhere((e) => e.id == emailId);
    if (index != -1) {
      final oldEmail = _emails[index];
      _emails[index] = EmailAccountEntity(
        id: oldEmail.id,
        emailAddress: newEmailAddress,
        quotas: List.from(
          oldEmail.quotas,
        ),
      );
      _saveEmailDataLocally();
      emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
    }
  }

  void deletePlatform(String platformId) {
    _platforms.removeWhere((p) => p.id == platformId);

    _emails = _emails.map((email) {
      final updatedQuotas = List<PlatformQuotaEntity>.from(email.quotas)
        ..removeWhere((q) => q.platformId == platformId);

      return EmailAccountEntity(
        id: email.id,
        emailAddress: email.emailAddress,
        quotas: updatedQuotas,
      );
    }).toList();

    _savePlatformDataLocally();
    _saveEmailDataLocally();
    emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
  }

  void editPlatform(String platformId, String newName) {
    final index = _platforms.indexWhere((p) => p.id == platformId);
    if (index != -1) {
      _platforms[index] = AiPlatformEntity(
        id: platformId,
        name: newName,
      );

      _savePlatformDataLocally();
      emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
    }
  }

  void addPlatform(String name) {
    final newPlatform = AiPlatformEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );

    _platforms.add(newPlatform);
    _savePlatformDataLocally();
    emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
  }
}
