/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: text_field_result_widget.dart
/// Description: `TextFieldResultWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';

class TextFieldResultWidget extends StatelessWidget {
  const TextFieldResultWidget({
    super.key,
    this.reviewModel,
    this.fieldController,
    this.isValidated = false,
    this.isReadOnly = false,
    this.isWhiteFill = false,
    this.isExpand = false,
    this.onChanged,
  });
  final bool isExpand;
  final TextFieldController? fieldController;
  final TextFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;
  final dynamic Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: _buildFieldContainer(context),
    );
  }

  // Build the container with field details
  Widget _buildFieldContainer(BuildContext context) {
    return SizedBox(
      width: !isExpand ? _calculateWidth(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show required indicator
          TextRequiredWidget(isRequired: _getIsRequired(), text: _getTitle()),
          verticalSpace(4),
          _buildTextField(),
        ],
      ),
    );
  }

  // Calculate width based on alignment
  double _calculateWidth(BuildContext context) {
    String? alignment = fieldController != null
        ? fieldController!.alignment
        : reviewModel!.alignment;

    return alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  // Build the text form field
  Widget _buildTextField() {
    return CustomTextField(
      height: 36,
      readOnly: isReadOnly,
      initialValue: _getInitialValue(),
      onChanged: onChanged,
      hint: _getHint(),
      contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp),
      fillColor: isWhiteFill ? AppColors.white : AppColors.background,
      width: double.infinity,
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

  String _getHint() {
    if (reviewModel != null) {
      return reviewModel?.hint ?? '';
    }
    return fieldController?.hint?.text ?? '';
  }

  Alignment _getAlignment() {
    if (reviewModel == null) {
      return fieldController!.alignment!.alignment;
    }

    return reviewModel!.alignment.alignment;
  }

  String? _getInitialValue() {
    if (fieldController != null) {
      return fieldController!.answer;
    }

    return null;
  }
}
