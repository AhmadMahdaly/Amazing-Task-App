import 'package:flutter/material.dart';

/// Returns RTL when the first strong letter is Arabic/Hebrew, otherwise LTR.
TextDirection textDirectionFor(String text) {
  for (final codeUnit in text.runes) {
    if (_isNeutral(codeUnit)) continue;
    return _isRtl(codeUnit) ? TextDirection.rtl : TextDirection.ltr;
  }
  return TextDirection.ltr;
}

TextAlign textAlignFor(String text) {
  return textDirectionFor(text) == TextDirection.rtl
      ? TextAlign.right
      : TextAlign.left;
}

bool _isNeutral(int codeUnit) {
  return codeUnit <= 0x0020 ||
      codeUnit == 0x00A0 ||
      (codeUnit >= 0x2000 && codeUnit <= 0x200F) ||
      (codeUnit >= 0x2028 && codeUnit <= 0x202E) ||
      (codeUnit >= 0x2066 && codeUnit <= 0x2069);
}

bool _isRtl(int codeUnit) {
  return (codeUnit >= 0x0590 && codeUnit <= 0x08FF) ||
      (codeUnit >= 0xFB1D && codeUnit <= 0xFDFF) ||
      (codeUnit >= 0xFE70 && codeUnit <= 0xFEFF);
}
