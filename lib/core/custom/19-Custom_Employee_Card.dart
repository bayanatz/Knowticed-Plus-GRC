// Figma node 6550:9608 — person chip card (265x65, light grey).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/23-custom_check_box.dart';
import 'package:grc_module/core/custom/16-custom_card_styles.dart';

/// Small person chip: avatar + name + up to two subtitle lines + trailing.
///
/// ```dart
/// PersonChipCard(
///   name: 'Amro Handousa',
///   subtitle1: 'Marketing',
///   subtitle2: 'Marketing Manager',
///   avatar: NetworkImage(url),
///   trailing: Icon(Icons.checklist, color: AppColors.primary),
///   onTap: () {},
/// )
/// ```
class PersonChipCard extends StatelessWidget {
  final String name;
  final String? subtitle1;
  final String? subtitle2;
  final ImageProvider? avatar;

  /// Custom trailing widget. If null and [showCheckBox] is true,
  /// the app's [CustomCheckBox] is shown instead.
  final Widget? trailing;

  /// Shows the app checkbox as the trailing widget.
  final bool showCheckBox;

  /// Checkbox state (used when [showCheckBox] is true).
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? width;

  const PersonChipCard({
    super.key,
    required this.name,
    this.subtitle1,
    this.subtitle2,
    this.avatar,
    this.trailing,
    this.showCheckBox = true,
    this.isSelected = false,
    this.onTap,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: CardStyles.radius(),
      child: Container(
        width: width ?? 265.w,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.card,
          borderRadius: CardStyles.radius(),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.barrierColor,
              foregroundImage: avatar,
              child: ClipOval(
                child: CardSvg.icon(CardSvg.male, size: 40),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: CardStyles.title(14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle1 != null)
                    Text(
                      subtitle1!,
                      style: CardStyles.label(12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (subtitle2 != null)
                    Text(
                      subtitle2!,
                      style: CardStyles.label(12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (trailing != null || showCheckBox) ...[
              SizedBox(width: 5.w),
              SizedBox(
                width: 25.r,
                height: 25.r,
                child: FittedBox(
                  child: trailing ?? CustomCheckBox(isSelected: isSelected),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
