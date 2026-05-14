import 'package:flutter/foundation.dart';

extension DebugPrintExtension on Object? {
  void dPrint([String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix${this ?? 'null'}');
    }
  }
}
