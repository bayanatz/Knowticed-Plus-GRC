import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/navigation/breadcrumb_separator.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class BreadCrumbsComponent extends StatefulWidget {
  const BreadCrumbsComponent({
    super.key,
    required this.titles,
    required this.onTaps,
    this.isQiyasMode = false,
  });

  final bool isQiyasMode;
  final List<String> titles; // List of titles
  final List<Function()?> onTaps; // List of onTap callbacks

  @override
  State<BreadCrumbsComponent> createState() => _BreadCrumbsComponentState();
}

class _BreadCrumbsComponentState extends State<BreadCrumbsComponent> {
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    TextStyle breadCrumbsTextStyle = StyleText.fontSize16Weight400.copyWith(
      fontSize: isPortrait ? 18.sp : 10.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
      height: isPortrait ? 1.5 : 1.6,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(widget.titles.length, (index) {
          return Row(
            children: [
              GestureDetector(
                onTap: withHaptic(widget.onTaps[index], HapticLevel.low),
                child: Text(
                  widget.titles[index].tr,
                  style: breadCrumbsTextStyle,
                ),
              ),
              // Add separator and arrow only between items
              if (index < widget.titles.length - 1) ...[
                ...BreadcrumbSeparator.between(
                  isArabic: widget.isQiyasMode
                      ? true
                      : !Get.locale.toString().contains('en'),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}
