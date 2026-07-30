// ignore_for_file: one_member_abstracts

import 'package:flutter/services.dart';
import 'package:s/features/islamic_section/anbyaa/domain/entities/anbyaa.dart';

abstract class AnbyaaLocalDataSource {
  Future<List<Anbyaa>> getAll();
}

class AnbyaaLocalDataSourceImpl implements AnbyaaLocalDataSource {
  @override
  Future<List<Anbyaa>> getAll() async {
    final raw = await rootBundle.loadString(
      'assets/text/anbyaa.txt',
    );

    return _parse(raw);
  }

  List<Anbyaa> _parse(String raw) {
    final result = <Anbyaa>[];

    final matches = RegExp(
      r'^(\d+)\s*\r?\n([^\r\n]+)\r?\n',
      multiLine: true,
    ).allMatches(raw).toList();

    for (var i = 0; i < matches.length; i++) {
      final current = matches[i];

      final start = current.end;
      final end = i == matches.length - 1 ? raw.length : matches[i + 1].start;

      final id = int.parse(current.group(1)!); // الرقم
      final title = current.group(2)!.trim(); // أول سطر بعد الرقم
      final content = raw.substring(start, end).trim();

      result.add(
        Anbyaa(
          id: id,
          title: title,
          preview: _buildPreview(content),
          content: content,
        ),
      );
    }

    return result;
  }

  String _buildPreview(String content) {
    final preview = content
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return preview.length > 120 ? '${preview.substring(0, 120)}...' : preview;
  }
}
