/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_controls.dart
/// Purpose: Declares the module's shared toolbar / form controls, one look
///          on every Time Tracker screen: `TtAssets` (the Figma icons),
///          `TtSearchField`, `TtFilterButton`, `TtExportButton`,
///          `CustomSegmentedToggle` and `TtUploadButton`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI fix round 1 — owner review on iPad)
///
/// All built on core widgets (`AppSearchTextField` 35, `customButtonWithSvg`
/// 6, `CustomSegmentedTabs` 9, `CustomSvgImage` 32, `ButtonSizing` 41).
/// Figma `QVFDXSnFPExQVOIycX9ECb`, iPad VERTICAL frames:
/// - Toolbar (`661:19747` Attendance, same on Requests / Request Types /
///   Locations / Approvals): Search 38 high · Filter = white 38×38 square
///   with the "Tuning 2" icon (23, #797979) · Export = yellow 38×38 square
///   with the "solar:download-linear" tray-arrow icon (24) · then the yellow
///   "+ …" text button. Filter and Export are ICON-ONLY on every device.
/// - Two-option toggle: "Counts / Minutes" (`661:10741`, inside a white
///   card) = a 145×35 page-colour container, padding 5, active tab 25 high,
///   radius 8, text 12 Medium; "Employees | Locations" (`661:93542`, on the
///   page) = a 203×41 card-colour container, padding 7, radius 4, text 16
///   Medium. The container always takes the OTHER surface colour, so it
///   shows on both (owner finding 1).
/// - Upload (`661:16900` / `661:17016` "Upload", `661:80120` "Upload
///   Attachment"): yellow 36 high, radius 4, upload icon 16 + 14 Medium.
/// Haptics: Filter / toggles LOW, Export / Upload MEDIUM (core button).
/// Yellow buttons shrink on tap. Colours are `AppColors` getters (dark mode).
/// Updated: 9/10/2026 - phase 5: `CustomSegmentedToggle.compact` (the Overview
/// "My Dashboard | HR" toggle on the page, Figma `661:43164`).
/// Updated: 9/10/2026 - code review (playbook §4 "SVG: CustomSvgImage
/// only"): `TtAssets` gains the app's existing line icons that match the
/// Material ones the module used (calendar, e-mail, phone, edit, reminder
/// bell, clock, person, department, group, description, attachment, send,
/// camera, image, location, status pulse, minus); `TtGlyph` + `TtIcon`
/// draw a leading icon from an SVG asset, falling back to a Material icon
/// ONLY where the app has no equivalent asset (listed in STATUS.md).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_toolbar_action_button.dart';

/// The Figma icons exported for this module (read-only `exportAsync` SVG,
/// 9/10/2026), registered through `assets/icons_assets/time_tracker_assets/`.
abstract class TtAssets {
  static const String _dir = 'assets/icons_assets/time_tracker_assets';

  /// "Linear / Settings, Fine Tuning / Tuning 2" (`661:19870`).
  static const String filter =
      'assets/icons_assets/main_icons_assets/ic_action_filter.svg';

  /// "solar:download-linear" — the tray with an up arrow (`661:19872`).
  static const String export =
      'assets/icons_assets/main_icons_assets/ic_action_upload_rounded.svg';

  /// "Linear / Arrows Action / Upload" (`661:17006`).
  static const String upload = '$_dir/ic_upload.svg';

  /// ADDED 12/10/2026 (owner R7): toolbar "+" and Import with the SAME
  /// drawn stroke as Filter / Export at `TtToolbar.iconSize` (the house
  /// plus.svg was a 1-unit hairline; upload_arrow a 3-unit bold line).
  static const String add =
      'assets/icons_assets/main_icons_assets/ic_action_plus.svg';
  static const String import =
      'assets/icons_assets/time_tracker_assets/ic_action_download.svg';

  static const String calendar =
      'assets/icons_assets/main_icons_assets/ic_time_calendar.svg';
  static const String email =
      'assets/icons_assets/main_icons_assets/ic_comms_email.svg';
  static const String phone =
      'assets/icons_assets/main_icons_assets/ic_comms_phone_rounded.svg';
  static const String edit =
      'assets/icons_assets/main_icons_assets/ic_action_edit.svg';
  static const String reminder =
      'assets/icons_assets/main_icons_assets/ic_time_reminder_bell.svg';
  static const String clock =
      'assets/icons_assets/main_icons_assets/ic_time_clock.svg';
  static const String person =
      'assets/icons_assets/main_icons_assets/ic_user_profile.svg';
  static const String department =
      'assets/icons_assets/main_icons_assets/ic_building_office.svg';
  static const String group =
      'assets/icons_assets/main_icons_assets/ic_user_group.svg';
  static const String description =
      'assets/icons_assets/main_icons_assets/ic_form_field_description.svg';
  static const String attachment =
      'assets/icons_assets/main_icons_assets/ic_media_attach_square.svg';
  static const String send =
      'assets/icons_assets/main_icons_assets/ic_action_send_white.svg';

