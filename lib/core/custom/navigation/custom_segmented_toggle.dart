/// Module: core/custom/navigation
/// Description: Two-or-more option toggle in its own rounded container
///              (List | Grid, Counts | Minutes, My Dashboard | HR, AR | EN).
///              MOVED 17/10/2026 from the Time Tracker (CustomSegmentedToggle) —
///              it replaces the unused LanguageToggle (K-30: one component).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_tab_with_container.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

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
    this.height,
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

  /// ADDED 22/10/2026 (owner): compact only — the whole switch is exactly
  /// this tall, e.g. the height of the button beside it (Notification
  /// Control: the Edit button, 38).
  final double? height;

  // 22/10/2026 — owner: every switch is box 8, gap 4, pill 4.
  static double get _compactPad => 4.r;

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
        // 22/10/2026 (owner, "I cannot see it"): light grey on the white
        // light-theme box was unreadable, worst in Arabic.
        unselectedTextColor: AppColors.secondaryText,
        // 22/10/2026 (owner, "think as a designer"): a 3 gap round the pill
        // (was 5) so box and pill read as one shape; the pill's corner is
        // 8 − 3 = 5 (CustomSegmentedTabs makes the two curves concentric).
        containerPadding: EdgeInsets.all(_compactPad),
        borderRadius: 8.r,
        animated: true,
        spacing: 3.w,
        tabHorizontalPadding: 16.w,
        tabVerticalPadding: height == null
            ? 7.r
            : ((height! -
                        _compactPad * 2 -
                        StyleText.fontSize12Weight500.fontSize!) /
                    2)
                .clamp(0, double.infinity)
                .toDouble(),
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
      // 22/10/2026 (owner, "I cannot see it"): light grey on the white
      // light-theme box was unreadable, worst in Arabic.
      unselectedTextColor: AppColors.secondaryText,
      // 22/10/2026 — owner: box 8, gap 4, pill 4 for every switch.
      containerPadding: EdgeInsets.all(4.r),
      borderRadius: 8.r,
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
