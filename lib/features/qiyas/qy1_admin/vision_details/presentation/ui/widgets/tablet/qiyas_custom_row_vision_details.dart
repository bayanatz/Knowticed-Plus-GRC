/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_custom_row_vision_details.dart
/// Purpose: Displays a custom row of vision details for the Qiyas document, showing various attributes such as goals, requirements, and related documents.
///          This widget adapts to both pages and mobile screen sizes and handles text that contains special syntax (e.g., text between dollar signs).
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget is designed to display the details of vision-related data in a dynamic row format. It is optimized for responsiveness, adjusting to pages and mobile screen sizes.
///              Special handling is provided for text containing custom syntax (i.e., text between dollar signs) for special formatting.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/titles_row.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/vision_details/presentation/ui/widgets/mobile/qiyas_vision_details_container_mobile.dart';

class QiyasCustomRowVisionDetails extends StatelessWidget {
  const QiyasCustomRowVisionDetails(
      {super.key, required this.visionNumber, required this.visionValues});

  final String visionNumber;
  final List<dynamic> visionValues;

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Row(
      children: [
        Expanded(
          child: isTablet
              ? ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: titlesRow.length,
                  itemBuilder: (context, index) {
                    final regex = RegExp(r'\$(.*?)\$', dotAll: true);
                    regex.allMatches(
                      visionValues[index] == null || visionValues[index] == ""
                          ? "غير متوفر"
                          : visionValues[index],
                    );
                    return Column(
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 110.sp,
                                padding: EdgeInsets.all(10.sp),
                                decoration: BoxDecoration(
                                    color: index == 0
                                        ? AppTheme.isDark
                                            ? AppColors.secondaryButton
                                            : AppColors.text
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                          index == 0
                                              ? visionNumber
                                              : titlesRow[index],
                                          textAlign: TextAlign.center,
                                          style: StyleText.fontSize16Weight500
                                              .copyWith(
                                                  color: (index == 0)
                                                      ? AppTheme.isDark
                                                          ? AppColors.black
                                                          : AppColors.white
                                                      : AppColors.textButton)),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10.sp),
                              Expanded(
                                child: SizedBox(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      color: index == 0
                                          ? AppColors.secondaryPrimary
                                          : AppColors.card,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isPortrait ? 0.01.w : 0.01.h,
                                      vertical:
                                          isPortrait ? 0.0065.w : 0.0065.h,
                                    ),
                                    child: Text(
                                        visionValues[index] == null ||
                                                visionValues[index] == ""
                                            ? "غير متوفر"
                                            : visionValues[index],
                                        maxLines: 30,
                                        overflow: TextOverflow.ellipsis,
                                        style: StyleText.fontSize12Weight500
                                            .copyWith(
                                                color: AppColors.secondaryBlack)
                                            .copyWith(
                                                height: 2.5,
                                                color: index == 0
                                                    ? AppColors
                                                        .secondaryPrimaryText
                                                    : AppColors.secondaryText)),
                                  ),
                                )),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.sp,
                        ),
                      ],
                    );
                  },
                )
              : QiyasVisionDetailsContainerMobile(
                  visionNumber: visionNumber,
                  visionValues: visionValues,
                ),
        ),
      ],
    );
  }
}