  /// ADDED 12/10/2026 (owner I5): the house comment-send icon (Knowledge Hub
  /// comments) for the square Send of "Inquiries And Comments".
  static const String commentSend =
      'assets/icons_assets/main_icons_assets/ic_comms_send.svg';
  static const String camera =
      'assets/icons_assets/main_icons_assets/ic_media_camera_teal.svg';
  static const String image =
      'assets/icons_assets/main_icons_assets/ic_form_field_image.svg';
  static const String location =
      'assets/icons_assets/main_icons_assets/ic_place_pin.svg';
  static const String status =
      'assets/icons_assets/main_icons_assets/ic_status.svg';
  static const String logout =
      'assets/icons_assets/time_tracker_assets/ic_action_logout.svg';

  /// 13/10/2026 (owner O1): the attendance day-card icons, exported from
  /// Figma (mobile attendance card `661:11059`).
  static const String dayCalendar =
      'assets/icons_assets/time_tracker_assets/ic_tt_day_calendar.svg';
  static const String dayOncoming =
      'assets/icons_assets/time_tracker_assets/ic_tt_day_oncoming.svg';
  static const String dayLeaving =
      'assets/icons_assets/time_tracker_assets/ic_tt_day_leaving.svg';
  static const String dayBreak =
      'assets/icons_assets/time_tracker_assets/ic_tt_day_break.svg';
  static const String dayTotal =
      'assets/icons_assets/time_tracker_assets/ic_tt_day_total.svg';

  /// 13/10/2026 (owner F1): the Attendance summary-tile badges.
  /// Owner 21/10/2026: replaced with the badges of Figma Attendance frame
  /// `661:74949` (KPI group `661:75088`), read-only `exportAsync` SVG:
  /// Present `661:75262`, Absent `661:75237`, Late `661:75145`,
  /// Vacation `661:75091`, Excused `661:75195`. Sick Leave is two sibling
  /// layers in Figma (circle `661:75221` + folder `661:75226`), stacked in
  /// code by `TtKpiSickBadge`.
  static const String tilePresent = '$_dir/ic_tt_kpi_present.svg';
  static const String tileAbsent = '$_dir/ic_tt_kpi_absent.svg';
  static const String tileLate = '$_dir/ic_tt_kpi_late.svg';
  static const String tileVacation = '$_dir/ic_tt_kpi_vacation.svg';
  static const String tileSickCircle = '$_dir/ic_tt_kpi_sick_circle.svg';
  static const String tileSickFolder = '$_dir/ic_tt_kpi_sick_folder.svg';
  static const String tileExcuse = '$_dir/ic_tt_kpi_excused.svg';

  /// 13/10/2026 (owner I1 / Q1): the Approve / Reject / Cancel button icons
  /// from Figma (`661:46511`, `661:22112`) — full-colour badges, not tinted.
  static const String btnApprove =
      'assets/icons_assets/main_icons_assets/ic_status_approved_circle.svg';
  static const String btnReject =
      'assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg';

  /// Owner 22/10/2026: the minus circle Settings and Services use for
  /// Cancel (the X was wrong).
  static const String btnCancel =
      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg';

  /// 13/10/2026 (owner): Request Details icons from Figma — the big request
  /// box (`661:22417`), Request Type (`661:23117`), Requested By
  /// (`661:46528`), Job Title (`661:46535`) and the status-button badges
  /// (Pending `661:22459`, Under Review `661:23162`, Canceled `661:22963`,
  /// Approved `661:22043`).
  static const String reqBox =
      'assets/icons_assets/time_tracker_assets/ic_tt_req_type.svg';
  static const String reqType =
      'assets/icons_assets/time_tracker_assets/ic_tt_req_type.svg';
  static const String reqUser =
      'assets/icons_assets/main_icons_assets/ic_user_person.png';
  static const String reqJob =
      'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg';

  /// 13/10/2026 (owner: "this is not a Lottie for checking out"): the app's
  /// leaving animation (the same one the sign-out confirm uses).
  static const String lottieCheckOut =
      'assets/lottie_assets/main_lottie_assets/lot_action_logout.json';
  static const String statusPending =
      'assets/icons_assets/main_icons_assets/ic_status_work_in_progress.svg';
  static const String statusReview =
      'assets/icons_assets/time_tracker_assets/ic_tt_status_review.svg';
  static const String statusCanceled =
      'assets/icons_assets/time_tracker_assets/ic_tt_status_canceled.svg';
  static const String statusApproved =
      'assets/icons_assets/main_icons_assets/ic_status_approved_circle.svg';

