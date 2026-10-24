/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_widget_gear_badge.dart
/// Purpose: Declares `HomeWidgetGearBadge` — the settings gear on the top-right
///          corner of a home widget or chart, beside the red minus on
///          the top-right (D-242). Same place on Home Layout and on the
///          Adding Widget page.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dialogs/custom_settings_dialog_frame.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_widget_settings_schema.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/widget_settings/home_widget_settings_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Hands the new settings of [model] to whoever owns the draft.
typedef HomeSettingsSaved = void Function(
    HomeComponentModel model, Map<String, dynamic> settings);

class HomeWidgetGearBadge extends StatelessWidget {
  const HomeWidgetGearBadge({
    super.key,
    required this.model,
    required this.onSaved,
  });

  final HomeComponentModel model;
  final HomeSettingsSaved onSaved;

  /// True when [model]'s widget has a settings dialog.
  static bool shownFor(HomeComponentModel model) =>
      HomeWidgetSettingsSchema.has(model.component);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey<String>('gear_${model.component.name}'),
      button: true,
      label: S.of(context).hwsGear,
      child: InkWell(
        splashColor: AppColors.transparent,
        hoverColor: AppColors.transparent,
        highlightColor: AppColors.transparent,
        onTapDown: (_) => HapticController.low(),
        onTap: () async {
          final Map<String, dynamic>? saved =
              await showHomeWidgetSettingsDialog(context, model: model);
          if (saved != null) onSaved(model, saved);
        },
        // 23/10/2026 (Moataz): the gear is the SAME size as the red minus —
        // both are a 17 circle centred in a 25 box ([HomeCardMetrics.badgeDiameter]).
        child: SizedBox(
          width: HomeCardMetrics.badgeBoxOf(context),
          height: HomeCardMetrics.badgeBoxOf(context),
          child: Center(
            child: Container(
              width: HomeCardMetrics.badgeDiameterOf(context),
              height: HomeCardMetrics.badgeDiameterOf(context),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(3.sp),
              child: CustomSvgImage.natural(
                assetPath: kSettingsGearAsset,
                color: AppColors.textButton,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
