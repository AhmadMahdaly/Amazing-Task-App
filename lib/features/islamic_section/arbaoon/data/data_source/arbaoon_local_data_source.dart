import 'package:flutter/services.dart';

import '../../domain/entities/hadith.dart';

abstract class ArbaoonLocalDataSource {
  Future<List<Hadith>> getHadiths();
}

class ArbaoonLocalDataSourceImpl implements ArbaoonLocalDataSource {
  @override
  Future<List<Hadith>> getHadiths() async {
    final text = await rootBundle.loadString('assets/text/arbaoon.txt');

    final regex = RegExp(
      r'(الحديث\s+[^\n]+)',
      multiLine: true,
    );

    final matches = regex.allMatches(text).toList();

    final hadiths = <Hadith>[];

    for (var i = 0; i < matches.length; i++) {
      final start = matches[i].start;
      final end = i == matches.length - 1 ? text.length : matches[i + 1].start;

      final block = text.substring(start, end).trim();

      final lines = block
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList();

      if (lines.isEmpty) continue;

      final title = lines.first.trim();

      final content = lines.skip(1).join('\n').trim();

      final preview = content
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      hadiths.add(
        Hadith(
          id: i + 1,
          title: title,
          preview: preview.length > 120
              ? '${preview.substring(0, 120)}...'
              : preview,
          content: content,
        ),
      );
    }

    return hadiths;
  }
}
