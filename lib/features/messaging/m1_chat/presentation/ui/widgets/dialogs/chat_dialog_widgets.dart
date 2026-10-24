/// Module: messaging / chat / presentation/ui/widgets/dialogs/chat_dialog_widgets.dart
/// Description: Building blocks shared by the chat dialogs from Figma section
///          6290:740 — Schedule Message, Mute Notifications, Disappearing
///          Messages, Contact and Poll.
/// Author: Amr Mesbah
/// Created at: 30/9/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_time_picker.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart'
    show kDropdownFillColor, kDropdownHintColor;
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/inputs/field_sizing.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/helper/localized_date.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

bool chatDialogIsAr(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

void chatDialogToast(String msg) => Fluttertoast.showToast(
      msg: msg,
      backgroundColor: AppColors.primary,
      textColor: AppColors.textButton,
    );

/// Opens [child] in the app's dialog shell with the Figma radius.
Future<T?> showChatDialog<T>({
  required BuildContext context,
  required Widget child,
  required double width,
  double radius = 8,
}) {
  return CustomDialogManager.showContent<T>(
    context: context,
    width: width,
    padding: EdgeInsets.zero,
    borderRadius: BorderRadius.circular(radius.r),
    child: child,
  );
}

/// Dialog title: the app's header — a 30 yellow circle with the [icon], then
/// the title (`CustomDialogHeader`). CHANGED 20/10/2026 (owner: "we always
/// put the title and the circle"); was a centred title without an icon.
class ChatDialogTitle extends StatelessWidget {
  const ChatDialogTitle(this.text, {super.key, required this.icon});
  final String text;
  final String icon;

  @override
  Widget build(BuildContext context) =>
      CustomDialogHeader(title: text, icon: icon);
}

/// 12 Regular grey subtitle under the header (start-aligned like it).
class ChatDialogSubtitle extends StatelessWidget {
  const ChatDialogSubtitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.secondaryBlack,
        ),
      );
}

/// Header of the Contact / Poll dialogs: the app's circle header; an empty
/// [icon] shows the title alone (contact dialog: icon removed 17/10/2026).
/// CHANGED 20/10/2026: the badge is the round one of every dialog (was a
/// square).
class ChatDialogBadgeHeader extends StatelessWidget {
  const ChatDialogBadgeHeader({
    super.key,
    required this.icon,
    required this.title,
  });
  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (icon.isNotEmpty) return CustomDialogHeader(title: title, icon: icon);
    return Text(
      title,
      style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
    );
  }
}

/// Figma radio option: 16px ring, 5px gap, 14 Medium label — dark when
/// selected, grey otherwise. No hover / press highlight (owner 20/10/2026).
class ChatRadioOption<T> extends StatelessWidget {
  const ChatRadioOption({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  final T value;
  final T groupValue;
  final String label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool selected = value == groupValue;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => HapticController.low(),
      onTap: () => onChanged(value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Container(
              width: 16.r,
              height: 16.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.secondaryPrimary
                      : AppColors.secondaryBlack,
                  width: 1.5.r,
                ),
              ),
              child: selected
                  ? Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryPrimary,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style: StyleText.fontSize14Weight500.copyWith(
                color: selected ? AppColors.text : AppColors.secondaryBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cancel (grey) at the left edge, the primary (yellow) at the right edge,
/// same width, in both languages — the filter dialog's row (X-73). CHANGED
/// 20/10/2026 (owner: the two buttons were centred, so their gaps to the
/// dialog's edges did not match the dialog's padding).
class ChatDialogButtons extends StatelessWidget {
  const ChatDialogButtons({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.onCancel,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 130.w,
          child: customButton(
            title: s.cancel,
            haptic: HapticController.low,
            function: onCancel ?? () => Navigator.of(context).pop(),
            color: AppColors.secondaryAction,
            textStyle: StyleText.fontSize16Weight500
                .copyWith(color: AppColors.onSecondaryAction),
          ),
        ),
        SizedBox(
          width: 130.w,
          child: ShrinkOnTap(
            child: customButton(
              title: primaryLabel,
              haptic: HapticController.medium,
              function: onPrimary,
              color: AppColors.primary,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.textButton),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small label above a field (14 Medium).
class ChatFieldLabel extends StatelessWidget {
  const ChatFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(
          text,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
      );
}

/// Text field of the chat dialogs: the app's field colours (fill
/// `kDropdownFillColor`, hint `kDropdownHintColor`) — CHANGED 20/10/2026
/// (owner): it had the dialog's own colour, so it could not be seen.
class ChatTextField extends StatelessWidget {
  const ChatTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.radius = 4,
    this.height,
    this.prefix,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final double radius;
  final double? height;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final Widget field = TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: 1,
      onChanged: onChanged,
      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: kDropdownFillColor,
        hintText: hint,
        hintStyle: StyleText.fontSize12Weight400.copyWith(
          color: kDropdownHintColor,
        ),
        prefixIcon: prefix,
        prefixIconConstraints: BoxConstraints(minWidth: 32.w),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
    return height == null ? field : SizedBox(height: height, child: field);
  }
}

/// "Choose Date": the app's date field and calendar (`CustomDateField`,
/// today or later). CHANGED 20/10/2026 (owner: "choose the package of the
/// date picker right") — was the plain Material date picker.
class ChatDateField extends StatelessWidget {
  const ChatDateField({super.key, required this.value, required this.onPicked});
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    return CustomDateField(
      value: value,
      hint: S.of(context).chooseDate,
      disablePastDates: true,
      onChanged: (DateTime? d) {
        if (d != null) onPicked(d);
      },
    );
  }
}

/// "Choose Time": drawn like the date field next to it (36 high, the app's
/// field colours, clock at the end); opens the time picker every module uses.
/// Times read "09:00 AM". CHANGED 20/10/2026 (owner): "Time" capitalised,
/// field colours, no hover highlight.
class ChatTimeField extends StatelessWidget {
  const ChatTimeField({super.key, required this.value, required this.onPicked});
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onPicked;

  Future<void> _pick(BuildContext context) async {
    final TimeOfDay? t = await showKpTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
    );
    if (t != null) onPicked(t);
  }

  @override
  Widget build(BuildContext context) {
    final TimeOfDay? time = value;
    final String text = time == null
        ? S.of(context).chooseTime
        : LocalizedDate.of(
            context,
            DateTime(2000, 1, 1, time.hour, time.minute),
            pattern: 'hh:mm a',
          );
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () => _pick(context),
      child: Container(
        height: FieldSizing.height.sp,
        // The date field's insets, so both hints and icons line up.
        padding: EdgeInsetsDirectional.only(start: 16.sp, end: 14.sp),
        decoration: BoxDecoration(
          color: kDropdownFillColor,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: time == null ? kDropdownHintColor : AppColors.text,
                ),
              ),
            ),
            CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_time_clock.svg',
              width: 16.r,
              height: 16.r,
              fit: BoxFit.contain,
              color: kDropdownHintColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// Joins a picked date and time; null when either is missing.
DateTime? combineDateTime(DateTime? date, TimeOfDay? time) {
  if (date == null || time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
