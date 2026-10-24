/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: add_component_widget.dart
/// Purpose: Declares `AddComponentWidget`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';

class AddComponentWidget extends StatelessWidget {
  const AddComponentWidget(
      {required this.columnIndex,
      required this.rowIndex,
      this.width,
      super.key});
  final int columnIndex;
  final int rowIndex;

  /// Natural width of one empty slot.
  ///
  /// Exposed because edit_home_page.dart counts how many slots fit across a
  /// row, and that arithmetic has to read the SAME number this widget draws —
  /// duplicating 125.sp at the call site is how the two drift apart.
  static double get slotWidth => 125.sp;

  /// Optional fixed width. Null = at least [slotWidth], growing to fill.
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Padding(
      // The same top room a filled card keeps for its minus badge, so every
      // slot in a row starts at the same height.
      padding: EdgeInsets.only(top: HomeCardMetrics.badgeInset),
      child: DottedBorder(
          // Drawn over the grey fill: under it, only the outer half of the line
          // showed, and the row's scroll edge cut that half off.
          childOnTop: false,
          options: RoundedRectDottedBorderOptions(
            padding: EdgeInsets.all(0.sp),
            // Owner 21/10/2026: the line sits fully inside the box (first / last
            // slot of a scrolling row included).
            borderPadding: const EdgeInsets.all(0.5),
            color: AppColors.primary,
            strokeWidth: 1,
            radius: Radius.circular(8.sp),
            dashPattern: const [10, 5],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.sp),
              border: Border.all(color: AppColors.border, width: 1.sp),
              color: AppColors.card,
            ),
            // HEIGHT comes from HomeCardMetrics so an empty slot is exactly as
            // tall as a filled one beside it — that is the dimension every card
            // in a row shares.
            //
            // WIDTH is this widget's own. A placeholder has no content to
            // measure, so unlike a real card it cannot take "the width it
            // needs" — it has to state one. 125.sp is what it has always been;
            // it briefly used HomeCardMetrics.width while the cards were pinned
            // to a shared width too, and went back when they stopped being.
            // Owner 21/10/2026: with no [width] the slot is at least
            // [slotWidth] and grows to the space its row gives it, so the fill
            // stretches with the dotted border instead of stopping at 125.
            //
            // Owner 23/10/2026: on a phone the slot is the height the cards
            // beside it are DRAWN at (they are scaled there), and a perfect
            // square of that height.
            height: kpIsPhoneLayout(context)
                ? HomeCardMetrics.drawnHeightOf(context)
                : HomeCardMetrics.heightOf(context),
            width: kpIsPhoneLayout(context)
                ? HomeCardMetrics.drawnHeightOf(context)
                : width,
            constraints: width == null && !kpIsPhoneLayout(context)
                ? BoxConstraints(minWidth: slotWidth)
                : null,
            child: Center(
              child: Icon(Icons.add, size: 24.sp, color: AppColors.text),
            ),
          )),
    );
  }
}
