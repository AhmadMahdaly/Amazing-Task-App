import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_lesson.dart';

abstract class AsmaaRepository {
  Future<List<AsmaaLesson>> getAsmaaLessons();
}
