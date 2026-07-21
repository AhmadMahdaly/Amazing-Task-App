// ignore_for_file: one_member_abstracts

import 'package:flutter/services.dart';
import 'package:s/features/islamic_section/tabeen/domain/entities/tabeen.dart';

abstract class TabeenLocalDataSource {
  Future<List<Tabeen>> getAll();
}

class TabeenLocalDataSourceImpl implements TabeenLocalDataSource {
  @override
  Future<List<Tabeen>> getAll() async {
    final raw = await rootBundle.loadString(
      'assets/text/tabeen.txt',
    );

    return _parse(raw);
  }

  List<Tabeen> _parse(String raw) {
    final result = <Tabeen>[];

    final matches = RegExp(
      r'^(\d+)\s*\r?\n([^\r\n]+)\r?\n',
      multiLine: true,
    ).allMatches(raw).toList();

    for (var i = 0; i < matches.length; i++) {
      final current = matches[i];

      final start = current.end;
      final end = i == matches.length - 1 ? raw.length : matches[i + 1].start;

      final title = current.group(2)!.trim();

      final content = raw.substring(start, end).trim();

      final preview = _buildPreview(content);

      result.add(
        Tabeen(
          id: result.length + 1,
          title: title,
          preview: preview,
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