  /// 13/10/2026 (owner I4): the approval-cycle arrow (Figma `661:23090`).
  static const String cycleArrow =
      'assets/icons_assets/time_tracker_assets/ic_tt_cycle_arrow.svg';

  /// 13/10/2026 (owner R-1): the Request Type card row icons (Figma
  /// `661:35531`).
  static const String rtHr =
      'assets/icons_assets/time_tracker_assets/ic_tt_rt_hr.svg';
  static const String rtManager =
      'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg';
  static const String rtDescription =
      'assets/icons_assets/main_icons_assets/ic_form_field_description.svg';
  static const String rtAttachments =
      'assets/icons_assets/main_icons_assets/ic_action_attach_blue.svg';
  static const String rtStatus =
      'assets/icons_assets/main_icons_assets/ic_status_pulse.svg';

  /// 13/10/2026 (owner S2): the Location card icons (Figma `661:117634`).
  static const String locBuilding =
      'assets/icons_assets/time_tracker_assets/ic_tt_loc_building.svg';
  static const String locGeofence =
      'assets/icons_assets/time_tracker_assets/ic_tt_loc_geofence.svg';
  static const String locCountry =
      'assets/icons_assets/main_icons_assets/ic_hr_detail_nationality.svg';
  static const String locCity =
      'assets/icons_assets/time_tracker_assets/ic_tt_loc_city.svg';
  static const String locPause =
      'assets/icons_assets/time_tracker_assets/ic_tt_loc_pause.svg';

  /// Red filled circle with a white minus (drawn in its own colours).
  static const String minusCircle =
      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg';

  // ── UI quality pass (9/10/2026) ───────────────────────────────────────────
  static const String chevronRight =
      'assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg';
  static const String chevronLeft =
      'assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg';

  /// The house trash (tinted white on the red destructive buttons).
  static const String trash =
      'assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg';

  /// "⋯" (card overflow menu).
  static const String more =
      'assets/icons_assets/main_icons_assets/ic_nav_more_horizontal.svg';

  /// Chat bubble of the Message buttons.
  static const String message =
      'assets/icons_assets/main_icons_assets/ic_messages_new.svg';
}

/// ADDED 9/10/2026 (code review): a leading icon — an SVG asset (preferred,
/// [TtGlyph.svg]) or a Material icon where the app has no equivalent asset
/// ([TtGlyph.icon]).
class TtGlyph {
  const TtGlyph.svg(String this.asset, {this.tinted = true}) : icon = null;
  const TtGlyph.icon(IconData this.icon)
      : asset = null,
        tinted = true;

  final String? asset;
  final IconData? icon;

  /// Draw the SVG in the caller's colour (false = its own colours).
  final bool tinted;
}

/// ADDED 9/10/2026 (code review): draws a [TtGlyph] at [size] in [color]
/// (`CustomSvgImage` for an asset).
class TtIcon extends StatelessWidget {
  const TtIcon(this.glyph, {super.key, required this.size, this.color});

  final TtGlyph glyph;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final String? asset = glyph.asset;
    if (asset != null) {
      // 9/10/2026 (UI pass): `contain`, not the core default `scaleDown` —
      // an icon asked for at 48 drew at its natural ~20 (the tiny pen in the
      // request details' icon box).
      return CustomSvgImage(
        assetPath: asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        color: glyph.tinted ? color : null,
      );
    }
    return Icon(glyph.icon, size: size, color: color);
  }
}

/// ADDED 12/10/2026 (owner rule R9): the module's one text link ("Expand",
/// "Hide", "View All", comment "Edit" / "Delete"). The underline is a 1 px
/// line drawn [gap] BELOW the text box instead of `TextDecoration.underline`
/// (which sits on the baseline and touches the Cairo descenders). Tap area
/// padded so the link is easy to hit. LOW haptic.
class TtLink extends StatelessWidget {
  const TtLink({
    super.key,
    required this.label,
    required this.onTap,
    this.style,
    this.color,
    this.padding,
  });

  final String label;
  final VoidCallback onTap;

  /// Size / weight (colour comes from [color]); default 14 Medium.
  final TextStyle? style;

  /// Text + underline colour; default `AppColors.blue`.
  final Color? color;

