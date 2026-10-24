/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: time_selector_preview_widget.dart
/// Description: `TimeSelectorPreviewWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/helpers/text_in_language.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_time_picker.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_form_language.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/time_selector_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class TimeSelectorPreviewWidget extends StatelessWidget {
  const TimeSelectorPreviewWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isReadOnly = false,
    this.isWhiteFill = false,
    this.onTapZone,
    this.onTapTime,
  });
  final TimeSelectorFieldController? fieldController;
  final TimeSelectorFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;
  final void Function()? onTapZone;
  final void Function(TimeOfDay)? onTapTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and required indicator
        TextRequiredWidget(isRequired: _getIsRequired(), text: _getTitle()),
        verticalSpace(4),
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // (vertical bug report p.9 / p.10 — "when
              // there are 2 in a row give this full width"): the time box was
              // a fixed 70 wide with an empty flex-2 spacer after AM, so next
              // to a date field it filled barely a third of its column. It
              // now takes all the width AM leaves it.
              Expanded(
                child: GestureDetector(
                  onTapDown: isReadOnly ? null : (_) => HapticController.low(),
                  onTap: isReadOnly ? null : () => _pickTime(context),
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomTextField(
                      enabled: false,
                      height: 36,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.sp,
                        horizontal: 10.sp,
                      ), // form bug report #23
                      hint: fieldController?.time ?? _getHint(),
                      // Same placeholder grey as every other field's hint (bug report p.9
                      // "make the hints same color"); a picked time keeps the text colour.
                      hintStyle: StyleText.fontSize12Weight400.copyWith(
                        color: fieldController?.time != null
                            ? AppColors.text
                            : AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      fillColor: isWhiteFill
                          ? AppColors.white
                          : AppColors.background,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              horizontalSpace(10),

              GestureDetector(
                onTapDown: hapticDown(onTapZone, HapticLevel.low),
                onTap: onTapZone,
                child: Container(
                  height: 36
                      .sp, // form bug report #23: same scale as CustomTextField
                  width: 36.w,
                  decoration: BoxDecoration(
                    color: isWhiteFill ? AppColors.white : AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.center,
                    // Localized 13/10/2026 (bug report p.10): "AM" /
                    // "PM" in the form's language. The stored value stays
                    // the English 'AM' / 'PM' the cubit expects.
                    child: Text(
                      _amPmLabel(
                        context,
                        isValidated ? (fieldController?.amOrPM ?? 'AM') : 'AM',
                      ),
                      style: StyleText.fontSize12Weight400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Opens the time picker in the form's language and reports the pick.
  void _pickTime(BuildContext context) {
    // The picker speaks the FORM's language (bug report
    // p.24), not the app's — see FormLanguageScope.
    final bool formIsArabic = FormLanguageScope.isArabicOf(context);
    final Locale appLocale = Localizations.localeOf(context);
    showKpTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // Bug report p.15 ("white color"): no local
        // Theme override any more. It set the colour
        // scheme's `surface` to the yellow primary, which
        // painted the dial and the hour/minute boxes
        // yellow with dark digits. The picker now uses
        // the app theme, the same one the Role
        // Management time pickers use.
        return Localizations.override(
          context: context,
          locale: Locale(formIsArabic ? 'ar' : 'en'),
          child: Directionality(
            textDirection: formIsArabic
                ? ui.TextDirection.rtl
                : ui.TextDirection.ltr,
            child: child!,
          ),
        );
      },
    ).then((value) {
      // `Localizations.override` re-loads every
      // inherited delegate for the override locale —
      // `S.delegate` included — and `S.load` rewrites
      // the app-wide `S.current` / `Intl.defaultLocale`.
      // Put the APP language back now the picker is
      // closed (see the note in head_form_fields.dart).
      S.load(appLocale);
      if (value != null) {
        // Convert TimeOfDay to formatted string
        if (context.mounted) value.format(context);

        onTapTime?.call(value);
      }
    });
  }

  String _amPmLabel(BuildContext context, String value) {
    final bool isPm = value.toUpperCase() == 'PM';
    // The AM/PM marks follow the FORM's language, from the translation files.
    return textInFormLanguage(
      FormLanguageScope.isArabicOf(context),
      (s) => isPm ? s.pm : s.am,
    );
  }

  bool _getIsRequired() {
    bool flag = false;
    if (reviewModel != null) {
      flag = reviewModel?.isRequired ?? false;
      return flag;
    }
    flag = fieldController?.isRequired ?? false;
    return flag;
  }

  String _getTitle() {
    if (reviewModel != null) {
      return reviewModel?.title ?? '';
    }
    return fieldController?.title?.text ?? '';
  }

  // Bug report p.14: was "0 0 : 0 0" (with spaces), which did not fit the
  // 70-wide box and showed as "00:...". Now the plain "00:00".
  String _getHint() => '00:00';
}
