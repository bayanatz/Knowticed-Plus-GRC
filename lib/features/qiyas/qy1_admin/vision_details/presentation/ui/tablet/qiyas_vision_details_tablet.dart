/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_vision_details_tablet.dart
/// Purpose: Displays the "Qiyas Vision Details" screen for pages layout with responsive features such as dynamic filtering,
///          approval details, and expandable content. It adapts to both portrait and landscape orientations to provide a user-friendly interface.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget renders the pages layout for the "Qiyas Vision Details" screen, showing vision details, topics, and approval data.
///              It includes dynamic filtering, expandable sections, and document display for various devices, enhancing user interaction and experience.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/presentation/ui/widgets/qiyas_approvals_container_details.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/vision_details/presentation/controller/vision_details_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/vision_details/presentation/ui/widgets/tablet/qiyas_custom_row_vision_details.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class QiyasVisionDetailsTablet extends StatelessWidget {
  const QiyasVisionDetailsTablet({super.key, required this.visionName});

  final String visionName;

  @override
  Widget build(BuildContext context) {
    VisionDetailsCubit controller = VisionDetailsCubit();
    controller.selectVision(visionName);
    List<String> titlesTaps = controller.selectedVisionTopics;
    bool isTablet = !kpIsPhoneLayout(context);
    return BlocProvider<VisionDetailsCubit>.value(
      value: controller,
      child: BlocBuilder<VisionDetailsCubit, VisionDetailsState>(
          buildWhen: (_, __) {
        return true;
      }, builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                  start: isTablet ? 30.sp : 15.sp, end: 15.sp),
              child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaginationAppBar(
                        screensTitles: [
                          "قياس التحول الرقمي",
                          visionName,
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticController
                                      .low(); // list row: on the tap (X-117)
                                  controller.toggleExpanded();
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'معلومات المنظور',
                                      style: StyleText.fontSize14Weight600,
                                    ),
                                    IntrinsicWidth(
                                      child: Column(
                                        spacing: 4.sp,
                                        children: [
                                          Text(
                                            controller.isExpanded
                                                ? "إخفاء"
                                                : "اظهار",
                                            style: StyleText.fontSize14Weight600
                                                .copyWith(
                                              color: const Color(0xff1877F2),
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          Container(
                                            height: 2,
                                            color: const Color(0xff1877F2),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.sp),
                              controller.isExpanded == true
                                  ? const QiyasApprovalsContainerDetails()
                                  : const SizedBox.shrink(),
                              SizedBox(
                                  height: controller.isExpanded == true
                                      ? 25.sp
                                      : 15.sp),
                              Row(children: [
                                Expanded(
                                  child: CustomTabs(
                                    selectedValue:
                                        controller.selectedQiyasScreenIndex,
                                    onChanged: controller
                                        .updateSelectedQiyasScreenIndex,
                                    tabs: [
                                      for (int i = 0;
                                          i < titlesTaps.length;
                                          i++)
                                        titlesTaps[i],
                                    ],
                                  ),
                                ),
                              ]),
                              SizedBox(height: 32.sp),
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      controller.selectedTopicCriteria.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          child: InkWell(
                                            onTap: () {
                                              HapticController
                                                  .low(); // list row: on the tap (X-117)
                                              controller
                                                  .toggleExpandedDetails(index);
                                            },
                                            hoverColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            child: Container(
                                              padding: EdgeInsets.all(10.sp),
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xff797979),
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                        controller
                                                                .selectedTopicCriteria[
                                                            index],
                                                        style: StyleText
                                                            .fontSize16Weight500
                                                            .copyWith(
                                                                color: AppColors
                                                                    .white,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis)),
                                                  ),
                                                  RotatedBox(
                                                      quarterTurns:
                                                          controller.isExpandedDetailsMap[
                                                                      index] ==
                                                                  true
                                                              ? 2
                                                              : 0,
                                                      child: SvgPicture.asset(
                                                        "assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg",
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                                AppColors.white,
                                                                BlendMode
                                                                    .srcIn),
                                                        height: 10.sp,
                                                        width: 10.sp,
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10.sp),
                                        controller.isExpandedDetailsMap[
                                                    index] ==
                                                true
                                            ? Column(
                                                children: [
                                                  QiyasCustomRowVisionDetails(
                                                      visionNumber: controller
                                                          .getCriteriaNumber(
                                                              controller
                                                                      .selectedTopicCriteria[
                                                                  index]),
                                                      visionValues: controller
                                                          .getCriteriaDetails(
                                                              controller
                                                                      .selectedTopicCriteria[
                                                                  index])),
                                                ],
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    );
                                  })
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.sp)
                    ],
                  )),
            ),
          ),
        );
      }),
    );
  }
}
