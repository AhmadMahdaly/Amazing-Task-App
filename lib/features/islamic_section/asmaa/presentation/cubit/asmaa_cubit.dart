// ignore_for_file: discarded_futures

import 'package:bloc/bloc.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_lesson.dart';
import 'package:s/features/islamic_section/asmaa/domain/repositories/asmaa_repository.dart';

part 'asmaa_state.dart';

class AsmaaCubit extends Cubit<AsmaaState> {
  AsmaaCubit(this.repository) : super(AsmaaInitial());
  final AsmaaRepository repository;

  List<AsmaaLesson> allLessons = [];

  Future<void> loadLessons() async {
    emit(AsmaaLoading());
    try {
      final lessons = await repository.getAsmaaLessons();
      allLessons = lessons;

      final lastReadId = CacheHelper.getData(CacheKeys.lastReadAsmaa) as int?;

      emit(AsmaaLoaded(lessons, lastReadLessonId: lastReadId));
    } catch (e) {
      emit(AsmaaError(e.toString()));
    }
  }

  void saveLastRead(int lessonId) {
    CacheHelper.saveData(key: CacheKeys.lastReadAsmaa, value: lessonId);

    if (state is AsmaaLoaded) {
      final currentState = state as AsmaaLoaded;
      emit(AsmaaLoaded(currentState.lessons, lastReadLessonId: lessonId));
    }
  }
}
