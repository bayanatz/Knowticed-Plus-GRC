/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: title_result_widget.dart
/// Description: `TitleResultWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/title_field_model.dart';
import 'package:knowticed_plus/core/helper/extensions.dart';

class TitleResultWidget extends StatelessWidget {
  const TitleResultWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isWhiteFill = false,
  });
  final TitleFieldController? fieldController;
  final TitleFieldModel? reviewModel;
  final bool isValidated, isWhiteFill;
  @override
  Widget build(BuildContext context) {
    // Align the text based on the selected alignment
    return Align(alignment: _getAlignment(), child: _buildText());
  }

  // Build the text with custom styling
  Widget _buildText() {
    return Text(
      // Use empty string if title is null
      _getText(),
      // The app text style, with the size and decoration picked in the editor.
      style: StyleText.fontSize14Weight400.copyWith(
        // Apply selected text color
        color: _getTextColor(),
        // Parse and apply text size
        fontSize: _parseTextSize(),
        // Apply bold styling
        fontWeight: _getFontWeight(),
        // Apply underline decoration
        decoration: _getDecoration(),
        // Use same color for decoration
        decorationColor: _getTextColor(),
        // Apply italic styling
        fontStyle: _getFontStyle(),
      ),
    );
  }

  // Safely parse text size, returning a default if parsing fails
  double _parseTextSize() {
    if (reviewModel != null) {
      return reviewModel?.textSize ?? 14;
    }
    return fieldController?.textSize?.text.toEnglishNumberAsDouble() ?? 14;
  }

  // Determine font weight based on bold setting
  FontWeight _getFontWeight() {
    if (reviewModel != null) {
      return reviewModel?.isBold ?? false ? FontWeight.bold : FontWeight.normal;
    }
    return fieldController?.isBold ?? false
        ? FontWeight.bold
        : FontWeight.normal;
  }

  // Determine text decoration based on underline setting
  TextDecoration _getDecoration() {
    if (reviewModel != null) {
      return reviewModel?.isUnderLine ?? false
          ? TextDecoration.underline
          : TextDecoration.none;
    }
    return fieldController?.isUnderLine ?? false
        ? TextDecoration.underline
        : TextDecoration.none;
  }

  // Determine font style based on italic setting
  FontStyle _getFontStyle() {
    if (reviewModel != null) {
      return reviewModel?.isItalic ?? false
          ? FontStyle.italic
          : FontStyle.normal;
    }
    return fieldController?.isItalic ?? false
        ? FontStyle.italic
        : FontStyle.normal;
  }

  Alignment _getAlignment() {
    if (reviewModel == null) {
      return fieldController!.alignment!.alignment;
    }
    return reviewModel!.alignment.alignment;
  }

  String _getText() {
    if (reviewModel != null) {
      return reviewModel?.title ?? '';
    }
    return fieldController?.title?.text ?? '';
  }

  Color? _getTextColor() {
    if (reviewModel != null) {
      return reviewModel?.titleColor.toColor();
    }

    return fieldController?.titleColor ?? AppColors.black;
  }
}
