/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_dropdown_calendar.dart
/// Description: Declares `CustomDateField`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 30/8/2026 - The picker opens at `DatePicker`'s size (520×380 on
///          tablet, 360×380 on phone) instead of a 320 square, so the app's two
///          calendars are the same dialog.
/// Updated: 30/8/2026 - The picker's two action buttons are `customButton`s,
///          one pinned to each edge of the dialog, and the month arrows are the
///          app's own `chevron_left` / `chevron_right` assets. `Get.locale` is
///          gone with them — text direction now comes from `Directionality`.
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/inputs/field_sizing.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// `hide TextDirection`: intl exports a class of that name whose members are
// `LTR` / `RTL`, and it wins the import race against the framework's enum —
// `TextDirection.rtl` in `_isRtl` below then fails to compile with
// "Member not found: 'rtl'". Only the date formatting is wanted from here.
import 'package:intl/intl.dart' hide TextDirection;

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// The app's one button. The picker's actions used to be a local
// `GestureDetector` + `Container` pair with their own height, radius and text
// style — a second button implementation living in a core file.
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
// For `kDropdownHintColor` — the single placeholder grey all three dropdowns
// share. Imported rather than redeclared: a local copy is exactly how this
// widget ended up with a different hint colour from `CustomDropdown`.
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/generated/l10n.dart';
// Form-language lookup for the picker (13/10/2026).
import 'package:knowticed_plus/core/helper/content_language_scope.dart';

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'dart:ui' as ui;

part 'custom_date_field/part.dart';
part 'custom_date_field/custom_date_field_logic.dart';
part 'custom_date_field/custom_date_field_builders.dart';

/// REVISED: was 360, which is wider than a dialog can actually be on a phone.
/// `Dialog` reserves `insetPadding` (40 a side) plus the safe area, so on a
/// 402pt-wide handset the widest a dialog gets is ~322 — but the action-button
/// slots were still measured from the 360 that was ASKED for, so the two slots
/// added up to more than the row had and the trailing button overflowed. The
/// number is smaller now AND clamped to what is available in
/// [_pickerDialogSize]; do not raise it past what the narrowest supported
/// phone can show.
const double _kPickerDialogWidthPhone = 300;

/// Horizontal room a `Dialog` gives up before its child is laid out:
/// `insetPadding` is 40 on each side.
const double _kDialogInsetPadding = 40;

/// The package's own `gapBetweenCalendarAndButtons` default, raw.
const double _kPickerCalendarButtonGap = 10;

/// `customButton`'s fixed height (5-custom_button.dart), scaled with `.sp`.
const double _kPickerButtonHeight = 38;

/// Room the package reserves on EACH side of the month / year pickers for the
/// prev / next month arrows: `_monthNavButtonsWidth` is 108 and
/// `centerAlignModePicker` halves it, so 54 + 54 comes off the header row
/// before either picker gets a pixel. Raw.
const double _kPickerNavButtonsRoom = 108;

/// Gap between the month picker and the year picker — the package's own
/// default for a centre-aligned header, passed explicitly so the width the
/// mode pickers are given below and the width the package actually leaves
/// between them cannot drift apart. Raw.
const double _kPickerModePickersGap = 15;

/// The button inside a slot, and its gap from the dialog edge. Both are
/// `DatePicker`'s. `button + margin` must fit within a slot (half the dialog).
const double _kPickerButtonWidthTablet = 150;
const double _kPickerButtonWidthPhone = 120;
const double _kPickerButtonMargin = 20;

/// Month-navigation chevrons, and the size they are drawn at.
const String _kChevronLeft =
    'assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg';
const String _kChevronRight =
    'assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg';
const double _kPickerArrowSize = 16;

