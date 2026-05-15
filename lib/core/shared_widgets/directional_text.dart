import 'package:flutter/material.dart';
import 'package:s/core/utils/text_direction_utils.dart';

class DirectionalText extends StatelessWidget {
  const DirectionalText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final direction = textDirectionFor(text);
    return Text(
      text,
      style: style,
      textDirection: direction,
      textAlign: textAlignFor(text),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
