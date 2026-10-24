/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: phone_pdf_result_widget.dart
/// Description: `PhonePdfResultWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';

class PhonePdfResultWidget extends StatelessWidget {
  const PhonePdfResultWidget({
    super.key,
    required this.model,
    this.isExpand = false,
  });
  final bool isExpand;

  final PhoneFieldModel model;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: SizedBox(
        width: isExpand ? null : _calculateWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            verticalSpace(8),
            _buildPhoneInputRow(context),
          ],
        ),
      ),
    );
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context) {
    String? alignment = model.alignment;

    return alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  /// Build title widget based on alignment
  Widget _buildTitleWidget() {
    return TextRequiredWidget(isRequired: _getIsRequired(), text: _getTitle());
  }

  /// Build phone input row with country code selector and phone number field
  ///
  /// In a
  /// three-column row on a phone the column is ~70 wide, but the code box
  /// alone was 75 (50 + 2 × 10 padding + 5), so the number box was squeezed
  /// to a sliver beside it. When the column is narrow the "+" now sits inside
  /// the number box as a prefix — one field, full column width.
  static const double _kSplitMinWidth = 160;

  Widget _buildPhoneInputRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _kSplitMinWidth) {
          return Row(children: [_buildPhoneNumberField(withPrefix: true)]);
        }
        return Row(
          children: [
            _buildCountryCodeSelector(context),
            horizontalSpace(8),
            _buildPhoneNumberField(),
          ],
        );
      },
    );
  }

  /// Build country code selector container
  Widget _buildCountryCodeSelector(BuildContext context) {
    return Container(
      height: 36.sp, // #40: same scale as CustomTextField
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: _buildCountryCodeRow(),
      ),
    );
  }

  /// Build row with country flag, phone code, and dropdown arrow
  Row _buildCountryCodeRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          color: AppColors.background,
          child: Text(
            '+',
            style: StyleText.fontSize14Weight400.copyWith(
              backgroundColor: AppColors.transparent,
              color: AppColors.text,
            ),
          ),
        ),
        horizontalSpace(5),
      ],
    );
  }

  /// Build phone number input field
  Widget _buildPhoneNumberField({bool withPrefix = false}) {
    return Expanded(
      child: Container(
        height: 36.sp, // #40: same scale as CustomTextField
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            horizontalSpace(withPrefix ? 10 : 16),
            if (withPrefix) ...[
              Text(
                '+',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
              horizontalSpace(6),
            ],
            Expanded(
              child: CustomTextField(
                readOnly: true,
                keyboardType: TextInputType.phone,
                fillColor: AppColors.transparent,
                borderRadius: BorderRadius.zero,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 6.h,
                ),
                valueStyle: StyleText.fontSize14Weight400,
                hintStyle: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Alignment _getAlignment() {
    return model.alignment.alignment;
  }

  bool _getIsRequired() {
    bool flag = false;

    flag = model.isRequired;
    return flag;
  }

  String _getTitle() {
    return model.title;
  }
}
