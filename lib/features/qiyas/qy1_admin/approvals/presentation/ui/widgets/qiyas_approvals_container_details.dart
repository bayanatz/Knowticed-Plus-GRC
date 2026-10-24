/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_approvals_container_details.dart
/// Purpose: Displays the container for detailed Qiyas approval information,
///          including perspective, description, pillar, and standard.
///          Supports responsive layout for different screen sizes (mobile, tablet).
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget provides a responsive layout for Qiyas approval
///              details, displaying key information such as perspective, description,
///              pillar, and standard. The layout adapts to various screen sizes
///              including mobile and tablet, with an image preview and expandable content.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/vision_details/presentation/controller/vision_details_cubit.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/cards/custom_title_value_widget.dart';

class QiyasApprovalsContainerDetails extends StatelessWidget {
  const QiyasApprovalsContainerDetails(
      {this.isTopicSelected = false, super.key});
  final bool isTopicSelected;

  @override
  Widget build(BuildContext context) {
    VisionDetailsCubit visionDetailsCubit = context.read<VisionDetailsCubit>();
    bool isTablet = !kpIsPhoneLayout(context);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: AppColors.card),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: isTablet ? 85.sp : 50.sp,
                height: isTablet ? 85.sp : 50.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.background,
                ),
                child: Padding(
                  padding: EdgeInsets.all(5.sp),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons_assets/main_icons_assets/ic_module_service_approvals.svg",
                      height: isTablet ? 50.sp : 30.sp,
                      width: isTablet ? 50.sp : 30.sp,
                      fit: BoxFit.scaleDown,
                      colorFilter:
                          ColorFilter.mode(AppColors.text, BlendMode.srcIn),
                    ),
                  ),
                )),
            SizedBox(width: 10.sp),
            Expanded(
              child: Column(
                spacing: 5.sp,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTitleValueWidget(
                      title: "المنظور",
                      value: visionDetailsCubit.selectedVisionName!),
                  CustomTitleValueWidget(
                    title: "الوصف",
                    value:
                        "يشمل المحور تطوير خطة إستراتيجية للتحول الرقمي وخارطة طريق تضعها الجهة الحكومية لتخطيط مسار تطوير الأنظمة والعمليات الأساسية، للوصول إلى رؤية الجهة والأهداف ا لإستراتيجية التي ترغب الجهة بتحقيقها من التحول الرقمي.",
                  ),
                  if (isTopicSelected)
                    CustomTitleValueWidget(
                        title: "المحور",
                        value: visionDetailsCubit.selectedTopicName!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
