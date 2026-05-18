import 'package:flutter/material.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';

class LegendItem {
  LegendItem({required this.color, required this.text, required this.count});
  final Color color;
  final String text;
  final int count;
}

class Legend extends StatelessWidget {
  const Legend({required this.items, super.key});

  final List<LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24.r,
      runSpacing: 12.r,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16.w, height: 16.h, color: item.color),
            8.horizontalSpace,
            Text(
              '${item.text}: ${item.count}',
              style: AppTextStyle.style16W500,
            ),
          ],
        );
      }).toList(),
    );
  }
}
