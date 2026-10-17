/// Module: roles / shared_mobile_export
///
///*************************** FILE INFO ****************************///
/// File Name: mobile_export_widgets.dart
/// Description: The mobile-only export chrome shared by Active Directory (r4) and
///          System Logs (r5).
/// Author: Amr Mesbah
/// Created at: 9/9/2026
///
/// WHY THIS FILE EXISTS
/// The phone export screens in Figma (MESBAH / page ROLE MANAGEMENT) are a
/// different LAYOUT from the desktop dialogs, not a narrower one: the desktop
/// export is a two-pane `Dialog` (filters on the left, preview on the right),
/// the phone export is a page of stacked fields inside one white card followed
/// by a second full-screen step. Squeezing the dialog down could never produce
/// it, so the phone gets its own screens and the dialog is left untouched for
/// tablet and desktop.
///
/// Both phone flows draw the same nine pieces, so they live here once rather
/// than being copied into r4 and r5.
///
/// EVERY VISUAL IS BUILT FROM `lib/core/custom`
/// `CustomDropdown`, `CustomTextField`, `customButton`, `customButtonWithSvg`,
/// `CustomCheckBox` and `CustomSvgImage` — no bespoke fields, no bespoke
/// buttons. What this file adds is only the Figma GEOMETRY around them.
///
/// SIZES ARE THE FIGMA NUMBERS, UNSCALED
/// `main.dart::_getDesignSize` sets ScreenUtil's design size to 375x812 in
/// phone portrait, and the Figma frames are 375 wide — so a raw design pixel
/// and a `.w` / `.h` / `.sp` unit are the same thing here. Every number below
/// is read straight off the frame; see the doc on each widget for its node.
library;

// `hide State`: dartz exports a `State` monad that collides with
// `StatefulWidget`'s `State`, which this file declares several of. The same
// spelling every widget file in the app that touches dartz uses.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/constants/app_assets.dart';
import 'package:grc_module/core/custom/dropdowns/custom_dropdown.dart';
import 'package:grc_module/core/custom/inputs/custom_textfield.dart';
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/custom/inputs/custom_check_box.dart';
import 'package:grc_module/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:grc_module/core/custom/feedback/circle_progress.dart';
import 'package:grc_module/core/helper/csv_helper.dart';
import 'package:grc_module/core/helper/format_title.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/features/roles/presentation/ui/widgets/shared_mobile_export/mobile_export_person.dart';
import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

part 'mobile_export_widgets/mobile_export_person_card.dart';
part 'mobile_export_widgets/mobile_export_actions.dart';
part 'mobile_export_widgets/mobile_export_multi_select_field.dart';
part 'mobile_export_widgets/mobile_export_selected_avatars.dart';
part 'mobile_export_widgets/mobile_export_file_name_dialog.dart';
part 'mobile_export_widgets/mobile_export_card.dart';

// ═══════════════════════════════════════════════════════════════════════════
// GEOMETRY
// ═══════════════════════════════════════════════════════════════════════════

/// The one place the Figma numbers are written down.
///
/// They are raw design pixels; call sites apply `.w` / `.h` / `.sp` so a value
/// is never scaled twice.
abstract class MobileExportMetrics {
  /// Page gutter. Every frame starts its content at x = 15 and ends it at
  /// x = 360 on a 375-wide screen.
  static const double pagePadding = 15;

  /// The white panel behind the fields — 345 wide (375 - 2*15), radius 8.
  static const double cardRadius = 8;

  /// Padding inside that panel. The first label sits 15 below the card's top
  /// edge (card top 193, first label 208) and the last field ends 15 above its
  /// bottom edge.
  static const double cardPadding = 15;

  /// Field box: 315x36, radius 4, 9 horizontal / 7 vertical padding.
  static const double fieldHeight = 36;
  static const double fieldRadius = 4;

  /// Gap between one field's bottom and the next field's label. The frame puts
  /// 69 between consecutive label tops: label (~21) + `kFieldLabelGap` (6) +
  /// field (36) leaves 6.
  static const double fieldGap = 6;

