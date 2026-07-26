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

  // 1. تعديل الإيميل (تحديث الاسم + تحديد المنصات)
  void editEmail(
    String emailId,
    String newEmailAddress,
    List<String> selectedPlatformIds,
  ) {
    final oldIndex = _emails.indexWhere((e) => e.id == emailId);
    if (oldIndex == -1) return;

    final oldEmail = _emails[oldIndex];
    var targetEmailId = emailId;

    // التحقق من الدمج
    final existingEmailIndex = _emails.indexWhere(
      (e) =>
          e.emailAddress.toLowerCase() == newEmailAddress.toLowerCase() &&
          e.id != emailId,
    );

    final baseQuotas = List<PlatformQuotaEntity>.from(oldEmail.quotas);

    if (existingEmailIndex != -1) {
      final existingEmail = _emails[existingEmailIndex];
      targetEmailId = existingEmail.id;

      // دمج الحصص لعدم فقدان التوقيتات
      for (final q in existingEmail.quotas) {
        if (!baseQuotas.any((bq) => bq.platformId == q.platformId)) {
          baseQuotas.add(q);
        }
      }
      _emails.removeAt(oldIndex); // نحذف القديم لدمجه
    } else {
      _emails.removeAt(oldIndex);
    }

    // بناء الحصص الجديدة بناءً على ما حدده المستخدم
    final finalQuotas = <PlatformQuotaEntity>[];
    for (final pId in selectedPlatformIds) {
      final existingQ = baseQuotas
          .where((q) => q.platformId == pId)
          .firstOrNull;
      if (existingQ != null) {
        finalQuotas.add(existingQ); // احتفظ بالوقت القديم
      } else {
        finalQuotas.add(
          PlatformQuotaEntity(platformId: pId, resetTime: DateTime.now()),
        ); // منصة جديدة
      }
    }

    final updatedEmail = EmailAccountEntity(
      id: targetEmailId,
      emailAddress: existingEmailIndex != -1
          ? _emails[existingEmailIndex].emailAddress
          : newEmailAddress,
      quotas: finalQuotas,
    );

    final updateIndex = _emails.indexWhere((e) => e.id == targetEmailId);
    if (updateIndex != -1) {
      _emails[updateIndex] = updatedEmail;
    } else {
      _emails.add(updatedEmail);
    }

    _saveEmailDataLocally();
    emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
  }

  // 2. إضافة منصة وتحديد إيميلاتها
  void addPlatformWithEmails(String name, List<String> selectedEmailIds) {
    final newPlatformId = DateTime.now().millisecondsSinceEpoch.toString();
    final newPlatform = AiPlatformEntity(id: newPlatformId, name: name);

    _platforms.add(newPlatform);

    for (var i = 0; i < _emails.length; i++) {
      if (selectedEmailIds.contains(_emails[i].id)) {
        final updatedQuotas = List<PlatformQuotaEntity>.from(_emails[i].quotas);
        updatedQuotas.add(
          PlatformQuotaEntity(
            platformId: newPlatformId,
            resetTime: DateTime.now(),
          ),
        );

        _emails[i] = EmailAccountEntity(
          id: _emails[i].id,
          emailAddress: _emails[i].emailAddress,
          quotas: updatedQuotas,
        );
      }
    }

    _savePlatformDataLocally();
    _saveEmailDataLocally();
    emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
  }

  // 3. تعديل منصة (الاسم + تحديد إيميلاتها)
  void editPlatform(
    String platformId,
    String newName,
    List<String> selectedEmailIds,
  ) {
    final oldIndex = _platforms.indexWhere((p) => p.id == platformId);
    if (oldIndex == -1) return;

    var targetPlatformId = platformId;

    final existingPlatformIndex = _platforms.indexWhere(
      (p) =>
          p.name.toLowerCase() == newName.toLowerCase() && p.id != platformId,
    );

    if (existingPlatformIndex != -1) {
      targetPlatformId = _platforms[existingPlatformIndex].id;
      _platforms.removeAt(oldIndex); // دمج
    } else {
      _platforms[oldIndex] = AiPlatformEntity(id: platformId, name: newName);
    }

    for (var i = 0; i < _emails.length; i++) {
      final email = _emails[i];
      final isSelected = selectedEmailIds.contains(email.id);

      final updatedQuotas = List<PlatformQuotaEntity>.from(email.quotas);

      if (isSelected) {
        if (!updatedQuotas.any((q) => q.platformId == targetPlatformId)) {
          final oldQ = email.quotas
              .where((q) => q.platformId == platformId)
              .firstOrNull;
          updatedQuotas.add(
            PlatformQuotaEntity(
              platformId: targetPlatformId,
              resetTime: oldQ?.resetTime ?? DateTime.now(),
            ),
          );
        }
      } else {
        updatedQuotas.removeWhere((q) => q.platformId == targetPlatformId);
      }

      if (targetPlatformId != platformId) {
        updatedQuotas.removeWhere(
          (q) => q.platformId == platformId,
        ); // تنظيف إذا تم دمج
      }

      _emails[i] = EmailAccountEntity(
        id: email.id,
        emailAddress: email.emailAddress,
        quotas: updatedQuotas,
      );
    }

    _savePlatformDataLocally();
    _saveEmailDataLocally();
    emit(AiTrackerLoaded(List.from(_emails), List.from(_platforms)));
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
