/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: terms_preview.dart
/// Description: `TermsAndConditionsPdfPreviewWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/terms_and_condition.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

// Purpose: PDF preview widget for Terms and Conditions field

/// PDF Preview widget for Terms and Conditions field
///
/// This widget is used specifically for PDF generation.
/// It displays the T&C title, terms text, and acceptance status
/// in a format suitable for PDF export.
/// UI matches TermsAndConditionsPreviewWidget for consistency.
class TermsAndConditionsPdfPreviewWidget extends StatelessWidget {
  final TermsAndConditionsFieldModel model;

  const TermsAndConditionsPdfPreviewWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    // Show every language that has
    // text — Arabic only, English only, or both — not one picked by locale.
    final String termsEn = model.termsEn.trim();
    final String termsAr = model.termsAr.trim();
    final bool hasAnyTerms = termsEn.isNotEmpty || termsAr.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15), // Match preview widget padding
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8), // Match preview widget radius
      ),
      child: Column(
        crossAxisAlignment: _getCrossAxisAlignment(),
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          if (model.title.isNotEmpty) ...[
            Text(
              model.title,
              style:
                  StyleText.fontSize16Weight500, // Match preview widget style
              textAlign: _getTextAlignment(),
            ),
            verticalSpace(12), // Match preview widget spacing
          ],

          // Terms Text Container
          _buildTermsBox(context, termsEn, termsAr, hasAnyTerms),

          verticalSpace(12), // Match preview widget spacing
          // Acceptance Status - Using CustomCheckBox for consistency
          Row(
            children: [
              CustomCheckBox(
                isSelected:
                    model.isAccepted ??
                    false, // Use CustomCheckBox like preview widget
                borderColor: AppColors.text,
              ),
              horizontalSpace(8), // Match preview widget spacing
              Expanded(
                child: Text(
                  S.of(context).iAgreeToThePrivacyPolicyAndTermsAndConditions,
                  style: StyleText
                      .fontSize14Weight400, // Match preview widget style
                ),
              ),
            ],
          ),

          if (model.isAccepted != null) ...[
            verticalSpace(8),
            _buildAcceptedChip(context),
          ],
        ],
      ),
    );
  }

  /// The terms text box (every language that has text).
  Widget _buildTermsBox(
    BuildContext context,
    String termsEn,
    String termsAr,
    bool hasAnyTerms,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12), // Match preview widget padding
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6), // Match preview widget radius
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      constraints: const BoxConstraints(
        minHeight: 100, // Match preview widget constraints
        maxHeight: 200,
      ),
      child: SingleChildScrollView(
        // Add scroll like preview widget
        child: !hasAnyTerms
            ? Text(
                S.of(context).fieldTypeTermsAndCondition,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text.withValues(alpha: 0.4),
                  height: 1.5,
                ),
                textAlign: TextAlign.start,
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

  /// The Accepted / Not accepted chip.
  Widget _buildAcceptedChip(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: model.isAccepted == true
              ? AppColors.green.withValues(alpha: 0.1)
              : AppColors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              model.isAccepted == true ? Icons.check_circle : Icons.cancel,
              size: 12,
              color: model.isAccepted == true ? AppColors.green : AppColors.red,
            ),
            horizontalSpace(4),
            Text(
              model.isAccepted == true
                  ? S.of(context).accepted
                  : S.of(context).notAccepted,
              style: StyleText.fontSize12Weight400.copyWith(
                color: model.isAccepted == true
                    ? AppColors.green
                    : AppColors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get cross axis alignment based on field configuration
  CrossAxisAlignment _getCrossAxisAlignment() {
    switch (model.alignment) {
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
    switch (model.alignment) {
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

  /// One language's terms in that language's direction (Arabic RTL).
  Widget _termsText(String text, {required bool isArabicText}) {
    return Text(
      text,
      textDirection: isArabicText ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      textAlign: isArabicText ? TextAlign.right : TextAlign.left,
      style: StyleText.fontSize14Weight400.copyWith(
        color: AppColors.text,
        height: 1.5,
      ),
    );
  }
}
