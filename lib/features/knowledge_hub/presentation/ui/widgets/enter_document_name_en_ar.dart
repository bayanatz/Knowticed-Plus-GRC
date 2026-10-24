/// Module: knowledge_hub/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: enter_document_name_en_ar.dart
/// Description: `enterDocumentNameEnAr()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'dart:ui' as ui;

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';

Widget enterDocumentNameEnAr(
  BuildContext context, {
  required TextEditingController englishController,
  required TextEditingController arabicController,
  required GlobalKey<FormState> documentNameKey,
  required void Function(String)? onChanged,
  required void Function(String)? onArabicChanged,
}) {
  final isMobile = ContextExtension(context).isPhone;

  final englishField = Directionality(
    textDirection: ui.TextDirection.ltr,
    child: CustomTextField(
      label: S.of(context).khEnglishDocumentName,
      hint: S.of(context).textHere,
      controller: englishController,
      height: 36,
      // English field takes English only. CustomTextField's
      // built-in script guard refuses any edit that ADDS an Arabic character
      // (typed or pasted) and shows "Please use English characters only." when a
      // value loaded from Firestore already contains one. Digits, punctuation
      // and symbols are untouched: the rule is about SCRIPT, not about marks.
      restrictByDirection: true,
      onChanged: (value) {
        // ✅ Apply capitalization before calling the original callback
        final capitalizedValue = FormatHelper.capitalize(value);
        if (capitalizedValue != value) {
          englishController.value = TextEditingValue(
            text: capitalizedValue,
            selection: TextSelection.collapsed(offset: capitalizedValue.length),
          );
        }
        onChanged?.call(capitalizedValue);
      },
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
      fillColor: AppColors.background,
    ),
  );

  final arabicField = Directionality(
    textDirection: ui.TextDirection.rtl,
    child: CustomTextField(
      label: S.of(context).khArabicDocumentName,
      hint: S.of(context).khWriteHere,
      controller: arabicController,
      textDirection: ui.TextDirection.rtl,
      textAlign: TextAlign.right,
      height: 36,
      // mirror of the English field: Arabic only, enforced by
      // the same guard reading textDirection: rtl blocks `[a-zA-Z]`.
      restrictByDirection: true,
      onChanged: (value) {
        // ✅ Apply capitalization for Arabic text too
        final capitalizedValue = FormatHelper.capitalize(value);
        if (capitalizedValue != value) {
          arabicController.value = TextEditingValue(
            text: capitalizedValue,
            selection: TextSelection.collapsed(offset: capitalizedValue.length),
          );
        }
        onArabicChanged?.call(capitalizedValue);
      },
      fillColor: AppColors.background,
    ),
  );

  // The field in the UI language comes first.
  final List<Widget> fields = KhLocale.uiLanguageFirst(
    context,
    en: englishField,
    ar: arabicField,
  );

  return Form(
    key: documentNameKey,
    child: isMobile
        ? Column(
            children: [
              fields.first,
              SizedBox(height: 10.h),
              fields.last,
            ],
          )
        : Row(
            children: [
              Expanded(child: fields.first),
              SizedBox(width: 15.w),
              Expanded(child: fields.last),
            ],
          ),
  );
}
