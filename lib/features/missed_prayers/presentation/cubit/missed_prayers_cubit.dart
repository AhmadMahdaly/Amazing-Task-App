import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/features/missed_prayers/domain/entities/missed_prayers_entity.dart';
import 'package:s/features/missed_prayers/domain/repo/missed_prayers_repository.dart';

part 'missed_prayers_state.dart';

enum PrayerType { fajr, dhuhr, asr, maghrib, isha }

class MissedPrayersCubit extends Cubit<MissedPrayersState> {
  MissedPrayersCubit(this.repository) : super(MissedPrayersInitial());
  final MissedPrayersRepository repository;

  Future<void> loadPrayersData() async {
    emit(MissedPrayersLoading());
    try {
      final data = await repository.getMissedPrayers();
      if (data != null) {
        emit(MissedPrayersLoaded(data));
      } else {
        emit(MissedPrayersInitial());
      }
    } catch (e) {
      emit(MissedPrayersError(e.toString()));
    }
  }

  void calculateAndSaveInitialData({
    required DateTime birthDate,
    required DateTime commitmentDate,
    required int doubtMonths,
  }) {
    emit(MissedPrayersLoading());
    try {
      const daysIn15HijriYears = 5315;

      final mandateDate = birthDate.add(
        const Duration(days: daysIn15HijriYears),
      );

      final totalDaysSinceMandate = commitmentDate
          .difference(mandateDate)
          .inDays;

      final doubtDays = doubtMonths * 30;

      final missedDays = totalDaysSinceMandate - doubtDays;

      if (missedDays <= 0) {
        emit(MissedPrayersError(AppTexts.invalidDateCalculation));
        return;
      }

      final entity = MissedPrayersEntity(
        totalTargetPerPrayer: missedDays,
        fajrLeft: missedDays,
        dhuhrLeft: missedDays,
        asrLeft: missedDays,
        maghribLeft: missedDays,
        ishaLeft: missedDays,
        birthDate: birthDate,
        commitmentDate: commitmentDate,
        doubtMonths: doubtMonths,
      );

      unawaited(repository.saveMissedPrayers(entity));

      emit(MissedPrayersLoaded(entity));
    } catch (e) {
      emit(MissedPrayersError(e.toString()));
    }
  }

  void performPrayer(PrayerType type, {bool isUndo = false}) {
    final currentState = state;
    if (currentState is MissedPrayersLoaded) {
      final currentData = currentState.prayersData;
      final modifier = isUndo ? 1 : -1;

      var newFajr = currentData.fajrLeft;
      var newDhuhr = currentData.dhuhrLeft;
      var newAsr = currentData.asrLeft;
      var newMaghrib = currentData.maghribLeft;
      var newIsha = currentData.ishaLeft;

      switch (type) {
        case PrayerType.fajr:
          newFajr = (newFajr + modifier).clamp(
            0,
            currentData.totalTargetPerPrayer,
          );
        case PrayerType.dhuhr:
          newDhuhr = (newDhuhr + modifier).clamp(
            0,
            currentData.totalTargetPerPrayer,
          );
        case PrayerType.asr:
          newAsr = (newAsr + modifier).clamp(
            0,
            currentData.totalTargetPerPrayer,
          );
        case PrayerType.maghrib:
          newMaghrib = (newMaghrib + modifier).clamp(
            0,
            currentData.totalTargetPerPrayer,
          );
        case PrayerType.isha:
          newIsha = (newIsha + modifier).clamp(
            0,
            currentData.totalTargetPerPrayer,
          );
      }

      final updatedEntity = MissedPrayersEntity(
        totalTargetPerPrayer: currentData.totalTargetPerPrayer,
        fajrLeft: newFajr,
        dhuhrLeft: newDhuhr,
        asrLeft: newAsr, // 👈 تم التعديل هنا (كانت currentData.asrLeft)
        maghribLeft:
            newMaghrib, // 👈 تم التعديل هنا (كانت currentData.maghribLeft)
        ishaLeft: newIsha, // 👈 تم التعديل هنا (كانت currentData.ishaLeft)
        birthDate: currentData.birthDate,
        commitmentDate: currentData.commitmentDate,
        doubtMonths: currentData.doubtMonths,
      );

      emit(MissedPrayersLoaded(updatedEntity));

      unawaited(repository.saveMissedPrayers(updatedEntity));
    }
  }

  void updateCalculationData({
    required DateTime newBirthDate,
    required DateTime newCommitmentDate,
    required int newDoubtMonths,
  }) {
    final currentState = state;
    if (currentState is MissedPrayersLoaded) {
      final currentData = currentState.prayersData;

      try {
        const daysIn15HijriYears = 5315;
        final mandateDate = newBirthDate.add(
          const Duration(days: daysIn15HijriYears),
        );
        final totalDaysSinceMandate = newCommitmentDate
            .difference(mandateDate)
            .inDays;
        final doubtDays = newDoubtMonths * 30;
        final newMissedDays = totalDaysSinceMandate - doubtDays;

        if (newMissedDays <= 0) {
          return;
        }

        final difference = newMissedDays - currentData.totalTargetPerPrayer;

        final updatedEntity = MissedPrayersEntity(
          totalTargetPerPrayer: newMissedDays,
          birthDate: newBirthDate,
          commitmentDate: newCommitmentDate,
          doubtMonths: newDoubtMonths,
          fajrLeft: (currentData.fajrLeft + difference).clamp(0, newMissedDays),
          dhuhrLeft: (currentData.dhuhrLeft + difference).clamp(
            0,
            newMissedDays,
          ),
          asrLeft: (currentData.asrLeft + difference).clamp(0, newMissedDays),
          maghribLeft: (currentData.maghribLeft + difference).clamp(
            0,
            newMissedDays,
          ),
          ishaLeft: (currentData.ishaLeft + difference).clamp(0, newMissedDays),
        );

        unawaited(repository.saveMissedPrayers(updatedEntity));
        emit(MissedPrayersLoaded(updatedEntity));
      } catch (e) {
        emit(MissedPrayersError(e.toString()));
      }
    }
  }
}
