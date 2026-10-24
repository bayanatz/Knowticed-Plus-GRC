/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: time_selector_preview_widget.dart
/// Description: `TimeSelectorPdfPreviewWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/time_selector_field_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';

/// The Time field on the Convert to PDF page.
///
/// Large-screen bug report p.3: it was two small blank boxes (60 and 36 wide)
/// with no placeholder, next to a full-width Date field. It now matches the
/// Date field beside it: a full-width box with an "HH : MM" placeholder and a
/// clock icon, plus an "AM / PM" box, so whoever fills the printed form in by
/// hand knows what goes where.
class TimeSelectorPdfPreviewWidget extends StatelessWidget {
  const TimeSelectorPdfPreviewWidget({super.key, required this.model});
  final TimeSelectorFieldModel model;

  @override
  Widget build(BuildContext context) {
    final TextStyle hintStyle =
        StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryBlack);
    final EdgeInsets contentPadding =
        EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and required indicator
        TextRequiredWidget(
          isRequired: _getIsRequired(),
          text: _getTitle(),
        ),
        verticalSpace(8), // #40: same title gap as every other field

        Row(
          children: [
            Expanded(
              child: CustomTextField(
                height: 36,
                enabled: false,
                readOnly: true,
                fillColor: AppColors.background,
                hint: S.of(context).fbTimeHint,
                hintStyle: hintStyle,
                contentPadding: contentPadding,
                suffixIcon: Padding(
                  padding: EdgeInsetsDirectional.only(end: 10.sp),
                  child: CustomSvgImage.natural(
                    assetPath: AppAssets.timeSelectorIcon,
                    width: 24.sp,
                    height: 24.sp,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                        AppColors.secondaryBlack, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            horizontalSpace(10),
            SizedBox(
              width: 90.sp,
              child: CustomTextField(
                height: 36,
                enabled: false,
                readOnly: true,
                fillColor: AppColors.background,
                hint: '${S.of(context).am} / ${S.of(context).pm}',
                hintStyle: hintStyle,
                textAlign: TextAlign.center,
                contentPadding: contentPadding,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _getIsRequired() {
    bool flag = false;
    flag = model.isRequired ?? false;
    return flag;
  }

  String _getTitle() {
    return model.title ?? '';
  }
}
