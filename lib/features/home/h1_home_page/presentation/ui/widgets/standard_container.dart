/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: standard_container.dart
/// Purpose: Declares `StandardContainer`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_colors.dart';

class StandardContainer extends StatelessWidget {
  const StandardContainer(
      {this.padding = 10, this.height, required this.child, super.key});
  final int padding;
  final Widget child;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.all(padding.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
