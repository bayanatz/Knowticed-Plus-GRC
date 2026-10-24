/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: date_pdf_preview_widget.dart
/// Description: `DatePdfPreviewPdfWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/date_field_model.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';

class DatePdfPreviewPdfWidget extends StatelessWidget {
  const DatePdfPreviewPdfWidget({
    super.key,
    required this.model,
    this.isExpand = false,
  });
  final DateFieldModel model;
  final bool isExpand; // Not used in this widget, can be removed
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: model.alignment.alignment,
      child: SizedBox(
        width: (isExpand) ? null : _calculateWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextRequiredWidget(isRequired: model.isRequired, text: model.title),
            // Bug report p.8: same 8 gap as the other fields in the row.
            SizedBox(height: 8.h),
            _buildDateWidget(context),
          ],
        ),
      ),
    );
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context) {
    return model.alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  Widget _buildDateWidget(BuildContext context) {
    return CustomTextField(
      height: 36,
      enabled: false,
      fillColor: AppColors.background,
      readOnly: true,
      // Bug report p.8: was a row of bare backslashes. A readable
      // placeholder for the person filling the printed form in by hand.
      hint: S.of(context).fbDateHint,
      suffixIcon: Padding(
        padding: EdgeInsetsDirectional.only(end: 10.sp),
        // Bug report p.62 ("too small"): 18 -> 24.
        child: CustomSvgImage.natural(
          assetPath: AppAssets.calendar,
          width: 24.sp,
          height: 24.sp,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            AppColors.secondaryBlack,
            BlendMode.srcIn,
          ),
        ),
      ),
      hintStyle: StyleText.fontSize12Weight500.copyWith(
        color: AppColors.secondaryBlack,
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 12.sp,
        horizontal: 10.sp,
      ), // #40
    );
  }
}
