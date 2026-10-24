/// Module: knowledge_hub/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: document_desc_en_ar.dart
/// Description: `documentDescNameEnAr()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';

Widget documentDescNameEnAr(
  BuildContext context, {
  required TextEditingController englishDescController,
  required TextEditingController arabicDescController,
  required GlobalKey<FormState> documentDescriptionFormKey,
  required void Function(String)? onChanged,
  required void Function(String)? onArabicChanged,
  bool submitted = false,
}) {
  final englishField = Directionality(
    textDirection: ui.TextDirection.ltr,
    child: CustomTextField(
      label: S.of(context).khEnglishDocumentDescription,
      hint: S.of(context).textHere,
      hintStyle: StyleText.fontSize12Weight400.copyWith(
        color: AppColors.secondaryText,
      ),
      controller: englishDescController,
      height: 72,
      textDirection: ui.TextDirection.ltr,
      showCharCount: true,
      maxLines: 3,
      // English description takes English only. The built-in
      // script guard refuses any edit that ADDS an Arabic character (typed or
      // pasted); digits, punctuation and symbols still pass, so a normal
      // sentence's full stops and brackets are never flagged.
      restrictByDirection: true,
      onChanged: (value) {
        // ✅ Apply capitalization
        final capitalizedValue = FormatHelper.capitalize(value);
        if (capitalizedValue != value) {
          englishDescController.value = TextEditingValue(
            text: capitalizedValue,
            selection: TextSelection.collapsed(offset: capitalizedValue.length),
          );
        }
        onChanged?.call(capitalizedValue);
      },
      submitted: submitted,
      fillColor: AppColors.background,
    ),
  );

  final arabicField = Directionality(
    textDirection: ui.TextDirection.rtl,
    child: CustomTextField(
      label: S.of(context).khArabicDocumentDescription,
      hint: S.of(context).khWriteHere,
      hintStyle: StyleText.fontSize12Weight400.copyWith(
        color: AppColors.secondaryText,
      ),
      controller: arabicDescController,
      textDirection: ui.TextDirection.rtl,
      textAlign: TextAlign.right,
      height: 72,
      showCharCount: true,
      maxLines: 3,
      // mirror of the English description: Arabic only,
      // `[a-zA-Z]` blocked, punctuation and numbers left alone.
      restrictByDirection: true,
      onChanged: (value) {
        // ✅ Apply capitalization
        final capitalizedValue = FormatHelper.capitalize(value);
        if (capitalizedValue != value) {
          arabicDescController.value = TextEditingValue(
            text: capitalizedValue,
            selection: TextSelection.collapsed(offset: capitalizedValue.length),
          );
        }
        onArabicChanged?.call(capitalizedValue);
      },
      submitted: submitted,
      fillColor: AppColors.background,
    ),
  );

  final List<Widget> fields = KhLocale.uiLanguageFirst(
    context,
    en: englishField,
    ar: arabicField,
  );

  return Form(
    key: documentDescriptionFormKey,
    child: Column(
      // The field in the UI language comes first.
      children: [fields.first, SizedBox(height: 15), fields.last],
    ),
  );
}
