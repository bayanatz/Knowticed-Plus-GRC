/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: drawer_menu_item.dart
/// Description: A single icon + label entry in the app drawer rail.
/// Author: Amr Mesbah
/// Created at: 11/8/2026
///
/// Extracted from the 586-line `custom_drawer.dart`. Reordering state is read
/// from [AppDrawerCubit] rather than the module-global `RxBool` this used to
/// depend on.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class DrawerMenuItem extends StatelessWidget {
  const DrawerMenuItem({
    super.key,
    required this.cubit,
    required this.compact,
    required this.index,
    required this.iconPath,
    required this.title,
    required this.onTap,
    this.isLogout = false,
    this.scale = 1,
  });

  /// 18/10/2026 (Moataz: "no need to scroll the nav"): the rail shrinks its
  /// items to fit the window height — 1 = full size, never below 0.6.
  final double scale;

  /// Drawer cubit, passed explicitly because it is registered through GetX
  /// rather than provided in the widget tree.
  final AppDrawerCubit cubit;

  /// `true` for the narrow rail (icon only), `false` for icon + label.
  final bool compact;

  final int index;
  final String iconPath;
  final String title;

  /// Invoked with [index] when the item is tapped and reordering is off.
  final ValueChanged<int> onTap;

  final bool isLogout;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppDrawerCubit, AppDrawerState>(
      bloc: cubit,
      builder: (BuildContext context, AppDrawerState state) {
        final bool isReorderingActive = cubit.isReorderingActive;

        // SELECTION 24/8/2026: no selected highlight while reordering.
        //
        // Reorder mode already marks every item with its own outline, and the
        // filled yellow block on top of that read as "this row is the one being
        // dragged" — which it is not, it is just the page you came from. It
        // also fought the drag proxy's elevation.
        //
        // Computed inside the builder now: it used to be read before
        // `isReorderingActive` was known, one line above this BlocBuilder.
        final bool isSelected =
            cubit.selectedIndex == index && !isLogout && !isReorderingActive;

        // While reordering is active the item must not be tappable. This passes
        // `null` rather than relying solely on the guard inside the page's
        // handler: an onTap callback installs a tap recogniser that competes
        // with the reorder list's long-press drag, so removing it outright both
        // blocks navigation and makes dragging start cleanly. The cursor drops
        // back to the default arrow so the rail doesn't look clickable on
        // desktop.
        final bool tapDisabled = isReorderingActive;

        return MouseRegion(
          cursor:
              tapDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: withHaptic(
                tapDisabled ? null : () => onTap(index), HapticLevel.low),
            child: Container(
              // Owner 21/10/2026 13:41: every rail item is ONE fixed box (not the
              // width scale, which blew it up on iPad portrait).
              width: compact ? 40.r : 64.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isReorderingActive && !isLogout
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 1)
                    : null,
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 5.w, vertical: compact ? 0 : 2.h * scale),
              // Owner 21/10/2026 13:33 (iPad portrait, "the width when the
              // module is selected is too much"): the selected box hugs its
              // icon and label (8 sideways, 4 up and down) instead of filling
              // the whole item width.
              child: Center(
                child: Container(
                  // Same width and same height for every item, selected or
                  // not — the yellow box never changes size with the label.
                  // 13:51: fixed WIDTH only — the height is the icon + one-line
                  // label (equal for every item) and follows the rail's squeeze
                  // on iPad portrait; a fixed height overflowed there.
                  width: compact ? 36.r : 56.r,
                  decoration: isSelected
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColors.secondaryPrimary,
                        )
                      : null,
                  padding: EdgeInsets.symmetric(horizontal: 4.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8.h * scale),
                        // FIXED 13/10/2026 (form builder vertical bug report
                        // p.36 — "make the thickness of the icons equal"): the
                        // box was 26.w × 26.h with BoxFit.fill, and .w and .h
                        // scale differently — very differently in portrait — so
                        // every glyph was stretched on one axis and its strokes
                        // came out thicker one way than the other, by a
                        // different amount per icon. A square .sp box with
                        // `contain` draws each one undistorted.
                        child: CustomSvgImage.natural(
                          assetPath: iconPath,
                          width: 26.sp * (scale < 0.75 ? 0.75 : scale),
                          fit: BoxFit.contain,
                          height: 26.sp * (scale < 0.75 ? 0.75 : scale),
                          color: isSelected
                              ? AppColors.secondaryPrimaryText
                              : AppColors.secondaryText,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 6.h * scale,
                            bottom: compact ? 1.h : 5.h * scale),
                        child: compact
                            ? const SizedBox.shrink()
                            : FittedBox(
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: StyleText.fontSize10Weight500
                                      .copyWith(color: Color(0xff797979))
                                      .copyWith(
                                        color: isSelected
                                            ? AppColors.secondaryPrimaryText
                                            : AppColors.secondaryText,
                                      ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
