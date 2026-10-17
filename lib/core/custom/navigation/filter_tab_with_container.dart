/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_segmented_tabs.dart
/// Description: Declares `CustomSegmentedTabs`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 13/10/2026 - opt-in `animated`: the selected pill SLIDES to
///          the tapped tab and the text colours fade (default off).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

/// A customizable segmented tabs widget that can be reused throughout the app
///
/// Example usage:
/// ```dart
/// CustomSegmentedTabs(
///   tabs: ['المخطط', 'الجدول'],
///   selectedIndex: controller.selectedTabIndex,
///   onTabSelected: (index) {
///     controller.updateTabIndex(index);
///   },
/// )
/// ```
// CHANGED 17/10/2026 (Moataz: "the customs we fixed in the Time Tracker —
// use them"; "why is there no diagonal cut on the tablet"): the defaults are
// now the owner-approved Time Tracker toggle (CustomSegmentedToggle, page
// variant) — 7 inset on every side, radius 4 / 4, 16 Medium, sliding pill.
// Screens that pass their own values keep them.
class CustomSegmentedTabs extends StatelessWidget {
  const CustomSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.containerPadding,
    this.containerColor,
    this.borderRadius,
    this.spacing,
    this.tabHorizontalPadding,
    this.tabVerticalPadding,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.textStyle,
    this.equalWidth = false,
    this.tabBorderRadius,
    this.tabKeys,
    this.animated = true,
  });

  /// ADDED 13/10/2026 (Time Tracker owner review): the selected pill slides
  /// to the tapped tab and the text colours fade, instead of jumping.
  /// False keeps every existing caller exactly as it was.
  final bool animated;

  static const Duration _slide = Duration(milliseconds: 280);

  /// ADDED 12/10/2026 (Time Tracker owner review T1): an optional key per
  /// tab (same order as [tabs]) so a screen / test can find one segment.
  /// Null keeps every existing caller unchanged.
  final List<Key>? tabKeys;

  /// ADDED 9/10/2026 (Time Tracker UI fix round 1): corner radius of each
  /// tab. Null keeps the historical 4, so every existing caller is
  /// unchanged; the Time Tracker "Counts / Minutes" toggle (Figma
  /// `661:10741`) draws its active tab with radius 8.
  final double? tabBorderRadius;

  /// List of tab titles
  final List<String> tabs;

  /// Currently selected tab index (0-based)
  final int selectedIndex;

  /// Callback when a tab is tapped, returns the index
  final ValueChanged<int> onTabSelected;

  /// Padding around the entire container
  final EdgeInsets? containerPadding;

  /// Background color of the container
  final Color? containerColor;

  /// Border radius of the container
  final double? borderRadius;

  /// Spacing between tabs
  final double? spacing;

  /// Horizontal padding for each tab
  final double? tabHorizontalPadding;

  /// Vertical padding for each tab
  final double? tabVerticalPadding;

  /// Background color for selected tab
  final Color? selectedColor;

  /// Background color for unselected tabs
  final Color? unselectedColor;

  /// Text color for selected tab
  final Color? selectedTextColor;

  /// Text color for unselected tabs
  final Color? unselectedTextColor;

  /// Custom text style (will be merged with color changes)
  final TextStyle? textStyle;

  /// If true, all tabs will have equal width
  final bool equalWidth;

  @override
  Widget build(BuildContext context) {
    if (animated) return _buildAnimated(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
        color: containerColor ?? AppColors.card,
      ),
      padding: containerPadding ?? EdgeInsets.all(7.r),
      child: Row(
        mainAxisSize: equalWidth ? MainAxisSize.max : MainAxisSize.min,
        children: List.generate(tabs.length * 2 - 1, (index) {
          // Even indices are tabs, odd indices are spacers
          if (index.isOdd) {
            return SizedBox(width: spacing ?? 10.sp);
          }

          final tabIndex = index ~/ 2;
          final isSelected = tabIndex == selectedIndex;

          return equalWidth
              ? Expanded(
                  child: _buildTab(
                    key: tabKeys?[tabIndex],
                    title: tabs[tabIndex],
                    isSelected: isSelected,
                    onTap: () => onTabSelected(tabIndex),
                  ),
                )
              : _buildTab(
                  key: tabKeys?[tabIndex],
                  title: tabs[tabIndex],
                  isSelected: isSelected,
                  onTap: () => onTabSelected(tabIndex),
                );
        }),
      ),
    );
  }

  /// [animated]: one pill under the row slides to the selected tab. Tab
  /// widths come from their text (plus the tab padding) — or equal shares
  /// when [equalWidth] — so the pill lands exactly where the static tab
  /// would be drawn.
  Widget _buildAnimated(BuildContext context) {
    final TextStyle base = (textStyle ?? StyleText.fontSize16Weight500)
        .copyWith(height: 1, leadingDistribution: TextLeadingDistribution.even);
    final double hPad = tabHorizontalPadding ?? 8.w;
    final double vPad = tabVerticalPadding ?? 5.5.r;
    final double gap = spacing ?? 10.sp;
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final TextDirection direction = Directionality.of(context);
    final List<double> natural = <double>[
      for (final String t in tabs)
        (TextPainter(
              text: TextSpan(text: t, style: base),
              textDirection: direction,
              textScaler: scaler,
              maxLines: 1,
            )..layout())
                .width +
            hPad * 2,
    ];
    Widget row(List<double> widths) {
      double start = 0;
      for (int i = 0; i < selectedIndex && i < widths.length; i++) {
        start += widths[i] + gap;
      }
      // No tab selected (index -1, e.g. an unset status) → no pill.
      final bool hasPill = selectedIndex >= 0 && selectedIndex < widths.length;
      final double pillWidth = hasPill ? widths[selectedIndex] : 0;
      return Stack(
        children: [
          if (hasPill)
            AnimatedPositionedDirectional(
              duration: _slide,
              curve: Curves.easeOutCubic,
              start: start,
              top: 0,
              bottom: 0,
              width: pillWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(tabBorderRadius ?? 4.r),
                  color: selectedColor ?? AppColors.primary,
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < tabs.length; i++) ...[
                if (i > 0) SizedBox(width: gap),
                GestureDetector(
                  key: tabKeys?[i],
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => HapticController.low(),
                  onTap: () => onTabSelected(i),
                  child: SizedBox(
                    width: widths[i],
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: vPad),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: _slide,
                          curve: Curves.easeOutCubic,
                          style: base.copyWith(
                            color: i == selectedIndex
                                ? (selectedTextColor ?? AppColors.textButton)
                                : (unselectedTextColor ??
                                    AppColors.secondaryText),
                          ),
                          child: Text(tabs[i], maxLines: 1, softWrap: false),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
        color: containerColor ?? AppColors.card,
      ),
      padding: containerPadding ?? EdgeInsets.all(7.r),
      child: equalWidth
          ? LayoutBuilder(
              builder: (BuildContext context, BoxConstraints box) {
                final double each =
                    (box.maxWidth - gap * (tabs.length - 1)) / tabs.length;
                return row(List<double>.filled(tabs.length, each));
              },
            )
          : row(natural),
    );
  }

  Widget _buildTab({
    Key? key,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tabBorderRadius ?? 4.r),
          color: isSelected
              ? (selectedColor ?? AppColors.primary)
              : (unselectedColor ?? AppColors.card),
        ),
        padding: EdgeInsets.symmetric(
          vertical: tabVerticalPadding ?? 5.5.r,
          horizontal: tabHorizontalPadding ?? 8.w,
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              title,
              style: (textStyle ?? StyleText.fontSize16Weight500).copyWith(
                height: 1,
                color: isSelected
                    ? (selectedTextColor ?? AppColors.textButton)
                    : (unselectedTextColor ?? AppColors.secondaryText),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Container(
// width: 130,
// height: 40,
// child: CustomSegmentedTabs(
// tabs: ['نشط', 'مكتمل'],
// selectedIndex: selectedIndex,
// onTabSelected: (index) => setState(() => selectedIndex = index),
// selectedColor: AppColors.secondaryPrimary,
// unselectedColor: AppColors.background,
// equalWidth: true,  // All tabs same width
// spacing: 15,
// ),
// ),
