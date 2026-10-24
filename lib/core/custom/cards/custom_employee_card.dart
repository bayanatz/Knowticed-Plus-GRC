/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: person_chip_card.dart
/// Description: Declares `PersonChipCard`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 13/10/2026 - PersonChipCard opt-in `wrapText` (no "…", name clear of the tick box).
library;

// Figma node 6550:9608 — person chip card (265x65, light grey).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

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

  /// SVG shown inside the avatar circle when [avatar] is null — and also when
  /// it is set but fails to load, since `foregroundImage` falls back to the
  /// child.
  ///
  /// Defaults to [CardSvg.male] so every existing call site keeps the exact
  /// placeholder it has today. Pass a path to override it per screen; the
  /// database module passes [AppAssets.defaultEmployeeAvatar]
  /// (assets/icons_assets/qiyas_assets/ic_user_male.svg).
  final String? avatarPlaceholderAsset;

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

  /// Avatar radius (default 20). 24 makes the avatar as tall as the three
  /// text lines, so its padding is equal left / top / bottom (Time Tracker
  /// owner review C1, 13/10/2026).
  final double avatarRadius;

  /// ADDED 13/10/2026 (Time Tracker owner rule: data is never cut with
  /// "…"): the texts wrap instead of ending in "…", and the name keeps clear
  /// of the tick box in the corner. False keeps the historical one-line look.
  final bool wrapText;

  const PersonChipCard({
    super.key,
    required this.name,
    this.subtitle1,
    this.subtitle2,
    this.avatar,
    this.avatarPlaceholderAsset,
    this.trailing,
    this.showCheckBox = true,
    this.isSelected = false,
    this.onTap,
    this.backgroundColor,
    this.width,
    this.avatarRadius = 20,
    this.wrapText = false,
  });

  bool get _hasCorner => trailing != null || showCheckBox;
  double get _tickSize => 20.r;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: withHaptic(onTap, HapticLevel.low),
      borderRadius: CardStyles.radius(),
      child: Container(
        width: width ?? 265.w,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.card,
          borderRadius: CardStyles.radius(),
        ),
        child: Stack(
          children: [
            Padding(
              // Room for the corner box, so text never runs under it.
              padding: EdgeInsetsDirectional.only(
                end: _hasCorner ? _tickSize + 10.w : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: avatarRadius.r,
                    backgroundColor: AppColors.barrierColor,
                    foregroundImage: avatar,
                    child: ClipOval(
                      child: CardSvg.icon(
                        avatarPlaceholderAsset ?? CardSvg.male,
                        size: avatarRadius * 2,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          // [wrapText]: the name never runs under the tick box.
                          padding: EdgeInsetsDirectional.only(
                            end: 0,
                          ),
                          child: Text(
                            FormatHelper.capitalize(name),
                            style: CardStyles.title(14),
                            maxLines: wrapText ? null : 1,
                            overflow: wrapText ? null : TextOverflow.ellipsis,
                          ),
                        ),
                        if (subtitle1 != null)
                          Text(
                            FormatHelper.capitalize(subtitle1!),
                            style: CardStyles.label(12),
                            maxLines: wrapText ? null : 1,
                            overflow: wrapText ? null : TextOverflow.ellipsis,
                          ),
                        if (subtitle2 != null)
                          Text(
                            FormatHelper.capitalize(subtitle2!),
                            style: CardStyles.label(12),
                            maxLines: wrapText ? null : 1,
                            overflow: wrapText ? null : TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // CHANGED 17/10/2026 (Moataz: "the checkbox has to go to the left
            // corner with the diagonal cut" — on his Arabic screen): the tick
            // box (or a custom [trailing]) sits in the card's END corner —
            // left in Arabic, right in English — 10 from the top and 10 from
            // the side, the card's own 10 padding (D-03). It was a 25 box
            // scaled by a FittedBox, so its edges never sat on the 10 line.
            if (_hasCorner)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: trailing != null
                    ? SizedBox.square(
                        dimension: _tickSize,
                        child: FittedBox(child: trailing),
                      )
                    : CustomCheckBox(isSelected: isSelected, size: _tickSize),
              ),
          ],
        ),
      ),
    );
  }
}
