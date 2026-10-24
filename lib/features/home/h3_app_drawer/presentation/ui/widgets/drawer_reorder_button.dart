/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: drawer_reorder_button.dart
/// Purpose: Declares `DrawerReorderButton` — the Reorder / Done toggle at
///          the top of the drawer, shown only while Home Layout is open.
/// Author: Knowticed Plus team
/// Updated: 21/10/2026 - Moved here from the Home Layout page (Owner: the
///          first thing you press, then you reorganise — above Roles).
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class DrawerReorderButton extends StatelessWidget {
  const DrawerReorderButton({
    required this.cubit,
    required this.compact,
    super.key,
  });

  final AppDrawerCubit cubit;

  /// Portrait rail: icon only, like the module items.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppDrawerCubit, AppDrawerState>(
      bloc: cubit,
      builder: (BuildContext context, AppDrawerState state) {
        // Pages stay alive when another module is picked, so Home Layout can
        // be "open" behind Home — show the button only on Settings.
        final int i = cubit.selectedIndex;
        final bool onSettings = i >= 0 &&
            i < cubit.allowedDrawerModules.length &&
            cubit.allowedDrawerModules[i] == Modules.settings;
        if (!cubit.isHomeLayoutOpen || !onSettings) {
          return const SizedBox.shrink();
        }
        final bool active = cubit.isReorderingActive;
        // Off: yellow outline (it can be pressed). On: filled yellow, "Done".
        final Color ink = active ? AppColors.textButton : AppColors.primary;
        return Padding(
          padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
          child: GestureDetector(
            onTap: () {
              HapticController.medium();
              cubit.toggleReorderingActive();
            },
            child: Container(
              // Same box as a module item (DrawerMenuItem) so the rail lines up.
              width: compact ? 36.r : 56.r,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomSvgImage.natural(
                    assetPath:
                        'assets/icons_assets/main_icons_assets/ic_action_reorder.svg',
                    width: 22.sp,
                    height: 22.sp,
                    color: ink,
                  ),
                  if (!compact) ...<Widget>[
                    SizedBox(height: 4.h),
                    FittedBox(
                      child: Text(
                        active
                            ? S.of(context).drawerReorderDone
                            : S.of(context).drawerReorder,
                        style:
                            StyleText.fontSize10Weight500.copyWith(color: ink),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
