/// Module: services / sv2_create_single_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: sla_mobile_section.dart
/// Purpose: One "Notify …" section of the phone SLA step: its checkbox, the
///          bullet list of when it is sent, and optional extra content (the
///          SLA field, the manager switches). Replaces the extension on the
///          screen's State (Provider rule 7).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Class Name: [SlaMobileSection]
///
/// Purpose: A notification section with a checkbox.
class SlaMobileSection extends StatelessWidget {
  const SlaMobileSection({
    required this.title,
    required this.items,
    required this.isChecked,
    required this.onToggle,
    this.children = const [],
    super.key,
  });

  final String title;

  /// When the notification is sent (one bullet each).
  final List<String> items;
  final bool isChecked;
  final ValueChanged<bool> onToggle;

  /// Shown under the bullets (SLA field, switches).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTapDown: (_) => HapticController.low(),
          onTap: () => onToggle(!isChecked),
          child: Row(
            children: [
              CustomCheckBox(isSelected: isChecked, size: 20.sp),
              // QA p.15: 6 let the box touch the first letter of the title.
              SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  FormatHelper.capitalize(title),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsetsDirectional.only(
              start: 30.sp,
              top: 6.sp,
              bottom: 1.sp,
            ),
            child: Text(
              '• $item',
              style: StyleText.fontSize10Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ),
        ...children,
        SizedBox(height: 20.h),
      ],
    );
  }
}
