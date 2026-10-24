/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: text_required_widget.dart
/// Description: `TextRequiredWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

class TextRequiredWidget extends StatelessWidget {
  const TextRequiredWidget(
      {super.key, required this.isRequired, required this.text});

  /// Indicates if the text is required.
  final bool isRequired;

  /// The main text to be displayed.
  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: StyleText.fontSize14Weight400,
        children: [
          _buildMainText(),
          if (isRequired) _buildRequiredIndicator(),
        ],
      ),
    );
  }

  /// Builds the main text span.
  TextSpan _buildMainText() {
    return TextSpan(text: text);
  }

  /// Builds the required indicator text span.
  TextSpan _buildRequiredIndicator() {
    return TextSpan(
      text: ' *',
      style: StyleText.fontSize14Weight400.copyWith(
        color: AppColors.red,
      ),
    );
  }
}
