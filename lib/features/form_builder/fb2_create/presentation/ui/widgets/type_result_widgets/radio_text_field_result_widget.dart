/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: radio_text_field_result_widget.dart
/// Description: `RadioTextFieldResultWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/radio_text_field_model.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/validation/validator.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class RadioTextFieldResultWidget extends StatelessWidget {
  /// Constructor for RadioTextFieldResultWidget
  /// [index] represents the specific controller index
  /// [rowIndex] represents the row in the form
  /// [pageIndex] represents the page in the form
  const RadioTextFieldResultWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isWhiteFill = false,
    this.isReadOnly = false,
    this.onTapRadio,
    this.isShownError = false,
  });

  final RadioTextFieldController? fieldController;
  final RadioTextFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isShownError, isReadOnly;
  final void Function(String)? onTapRadio;

  @override
  Widget build(BuildContext context) {
    // Build the main widget container
    return _buildContainer(context);
  }

  /// Build the container with alignment and sizing
  Widget _buildContainer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _getWidgets(),
        ),
        verticalSpace(4),
        if (isShownError &&
            _isErrorNull(fieldController?.selectedRadio) == null)
          Text(
            _getError() ?? '',
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          )
      ],
    );
  }

  /// Build the radio button with text field
  Widget _buildRadioTextField(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTapDown: (_) => HapticController.low(),
                onTap: () {
                  onTapRadio?.call(text);
                },
                // Bug report p.13: the empty (26×26) and selected (16×16) SVGs were
                // drawn at their natural sizes, so a picked option shrank.
                child: CustomSvgImage.natural(
                    assetPath: _setImage(text),
                    width: 22,
                    height: 22,
                    colorFilter:
                        ColorFilter.mode(AppColors.text, BlendMode.srcIn)),
              ),
              horizontalSpace(5),
              // This was
              // Container > Flexible. A Flexible must be the direct child of
              // a Row/Column, so every frame threw "Incorrect use of
              // ParentDataWidget" — the lag — and the broken layout fed a
              // wrong height to the A4 overflow check, which kept adding
              // pages. Flexible now wraps the Container.
              Flexible(
                child: Container(
                  color: isWhiteFill ? AppColors.white : AppColors.background,
                  height: 36.sp, // form bug report #23
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    text,
                    style: StyleText.fontSize14Weight500,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _getWidgets() {
    List<Widget> widgets = [];
    if (reviewModel != null) {
      for (int i = 0; i < reviewModel!.hints.length; i++) {
        widgets.add(Expanded(
            child: Container(
          margin: const EdgeInsetsDirectional.only(bottom: 8.0, end: 8),
          child: _buildRadioTextField(reviewModel!.hints[i]),
        )));
      }
      return widgets;
    }
    for (int i = 0; i < fieldController!.hints.length; i++) {
      widgets.add(Expanded(
          child: Container(
        margin: EdgeInsetsDirectional.only(
            end: i == (fieldController!.hints.length - 1) ? 0 : 8),
        child: _buildRadioTextField(fieldController!.hints[i].text),
      )));
    }
    return widgets;
  }

  String _setImage(String text) {
    if (fieldController != null) {
      return fieldController!.selectedRadio == text
          ? AppAssets.radioSelected
          : AppAssets.radio;
    } else {
      return reviewModel!.selectedRadio == text
          ? AppAssets.radioSelected
          : AppAssets.radio;
    }
  }

  String? _isErrorNull(String? selectedRadio) {
    return selectedRadio == null || selectedRadio.isEmpty ? null : 'dasx';
  }

  String? _getError() {
    if (isValidated) {
      String? error = Validator.isEmpty(
          _isErrorNull(fieldController?.selectedRadio),
          S.current.fieldTypeRadioTextField);
      return error ?? '';
    }
    return null;
  }
}
