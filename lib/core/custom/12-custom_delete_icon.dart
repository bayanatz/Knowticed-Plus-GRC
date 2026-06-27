import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/core/custom/32-custom_svg.dart';
import '../theme/app_colors.dart';

/// Delete action button.
///
/// Fixed (static) values:
/// - Mobile: 38.sp x 38.sp, icon only (no text)
/// - Non-mobile: 100.sp x 38.sp, svg + text with 8.sp space
/// - Border radius: 8.r
/// - Svg: assets/delete.svg, 20.sp x 20.sp
class CustomDeleteIcon extends StatelessWidget {
  static const String _svgPath = 'assets/delete.svg';

  final String? title;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final Color? svgColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  const CustomDeleteIcon({
    super.key,
    this.title,
    this.onTap,
    this.color,
    this.borderColor,
    this.svgColor,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isPhone;
    final bool isArabic = Get.locale?.languageCode == 'ar';
    final String text = title ?? (isArabic ? 'حذف' : 'Delete');
    final Color iconColor = svgColor ?? AppColors.textButton;

    final Widget svg = CustomSvg(
      assetPath: _svgPath,
      width: 20.sp,
      height: 20.sp,
      color: iconColor,
      fit: BoxFit.scaleDown,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMobile ? 38.sp : 100.sp,
        height: 38.sp,
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          border: Border.all(color: borderColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: isMobile
            ? Center(child: svg)
            : Padding(
                padding: padding ?? EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    svg,
                    SizedBox(width: 8.sp),
                    Flexible(
                      child: Text(
                        text,
                        style: textStyle ??
                            TextStyle(fontSize: 14.sp, color: iconColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
