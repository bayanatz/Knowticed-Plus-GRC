/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: description_result_widget.dart
/// Description: `DescriptionResultWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/description_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/description_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/helper/extensions.dart'
    hide ContextExtension;
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/field_text_binder.dart';

class DescriptionResultWidget extends StatelessWidget {
  const DescriptionResultWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isReadOnly = false,
    this.isWhiteFill = false,
    this.isExpand = false,
  });

  final bool isExpand; // Not used in this widget, can be removed
  final DescriptionFieldController? fieldController;
  final DescriptionFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: SizedBox(
        width: isExpand ? null : _calculateWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextRequiredWidget(isRequired: _getIsRequired(), text: _getTitle()),
            verticalSpace(4),
            _buildDescriptionTextField(context),
          ],
        ),
      ),
    );
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context) {
    String? alignment = fieldController != null
        ? fieldController!.alignment
        : reviewModel!.alignment;

    return alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  Alignment _getAlignment() {
    if (reviewModel == null) {
      return fieldController!.alignment!.alignment;
    }
    return reviewModel!.alignment.alignment;
  }

  /// Build description text input field
  Widget _buildDescriptionTextField(BuildContext context) {
    final FieldText? answer = fieldController?.answerController;
    if (answer == null) return _descriptionInput(null);
    return FieldTextBinder(
      text: answer,
      builder: (context, textController) => _descriptionInput(textController),
    );
  }

  /// The answer input, bound to [controller] (null: an internal one).
  Widget _descriptionInput(TextEditingController? controller) {
    return CustomTextField(
      minLines: 4,
      maxLines: 10,
      readOnly: isReadOnly,
      controller: controller,
      hint: _getHint(),
      maxLength: _getMaxLength(),
      showCharCount: true,
      fillColor: isWhiteFill ? AppColors.white : AppColors.background,
      contentPadding: const EdgeInsetsDirectional.only(
        top: 7,
        bottom: 7,
        start: 9,
        end: 9,
      ),
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

  int _getMaxLength() {
    if (reviewModel != null) {
      int number = reviewModel?.limitation.toEnglishNumber() == 0
          ? 1
          : reviewModel?.limitation.toEnglishNumber() ?? 1;
      return number;
    }
    int number = fieldController?.limitation?.text.toEnglishNumber() == 0
        ? 1
        : fieldController?.limitation?.text.toEnglishNumber() ?? 1;

    return number;
  }
}
