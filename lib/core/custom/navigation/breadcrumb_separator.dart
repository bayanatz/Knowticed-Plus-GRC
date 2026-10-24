/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: breadcrumb_separator.dart
/// Purpose: The ONE chevron-with-gaps that sits between two page titles in a
///          breadcrumb ("Settings > Home Layout > Adding Widget").
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Three breadcrumbs drew their own separator with different gaps (15 / 10 /
/// none), so the same trail looked different from module to module. Moataz
/// 22/10/2026: the Settings > Home Layout > Adding Widget trail is the model —
/// 15 each side of a 25 chevron — and every module follows it. Use
/// [BreadcrumbSeparator.between] in any new trail; never hand-draw one.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

abstract final class BreadcrumbSeparator {
  /// Space between a title and the chevron, each side.
  static double get gap => 15.sp;

  /// Chevron width and height.
  static double get size => 25.sp;

  /// The three widgets that go between two crumbs: gap, chevron, gap. Flip for
  /// Arabic so the chevron points the reading direction.
  static List<Widget> between({required bool isArabic}) => <Widget>[
        SizedBox(width: gap),
        Transform.rotate(
          angle: isArabic ? -3.14 : 0,
          child: Container(
            // Arabic glyphs sit higher in their line box than Latin ones, so
            // the chevron is lifted there instead of dropped (it was 7 up in
            // the side frame before this widget; Moataz 22/10/2026: "not
            // centred by eye in Arabic").
            // 23/10/2026 (Moataz: "the arrow is not aligned with the two
            // words"): this margin sits INSIDE the 180° rotation, so a bottom
            // margin in Arabic pushes the chevron DOWN by half its size, the
            // opposite of the "lift" the old comment claimed. Measured on the
            // iPad: with no margin the chevron is ~3.8px above the centre of
            // "الرئيسية"; bottom 7 put it ~5.5px below. 3 centres it.
            margin: isArabic
                ? EdgeInsets.only(bottom: 3.sp)
                : EdgeInsets.only(top: 3.sp),
            child: CustomSvgImage.natural(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg',
              height: size,
              width: size,
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
            ),
          ),
        ),
        SizedBox(width: gap),
      ];
}
