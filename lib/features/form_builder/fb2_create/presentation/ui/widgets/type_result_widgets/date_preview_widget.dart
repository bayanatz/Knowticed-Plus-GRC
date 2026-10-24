/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: date_preview_widget.dart
/// Description: `DatePreviewWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
// CHANGED: was `3-custom_dropdwon_calander.dart`, the deprecated misspelled
// shim that does nothing but re-export this file. The shim's own header says
// it gets deleted once the last old-path import is gone — this was one.
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/date_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/date_field_model.dart';
import 'package:knowticed_plus/core/helper/validation/validator.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';

class DatePreviewWidget extends StatelessWidget {
  const DatePreviewWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isReadOnly = false,
    this.onDateChanged,
    this.isWhiteFill = false,
    this.isExpand = false,
    this.isShownError = true,
  });
  final bool isExpand;

  /// Whether the "required" error may be shown yet. (bug
  /// report p.11 — "don't show the required message until the user presses
  /// Submit"). The fill-out viewers pass their `isSubmitted`; defaults to
  /// true so every other caller is unchanged.
  final bool isShownError;
  final DateFieldController? fieldController;
  final DateFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;
  final Function(DateTime)? onDateChanged;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: SizedBox(
        width: (isExpand) ? null : _calculateWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextRequiredWidget(isRequired: _getIsRequired(), text: _getTitle()),
            verticalSpace(4),
            _buildTextField(),
          ],
        ),
      ),
    );
  }

  CustomDateField _buildTextField() {
    return CustomDateField(
      value: fieldController?.answerDate,
      fillColor: isWhiteFill ? AppColors.white : AppColors.background,
      hint: _getHint(),
      // form bug report #23: same height + padding as every other field.
      height: 36,
      contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp),
      enabled: !isReadOnly,
      errorText: _validationError(),
      dateFormatter: FormDateTimeHelper.formatDate,
      onChanged: (value) {
        if (value != null) {
          onDateChanged?.call(value);
        }
      },
    );
  }

  /// Mirrors the old validator: only complains when the field is validated,
  /// required and still empty.
  String? _validationError() {
    if (!isValidated || !isShownError) return null;
    if (!(fieldController?.isRequired ?? false)) return null;

    final String? answer = fieldController?.answerDate != null
        ? FormDateTimeHelper.formatDate(fieldController!.answerDate!)
        : null;

    return Validator.isEmpty(answer, 'Date');
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
}
