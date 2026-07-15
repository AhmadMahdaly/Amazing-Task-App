import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:s/core/utils/failure.dart';
import 'package:s/features/islamic_section/azkar/domain/entities/azkar_category_entity.dart';
import 'package:s/features/islamic_section/azkar/domain/repositories/base_azkar_repository.dart';

part 'azkar_state.dart';

enum AzkarType { morning, evening, sleeping }

class AzkarCubit extends Cubit<AzkarState> {
  AzkarCubit(this.azkarRepository) : super(AzkarInitial());
  final BaseAzkarRepository azkarRepository;

  AzkarCategoryEntity? currentCategory;
  Map<int, int> zekrCounters = {};

  Future<void> getAzkar(AzkarType type) async {
    emit(AzkarLoading());

    Either<Failure, AzkarCategoryEntity> result;

    switch (type) {
      case AzkarType.morning:
        result = await azkarRepository.getMorningAzkar();
      case AzkarType.evening:
        result = await azkarRepository.getEveningAzkar();
      case AzkarType.sleeping:
        result = await azkarRepository.getSleepingAzkar();
    }

    result.fold(
      (failure) => emit(AzkarError(failure.message)),
      (azkarCategory) {
        currentCategory = azkarCategory;

        zekrCounters.clear();
        for (final zekr in azkarCategory.items) {
          zekrCounters[zekr.id] = zekr.count;
        }

        emit(
          AzkarLoaded(
            azkarCategory: currentCategory!,
            counters: Map.from(zekrCounters),
          ),
        );
      },
    );
  }

  void decrementZekrCount(int zekrId) {
    if (currentCategory == null) return;

    if (zekrCounters.containsKey(zekrId) && zekrCounters[zekrId]! > 0) {
      zekrCounters[zekrId] = zekrCounters[zekrId]! - 1;

      emit(
        AzkarLoaded(
          azkarCategory: currentCategory!,
          counters: Map.from(zekrCounters),
        ),
      );
    }
  }
}
