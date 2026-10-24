/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: remove_component_wrapper.dart
/// Purpose: Declares `RemoveComponentWrapper`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/widget_settings/home_widget_gear_badge.dart';

class RemoveComponentWrapper extends StatelessWidget {
  const RemoveComponentWrapper(
      {required this.component, required this.model, super.key});
  final Widget component;
  final HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
        // D-242: 12 on the gear side too, so the gear mirrors the minus.
        padding: EdgeInsetsDirectional.only(
          top: HomeCardMetrics.badgeInset,
          end: HomeCardMetrics.badgeInset,
        ),
        child: component,
      ),
      Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: AppColors.transparent,
        ),
      ),
      if (HomeWidgetGearBadge.shownFor(model))
        // Top-right, the minus' neighbour: one badge width further in. The
        // 8 extra gap is gone (Moataz 23/10/2026: half the space between them).
        PositionedDirectional(
          top: 0,
          end: HomeCardMetrics.badgeBoxOf(context),
          child: HomeWidgetGearBadge(
            model: model,
            onSaved: (HomeComponentModel m, Map<String, dynamic> settings) =>
                context
                    .read<AppHomeCubit>()
                    .updateComponentSettings(m, settings),
          ),
        ),
      PositionedDirectional(
          top: 0,
          end: 0,
          child: InkWell(
            splashColor: AppColors.transparent,
            onTapDown: (_) => HapticController.high(),
            onTap: () {
              context.read<AppHomeCubit>().removeComponent(model);
            },
            child: SizedBox(
              width: HomeCardMetrics.badgeBoxOf(context),
              height: HomeCardMetrics.badgeBoxOf(context),
              child: Center(
                child: Container(
                  width: HomeCardMetrics.badgeDiameterOf(context),
                  height: HomeCardMetrics.badgeDiameterOf(context),
                  // Drawn, not an SVG: the same circle as the gear beside it, so the
                  // two are exactly one size (Moataz 24/10/2026).
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: HomeCardMetrics.badgeDiameterOf(context) * 0.5,
                      height: 2,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ))
    ]);
  }
}
