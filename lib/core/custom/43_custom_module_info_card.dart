// Figma node 6550:8690 — module info card (324x110) with compliance chip,
// plus the removable owner avatar chip and the AR/ENG language toggle
// from the same frame.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';

/// Module info card: leading icon box + title + info rows + yellow
/// compliance-score chip (bottom start) + last-update footer (bottom end)
/// + optional three-dot menu (top end).
///
/// ```dart
/// ModuleInfoCard(
///   title: 'Data Management',
///   infoRows: const [
///     CardInfo(label: 'Owner :', value: 'Amro Handousa'),
///     CardInfo(label: 'Creation Date:', value: '28 May 2020'),
///   ],
///   complianceScore: '-',
///   footerLabel: 'Last Update:',
///   footerValue: '28 May 2020',
///   onMenuTap: () {},
/// )
/// ```
class ModuleInfoCard extends StatelessWidget {
  final String title;
  final Widget? icon;
  final List<CardInfo> infoRows;

  /// Value shown inside the yellow chip ("Compliance Score: [value]").
  /// Hidden when null.
  final String? complianceScore;
  final String complianceLabel;
  final String? footerLabel;
  final String? footerValue;
  final VoidCallback? onMenuTap;
  final VoidCallback? onTap;
  final double? width;

  const ModuleInfoCard({
    super.key,
    required this.title,
    this.icon,
    this.infoRows = const [],
    this.complianceScore,
    this.complianceLabel = 'Compliance Score:',
    this.footerLabel,
    this.footerValue,
    this.onMenuTap,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: CardStyles.radius(4),
      child: Container(
        width: width ?? 324.w,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: CardStyles.radius(4),
          boxShadow: CardStyles.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading icon box (64x64, light grey, radius 4).
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 36.r,
                      height: 36.r,
                      child: FittedBox(
                        child: icon ?? CardSvg.icon(CardSvg.services),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: CardStyles.title(14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      for (final info in infoRows)
                        Padding(
                          padding: EdgeInsets.only(bottom: 3.h),
                          child: CardInfoRow(info: info, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                if (onMenuTap != null)
                  InkWell(
                    onTap: onMenuTap,
                    borderRadius: CardStyles.radius(4),
                    child: Padding(
                      padding: EdgeInsets.all(2.r),
                      child: Icon(
                        Icons.more_horiz,
                        size: 18.r,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (complianceScore != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '$complianceLabel $complianceScore',
                      style: CardStyles.title(12),
                    ),
                  ),
                const Spacer(),
                if (footerLabel != null || footerValue != null)
                  Text.rich(
                    TextSpan(
                      text: '${footerLabel ?? ''} ',
                      style: CardStyles.label(10),
                      children: [
                        TextSpan(
                          text: footerValue ?? '',
                          style: CardStyles.value(10),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular avatar with a small red "remove" badge (top end), as shown in
/// the selected Module Owner row of Figma node 6550:8690.
class RemovableAvatarChip extends StatelessWidget {
  final ImageProvider? avatar;
  final VoidCallback? onRemove;
  final double radius;

  const RemovableAvatarChip({
    super.key,
    this.avatar,
    this.onRemove,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (radius * 2 + 6).r,
      height: (radius * 2 + 6).r,
      child: Stack(
        children: [
          PositionedDirectional(
            bottom: 0,
            start: 0,
            child: CircleAvatar(
              radius: radius.r,
              backgroundColor: AppColors.barrierColor,
              foregroundImage: avatar,
              child: ClipOval(
                child: CardSvg.icon(CardSvg.male, size: radius * 2),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Container(
                width: 14.r,
                height: 14.r,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.card, width: 1.r),
                ),
                child: Icon(
                  Icons.close,
                  size: 9.r,
                  color: AppColors.colorWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// AR / ENG pill toggle from Figma node 6550:8690 ("language").
///
/// ```dart
/// LanguageToggle(
///   selectedIndex: 1, // ENG
///   onChanged: (i) {},
/// )
/// ```
class LanguageToggle extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const LanguageToggle({
    super.key,
    this.options = const ['AR', 'ENG'],
    this.selectedIndex = 0,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) SizedBox(width: 8.w),
            _pill(i),
          ],
        ],
      ),
    );
  }

  Widget _pill(int index) {
    final bool selected = index == selectedIndex;
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(index),
      borderRadius: CardStyles.radius(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: CardStyles.radius(),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.r,
          ),
        ),
        child: Text(
          options[index],
          style: CardStyles.title(12).copyWith(
            color: selected ? AppColors.textButton : AppColors.text,
          ),
        ),
      ),
    );
  }
}
