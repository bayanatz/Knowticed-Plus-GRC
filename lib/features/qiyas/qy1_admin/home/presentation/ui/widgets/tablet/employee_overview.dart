import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/qiyas/helpers/constant/qiyas_person_entity.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/main_helper/format_helper.dart';

class EmployeeOverview extends StatelessWidget {
  const EmployeeOverview({required this.personEntity, super.key});
  final QiyasPersonEntity personEntity;
  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.card,
        ),
        child: Padding(
          padding: EdgeInsets.all(10.sp),
          child: Row(
            children: [
              // ✅ FIX: Use ClipOval for proper circular SVG display
              ClipOval(
                child: Container(
                  width: isTablet ? 50.sp : 50.sp,
                  height: isTablet ? 50.sp : 50.sp,
                  color: AppColors.primary
                      .withValues(alpha: 0.1), // Optional background
                  child: CustomSvgImage(
                    assetPath:
                        "assets/icons_assets/qiyas_assets/ic_user_male.svg",
                    width: isTablet ? 50.sp : 50.sp,
                    height: isTablet ? 50.sp : 50.sp,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(width: 8.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      FormatHelper.capitalize(personEntity.name),
                      style: StyleText.fontSize14Weight500,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      personEntity.departmentName,
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.secondaryBlack),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      personEntity.title,
                      style:
                          StyleText.fontSize12Weight500.copyWith(height: 1.2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  customButtonWithSvg(
                    radius: 4.r,
                    height: 32.sp,
                    title: "رسالة",
                    image:
                        "assets/icons_assets/main_icons_assets/ic_messages_new.svg",
                    function: () {
                      // MessageInterfaceConsumer.openSingleChat(
                      //     personEntity.id, context);
                    },
                    color: AppColors.primary,
                    colorBorder: AppColors.transparent,
                    widthImage: 20.sp,
                    heightImage: 20.sp,
                    svgColor: AppColors.textButton,
                    textStyle: StyleText.fontSize16Weight400.copyWith(
                        color: AppColors.textButton,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