  /// Action buttons: 135x38, radius 8, 20 below the card.
  static const double buttonWidth = 135;
  static const double buttonsTopGap = 20;

  /// Employee card: 345x65, radius 8, 10 between consecutive cards
  /// (tops at 200 / 275 / 350 / …).
  static const double personCardHeight = 65;
  static const double personCardGap = 10;
  static const double avatarSize = 40;

  /// The remove badge stacked on a picked employee's avatar.
  static const double removeBadgeSize = 16;

  // Search bar: the frame's 345x38 is what `AppSearchTextField` already
  // renders (its own `height ?? 38`), so no constant is kept for it here.

  /// Date-range chip: 150x36, two per row with 15 between the columns
  /// (x = 30 and x = 195 inside a card whose content starts at x = 30).
  static const double chipWidth = 150;
  static const double chipGap = 15;
}

/// "Export Details" — Figma 6975:23556, Cairo Medium 16 with -0.5061 tracking,
/// sitting between the tabs and the card.
class MobileExportSectionTitle extends StatelessWidget {
  const MobileExportSectionTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.text,
        letterSpacing: -0.5061,
      ),
    );
  }
}

/// One labelled dropdown row of the export form.
///
/// This is `CustomDropdown` with the frame's geometry applied and nothing
/// else: 36 tall, radius 4, filled with `AppColors.background` (#F5F5F5 —
/// the field fill inside the white card), and left on `enforceTypeScale`,
/// which is what already pins the label to 14 and the hint to 12 exactly as
/// Figma draws them.
class MobileExportDropdownField extends StatelessWidget {
  const MobileExportDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final List<DropdownItem<String>> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      label: label,
      hint: hint,
      items: items,
      value: value,
      enabled: enabled,
      onChanged: onChanged,
      height: MobileExportMetrics.fieldHeight,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(MobileExportMetrics.fieldRadius.r),
      triggerPadding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
    );
  }
}

/// A one line of quiet explanation between two blocks of the form — Cairo
/// Regular 12 on `secondaryText`, the same pairing the unselected chip uses.
/// It carries "No matches found" under the card and "No employees found" under
/// the search box.
///
/// ADDED 10/9/2026. "Next" enables itself only when the filters above actually
/// match something, and a filter set CAN match nothing while every field on the
/// form is filled in — Country and City are drawn from the employee directory,
/// so nothing stops the admin from asking for a city that is not in the country
/// they picked. Before this the button simply sat there grey with no way to
/// tell a contradictory filter from a broken screen.
class MobileExportNote extends StatelessWidget {
  const MobileExportNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text(
        text,
        style: StyleText.fontSize12Weight400
            .copyWith(color: AppColors.secondaryText),
      ),
    );
  }
}

/// The gap between two consecutive fields inside [MobileExportCard].
class MobileExportFieldGap extends StatelessWidget {
  const MobileExportFieldGap({super.key});

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: MobileExportMetrics.fieldGap.h);
}

/// A label drawn above something that is not a `CustomDropdown` — the date
/// range chips. Same 14 Cairo Medium and same `kFieldLabelGap` the dropdown
/// puts above its own box, so a chip row lines up with the fields under it.
class MobileExportFieldLabel extends StatelessWidget {
  const MobileExportFieldLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: kFieldLabelGap.sp),
      child: Text(
        text,
        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      ),
    );
  }
}

/// One date-range chip — Figma 6976:24689..6976:24696.
///
/// Selected: `primary` fill, Cairo SemiBold 12 on `text`.
/// Unselected: `background` fill, Cairo Regular 12 on `secondaryText`.
class MobileExportChip extends StatelessWidget {
  const MobileExportChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: Container(
        height: MobileExportMetrics.fieldHeight.sp,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius:
              BorderRadius.circular(MobileExportMetrics.fieldRadius.r),
        ),
        child: FittedBox(
          child: Text(
            label,
            style: selected
                ? StyleText.fontSize12Weight600
                    .copyWith(color: AppColors.textButton)
                : StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
          ),
        ),
      ),
    );
  }
}

