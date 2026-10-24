/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_date_field_logic.dart
/// Description: Logic and event handlers of `_CustomDateFieldState` — split out of `3-custom_dropdown_calander.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_date_field.dart';

// Split from 3-custom_dropdown_calander.dart to keep every file under 700 lines.

extension _CustomDateFieldStateLogic on _CustomDateFieldState {
  Future<void> _openPicker() async {
    if (!widget.enabled) return;

    final List<String> weekdayLabels = _weekdayLabels(context);
    final bool isTablet = _isTablet;
    final Size dialogSize = _pickerDialogSize(isTablet);
    // CHANGED 13/10/2026 (form builder vertical bug report p.23 — "calendar
    // must be the same language as the form"): inside a form the picker
    // follows the FORM's language; everywhere else this is still the app
    // language (see ContentLanguageScope.isArabicOf).
    final bool isArabic = ContentLanguageScope.isArabicOf(context);
    final bool inForm = ContentLanguageScope.maybeIsArabicOf(context) != null;

    // Earliest selectable day: [firstDate], raised to today when
    // [disablePastDates] is on. A current value before it is not pre-selected
    // (it can no longer be picked), so the calendar opens on that first day.
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    DateTime effectiveFirstDate = widget.firstDate ?? DateTime(1900);
    if (widget.disablePastDates && effectiveFirstDate.isBefore(today)) {
      effectiveFirstDate = today;
    }
    final DateTime? initialValue = widget.value != null &&
            DateTime(
              widget.value!.year,
              widget.value!.month,
              widget.value!.day,
            ).isBefore(effectiveFirstDate)
        ? null
        : widget.value;

    final String okLabel = inForm
        ? (isArabic ? 'اختر التاريخ' : 'Set Date')
        : S.of(context).setDate;
    final String cancelLabel =
        inForm ? (isArabic ? 'إلغاء' : 'Cancel') : S.of(context).Cancel;
    // 17/10/2026: our own dialog (not showCalendarDatePicker2Dialog) so the
    // action row is always Cancel left / Set Date right (X-73) — the package
    // lays its two buttons out in the reading direction, which put the yellow
    // button on the LEFT in Arabic.
    final result = await _showPickerDialog(
      context: context,
      okLabel: okLabel,
      cancelLabel: cancelLabel,
      isTablet: isTablet,
      dialogBackgroundColor: AppColors.card,
      barrierDismissible: true,
      value: [initialValue],
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDate: effectiveFirstDate,
        lastDate: widget.lastDate ?? DateTime(2100),
        calendarType: CalendarDatePicker2Type.single,
        calendarViewMode: CalendarDatePicker2Mode.day,
        closeDialogOnCancelTapped: true,
        closeDialogOnOkTapped: true,

        // ADDED 13/9/2026 — the last two strips of the hover highlight.
        //
        // The package builds each action as
        // `InkWell(child: Padding(padding: buttonPadding, child: <our button>))`,
        // so the InkWell's hit area — and its highlight — is our widget PLUS
        // that padding. Covering the slot from inside `_buildActionButton`
        // therefore hid the middle band but left the padding showing above and
        // below it as two grey bars.
        //
        // With the padding at zero the InkWell is exactly our widget, so the
        // opaque slot covers all of it. Our own geometry is unaffected: the
        // two slots are measured from `dialogSize.width`, never from the
        // package's padding, and the button keeps its spacing from
        // `_kPickerButtonMargin` inside the slot.
        buttonPadding: EdgeInsets.zero,
        currentDate: initialValue ??
            (now.isBefore(effectiveFirstDate) ? effectiveFirstDate : now),
        centerAlignModePicker: true,
        dayBorderRadius: BorderRadius.circular(4.r),
        dayBuilder: _buildDay,
        modePickersGap: _kPickerModePickersGap,

        // ADDED 9/9/2026 — this is what clears the "RIGHT OVERFLOWED BY 3
        // PIXELS" stripe over the header.
        //
        // The package lays the two pickers out as
        // `Expanded(Row(children: [month, gap, year]))`, and NEITHER picker is
        // flexible: each is a `Row(mainAxisSize: min)` handed unbounded width,
        // so it takes its label's full intrinsic width and the pair overflows
        // the Expanded as soon as the labels plus two chevrons plus the
        // package's own 10-a-side padding exceed
        // `dialogWidth - _kPickerNavButtonsRoom`. On a 300.w phone dialog that
        // budget is ~197, and "September" + "2026" wanted a few more.
        //
        // `modePickerBuilder` is the only hook that replaces that inner
        // content, so each picker is given a fixed slice of the room that IS
        // available, with a FittedBox inside: a label too long for its slice
        // scales down instead of overflowing — at any dialog width, in any
        // locale, for the longest month name there is.
        //
        // It replaces `customModePickerIcon` (29/8/2026), which the package
        // only reads on the path this builder now takes over — the chevron and
        // its gap moved into `_modePicker` unchanged.
        modePickerBuilder: ({
          required CalendarDatePicker2Mode viewMode,
          required DateTime monthDate,
          bool? isMonthPicker,
        }) {
          final bool isMonth = isMonthPicker == true;
          final double room = dialogSize.width -
              _kPickerNavButtonsRoom -
              _kPickerModePickersGap;

          // FIXED 29/9/2026 (Settings mobile bug p.1 — "increase font size"
          // on the year). The year got a flat 40% slice; on a phone-width
          // dialog that was narrower than "1977" + its chevron, so the
          // FittedBox shrank the year to a few pixels. The year now always
          // gets the width it needs (4 digits + chevron) and the month takes
          // the rest, still inside the room the header has.
          final double yearNeeded = _labelWidth('0000') + 14.sp + 12.sp + 4;
          final double yearSlice =
              yearNeeded > room * 0.40 ? yearNeeded : room * 0.40;
          final double monthSlice = (room - yearSlice - 2).clamp(0.0, room);

          return _modePicker(
            width: isMonth ? monthSlice : yearSlice,
            label: isMonth
                ? DateFormat(
                    'MMMM',
                    isArabic ? 'ar' : 'en',
                  ).format(monthDate)
                // Western digits, like the day cells — `formatYear` would give
                // Arabic-Indic ones in Arabic and the header would not match
                // the grid under it.
                : monthDate.year.toString(),
            // The chevron points up while that picker's own list is open.
            isOpen: viewMode ==
                (isMonth
                    ? CalendarDatePicker2Mode.month
                    : CalendarDatePicker2Mode.year),
          );
        },
        // CHANGED 30/8/2026: the app's own chevrons. These were one
        // `arrow_back_curved` asset drawn twice and flipped with
        // `Transform.rotate(3.14)` — a rotation, not a mirror, so the curve
        // came out upside down on whichever of the two was rotated, and the
        // angle was picked by asking `Get.locale` for the language.
        lastMonthIcon: _monthArrow(forward: false),
        nextMonthIcon: _monthArrow(forward: true),
        weekdayLabels: weekdayLabels,
        // The `FittedBox` scales a label down to its column only when it does
        // not fit: the English abbreviations ("Sun", "Mon") are left at full
        // size, and it earns its place for Arabic, where the day names have no
        // short form ("الأربعاء") and would otherwise clip.
        weekdayLabelBuilder: (
            {required int weekday, bool? isScrollViewTopHeader}) {
          // Bug report (Settings mobile p.1): the full Arabic day names ran
          // into each other on a phone. Smaller type on a phone and a real gap
          // either side of each name.
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 1.sp : 3,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  weekdayLabels[weekday],
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: (isTablet
                          ? StyleText.fontSize16Weight400
                          : StyleText.fontSize12Weight400)
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ),
          );
        },
        weekdayLabelTextStyle: StyleText.fontSize16Weight400.copyWith(
          color: AppColors.primary,
        ),
        controlsTextStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.primary,
        ),
        selectedYearTextStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.primary,
        ),
        selectedDayHighlightColor: AppColors.primary,
        dayTextStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.text,
        ),
        // Days outside firstDate / lastDate: dimmed so they read as not
        // selectable.
        disabledDayTextStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.text.withValues(alpha: .25),
        ),
        selectedDayTextStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.textButton,
        ),
        yearTextStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.text,
        ),
        todayTextStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.text,
        ),
        // HORIZONTAL: still zero. This padding wraps each action button INSIDE
        // the row, so any of it here comes out of the half-dialog slot
        // `_buildActionButton` measures (see the geometry block at the top of
        // this file). The gap from the dialog edge is the button's own margin
        // instead — `_kPickerButtonMargin`.
        //
        // VERTICAL: `_kPickerButtonMargin` as well, since 9/9/2026, so the
        // space above and below the action row matches the space beside it.
        // It was zero because the dialog height was a flat 380 that the
        // package floored at 410 — exactly the content — and 8 across the pair
        // was enough to paint "BOTTOM OVERFLOWED BY 1.6 PIXELS". The height is
        // derived from these parts now (see [_kPickerCalendarHeight]), so the
        // room comes with the padding.
        // buttonPadding: EdgeInsets.symmetric(vertical: _kPickerButtonMargin.sp),
      ),
      dialogSize: dialogSize,
      borderRadius: BorderRadius.circular(4.r),
      useSafeArea: true,
      // ADDED 13/10/2026: the dialog is built on the root navigator, so it
      // inherited the APP's direction even when opened from an English form
      // in the Arabic app. Pin it to the same language as its labels.
      builder: (BuildContext dialogContext, Widget? child) => Directionality(
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: child!,
      ),
    );
    if (result != null && result.isNotEmpty) {
      widget.onChanged?.call(result.first);
    }
  }
}
