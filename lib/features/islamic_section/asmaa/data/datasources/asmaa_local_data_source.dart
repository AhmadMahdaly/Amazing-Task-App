// data/datasources/asmaa_local_data_source.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_lesson.dart';

class AsmaaLocalDataSource {
  Future<List<AsmaaLesson>> fetchAndParseLessons() async {
    try {
      final rawText = await rootBundle.loadString('assets/text/asmaa.txt');

      final rawLessons = rawText.split('بسـم اللـه الرحمـن الرحيـم');

      final lessons = <AsmaaLesson>[];

      final titleRegex = RegExp(
        r'الدرس\s*:\s*\d+\s*-\s*(اسم الله .+)\s*\.',
      );

      var currentId = 1;

      for (final rawLesson in rawLessons) {
        if (rawLesson.trim().isEmpty) continue;

        final match = titleRegex.firstMatch(rawLesson);
        final title = match != null
            ? match.group(1)?.trim() ?? 'درس غير معروف'
            : 'مقدمة/درس';

        lessons.add(
          AsmaaLesson(
            id: currentId,
            title: title,
            content: 'بسـم اللـه الرحمـن الرحيـم\n${rawLesson.trim()}',
          ),
        );
        currentId++;
      }

      return lessons;
    } catch (e) {
      throw Exception('فشل في قراءة أو معالجة ملف أسماء الله الحسنى');
    }
  }
}
