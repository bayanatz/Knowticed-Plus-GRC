/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: add_component_wrapper.dart
/// Description: Declares `AddComponentWrapper`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';

// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/text_field.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/widget_settings/home_widget_gear_badge.dart';

class AddComponentWrapper extends StatelessWidget {
  const AddComponentWrapper({
    required this.component,
    required this.model,
    super.key,
  });
  final Widget component;
  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: AppColors.transparent,
      hoverColor: AppColors.transparent,
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        context.read<AppHomeCubit>().editComponent(model);
        Navigator.pop(context);
      },
      child: Stack(
        children: [
          Padding(
            // .w/.h rather than .sp so this padding scales on the same
            // axis as the card widths it sits between — together with
            // the Wrap's 3 it makes up Figma's 15 gutter.
            padding: EdgeInsetsDirectional.only(
              top: HomeCardMetrics.badgeInset,
              end: HomeCardMetrics.badgeInset,
            ),
            child: component,
          ),
          // A chart has live controls (the range chips, "View details"); the
          // catching layer would swallow their taps, so a chart has none and a
          // tap on its plain area still adds it (Moataz 24/10/2026).
          if (!model.component.isChart)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(color: AppColors.transparent),
            ),
          // D-242: the same gear as Home Layout, top-right. Settings changed
          // here are carried into the layout when the card is picked.
          if (HomeWidgetGearBadge.shownFor(model))
            PositionedDirectional(
              top: 0,
              end: 0,
              child: HomeWidgetGearBadge(
                model: model,
                onSaved:
                    (HomeComponentModel m, Map<String, dynamic> settings) =>
                        context
                            .read<AppHomeCubit>()
                            .updateReadyToAddSettings(m, settings),
              ),
            ),
        ],
      ),
    );
  }
}
