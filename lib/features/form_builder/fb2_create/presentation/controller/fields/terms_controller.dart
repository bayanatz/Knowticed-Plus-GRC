/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: terms_controller.dart
/// Description: `TermsAndConditionsPreviewWidget` widget, state and UI of the `TermsAndConditionsPreviewWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/helpers/text_in_language.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/terms_conditions_field_controller.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Preview widget for Terms and Conditions field
///
/// Displays:
/// - Title (aligned based on configuration)
/// - Terms and conditions text (based on current locale)
/// - Acceptance checkbox (always required)
class TermsAndConditionsPreviewWidget extends StatefulWidget {
  final bool isReadOnly;
  final TermsConditionsFieldController fieldController;

  const TermsAndConditionsPreviewWidget({
    super.key,
    required this.isReadOnly,
    required this.fieldController,
  });

  @override
  State<TermsAndConditionsPreviewWidget> createState() =>
      _TermsAndConditionsPreviewWidgetState();
}

class _TermsAndConditionsPreviewWidgetState
    extends State<TermsAndConditionsPreviewWidget> {
  @override
  Widget build(BuildContext context) {
    // The box
    // used to show ONE language, picked by the app locale, so terms written
    // only in Arabic showed the empty English placeholder. It now shows every
    // language that has text: Arabic only -> Arabic, English only ->
    // English, both -> both.
    final String termsEn = (widget.fieldController.termsEn?.text ?? '').trim();
    final String termsAr = (widget.fieldController.termsAr?.text ?? '').trim();
    final bool hasAnyTerms = termsEn.isNotEmpty || termsAr.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: _getCrossAxisAlignment(),
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          if (widget.fieldController.title?.text.isNotEmpty ?? false) ...[
            Text(
              widget.fieldController.title!.text,
              style: StyleText.fontSize16Weight500,
              textAlign: _getTextAlignment(),
            ),
            verticalSpace(12),
          ],

          // Terms and Conditions Text Container
          _buildTermsBox(termsEn, termsAr, hasAnyTerms),

          verticalSpace(12),

          // Acceptance Checkbox
          _buildAcceptance(context),
        ],
      ),
    );
  }

  /// The terms text box (every language that has text).
  Widget _buildTermsBox(String termsEn, String termsAr, bool hasAnyTerms) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      constraints: const BoxConstraints(minHeight: 100, maxHeight: 200),
      child: SingleChildScrollView(
        // Large-screen bug report p.5 ("where is the Arabic"): with
        // nothing typed yet the box showed only the English
        // placeholder, so the Arabic box looked like it was not wired
        // to the preview. The empty box now shows both placeholders,
        // each in its own direction, like the filled box does.
        child: !hasAnyTerms
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _termsText(
                    textInLanguage('en', (s) => s.fieldTypeTermsAndCondition),
                    isArabicText: false,
                    isPlaceholder: true,
                  ),
                  verticalSpace(8),
                  _termsText(
                    textInLanguage('ar', (s) => s.fieldTypeTermsAndCondition),
                    isArabicText: true,
                    isPlaceholder: true,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (termsEn.isNotEmpty)
                    _termsText(termsEn, isArabicText: false),
                  if (termsEn.isNotEmpty && termsAr.isNotEmpty) ...[
                    verticalSpace(8),
                    Divider(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.2),
                    ),
                    verticalSpace(8),
                  ],
                  if (termsAr.isNotEmpty)
                    _termsText(termsAr, isArabicText: true),
                ],
              ),
      ),
    );
  }

  /// The acceptance check box.
  Widget _buildAcceptance(BuildContext context) {
    return InkWell(
      onTapDown: widget.isReadOnly ? null : (_) => HapticController.low(),
      onTap: widget.isReadOnly
          ? null
          : () {
              setState(() {
                widget.fieldController.isAccepted =
                    !widget.fieldController.isAccepted;
              });
            },
      child: Row(
        children: [
          CustomCheckBox(
            isSelected: widget.fieldController.isAccepted,
            borderColor: AppColors.text,
          ),
          horizontalSpace(8.w),
          Expanded(
            child: Text(
              S.of(context).iAgreeToThePrivacyPolicyAndTermsAndConditions,
              style: StyleText.fontSize14Weight400,
            ),
          ),
        ],
      ),
    );
  }

  /// One language's terms, laid out in that language's direction — Arabic
  /// right-to-left and right-aligned, English left-to-right — whatever the
  /// app language is.
  Widget _termsText(
    String text, {
    required bool isArabicText,
    bool isPlaceholder = false,
  }) {
    return Text(
      text,
      textDirection: isArabicText ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      textAlign: isArabicText ? TextAlign.right : TextAlign.left,
      style: StyleText.fontSize14Weight400.copyWith(
        color: isPlaceholder
            ? AppColors.text.withValues(alpha: 0.4)
            : AppColors.text,
        height: 1.5,
      ),
    );
  }

  /// Get cross axis alignment based on field configuration
  CrossAxisAlignment _getCrossAxisAlignment() {
    final alignment = widget.fieldController.alignment;
    switch (alignment) {
      case 'Left':
        return CrossAxisAlignment.start;
      case 'Right':
        return CrossAxisAlignment.end;
      case 'Center':
        return CrossAxisAlignment.center;
      case 'Expand':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.center;
    }
  }

  /// Get text alignment based on field configuration
  TextAlign _getTextAlignment() {
    final alignment = widget.fieldController.alignment;
    switch (alignment) {
      case 'Left':
        return TextAlign.left;
      case 'Right':
        return TextAlign.right;
      case 'Center':
        return TextAlign.center;
      case 'Expand':
        return TextAlign.justify;
      default:
        return TextAlign.center;
    }
  }
}
