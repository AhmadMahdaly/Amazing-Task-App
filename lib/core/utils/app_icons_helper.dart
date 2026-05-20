import 'package:flutter/material.dart';

class AppIconsHelper {
  static const List<IconData> availableIcons = [
    Icons.list,
    Icons.work_outline,
    Icons.home_outlined,
    Icons.shopping_cart_outlined,
    Icons.school_outlined,
    Icons.flight_takeoff,
    Icons.favorite_border,
    Icons.star_border,
    Icons.fitness_center,
    Icons.cake_outlined,
    Icons.palette_outlined,
    Icons.menu_book,
  ];

  static IconData getIconFromCode(int? codePoint) {
    if (codePoint == null) return Icons.list;

    return availableIcons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.list,
    );
  }
}
