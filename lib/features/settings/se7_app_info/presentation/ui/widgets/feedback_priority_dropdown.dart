/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_priority_dropdown.dart
/// Purpose: The "Select Priority" field under each box on the comments and
///          feedback form.
/// Author: Knowticed Plus team
/// Created at: 1/9/2026
/// Updated: 1/9/2026 - Rebuilt on [CustomDropdown]. It was a hand-rolled
///          PopupMenuButton, which meant a second idea about placeholder
///          colour, label size and chevron in a codebase that already has one.
///
/// Figma: MESBAH 7628:8169 — a 265×36 field with a chevron, sitting beside the
/// "Attach Document" button.
///
/// The label, the 14.sp-label / 12.sp-hint type scale and the placeholder
/// colour all come from [CustomDropdown]; nothing is restated here. Only two
/// things are passed that are specific to this screen: the [AppColors.card]
/// fill and the 36 height the design draws.
///
/// NOTE the clear path. [CustomDropdown.onChanged] is `ValueChanged<T>`, so it
/// can only ever report a CHOSEN value — there is no "none" entry, and none is
/// wanted: priority is optional, the field starts empty, and the way to clear
/// it is to untick the box, which drops the whole entry in the screen's
/// `_priorities` map.
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_display.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class FeedbackPriorityDropdown extends StatelessWidget {
  const FeedbackPriorityDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  /// Null while the user has not chosen — the "Select Priority" placeholder
  /// state. [CustomDropdown] draws the hint whenever no item matches.
  final FeedbackPriority? value;

  final ValueChanged<FeedbackPriority> onChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<FeedbackPriority>(
      label: S.of(context).priority,
      hint: S.of(context).selectpriority,
      value: value,
      enabled: enabled,
      // 23/10/2026 (Moataz): the hint and value are 14, like the text
      // fields in this form (the dropdown default is 12).
      enforceTypeScale: false,
      hintStyle: StyleText.fontSize14Weight400,
      valueStyle: StyleText.fontSize14Weight400,
      fillColor: AppColors.background,
      // Raw, not `.sp` — CustomDropdown.height is documented as being
      // interpreted in .sp and scaled internally. Pre-scaling it here would
      // scale it twice.
      height: 38, // same height as the Attach Document button (20/10/2026)
      // ADDED 8/9/2026 — tighter than the shared kFieldLabelGap (6) for this
      // form, where the label and its field read as one unit stacked under a
      // checkbox rather than as a row of aligned fields. Same value is passed
      // by the More Options dropdowns below, so the whole form agrees.
      // Owner 21/10/2026: shared label gap (8), the same as the Attach
      // Document label beside it — with 3 here the Priority box started 5px
      // higher than the button and the two read as different heights.
      onChanged: onChanged,
      items: <DropdownItem<FeedbackPriority>>[
        for (final FeedbackPriority priority in FeedbackPriority.values)
          DropdownItem<FeedbackPriority>(
            value: priority,
            label: FeedbackDisplay.priorityLabel(context, priority),
          ),
      ],
    );
  }
}
