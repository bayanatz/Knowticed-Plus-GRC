/// Module: roles/shared_mobile_export
///
///*************************** FILE INFO ****************************///
/// File Name: mobile_export_person_card.dart
/// Description: `MobileExportPersonCard` widget — split out of `mobile_export_widgets.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../mobile_export_widgets.dart';

// Split from mobile_export_widgets.dart to keep every file under 700 lines.

// ═══════════════════════════════════════════════════════════════════════════
// SEARCH + PEOPLE
// ═══════════════════════════════════════════════════════════════════════════

// REMOVED 9/9/2026: `MobileExportSearchBar`.
//
// `AppSearchTextField` (core/custom/35-custom_search_widget_custom.dart) is the
// app's one search box — it is what every other search row in the module uses,
// it already owns the magnifier, the hint colour and the 38 height, and it
// carries the fixes made to that field over time. A second search box built
// here out of `CustomTextField` would drift from it on the first change.
//
// Callers pass `expanded: false`: that widget wraps itself in an `Expanded` by
// default, which is right for the search rows that sit in a `Row` next to
// filter buttons and illegal for these two, where it is a direct child of a
// `Column`.

/// One employee row — Figma 6975:23900 (preview) and 6976:24560 (selectable).
///
/// 345x65, white, radius 8; a 40 avatar 10 in from the leading edge, then the
/// name (Cairo Medium 14 on `text`) over the department and the job title
/// (Cairo Medium 12 on `secondaryText`), and — when [onTap] is given — a tick
/// pinned to the top trailing corner.
///
/// The avatar is [MobileExportAvatar] — extracted 10/9/2026 so the picked-people
/// row can draw the same circle; the rule it applies is unchanged.
///
/// The three lines are given `height: 1.15` so all of them fit the fixed 65
/// card: Figma trims each text box to its cap height, which Flutter's default
/// ~1.4 line box does not, and at the default the third line would overflow.
class MobileExportPersonCard extends StatelessWidget {
  const MobileExportPersonCard({
    super.key,
    required this.person,
    this.onTap,
    this.selected = false,
    this.showTick = true,
  });

  final MobileExportPerson person;

  /// Null renders a read-only row (the Active Directory preview); non-null
  /// adds the tick and makes the whole card the tap target (System Logs).
  final VoidCallback? onTap;

  final bool selected;

  /// Whether a tappable card also draws the tick.
  ///
  /// ADDED 10/9/2026 for the export form's search results: those rows ARE
  /// tappable, but tapping one moves that person into the avatar row and takes
  /// the row out of the list, so a checkbox that could only ever be drawn empty
  /// would misdescribe what the row does. Defaults to true, so the picker on
  /// step 2 keeps its ticks.
  final bool showTick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap, HapticLevel.low),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: MobileExportMetrics.personCardHeight.sp,
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(MobileExportMetrics.cardRadius.r),
        ),
        child: Row(
          children: [
            MobileExportAvatar(person: person),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Role QA p.48 / p.49: shown capitalised.
                    FormatHelper.capitalize(person.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.text,
                      height: 1.15,
                      letterSpacing: -0.8224,
                    ),
                  ),
                  Text(
                    // Role QA p.48 / p.49: shown capitalised.
                    FormatHelper.capitalize(person.department),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight500.copyWith(
                      color: AppColors.secondaryText,
                      height: 1.15,
                      letterSpacing: -0.8224,
                    ),
                  ),
                  Text(
                    // Role QA p.48 / p.49: shown capitalised.
                    FormatHelper.capitalize(person.jobTitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight500.copyWith(
                      color: AppColors.secondaryText,
                      height: 1.15,
                      letterSpacing: -0.8224,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null && showTick) ...[
              SizedBox(width: 10.w),
              // Top-aligned: the frame puts the 25 tick at y = 10 inside a 65
              // card, not on the vertical centre.
              //
              // The SizedBox is load-bearing. A bare `Align` in a Row is laid
              // out with an UNBOUNDED main-axis constraint, which throws — it
              // has no intrinsic width to fall back on. Pinning the slot to the
              // tick's own size and the row's content height gives the Align
              // something to align inside.
              SizedBox(
                width: 25.sp,
                height: (MobileExportMetrics.personCardHeight - 20).sp,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: CustomCheckBox(isSelected: selected, size: 25.sp),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
