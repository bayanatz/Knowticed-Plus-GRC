/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_more_options_panel.dart
/// Description: The collapsible "More Options" block under each box on the
///          comments-and-feedback form — seven triage dropdowns and the
///          "Steps to reproduce" field.
/// Author: Amr Mesbah
/// Created at: 2/9/2026
///
/// Figma: MESBAH 4717:8596. A slate header bar with a chevron, and under it a
/// two-column grid: Module / Screen-Section, Design Issue / Logic Issue,
/// Device / Software Type, then Frequency alone on its own row, then a
/// full-width multi-line "Steps to reproduce" box with a 0/500 counter.
///
/// WHY COLLAPSED BY DEFAULT, AND WHY IT MATTERS. Seven optional dropdowns in
/// front of someone reporting a typo is how a feedback form stops being used.
/// The panel is shut until asked for, every field inside it is optional, and
/// nothing here gates Submit — see `hasAnyData` on the screen, which still
/// only asks for a ticked box with text in it.
///
/// STATELESS ON PURPOSE. The open/closed flag and the answers both live in the
/// screen's State, keyed by [FeedbackKind]. A user can have the bug box's
/// panel open with a Module chosen while the feature-request box's panel is
/// shut and empty, and that is three pieces of per-kind state — putting any of
/// it in here would mean this widget losing it every time the parent rebuilds
/// the list of boxes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_display.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class FeedbackMoreOptionsPanel extends StatelessWidget {
  const FeedbackMoreOptionsPanel({
    super.key,
    required this.details,
    required this.isExpanded,
    required this.onToggle,
    required this.onChanged,
    required this.stepsController,
    required this.isMobile,
    this.enabled = true,
  });

  /// The answers so far for THIS box. Never null — the screen creates an empty
  /// [FeedbackDetails] the first time a box is ticked, so this widget never
  /// has to distinguish "no panel yet" from "panel with nothing in it".
  final FeedbackDetails details;

  /// Whether the body under the header bar is showing.
  final bool isExpanded;

  final VoidCallback onToggle;

  /// Reports the whole [FeedbackDetails] back, not the single field that
  /// changed. Each dropdown below calls `details.copyWith(...)` itself, which
  /// keeps the screen from needing seven callbacks or a stringly-typed
  /// "which field" parameter.
  final ValueChanged<FeedbackDetails> onChanged;

  /// Owned by the screen, like the three body controllers beside it, so it is
  /// created and disposed exactly once per kind rather than on every rebuild.
  ///
  /// Its text is NOT mirrored into [details] on every keystroke — the screen
  /// folds it in at submit time. Rebuilding seven dropdowns for each character
  /// typed is work nobody sees.
  final TextEditingController stepsController;

  /// One column instead of two. The design's two-up grid needs ~530pt to stay
  /// readable, which a phone does not have.
  final bool isMobile;

  /// False while a file is uploading for this box, matching the attach button
  /// and priority field above.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _header(context),
        if (isExpanded) ...<Widget>[SizedBox(height: 12.h), _body(context)],
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  /// The slate bar. [AppColors.navyBlue] is `#768396` in BOTH themes — one of
  /// the few colours in the palette that does not flip — which is why the
  /// label and chevron on it can be a flat white rather than a theme lookup.
  Widget _header(BuildContext context) {
    return InkWell(
      onTapDown: hapticDown(onToggle, HapticLevel.low),
      onTap: onToggle,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: double.infinity,
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          // 23/10/2026 (Moataz): the same bar colour as the Org Chart
          // sections (grey 700 with white text and chevron).
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                S.of(context).moreOptions,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            AnimatedRotation(
              // Same 0.5 turn and 180ms CustomDropdown gives its own chevron,
              // so the two controls on this form animate identically.
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: CustomSvgImage(
                assetPath:
                    'assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg',
                width: 18.sp,
                height: 18.sp,
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _pair(_moduleField(context), _screenSectionField(context)),
        SizedBox(height: 16.sp),
        _pair(_designIssueField(context), _logicIssueField(context)),
        SizedBox(height: 16.sp),
        _pair(_deviceField(context), _softwareTypeField(context)),
        SizedBox(height: 16.sp),
        _pair(_frequencyField(context), null),
        SizedBox(height: 16.sp),
        _stepsField(context),
      ],
    );
  }

  /// Function Name: [_pair]
  ///
  /// Purpose: Two fields side by side on tablet, stacked on a phone.
  ///
  /// Parameters:
  /// - [left], [right]: [right] may be null for a half-width row.
  ///
  /// `Expanded` on both halves rather than a fixed width: this panel sits
  /// inside the settings pane, whose width changes with the split, and a
  /// hardcoded 265 from the design would clip the moment the pane narrowed.
  Widget _pair(Widget left, Widget? right) {
    // Moataz 23/10/2026: one field per row on every device.
    if (right == null) return left;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        left,
        SizedBox(height: 12.h),
        right,
      ],
    );
  }

  Widget _dropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownItem<T>> items,
    required ValueChanged<T?> onSelected,
  }) {
    return CustomDropdown<T>(
      label: label,
      hint: hint,
      value: value,
      items: items,
      enabled: enabled,
      // NO triggerPadding — FIXED 8/9/2026.
      //
      // It was `EdgeInsets.symmetric(horizontal: 10.sp, vertical: 12.sp)`.
      // 12 + 12 of vertical padding plus a 14pt line needs more than the 36.sp
      // the trigger is pinned to, so InputDecorator laid the value out below
      // the visible box: the SELECTED text was clipped along its bottom and sat
      // off-centre, while the hint (12pt) still fit and looked fine — which is
      // why only chosen values looked broken.
      //
      // Dropping it falls back to CustomDropdown's own 12.sp/10.sp, which is
      // exactly what FeedbackPriorityDropdown above uses at the same 36 height,
      // so the value now centres in the box and the two controls match.
      // 23/10/2026 (Moataz): the hint and value are 14, like the text
      // fields in this form (the dropdown default is 12).
      enforceTypeScale: false,
      hintStyle: StyleText.fontSize14Weight400,
      valueStyle: StyleText.fontSize14Weight400,
      fillColor: AppColors.background,
      // Owner 21/10/2026: 38 and the shared label gap (8), the same as the
      // Priority box and the Attach Document button — one form, one size.
      height: 38,
      onChanged: (T chosen) => onSelected(chosen == value ? null : chosen),
    );
  }

  Widget _moduleField(BuildContext context) {
    return _dropdown<FeedbackModule>(
      label: S.of(context).module,
      hint: S.of(context).selectModule,
      value: details.module,
      onSelected: (FeedbackModule? value) =>
          onChanged(details.copyWith(module: () => value)),
      items: <DropdownItem<FeedbackModule>>[
        for (final FeedbackModule value in FeedbackModule.values)
          DropdownItem<FeedbackModule>(
            value: value,
            label: FeedbackDisplay.moduleLabel(context, value),
          ),
      ],
    );
  }

  Widget _screenSectionField(BuildContext context) {
    return _dropdown<FeedbackScreenSection>(
      label: S.of(context).screenSection,
      hint: S.of(context).selectScreenSection,
      value: details.screenSection,
      onSelected: (FeedbackScreenSection? value) =>
          onChanged(details.copyWith(screenSection: () => value)),
      items: <DropdownItem<FeedbackScreenSection>>[
        for (final FeedbackScreenSection value in FeedbackScreenSection.values)
          DropdownItem<FeedbackScreenSection>(
            value: value,
            label: FeedbackDisplay.screenSectionLabel(context, value),
          ),
      ],
    );
  }

  Widget _designIssueField(BuildContext context) {
    return _dropdown<FeedbackDesignIssue>(
      label: S.of(context).designIssue,
      hint: S.of(context).selectDesignIssue,
      value: details.designIssue,
      onSelected: (FeedbackDesignIssue? value) =>
          onChanged(details.copyWith(designIssue: () => value)),
      items: <DropdownItem<FeedbackDesignIssue>>[
        for (final FeedbackDesignIssue value in FeedbackDesignIssue.values)
          DropdownItem<FeedbackDesignIssue>(
            value: value,
            label: FeedbackDisplay.designIssueLabel(context, value),
          ),
      ],
    );
  }

  Widget _logicIssueField(BuildContext context) {
    return _dropdown<FeedbackLogicIssue>(
      label: S.of(context).logicIssue,
      hint: S.of(context).selectLogicIssue,
      value: details.logicIssue,
      onSelected: (FeedbackLogicIssue? value) =>
          onChanged(details.copyWith(logicIssue: () => value)),
      items: <DropdownItem<FeedbackLogicIssue>>[
        for (final FeedbackLogicIssue value in FeedbackLogicIssue.values)
          DropdownItem<FeedbackLogicIssue>(
            value: value,
            label: FeedbackDisplay.logicIssueLabel(context, value),
          ),
      ],
    );
  }

  Widget _deviceField(BuildContext context) {
    return _dropdown<FeedbackDevice>(
      label: S.of(context).device,
      hint: S.of(context).selectDevice,
      value: details.device,
      onSelected: (FeedbackDevice? value) =>
          onChanged(details.copyWith(device: () => value)),
      items: <DropdownItem<FeedbackDevice>>[
        for (final FeedbackDevice value in FeedbackDevice.values)
          DropdownItem<FeedbackDevice>(
            value: value,
            label: FeedbackDisplay.deviceLabel(context, value),
          ),
      ],
    );
  }

  Widget _softwareTypeField(BuildContext context) {
    return _dropdown<FeedbackSoftwareType>(
      label: S.of(context).softwareType,
      hint: S.of(context).selectSoftwareType,
      value: details.softwareType,
      onSelected: (FeedbackSoftwareType? value) =>
          onChanged(details.copyWith(softwareType: () => value)),
      items: <DropdownItem<FeedbackSoftwareType>>[
        for (final FeedbackSoftwareType value in FeedbackSoftwareType.values)
          DropdownItem<FeedbackSoftwareType>(
            value: value,
            label: FeedbackDisplay.softwareTypeLabel(context, value),
          ),
      ],
    );
  }

  Widget _frequencyField(BuildContext context) {
    return _dropdown<FeedbackFrequency>(
      label: S.of(context).frequency,
      hint: S.of(context).selectFrequency,
      value: details.frequency,
      onSelected: (FeedbackFrequency? value) =>
          onChanged(details.copyWith(frequency: () => value)),
      items: <DropdownItem<FeedbackFrequency>>[
        for (final FeedbackFrequency value in FeedbackFrequency.values)
          DropdownItem<FeedbackFrequency>(
            value: value,
            label: FeedbackDisplay.frequencyLabel(context, value),
          ),
      ],
    );
  }

  /// The full-width box at the bottom of the panel.
  ///
  /// [FeedbackDetails.maxStepsLength] rather than a literal 500, so the
  /// counter under this field and anything that validates the value later
  /// cannot disagree about the ceiling.
  ///
  /// No `showCharCount` — [CustomTextField] draws the counter whenever either
  /// that flag OR a [CustomTextField.maxLength] is set, and passing both would
  /// suggest they do different things.
  Widget _stepsField(BuildContext context) {
    return CustomTextField(
      label: S.of(context).stepsToReproduce,
      hint: S.of(context).describeTheStepsYouTook,
      controller: stepsController,
      enabled: enabled,
      maxLines: 3,
      maxLength: FeedbackDetails.maxStepsLength,
      fillColor: AppColors.background,
    );
  }
}
