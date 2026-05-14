import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../resources/app_colors.dart';
import '../responsive/responsive_config.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.size = 50, this.color});
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitSquareCircle(
        size: size.sp,
        color: color ?? AppColors.primaryColor, //.withAlpha(100),
      ),
    );
  }
}
