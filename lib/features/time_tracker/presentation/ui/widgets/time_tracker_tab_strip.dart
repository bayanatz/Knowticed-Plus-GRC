/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_tab_strip.dart
/// Purpose: Declares `TimeTrackerTabStrip` — the main page's tab strip
///          (Overview · Attendance · Requests · Approvals · Request Types ·
///          Locations · Employees · …), the core underlined `CustomTabs`
///          (10) — and `OverflowFade`, which keeps any one-row horizontal
///          strip (the tabs, the status counters) readable when it does not
///          fit: the selected item is scrolled into view and the edge that
///          hides more items fades out.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI fix round 1 — owner finding 9)
///
/// Figma HR iPad landscape `661:86558`: Cairo 18 Medium tabs, 24 apart
/// (14 / 14 on a phone), active tab yellow + underline. With all the HR
/// switches on, the tabs do not fit an iPad portrait / iPhone width (or an
/// iPad landscape one when the shell is narrow), and the strip used to end
/// in a half-cut tab with nothing telling the user it scrolls. Now:
/// - when everything fits, the strip is a plain row (nothing moves);
/// - when it does not, it scrolls sideways, the SELECTED item is always
///   scrolled fully into view (on open and on every change, with a small
///   margin so the next one peeks in), and the edge that hides more items
///   fades out instead of cutting a word in half.
/// The Figma iPad-portrait counters row (`661:20465`) also runs past the
/// frame, so the Requests / Approvals counters get the same treatment.
/// RTL: the scroll view and the fades follow the reading direction.
library;

import 'package:knowticed_plus/core/custom/layout/overflow_fade.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class TimeTrackerTabStrip extends StatelessWidget {
  const TimeTrackerTabStrip({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  /// Visible tab titles (already translated, unique).
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool phone = context.isPhone;
    final int index =
        labels.isEmpty ? 0 : selectedIndex.clamp(0, labels.length - 1);
    return OverflowFade(
      revealText: labels.isEmpty ? null : labels[index],
      child: CustomTabs(
        tabs: labels,
        selectedValue: selectedIndex,
        spacing: phone ? 14.w : 24.w,
        textStyle: (phone
                ? StyleText.fontSize14Weight500
                : StyleText.fontSize18Weight500)
            .copyWith(color: AppColors.secondaryText),
        selectedColor: AppColors.secondaryPrimary,
        unselectedColor: AppColors.secondaryText,
        onChanged: onChanged,
      ),
    );
  }
}
