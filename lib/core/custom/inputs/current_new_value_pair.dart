/// Module: core / custom / inputs
///
///*************************** FILE INFO ****************************///
/// File Name: current_new_value_pair.dart
/// Purpose: Declares `CurrentNewValuePair` — the Current → New comparison of
///          ONE changed field, shared by every Preview step and every Request
///          Details page in the app (D-224, K-52).
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// The rule (Moataz, 20–21 Oct 2026): the label goes above; the current value
/// sits in a GREY field marked "Current"; the new value sits under it (phone)
/// or beside it (iPad / large) in a field with a GREEN border marked "New".
/// Both are full width and the same height, 8 between them when stacked, 12
/// when side by side. The marks are drawn here so no page restates them.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart'
    show kFieldLabelGap;
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CurrentNewValuePair extends StatelessWidget {
  const CurrentNewValuePair({
    super.key,
    required this.label,
    this.current = '',
    this.next = '',
    this.changed = true,
    this.stacked = true,
    this.currentBox,
    this.nextBox,
  });

  /// The field name, drawn once above the pair (14 / 500, like every label).
  final String label;

  /// Plain-text values. Ignored for a side that passes its own box.
  final String current;
  final String next;

  /// `false` when only the pair's layout is wanted and the value did not
  /// change (no green border on the New side).
  final bool changed;

  /// Under each other (phone) or side by side (iPad / large).
  final bool stacked;

  /// A custom box for a side (e.g. a photo, or code + number for a phone).
  /// The "Current" / "New" marks are still laid over it.
  final Widget? currentBox;
  final Widget? nextBox;

  /// Lays the "Current" / "New" mark over the end of [box].
  static Widget mark(Widget box, String text, Color color) {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: <Widget>[
        box,
        PositionedDirectional(
          end: 12.sp,
          child: IgnorePointer(
            child: Text(
              text,
              style: StyleText.fontSize12Weight400.copyWith(color: color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _box(String value, {required bool highlight}) {
    return Container(
      width: double.infinity,
      height: 40.sp,
      padding: EdgeInsetsDirectional.only(start: 12.sp, end: 70.sp),
      alignment: AlignmentDirectional.centerStart,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        border: highlight
            ? Border.all(color: AppColors.statusApproved, width: 1.5)
            : null,
      ),
      child: Text(
        value.isEmpty ? '-' : value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final Widget before = mark(
      currentBox ?? _box(current, highlight: false),
      l.currentTag,
      AppColors.secondaryText,
    );
    final Widget after = mark(
      nextBox ?? _box(next, highlight: changed),
      l.newTag,
      AppColors.statusApproved,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // RichText, not Text: the same label CustomTextField draws, so a pair
        // sits level with any field beside it.
        RichText(
          text: TextSpan(
            text: label,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.text, fontSize: 14.sp),
          ),
        ),
        SizedBox(height: kFieldLabelGap.sp),
        if (stacked) ...<Widget>[
          before,
          SizedBox(height: 8.sp),
          after,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: before),
              SizedBox(width: 12.sp),
              Expanded(child: after),
            ],
          ),
      ],
    );
  }
}
