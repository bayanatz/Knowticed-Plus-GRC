import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/titles_row.dart';

class QiyasVisionDetailsContainerMobile extends StatelessWidget {
  const QiyasVisionDetailsContainerMobile(
      {super.key, required this.visionNumber, required this.visionValues});
  final String visionNumber;
  final List<dynamic> visionValues;

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      children: [
        SizedBox(
            height: 30,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                  color: AppTheme.isDark
                      ? AppColors.secondaryButton
                      : AppColors.text,
                  borderRadius: BorderRadius.circular(4)),
              child: Center(
                child: Text(visionNumber,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: AppColors.card)),
              ),
            )),
        SizedBox(height: 10.sp),
        SizedBox(
            width: double.infinity,
            height: 30,
            child: Container(
              padding: EdgeInsets.all(5.sp),
              decoration: BoxDecoration(
                  color: AppColors.secondaryPrimary,
                  borderRadius: BorderRadius.circular(4)),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isPortrait ? 0.01.w : 0.01.h),
                child: FittedBox(
                  child: Text(visionValues[0],
                      style: StyleText.fontSize14Weight600.copyWith(
                          color: AppColors.secondaryPrimaryText, height: 1.3)),
                ),
              ),
            )),
        SizedBox(
          height: 15.sp,
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: titlesRow.length,
          itemBuilder: (context, index) {
            return index == 0
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      SizedBox(
                          height: 30.sp,
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4)),
                            child: Center(
                              child: Text(titlesRow[index],
                                  style: StyleText.fontSize14Weight600
                                      .copyWith(color: AppColors.textButton)),
                            ),
                          )),
                      SizedBox(height: 10.sp),
                      SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            padding: EdgeInsets.all(10.sp),
                            decoration: BoxDecoration(
                                color: index == 0
                                    ? AppColors.primary
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(
                                visionValues[index] == null ||
                                        visionValues[index] == ""
                                    ? "غير متوفر"
                                    : visionValues[index],
                                style: StyleText.fontSize14Weight500
                                    .copyWith(color: AppColors.secondaryBlack)
                                    .copyWith(height: 1.6)),
                          )),
                      SizedBox(height: 15.sp),
                    ],
                  );
          },
        ),
      ],
    );
  }
}
