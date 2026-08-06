import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/theme/app_colors.dart';

import 'package:grc_module/core/theme/app_theme.dart';

class AccessGrantorWidget extends StatelessWidget {
  final String title;
  final String name;
  final String? imagePath;

  const AccessGrantorWidget({
    super.key,
    required this.title,
    required this.name,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.all(12.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              title,
              style: StyleText.fontSize10Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 6.sp),

            // Name/Value
            Text(
              name,
              style: StyleText.fontSize12Weight500.copyWith(
                color: lightMode
                    ? const Color(0xFF1F2937)
                    : const Color(0xFFF3F4F6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}