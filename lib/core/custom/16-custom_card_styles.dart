// Shared visual tokens & helpers for the reusable Figma card widgets.
// Theme source: Knowticed app (AppColors / AppFontWeights).
// All sizes are responsive via flutter_screenutil (.sp / .w / .h / .r).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';

/// SVG icon assets used by the card widgets.
/// All paths point to existing, pubspec-declared assets in assets/icons_assets.
abstract class CardSvg {
  static const String _icons = 'assets/icons_assets';

  static const String services = '$_icons/settings_assets/services_icon.svg';
  static const String serviceProvider = '$_icons/todo_new_assets/Provider.svg';
  static const String jobTitle = '$_icons/roles_assets/job_title.svg';
  static const String duration = '$_icons/tracking_assets/duration.svg';
  static const String approval = '$_icons/services_assets/approval_icons.svg';
  static const String personalInfo =
      '$_icons/main_icons_assets/personalInfo.svg';
  static const String department =
      '$_icons/main_icons_assets/images_department.svg';
  static const String message =
      '$_icons/main_icons_assets/message_new_icon.svg';
  static const String email = '$_icons/form_builder_assets/email_icon.svg';
  static const String phone = '$_icons/form_builder_assets/phone_icon.svg';
  static const String male = '$_icons/main_icons_assets/assets_male.svg';
  static const String approve = '$_icons/main_icons_assets/approve.svg';
  static const String reject = '$_icons/main_icons_assets/state_reject.svg';
  static const String remove =
      '$_icons/knowledge_hub_assets/remove_icon.svg';

  /// Builds an SVG icon, optionally tinted with [color].
  static Widget icon(String path, {Color? color, double? size}) =>
      SvgPicture.asset(
        path,
        width: size?.r,
        height: size?.r,
        colorFilter:
            color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
      );
}

abstract class CardStyles {
  /// Default card corner radius (8 in Figma).
  static BorderRadius radius([double r = 8]) => BorderRadius.circular(r.r);

  /// Figma drop shadow: (-3, 4) blur 20, black 2%.
  static List<BoxShadow> get shadow => [
        BoxShadow(
          color: AppColors.totalBlack.withOpacity(0.02),
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
            child: FittedBox(child: info.icon,),
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