  /// Tap padding around the link; default 4 vertical.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.blue;
    return Semantics(
      link: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticController.low();
          onTap();
        },
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(vertical: 4.h),
          child: Container(
            padding: EdgeInsets.only(bottom: 2.h),
            decoration:
                BoxDecoration(border: Border(bottom: BorderSide(color: c))),
            child: Text(
              label,
              style: (style ?? StyleText.fontSize14Weight500)
                  .copyWith(color: c, height: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}

/// ADDED 9/10/2026 (owner review): ONE height and corner radius for every
/// toolbar control — Search (`AppSearchTextField` 38 / 8), the Department /
/// filter dropdowns, Export and Import (core `ButtonSizing` 38 / 8).
abstract class TtToolbar {
  /// Raw height for `CustomDropdown.height` / `AppSearchTextField.height`
  /// (they scale it themselves).
  static const double height = 38;

  /// The corner radius of every toolbar control.
  static BorderRadius get radius => BorderRadius.circular(ButtonSizing.radius);

  /// ADDED 12/10/2026 (owner R7): ONE icon size for Filter, Export, Import
  /// and "+" (they were 23 / 24 / 16 / 16).
  // 22/10/2026 — Owner: the same token as Filter / Sort / search
  // (ToolbarStyle.iconSize, 20.sp) — 20.r differed on iPad.
  static double get iconSize => ToolbarStyle.iconSize;
}

/// The module's search box: core `AppSearchTextField` (self-Expanded — put
/// it straight into a `Row`) with its text CENTRED in the 38-high box
/// (owner finding 4): no vertical padding, so the field centres the line
/// itself, and an even line height, so the Cairo cap height sits on the
/// middle instead of ~2 px low (measured on a rendered field: 16 above /
/// 12 below before, 14 / 14 after).
class TtSearchField extends StatelessWidget {
  const TtSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.fillColor,
    this.hint,
    this.onSubmitted,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// ADDED 13/10/2026 (location address search): the keyboard "Search" key
  /// (core `AppSearchTextField.onSubmitted`); null = a plain filter field.
  final ValueChanged<String>? onSubmitted;

  /// ADDED 13/10/2026: e.g. a spinner while a search runs.
  final Widget? suffixIcon;

  /// Defaults to the card colour (the field sits on the page background).
  final Color? fillColor;

  /// ADDED 9/10/2026 (KP-TT-006): the hint ("Search country…"); null =
  /// "Search".
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return AppSearchTextField(
      controller: controller,
      hintText: hint ?? S.of(context).search,
      fillColor: fillColor ?? AppColors.card,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: onSubmitted == null ? null : TextInputAction.search,
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.sp),
      // 22/10/2026 — Owner: toolbar text is 14 medium (500) in every module
      // (was 14 regular); the line metrics below stay for the centring.
      valueStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.text,
        height: 1,
        leadingDistribution: TextLeadingDistribution.even,
      ),
    );
  }
}

/// Icon-only Export: the yellow 38×38 core icon button with the Figma
/// tray-arrow icon (MEDIUM haptic from the core button; shrinks on tap).
class TtExportButton extends StatelessWidget {
  const TtExportButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: S.of(context).export,
      child: ShrinkOnTap(
        child: customButtonWithSvg(
          title: '',
          function: onTap,
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: TtAssets.export,
          widthImage: TtToolbar.iconSize,
          heightImage: TtToolbar.iconSize,
          svgColor: AppColors.textButton,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }
}

/// 13/10/2026 (owner rule): every Time Tracker dialog uses ONE of two
/// widths, so a filter / form / import looks the same size on every tab.
///   [standard] — filters, forms, edit and import dialogs.
///   [compact]  — short choices (check-in options, country picker).
/// Messages, success, confirm and export dialogs keep the core sizes.
class TtDialogWidth {
  const TtDialogWidth._();

  static const double standard = 600;
  static const double compact = 450;

  /// 13/10/2026 (owner): pickers that list people as cards (HR Employees) —
  /// wide enough that a name and job title each stay on one line.
  static const double wide = 820;

  /// 13/10/2026 (owner): every small status dialog — "Are you sure?",
  /// success, export done, warnings — has this ONE width (unscaled; the
  /// core dialog manager applies `.sp`), so none looks bigger than another.
  static const double status = 411;
}

/// The yellow Upload button of the attachment fields (owner finding 6):
/// 36 high, radius 4, upload icon + label. 13/10/2026 (owner G2 / P1): as
/// WIDE as the fields (the whole column). A missing required file draws a
/// red border (owner rule: validation = red border + message).
class TtUploadButton extends StatelessWidget {
  const TtUploadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.hasError = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) => ShrinkOnTap(
        child: customButtonWithSvg(
          title: label,
          function: onTap,
          color: AppColors.primary,
          colorBorder: hasError ? AppColors.red : AppColors.transparent,
          image: TtAssets.upload,
          widthImage: 16.r,
          heightImage: 16.r,
          svgColor: AppColors.textButton,
          fixedWidth: box.maxWidth,
          fixedHeight: 36.sp,
          fixedRadius: 4.r,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }
}
