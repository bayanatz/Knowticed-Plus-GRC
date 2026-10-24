/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_card_styles.dart
/// Purpose: Declares `CardSvg`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// Shared visual tokens & helpers for the reusable Figma card widgets.
// Theme source: Knowticed app (AppColors / AppFontWeights).
// All sizes are responsive via flutter_screenutil (.sp / .w / .h / .r).

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// SVG icon assets used by the card widgets.
/// All paths point to existing, pubspec-declared assets in assets/icons_assets.
abstract class CardSvg {
  static const String services =
      'assets/icons_assets/main_icons_assets/ic_module_services.svg';
  static const String serviceProvider =
      'assets/icons_assets/main_icons_assets/ic_hr_healthcare_provider.svg';
  static const String jobTitle =
      'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg';
  static const String duration =
      'assets/icons_assets/main_icons_assets/ic_time_clock.svg';
  static const String approval =
      'assets/icons_assets/main_icons_assets/ic_status_approved_rosette.svg';
  static const String personalInfo =
      'assets/icons_assets/main_icons_assets/ic_user_profile.svg';
  static const String department =
      'assets/icons_assets/main_icons_assets/ic_building_office.svg';
  static const String message =
      'assets/icons_assets/main_icons_assets/ic_comms_chat_double.svg';
  static const String email =
      'assets/icons_assets/main_icons_assets/ic_comms_email.svg';
  static const String phone =
      'assets/icons_assets/main_icons_assets/ic_comms_phone_rounded.svg';
  static const String male =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png';
  static const String approve =
      'assets/icons_assets/main_icons_assets/ic_status_approved_rosette.svg';
  static const String reject =
      'assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg';
  static const String remove =
      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg';

  /// Builds an SVG icon, optionally tinted with [color].
  static Widget icon(String path, {Color? color, double? size}) =>
      CustomSvgImage.natural(
        assetPath: path,
        width: size?.r,
        height: size?.r,
        colorFilter:
            color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
      );
}

abstract class CardStyles {
  /// Default card corner radius (8 in Figma).
  static BorderRadius radius([double r = 8]) => BorderRadius.circular(r.r);

  /// "Diagonal cut" (D-03): an element in a card's corner — tick box, red
  /// minus, Message button, ribbon, ⋯ menu — sits this far from the top AND
  /// from the side. ADDED 17/10/2026 (Moataz: "all the diagonal cut is
  /// ten ten").
  static double get cornerInset => 10.r;

  /// Figma drop shadow: (-3, 4) blur 20, black 2%.
  static List<BoxShadow> get shadow => [
        BoxShadow(
          color: AppColors.totalBlack.withValues(alpha: 0.02),
          offset: Offset(-3.w, 4.h),
          blurRadius: 20.r,
        ),
      ];

  /// Maps a font size to the matching regular (w400) [StyleText] token.
  static TextStyle _regular(double size) {
    switch (size.round()) {
      case 8:
        return StyleText.fontSize8Weight400;
      case 10:
        return StyleText.fontSize10Weight400;
      case 11:
        return StyleText.fontSize11Weight400;
      case 12:
        return StyleText.fontSize12Weight400;
      case 13:
        return StyleText.fontSize13Weight400;
      case 15:
        return StyleText.fontSize15Weight400;
      case 16:
        return StyleText.fontSize16Weight400;
      case 14:
      default:
        return StyleText.fontSize14Weight400;
    }
  }

  /// Maps a font size to the matching medium (w500) [StyleText] token.
  static TextStyle _medium(double size) {
    switch (size.round()) {
      case 12:
        return StyleText.fontSize12Weight500;
      case 13:
        return StyleText.fontSize13Weight500;
      case 14:
        return StyleText.fontSize14Weight500;
      case 15:
        return StyleText.fontSize15Weight500;
      case 18:
        return StyleText.fontSize18Weight500;
      case 20:
        return StyleText.fontSize20Weight500;
      case 16:
      default:
        return StyleText.fontSize16Weight500;
    }
  }

  /// Grey label style (e.g. "Job Title:").
  static TextStyle label(double size) =>
      _regular(size).copyWith(color: AppColors.secondaryText);

  /// Dark value style (e.g. "Marketing Manager").
  static TextStyle value(double size) =>
      _regular(size).copyWith(color: AppColors.text);

  /// Card title style.
  static TextStyle title(double size) =>
      _medium(size).copyWith(color: AppColors.text);
}

/// A "label: value" entry used by the cards, with an optional leading icon.
class CardInfo {
  final String label;
  final String value;
  final Widget? icon;

  const CardInfo({required this.label, required this.value, this.icon});
}

/// Renders: [icon] label value   (e.g. "👤 Service Provider: Ahmed Mohammed")
class CardInfoRow extends StatelessWidget {
  final CardInfo info;
  final double fontSize;
  final double iconSize;

  const CardInfoRow({
    super.key,
    required this.info,
    this.fontSize = 14,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (info.icon != null) ...[
          SizedBox(
            width: iconSize.r,
            height: iconSize.r,
            // 22/10/2026: every info-row icon in the label grey
            // (AppColors.infoIcon), whatever colour the caller drew it in.
            child: ColorFiltered(
              colorFilter:
                  ColorFilter.mode(AppColors.infoIcon, BlendMode.srcIn),
              child: FittedBox(
                child: info.icon,
              ),
            ),
          ),
          SizedBox(width: 4.w),
        ],
        Flexible(
          child: Text.rich(
            TextSpan(
              text: '${info.label} ',
              style: CardStyles.label(fontSize),
              children: [
                TextSpan(
                  text: info.value,
                  style: CardStyles.value(fontSize),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
