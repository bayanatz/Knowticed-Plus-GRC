/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_date_field_builders.dart
/// Description: UI builder methods of `_CustomDateFieldState` — split out of `3-custom_dropdown_calander.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_date_field.dart';

// Split from 3-custom_dropdown_calander.dart to keep every file under 700 lines.

extension _CustomDateFieldStateBuilders on _CustomDateFieldState {
  /// ADDED 17/10/2026 — the picker dialog, built here instead of
  /// `showCalendarDatePicker2Dialog`. Same Dialog geometry as the package
  /// (inset 16/24, height floored at 410), but the action row is ours and
  /// always left-to-right: Cancel on the left, Set Date on the right, in both
  /// languages (X-73). The calendar keeps the dialog's reading direction.
  Future<List<DateTime?>?> _showPickerDialog({
    required BuildContext context,
    required CalendarDatePicker2WithActionButtonsConfig config,
    required Size dialogSize,
    required String okLabel,
    required String cancelLabel,
    required bool isTablet,
    List<DateTime?> value = const <DateTime?>[],
    BorderRadius? borderRadius,
    bool barrierDismissible = true,
    bool useSafeArea = true,
    Color? dialogBackgroundColor,
    TransitionBuilder? builder,
  }) {
    final double dialogHeight = config.dayMaxWidth != null
        ? dialogSize.height
        : (dialogSize.height < 410 ? 410 : dialogSize.height);
    return showDialog<List<DateTime?>>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      useSafeArea: useSafeArea,
      builder: (BuildContext dialogContext) {
        List<DateTime?> picked = List<DateTime?>.of(value);
        final Widget dialog = Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          backgroundColor: dialogBackgroundColor ?? AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: dialogSize.width,
            height: dialogHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MediaQuery.removePadding(
                  context: dialogContext,
                  child: CalendarDatePicker2(
                    value: picked,
                    config: config,
                    onValueChanged: (List<DateTime?> v) => picked = v,
                  ),
                ),
                SizedBox(height: config.gapBetweenCalendarAndButtons ?? 10),
                Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (_) =>
                            HapticController.high(), // Cancel is always HIGH
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: _buildActionButton(
                          cancelLabel,
                          dialogWidth: dialogSize.width,
                          isTablet: isTablet,
                          isCancel: true,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (_) => HapticController.medium(),
                        onTap: () {
                          Navigator.of(dialogContext).pop(picked);
                        },
                        child: _buildActionButton(
                          okLabel,
                          dialogWidth: dialogSize.width,
                          isTablet: isTablet,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        return builder == null ? dialog : builder(dialogContext, dialog);
      },
    );
  }

  Widget _buildActionButton(
    String label, {
    required double dialogWidth,
    required bool isTablet,
    bool isCancel = false,
  }) {
    // Half the dialog, taken from the width the dialog was actually opened
    // at — the two slots have to add up to it exactly.
    final double slot = dialogWidth / 2;
    // Never under 16 logical px: on a narrow desktop window `.sp` shrank the
    // margin until Cancel touched the dialog edge (Settings mobile bug p.1).
    final double margin =
        _kPickerButtonMargin.sp < 16 ? 16 : _kPickerButtonMargin.sp;

    // The button plus its own margin must fit INSIDE the slot. On a narrow
    // phone the fixed width no longer does, and the surplus is exactly what
    // used to paint the overflow stripe over the trailing button — so shrink
    // the button to the room it has rather than letting the row overflow.
    final double desiredButtonWidth =
        isTablet ? _kPickerButtonWidthTablet.sp : _kPickerButtonWidthPhone.sp;
    final double maxButtonWidth = slot - margin;
    final double buttonWidth = maxButtonWidth <= 0
        ? slot
        : (desiredButtonWidth > maxButtonWidth
            ? maxButtonWidth
            : desiredButtonWidth);

    // The grey rectangle on hover is NOT this button — it is the InkWell the
    // picker package wraps this whole slot in (see the IgnorePointer note
    // above: that InkWell is what commits the date). It covers the full
    // `slot`, i.e. half the dialog, which is why the highlight was far wider
    // than the button and bled past it.
    //
    // A `Theme` override here does NOT work, and that was the first attempt:
    // Theme only reaches descendants, and the InkWell is this widget's
    // ANCESTOR — it reads the theme from its own position, above us.
    //
    // What does work is paint order. An InkWell's hover / highlight / splash
    // are InkFeatures drawn by the nearest ancestor Material, and that
    // Material paints its ink layer BEFORE its child subtree. So anything
    // opaque in the subtree covers the ink. Filling the whole slot with the
    // dialog's own background (`dialogBackgroundColor: AppColors.card`, passed
    // where this picker is opened) hides the highlight while leaving the
    // dialog looking exactly as it does now — and the tap still reaches the
    // InkWell underneath, because ColoredBox is not a hit-test barrier the way
    // an AbsorbPointer would be.
    return ColoredBox(
      color: AppColors.card,
      child: SizedBox(
        width: slot,
        child: Align(
          alignment: isCancel
              ? AlignmentDirectional.centerStart
              : AlignmentDirectional.centerEnd,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: isCancel ? margin : 0,
              end: isCancel ? 0 : margin,
            ),
            child: IgnorePointer(
              child: customButton(
                title: label,
                function: () {},
                width: buttonWidth,
                color: isCancel ? AppColors.darkGrey : AppColors.primary,
                textStyle: StyleText.fontSize14Weight400.copyWith(
                  color: isCancel ? AppColors.text : AppColors.textButton,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