/// The four date-range chips, two per row — Figma 6976:24687.
///
/// `Expanded` rather than a pinned 150: the frame's two columns are 150 wide
/// inside a 315 content width with 15 between them, which is exactly what two
/// equal columns and a 15 gap give — and it survives a wider phone, which a
/// hard 150 would not.
class MobileExportChipGrid extends StatelessWidget {
  const MobileExportChipGrid({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];

    for (int i = 0; i < labels.length; i += 2) {
      if (i > 0) {
        // 226 -> 277 between the two chip rows: 36 of chip and 15 of gap.
        rows.add(SizedBox(height: MobileExportMetrics.chipGap.h));
      }
      rows.add(
        Row(
          children: [
            Expanded(
              child: MobileExportChip(
                label: labels[i],
                selected: selectedIndex == i,
                onTap: () => onSelected(i),
              ),
            ),
            SizedBox(width: MobileExportMetrics.chipGap.w),
            Expanded(
              child: i + 1 < labels.length
                  ? MobileExportChip(
                      label: labels[i + 1],
                      selected: selectedIndex == i + 1,
                      onTap: () => onSelected(i + 1),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

/// One 40 circular avatar — a real photo when [MobileExportPerson.imagePath] is
/// an http(s) URL, the gender SVG otherwise.
///
/// EXTRACTED 10/9/2026 from `MobileExportPersonCard._avatar`, unchanged. The
/// picked-avatars row draws the same circle without the card around it, and two
/// copies of the URL-or-SVG rule would drift the first time one is fixed —
/// `EmployeeHelper.getEmployeeImage` hands back an .svg NAME for anyone with no
/// photo, and `AssetImage` cannot decode one, which is the whole reason the
/// rule exists.
class MobileExportAvatar extends StatelessWidget {
  const MobileExportAvatar({super.key, required this.person});

  final MobileExportPerson person;

  @override
  Widget build(BuildContext context) {
    final double radius = MobileExportMetrics.avatarSize.sp / 2;

    if (person.imagePath.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary,
        backgroundImage: NetworkImage(person.imagePath),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.transparent,
      child: ClipOval(
        child: CustomSvgImage(
          assetPath: person.gender == 'male'
              ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
              : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
          width: MobileExportMetrics.avatarSize.sp,
          height: MobileExportMetrics.avatarSize.sp,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FILE NAME DIALOG
// ═══════════════════════════════════════════════════════════════════════════

/// The "Select All" button both list steps carry — Figma 6976:24796.
///
/// 135x38 on the trailing edge, `secondaryButton` fill, Cairo Medium 16 on
/// `text`. It is `customButton` with the frame's width, same as every other
/// button in this flow; the toggle behaviour lives in the pages, since only
/// they know what "everything" currently means.
class MobileExportSelectAllButton extends StatelessWidget {
  const MobileExportSelectAllButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return customButton(
      title: S.of(context).selectAll,
      function: onTap,
      width: MobileExportMetrics.buttonWidth.w,
      color: AppColors.secondaryButton,
      textColor: AppColors.text,
    );
  }
}

class _MobileExportFileNameDialogState
    extends State<MobileExportFileNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.defaultFileName);

  bool _isExporting = false;

  /// How long the in-row spinner stays up at minimum. A floor, never a delay
  /// added to a slow export — see the note on the widget.
  static const Duration _minimumProgressDuration = Duration(milliseconds: 700);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _message({
    required String title,
    required String subtitle,
    required String lottiePath,
  }) {
    return CustomDialogManager.showMessage(
      context: Navigator.of(context, rootNavigator: true).context,
      title: title,
      subtitle: subtitle,
      lottiePath: lottiePath,
    );
  }

  Future<void> _download() async {
    if (_isExporting) return;

    final String fileName = _controller.text.trim();
    if (fileName.isEmpty) {
      await _message(
        title: S.of(context).error,
        subtitle: S.of(context).pleaseEnterAFileName,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_status_warning.json',
      );
      return;
    }

    setState(() => _isExporting = true);
    final DateTime shownAt = DateTime.now();

    final Either<String, String> result = await widget.onExport(fileName);

    // Hold the spinner for the rest of its minimum, if the write beat it.
    final Duration elapsed = DateTime.now().difference(shownAt);
    if (elapsed < _minimumProgressDuration) {
      await Future<void>.delayed(_minimumProgressDuration - elapsed);
    }
    if (!mounted) return;
    setState(() => _isExporting = false);

    final String? error = result.fold((String message) => message, (_) => null);
    if (error != null) {
      await _message(
        title: S.of(context).exportFailed,
        subtitle: '${S.of(context).error}: $error',
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
      );
      return;
    }

    final String savedPath =
        result.fold((_) => CSVHelper.exportCancelled, (String path) => path);
    // The user closed the save sheet without picking anywhere. Nothing was
    // written and nothing failed, so the card stays open for another try.
    if (savedPath == CSVHelper.exportCancelled) return;

    // Resolved BEFORE the pop: once this card is gone its `context` is defunct,
    // and both `S.of()` and `showAppDialog()` would be reading a dead element.
    final BuildContext rootContext =
        Navigator.of(context, rootNavigator: true).context;
    final String title = S.of(context).success;
    // On a phone the user chose the destination in the system sheet and the
    // path that comes back is an opaque content URI, so naming it would say
    // nothing. On desktop the folder was chosen FOR them, and "it said success
    // and I found nothing" is the whole history of this feature.
    final bool isPhone = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final String subtitle = isPhone
        ? S.of(context).exportSuccess
        : '${S.of(context).exportSuccess}\n$savedPath';

    Navigator.of(context).pop(true);

    if (!rootContext.mounted) return;
    await CustomDialogManager.showSuccess(
      context: rootContext,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      title: title,
      subtitle: subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    return Dialog(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Container(
        width: 340.w,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(MobileExportMetrics.cardRadius.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.02),
              offset: Offset(-3.w, 4.h),
              blurRadius: 20.r,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.sp,
                  height: 30.sp,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: CustomSvgImage(
                    assetPath: AppAssets.export,
                    width: 16.sp,
                    height: 16.sp,
                    color: AppColors.textButton,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  s.export,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.text,
                    letterSpacing: -0.5061,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            CustomTextField(
              controller: _controller,
              label: s.fileName,
              hint: s.textHere,
              maxLines: 1,
              // Nothing to type into while the write is running, and nothing
              // to gain from renaming a file that is already being saved.
              enabled: !_isExporting,
              height: MobileExportMetrics.fieldHeight,
              fillColor: AppColors.background,
              borderRadius:
                  BorderRadius.circular(MobileExportMetrics.fieldRadius.r),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
              // Typing has to redraw the row so Download can enable itself the
              // moment the field stops being empty.
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 11.h),
            // The wait replaces the buttons rather than covering the screen:
            // it is where the user is already looking, and with the buttons
            // gone there is nothing left to double-tap.
            if (_isExporting)
              SizedBox(height: 38.sp, child: const CircleProgressMaster())
            else
              MobileExportActions(
                secondaryLabel: s.discard,
                onSecondary: () => Navigator.of(context).pop(false),
                primaryLabel: s.download,
                primaryEnabled: _controller.text.trim().isNotEmpty,
                onPrimary: _download,
              ),
          ],
        ),
      ),
    );
  }
}

/// The name an export card opens with — "`<what>` Export_12 Sep 2026".
///
/// The shape `RoleExportDialog` uses, lifted here so the phone flows open with
/// a usable name too rather than an empty field the user has to fill before
/// anything can happen. The month is localized; the digits are not, which
/// matches the desktop export and keeps the name safe as a file name.
String mobileExportDefaultFileName(BuildContext context, String subject) {
  final S s = S.of(context);
  final DateTime now = DateTime.now();
  final String month = [
    s.jan,
    s.feb,
    s.mar,
    s.apr,
    s.may,
    s.jun,
    s.jul,
    s.aug,
    s.sep,
    s.oct,
    s.nov,
    s.dec,
  ][now.month - 1];
  return '${subject}_${now.day} $month ${now.year}';
}