class CustomDateField extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final bool required;
  final bool enabled;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  /// Fixed height for the TRIGGER, or null to let it size itself. ADDED
  /// 17/8/2026 alongside the same parameter on `CustomDropdown`, so a row that
  /// holds one of each can pin both to one height.
  ///
  /// INTERPRETED IN `.sp` and scaled here — pass the raw design number (`36`),
  /// not `36.sp`, exactly as `CustomTextField.height` documents.
  ///
  /// It sizes the TRIGGER only, never the label or the error line under it.
  final double? height;

  /// Padding inside the trigger, or null for this widget's own default
  /// (12 horizontal / 10 vertical).
  ///
  /// ADDED 29/8/2026, mirroring `CustomDropdown.triggerPadding`. A screen that
  /// stands a dropdown and a date field side by side has to be able to give
  /// both the same inset — Adding New Access is the first — and the default
  /// here differs from `CustomDropdown`'s on purpose (see the note at the
  /// `contentPadding` use below), so it cannot simply be changed for everyone.
  ///
  /// Pre-scale it: unlike [height], this is passed through untouched.
  final EdgeInsetsGeometry? contentPadding;
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// ADDED 16/9/2026. When true, only TODAY and later can be picked: every
  /// earlier day is greyed out and not tappable. Combines with [firstDate]
  /// (the later of the two wins). Off by default so filters / history
  /// pickers that need past dates keep working.
  final bool disablePastDates;
  final String Function(DateTime)? dateFormatter;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  /// Size / weight / family of the placeholder.
  ///
  /// The COLOUR is not taken from here — it is always [kDropdownHintColor].
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;

  const CustomDateField({
    super.key,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.fillColor,
    this.borderRadius,
    this.height,
    this.contentPadding,
    this.firstDate,
    this.lastDate,
    this.disablePastDates = false,
    this.dateFormatter,
    this.labelStyle,
    this.valueStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
  });

  @override
  State<CustomDateField> createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {
  /// The box height: the screen's, else the shared 36 (D-18, 17/10/2026).
  double? get _fieldHeight => widget.height ?? FieldSizing.height;

  /// Whether the tree this picker opens from reads right-to-left.
  ///
  /// Replaces the two `Get.locale.toString().contains('en')` reads that used to
  /// pick the month-arrow rotation: direction is a property of the widget tree,
  /// and this widget has a context.
  bool get _isRtl => Directionality.of(context) == TextDirection.rtl;

  /// The weekday header, abbreviated — "Sun Mon … Sat".
  ///
  /// ADDED 30/8/2026 to match `DatePicker` (core/custom/53-custom_date_pic),
  /// the app's other calendar: without this the package falls back to
  /// `localizations.narrowWeekdays`, the single letters "S M T W T F S", where
  /// three of the seven are ambiguous. `weekdayLabels` is a 7-element list the
  /// package indexes 0 = Sunday … 6 = Saturday, so it is built Sunday-first
  /// (4 Jan 2026 is a Sunday).
  ///
  /// 'EEE', not 'EEEE': the full names are far too wide for seven day-wide
  /// columns. Arabic has no shorter form for most days, so there 'EEE' returns
  /// what 'EEEE' would — which is what the `FittedBox` in the builder below is
  /// for.
  List<String> _weekdayLabels(BuildContext context) {
    // Form language inside a form, app language elsewhere (13/10/2026).
    final bool isArabic = ContentLanguageScope.isArabicOf(context);

    return List<String>.generate(
      7,
      (int i) => DateFormat(
        'EEE',
        isArabic ? 'ar' : 'en',
      ).format(DateTime(2026, 1, 4).add(Duration(days: i))),
    );
  }

  /// `DatePicker`'s own breakpoint, so the two calendars switch size together.
  bool get _isTablet => !kpIsPhoneLayout(context);

  /// The size the dialog opens at, and the single source the button slots are
  /// measured from — see the geometry block at the top of this file.
  Size _pickerDialogSize(bool isTablet) {
    final double requestedWidth =
        isTablet ? _kPickerDialogWidthTablet.sp : _kPickerDialogWidthPhone.w;

    // Clamp to the width a dialog can actually occupy. Asking for more than
    // this does not widen the dialog — the dialog is constrained anyway — it
    // only inflates the half-dialog slots `_buildActionButton` measures, which
    // is what overflowed the action row.
    final MediaQueryData mq = MediaQuery.of(context);
    final double available =
        mq.size.width - mq.padding.horizontal - _kDialogInsetPadding * 2;

    final double width =
        requestedWidth > available ? available : requestedWidth;

    return Size(
      width,
      // See the geometry block at the top of this file: the calendar's part is
      // raw, the button row's part scales.
      _kPickerCalendarHeight +
          _kPickerCalendarButtonGap +
          _kPickerButtonHeight.sp +
          _kPickerButtonMargin.sp * 2,
    );
  }

  Widget _buildDay({
    required DateTime date,
    BoxDecoration? decoration,
    bool? isDisabled,
    bool? isSelected,
    bool? isToday,
    TextStyle? textStyle,
  }) {
    final now = DateTime.now();
    final isTodayDate =
        date.day == now.day && date.month == now.month && date.year == now.year;
    return Center(
      child: Container(
        width: 25.sp,
        height: 25.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: isSelected == true ? AppColors.primary : AppColors.card,
          border: Border.all(
            color: isTodayDate ? AppColors.primary : AppColors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: StyleText.fontSize14Weight400.copyWith(
              color: isSelected == true
                  ? AppColors.textButton
                  // Not selectable (before firstDate / after lastDate).
                  : isDisabled == true
                      ? AppColors.secondaryText.withValues(alpha: .25)
                      : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  /// One month-navigation chevron.
  ///
  /// ADDED 30/8/2026. The package positions these by PHYSICAL side, not by
  /// reading order — the "previous month" arrow is on the right in Arabic — so
  /// the asset is picked by direction rather than by rotating one arrow into
  /// the other. [forward] is "next month".
  Widget _monthArrow({required bool forward}) {
    final bool pointsEnd = forward != _isRtl;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.sp),
      child: CustomSvgImage(
        assetPath: pointsEnd ? _kChevronRight : _kChevronLeft,
        width: _kPickerArrowSize.sp,
        height: _kPickerArrowSize.sp,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }

  /// One of the picker's two action buttons, in its half of the dialog.
  ///
  /// CHANGED 30/8/2026: the button is now the app's [customButton] rather than
  /// a local `GestureDetector` + `Container` with its own height, radius and
  /// text style, and the two are pushed apart — Cancel against the leading
  /// edge, Set Date against the trailing one. See the geometry block at the top
  /// of this file for why each button is given exactly half the dialog width.
  ///
  /// [IgnorePointer] is load-bearing: `customButton` carries its own
  /// `GestureDetector`, and a live gesture detector here would win the arena
  /// against the `InkWell` the PACKAGE wraps this widget in — the one that
  /// actually commits the date and closes the dialog. Taps must fall through,
  /// so the button is passed a no-op `function` and made invisible to hit
  /// testing. (The cost is `customButton`'s haptic, which never fires.)
  /// One header picker — "September ⌄", "2026 ⌄" — inside a fixed [width].
  ///
  /// The width is what keeps the header from overflowing (see
  /// `modePickerBuilder` above); the `FittedBox` is what keeps a label legible
  /// inside it rather than clipped. `BoxFit.scaleDown` only ever shrinks, so a
  /// label that already fits — every English month, every Arabic one — is
  /// drawn at full size and nothing about the header changes.
  /// Width of [text] in the header label style.
  double _labelWidth(String text) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: StyleText.fontSize14Weight400.copyWith(color: AppColors.primary),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  Widget _modePicker({
    required double width,
    required String label,
    required bool isOpen,
  }) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          // The gap that keeps the label and its chevron from reading as one
          // glyph ("أغسطس⌄") — 29/8/2026, moved here 9/9/2026.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.sp),
            child: RotatedBox(
              quarterTurns: isOpen ? 2 : 0,
              child: CustomSvgImage(
                assetPath:
                    'assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg',
                height: 14.sp,
                fit: BoxFit.fitHeight,
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      widget.dateFormatter?.call(d) ??
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _sized(Widget trigger) {
    final double? h = _fieldHeight;
    if (h == null) return trigger;
    return SizedBox(height: h.sp, child: trigger);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final radius = BorderRadius.circular(4.r);
    final isDisabled = !widget.enabled;
    final displayText =
        widget.value != null ? _formatDate(widget.value!) : null;

    // ADDED 21/9/2026 — pin the painted box to [height], exactly as
    // `CustomDropdown._buildTrigger` does (its 16/9/2026 note). Without this
    // `height` only sized the SizedBox AROUND the decorator: the decorator kept
    // its own vertical content padding plus an unconstrained suffix, so it drew
    // a box of a different height from a `height: 36` dropdown beside it — the
    // Role Type / Access Granted / Access Revoked row (bug report p.10). With a
    // pinned height the vertical padding goes to 0, the suffix slot is held to
    // the height (InputDecorator uses it as the container minimum) and the
    // value is centred. A caller passing its own [contentPadding] is untouched.
    final double? pinnedHeight =
        _fieldHeight != null && widget.contentPadding == null
            ? _fieldHeight!.sp
            : null;

    // ── Label 14.sp / hint 12.sp, ALWAYS (16/8/2026) ──────────────────────
    //
    // Same contract as `CustomTextField` and `CustomDropdown`. This widget is
    // never alone on a row — "Start Date Of Access" and "End Date Of Access"
    // sit beside each other under a Permissions dropdown — so it has to measure
    // its title and its placeholder the same way they do. Its hint defaulted to
    // 14, which is why an empty date box's placeholder read larger than the
    // dropdown's above it.
    //
    // [labelStyle] still owns colour, weight and the rest; only the size is
    // reapplied. [hintStyle] no longer owns the colour — see
    // [kDropdownHintColor], forced on below.
    final TextStyle labelStyle = (widget.labelStyle ??
            StyleText.fontSize14Weight500.copyWith(
              color: hasError ? AppColors.red : AppColors.text,
            ))
        .copyWith(fontSize: 14.sp);

    final TextStyle hintStyle =
        (widget.hintStyle ?? StyleText.fontSize12Weight400).copyWith(
      fontSize: 12.sp,
      color: kDropdownHintColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: labelStyle,
              children: widget.required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.red,
                          fontSize: 14.sp,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
          // Shared with `CustomDropdown` (29/8/2026) so a labelled dropdown and
          // a labelled date field standing side by side start at the same
          // height. The literal 6 that used to be here is now [kFieldLabelGap],
          // imported from the same file this widget already takes
          // `kDropdownHintColor` from — for exactly the same reason.
          SizedBox(height: kFieldLabelGap.sp),
        ],
        // `_sized` applies [CustomDateField.height] to the trigger and
        // nothing else — see that field.
        _sized(
          GestureDetector(
            onTap: withHaptic(_openPicker, HapticLevel.low),
            child: InputDecorator(
              isFocused: false,
              textAlignVertical:
                  pinnedHeight != null ? TextAlignVertical.center : null,
              isEmpty: displayText == null,
              decoration: InputDecoration(
                isDense: true,
                // ADDED 21/9/2026 — the decorator itself is held to [height], not
                // just the SizedBox around it. The suffix-slot trick alone left the
                // painted box a few px short in some rows (Gender / Birthday /
                // Marital Status drew 37 / 40 / 37 px at the same `height: 40`).
                constraints: _fieldHeight == null
                    ? null
                    : BoxConstraints.tightFor(height: _fieldHeight!.sp),
                // 10.sp vertical (16/8/2026, was 12.sp). The trigger carries a
                // 18.sp calendar icon in its suffix, so its content is already
                // taller than a text field's single line — the same padding on
                // both made the date boxes stand proud of the fields beside them.
                contentPadding: widget.contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: 12.sp,
                      vertical: pinnedHeight != null ? 0 : 10.sp,
                    ),
                filled: true,
                fillColor: isDisabled
                    ? (widget.fillColor ?? AppColors.background)
                    : widget.fillColor ?? AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: hasError
                    ? OutlineInputBorder(
                        borderRadius: radius,
                        borderSide: BorderSide(
                          color: AppColors.red,
                          width: 1.5.sp,
                        ),
                      )
                    : OutlineInputBorder(
                        borderRadius: radius,
                        borderSide: BorderSide.none,
                      ),
                focusedBorder: hasError
                    ? OutlineInputBorder(
                        borderRadius: radius,
                        borderSide: BorderSide(
                          color: AppColors.red,
                          width: 1.5.sp,
                        ),
                      )
                    : OutlineInputBorder(
                        borderRadius: radius,
                        borderSide: BorderSide.none,
                      ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide.none,
                ),
                prefixIcon: null,
                prefixIconConstraints: const BoxConstraints(),
                // ── calendar icon now on the right, arrow removed ──
                // CHANGED 8/9/2026 — the icon was full-strength AppColors.text,
                // which read as darker and heavier than the chevron on the
                // dropdown standing next to it in the same row. It is now
                // AppColors.grey at 50%, matching that chevron. The error colour
                // is untouched: a red field still gets a red icon.
                // CHANGED 17/10/2026 (Moataz: "the icon arrow is not aligned
                // with the calendar and the colours are not the same"):
                // directional padding — the physical left/right put the icon
                // 8 from the edge in Arabic but 12 in English — the dropdown
                // chevron's 20 box, and the chevron's colour rule (grey while
                // empty, black once a date is picked).
                suffixIcon: Padding(
                  padding: EdgeInsetsDirectional.only(start: 8.sp, end: 12.sp),
                  child: SizedBox.square(
                    dimension: 20.sp,
                    child: Center(
                      child: CustomSvgImage(
                        assetPath:
                            'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
                        width: 18.sp,
                        height: 18.sp,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          hasError
                              ? AppColors.red
                              : kDropdownTrailingIconColor(
                                  hasValue: displayText != null),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                suffixIconConstraints: pinnedHeight != null
                    ? BoxConstraints(
                        minHeight: pinnedHeight,
                        maxHeight: pinnedHeight,
                      )
                    : const BoxConstraints(),
                hintText: displayText == null ? (widget.hint ?? '') : null,
                hintStyle: hintStyle,
                errorText: null,
              ),
              child: displayText != null
                  ? Text(
                      displayText,
                      style: widget.valueStyle ??
                          StyleText.fontSize14Weight400.copyWith(
                            color: isDisabled ? AppColors.text : AppColors.text,
                          ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.sp),
          Text(
            widget.errorText!,
            style: widget.errorStyle ??
                StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          ),
        ] else if (widget.helperText != null) ...[
          SizedBox(height: 4.sp),
          Text(
            widget.helperText!,
            style: widget.helperStyle ??
                StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text.withValues(alpha: 0.5),
                ),
          ),
        ],
      ],
    );
  }
}

/*
// ── Usage ─────────────────────────────────────────────────────────────────────
DateTime? _date;

CustomDateField(
  label: 'Birth Date',
  hint: 'Select date',
  required: true,
  value: _date,
  // errorText: 'Date is required',
  onChanged: (d) => setState(() => _date = d),
)
*/
