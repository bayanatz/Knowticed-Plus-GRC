/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_settings_dialog_frame.dart
/// Purpose: THE frame of every "[Name] Settings" dialog —
///          `CustomSettingsDialogFrame` (round gear header · scrolling fields
///          · Discard left / Save right) and `showCustomSettingsDialog`.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026 (D-242, Moataz 21/10/2026)
///
/// Rules: compact dialog, 450 wide (X-20); header = 30 yellow circle + gear +
/// 8 + 18 Medium title (X-18); Discard (grey) at the start edge and Save
/// (yellow) at the end edge, same width, 12 apart; Arabic mirrors (X-01); the fields scroll when the keyboard or a small screen leaves too
/// little room, the buttons never do.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The gear glyph shared by the dialog header and the home gear badge.
const String kSettingsGearAsset =
    'assets/icons_assets/main_icons_assets/ic_module_settings.svg';

/// Dialog width (X-20 "compact").
const double kSettingsDialogWidth = 450;

class CustomSettingsDialogFrame extends StatelessWidget {
  const CustomSettingsDialogFrame({
    super.key,
    required this.title,
    required this.children,
    required this.onDiscard,
    required this.onSave,
  });

  /// The full title, e.g. "Services Status Settings".
  final String title;

  /// The field rows, already spaced by the frame (15 between).
  final List<Widget> children;

  final VoidCallback onDiscard;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ScaleInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomDialogHeader(title: title, icon: kSettingsGearAsset),
          SizedBox(height: 15.h),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int i = 0; i < children.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(height: 15.h),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            // X-01 (owner, 21/10/2026): Discard at the start edge, Save at the
            // end edge — so in Arabic Save is on the LEFT. No forced ltr.
            children: <Widget>[
              Expanded(
                child: customButton(
                  title: s.discard,
                  haptic: HapticController.high,
                  function: onDiscard,
                  fullWidth: true,
                  color: AppColors.secondaryAction,
                  textStyle: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.onSecondaryAction),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ShrinkOnTap(
                  child: customButton(
                    title: s.save,
                    function: onSave,
                    fullWidth: true,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Opens [child] (a [CustomSettingsDialogFrame]) in the 450 wide compact
/// dialog. Returns whatever the frame's Save pops with.
Future<T?> showCustomSettingsDialog<T>({
  required BuildContext context,
  required Widget child,
}) =>
    CustomDialogManager.showContent<T>(
      context: context,
      width: kSettingsDialogWidth,
      child: child,
    );
