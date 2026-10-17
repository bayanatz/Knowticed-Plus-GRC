/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: app_search_text_field.dart
/// Description: Declares `AppSearchTextField`.
/// Author: Amr Mesbah
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - (Time Tracker UI fix round 1) optional
///          `contentPadding` and `valueStyle`; null keeps the previous look,
///          so every existing caller (To-Do included) is unchanged.
library;

/// ************************* FILE INFO *************************
/// File Name: 35-custom_search_widget_custom.dart
/// Description: app custom search text field (uses CustomTextField)
/// Created by: Mohamed Elrashidy
/// Created on: 5/5/2025
import 'package:grc_module/core/custom/buttons/custom_toolbar_action_button.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/custom/helpers/custom_haptic.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/custom/inputs/custom_textfield.dart';

class AppSearchTextField extends StatelessWidget {
  const AppSearchTextField({
    required this.controller,
    this.onChanged,
    super.key,
    this.fillColor,
    this.hintText, // ✅ Added optional hint parameter
    this.borderRadius,
    this.suffixIcon,
    this.textInputAction,
    this.hintFontSize,
    this.onSubmitted,
    this.textAlign,
    this.textDirection,
    this.showSearchIcon = true,
    this.prefixIcon,
    this.expanded = true,
    this.height,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.contentPadding,
    this.valueStyle,
  });

  final TextEditingController controller;
  final Color? fillColor;
  final dynamic Function(String)? onChanged;
  final String? hintText; // ✅ Optional hint text
  final BorderRadius? borderRadius;

  /// Optional hint font size (in `.sp`). Defaults to the field's own 12.sp.
  final double? hintFontSize;

  /// Optional trailing widget — normally a "clear" button.
  /// ADDED 16/8/2026: the screens that used to hand-roll a search field out of
  /// [CustomTextField] needed it, and they must all go through this widget now.
  final Widget? suffixIcon;

  /// Optional keyboard action, e.g. [TextInputAction.search]. Same reason.
  final TextInputAction? textInputAction;

  // ── ADDED 2/9/2026 ─────────────────────────────────────────────────────────
  // The chat composer (send_new_message/*) hand-rolled its input out of
  // [CustomTextField] because this widget could not do four things it needs.
  // All four are additive and default to the previous behaviour, so every
  // existing caller is unchanged.

  /// Called when the keyboard action button is pressed. The composer uses this
  /// for send-on-Enter on laptop/desktop; search screens leave it null.
  final ValueChanged<String>? onSubmitted;

  /// Text alignment inside the field. Null → [CustomTextField]'s own default
  /// ([TextAlign.start]).
  final TextAlign? textAlign;

  /// Text direction, for RTL/LTR mixed content. Null → inherited.
  final TextDirection? textDirection;

  /// Whether to draw the built-in search magnifier as the prefix.
  ///
  /// Defaults to true — this widget IS the app search field. Pass false where
  /// the field is not a search box (the chat composer), so it renders as a
  /// plain input with no leading icon.
  final bool showSearchIcon;

  /// Replaces the built-in magnifier with a custom leading widget. Takes
  /// precedence over [showSearchIcon].
  final Widget? prefixIcon;

  /// Whether to wrap the field in an [Expanded].
  ///
  /// Defaults to true, which is what every search screen wants — the field
  /// sits directly in a [Row] next to filter buttons. It MUST be false when
  /// the parent is not a [Flex] (e.g. inside an [AnimatedSwitcher] that is
  /// itself already inside an [Expanded]), otherwise Flutter throws
  /// "Expanded widgets must be placed inside Flex widgets".
  final bool expanded;

  /// Fixed field height, as a RAW number — pass 38, never 38.sp.
  ///
  /// [CustomTextField] applies the scaling itself (`height: widget.height?.sp`),
  /// so a value that already has `.sp` on it is scaled twice and the field
  /// comes out taller than everything beside it. Defaults to the search box's
  /// own 38.
  final double? height;

  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;

  // ── ADDED 9/10/2026 (Time Tracker UI fix round 1) ─────────────────────────
  // The owner asked for the typed text and the hint to sit in the vertical
  // centre of the 38-high box. With the default 11.sp top / bottom padding
  // the Cairo cap height lands ~2 px below the centre (measured on a
  // rendered field: 16 px above the letters, 12 px below). Both parameters
  // are additive; null = the historical values.

  /// Overrides the field's inner padding. Null → horizontal 12.sp,
  /// vertical 11.sp.
  final EdgeInsetsGeometry? contentPadding;

  /// Style of the typed text. Null → [CustomTextField]'s 14.sp regular.
  final TextStyle? valueStyle;


  @override
  Widget build(BuildContext context) {
    final Widget? leading = prefixIcon ??
        (showSearchIcon
            ? CustomSvgImage(
                assetPath:
                    "assets/icons_assets/main_icons_assets/ic_action_search_thin.svg",
                // CHANGED 18/10/2026 (Moataz: search, filter and sort icons
                // must be the same colour and size) — ToolbarStyle, the
                // tokens the Filter and Sort buttons beside it read.
                width: ToolbarStyle.iconSize,
                height: ToolbarStyle.iconSize,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  ToolbarStyle.contentColor,
                  BlendMode.srcIn,
                ),
              )
            : null);

    final Widget field = CustomTextField(
      height: height ?? 38,
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      hint: hintText ??
          S.of(context).search, // ✅ Use custom hint or default to search
      maxLines: 1,
      hintFontSize: hintFontSize,
      suffixIcon: suffixIcon,
      textInputAction: textInputAction,
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection,
      fillColor: fillColor ?? AppColors.card,
      // D-151 (17/10/2026): the search shows a secondary border while typing.
      focusBorderColor: AppColors.secondaryPrimary,
      borderRadius: borderRadius ?? BorderRadius.circular(8.r),
      // FIXED 8/9/2026 — vertical was 20.sp, against a field whose height is
      // 38 (see `height ?? 38` above). 20 top + 20 bottom is 40 of padding
      // inside a 38 box BEFORE the text itself, so the content InputDecorator
      // wanted was taller than the box it was given. A tight SizedBox does not
      // shrink that content; it clips it, and the overflow lands at the bottom
      // — which is why the hint and the typed text sat high in the field
      // instead of centred.
      //
      // 8.sp leaves 38 - 16 = 22 for a 12-14.sp line, which fits, so the
      // centring below has room to work.
      contentPadding: contentPadding ??
          EdgeInsets.symmetric(horizontal: 12.sp, vertical: 11.sp),
      valueStyle: valueStyle,
      hintStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.secondaryText,
      ),
      prefixIcon: leading,
      onTap: () {
        hapticController.triggerHapticFeedback(
          vibration: VibrateType.lightImpact,
          hapticFeedback: HapticFeedback.lightImpact,
        );
      },
    );

    return expanded ? Expanded(child: field) : field;
  }
}
