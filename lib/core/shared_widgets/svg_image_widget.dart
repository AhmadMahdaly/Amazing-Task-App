import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../responsive/responsive_config.dart';

class SvgImage extends StatelessWidget {
  const SvgImage({
    required this.imagePath,
    super.key,
    this.height = 24,
    this.width,
    this.color,
    this.isNetwork = false,
    this.isFill = false,
    this.placeholder,
    this.errorWidget,
  });

  final String imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final bool isNetwork;
  final bool isFill;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final boxFit = isFill ? BoxFit.fill : BoxFit.contain;
    final colorFilter = color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : null;

    if (isNetwork) {
      return SvgPicture.network(
        imagePath,
        height: height?.h ?? 24.h,
        width: width?.w ?? 24.w,
        fit: boxFit,
        colorFilter: colorFilter,
        placeholderBuilder: (context) =>
            placeholder ??
            Center(
              child: SizedBox(
                width: width?.w ?? 24.w,
                height: height?.h ?? 24.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: height?.r ?? 24.r,
            ),
      );
    } else {
      return SvgPicture.asset(
        imagePath,
        height: height?.h ?? 24.h,
        width: width?.w ?? 24.w,
        fit: boxFit,
        colorFilter: colorFilter,
      );
    }
  }
}
