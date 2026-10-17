/// Module: core/custom/navigation
/// Description: Two-or-more option toggle in its own rounded container
///              (List | Grid, Counts | Minutes, My Dashboard | HR, AR | EN).
///              MOVED 17/10/2026 from the Time Tracker (CustomSegmentedToggle) —
///              it replaces the unused LanguageToggle (K-30: one component).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/custom/navigation/filter_tab_with_container.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

/// A two-option toggle in its own rounded container (owner finding 1).
///
/// [onCard] = it sits inside a white card (Late History "Counts / Minutes")
/// → page-colour container, compact; otherwise it sits on the page
/// ("Employees | Locations") → card-colour container. The container is
/// never the same colour as the surface under it, in light and dark mode.
class CustomSegmentedToggle extends StatelessWidget {
  const CustomSegmentedToggle({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.onCard = false,
    this.compact = false,
    this.tabKeys,
  });

  /// ADDED 12/10/2026: one key per tab (core `CustomSegmentedTabs.tabKeys`).
  final List<Key>? tabKeys;

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool onCard;

  /// ADDED 9/10/2026 (phase 5): the compact metrics (padding 5, radius 8,
  /// 12 Medium) on the PAGE — the Overview "My Dashboard | HR" toggle
  /// (Figma `661:43164`: a 200×40 white container, active tab 30 high).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color surface = onCard ? AppColors.background : AppColors.card;
    if (compact && !onCard) {
      return CustomSegmentedTabs(
        tabKeys: tabKeys,
        tabs: tabs,
        selectedIndex: selectedIndex,
        onTabSelected: (int i) {
          if (i == selectedIndex) return;
          HapticController.low();
          onChanged(i);
        },
        containerColor: surface,
        unselectedColor: surface,
        selectedColor: AppColors.primary,
        selectedTextColor: AppColors.textButton,
        unselectedTextColor: AppColors.secondaryText,
        containerPadding: EdgeInsets.all(5.r),
        borderRadius: 8.r,
        // 13/10/2026 (owner): the yellow "My Dashboard" pill was too round.
        tabBorderRadius: 2.r,
        animated: true,
        spacing: 5.w,
        tabHorizontalPadding: 16.w,
        tabVerticalPadding: 7.r,
        textStyle: StyleText.fontSize12Weight500,
      );
    }
    return CustomSegmentedTabs(
      tabKeys: tabKeys,
      tabs: tabs,
      selectedIndex: selectedIndex,
      onTabSelected: (int i) {
        if (i == selectedIndex) return;
        HapticController.low();
        onChanged(i);
      },
      containerColor: surface,
      unselectedColor: surface,
      selectedColor: AppColors.primary,
      selectedTextColor: AppColors.textButton,
      unselectedTextColor: AppColors.secondaryText,
      containerPadding: EdgeInsets.all(onCard ? 5.r : 7.r),
      borderRadius: onCard ? 8.r : 4.r,
      tabBorderRadius: onCard ? 8.r : 4.r,
      spacing: onCard ? 5.w : 10.w,
      tabHorizontalPadding: onCard ? 14.w : 8.w,
      tabVerticalPadding: onCard ? 6.5.r : 5.5.r,
      textStyle: onCard
          ? StyleText.fontSize12Weight500
          : StyleText.fontSize16Weight500,
      // 13/10/2026 (owner): the pill slides instead of jumping (Counts ↔ Minutes).
      animated: true,
    );
  }
}
