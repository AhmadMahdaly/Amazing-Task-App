import 'package:bloc/bloc.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_lesson.dart';
import 'package:s/features/islamic_section/asmaa/domain/repositories/asmaa_repository.dart';

part 'asmaa_state.dart';

class AsmaaCubit extends Cubit<AsmaaState> {
  AsmaaCubit(this.repository) : super(AsmaaInitial());
  final AsmaaRepository repository;

  // حفظ كل الدروس للوصول لها عند التنقل للدرس التالي
  List<AsmaaLesson> allLessons = [];

  Future<void> loadLessons() async {
    emit(AsmaaLoading());
    try {
      final lessons = await repository.getAsmaaLessons();
      allLessons = lessons;

      // جلب آخر درس تم قراءته من الكاش
      final lastReadId = CacheHelper.getData('last_read_asmaa_lesson') as int?;

      emit(AsmaaLoaded(lessons, lastReadLessonId: lastReadId));
    } catch (e) {
      emit(AsmaaError(e.toString()));
    }
  }

  // دالة لحفظ آخر درس تم قراءته
  void saveLastRead(int lessonId) {
    CacheHelper.saveData(key: 'last_read_asmaa_lesson', value: lessonId);

    // تحديث الحالة إذا كانت محملة لتحديث كارت "العودة للقراءة"
    if (state is AsmaaLoaded) {
      final currentState = state as AsmaaLoaded;
      emit(AsmaaLoaded(currentState.lessons, lastReadLessonId: lessonId));
    }
  }
}
