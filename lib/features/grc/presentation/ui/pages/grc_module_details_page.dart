/// Module: GRC Module Management
/// Description: Provides the GRC dashboard/details page showing module
///              analytics, filter tabs, and quick-action buttons.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-28
/// Dependencies: Flutter SDK, AppColors, AppTheme, PaginationAppBar
/// Revision History: 2026-06-28 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_details_page.dart
/// Purpose: Contains GrcModuleDetailsPage, the GRC dashboard screen.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/6/2026

import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/custom/9_filter_tab_with_container.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [GrcModuleDetailsPage]
///
/// purpose: GRC dashboard screen that displays module analytics with filter
///          tabs, search, and quick-action buttons.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class GrcModuleDetailsPage extends StatelessWidget {
  const GrcModuleDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, Map<String, dynamic>>> status = [
      MapEntry('all', {'num': 10, 'color': AppColors.textButton}),
      MapEntry('Active', {'num': 5, 'color': AppColors.green}),
      MapEntry('Inactive', {'num': 3, 'color': AppColors.orange}),
      MapEntry('Expired', {'num': 2, 'color': AppColors.red}),
      MapEntry('Draft', {'num': 2, 'color': AppColors.colorGrey}),
    ];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaginationAppBar(
              screensTitles: [
                'GRC'.tr,
                'GRC Module Name',
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customButtonWithSvg(
                    colorBorder: AppColors.primary,
                    space: 10.w,
                    radius: 8.r,
                    widthImage: 16.w,
                    heightImage: 16.h,
                    image: "assets/icons/edit.svg",
                    title: "Approved Evidence".tr,
                    function: () {},
                    width: 200.w,
                    height: 38.h,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton)),
                customButton(
                    title: "Dashboard".tr,
                    function: () {},
                    width: 135.w,
                    height: 38.h,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton)),
              ],
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                customButton(
                    title: "Approvals".tr,
                    function: () {},
                    width: 135.w,
                    height: 38.h,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton)),
                SizedBox(width: 10.w),
                customButton(
                    title: "Assignment Controls".tr,
                    function: () {},
                    width: 180.w,
                    height: 38.h,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton)),
                Spacer(),
                customButton(
                    title: "My Audits".tr,
                    function: () {},
                    width: 135.w,
                    height: 38.h,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton)),
              ],
            ),
            SizedBox(height: 15.h),
            CustomSegmentedTabs(
                tabs: ['All', 'Pending', 'Approved'],
                selectedIndex: 0,
                onTabSelected: (_) {}),
            SizedBox(height: 15.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 30.sp,
                children: [
                  for (var roleEntry in status)
                    FilterBarItem(
                      title: roleEntry.key,
                      numberOfItems: roleEntry.value['num'],
                      color: roleEntry.value['color'],
                      onTap: () {},
                      isSelected: roleEntry.key == 'all',
                    ),
                ],
              ),
            ),
            SizedBox(height: 15.h),
            Row(
              spacing: 10.w,
              children: [
                AppSearchTextField(
                  onChanged: (value) {},
                  hintText: "Search".tr,
                  controller: TextEditingController(),
                ),
                customButtonWithSvg(
                    colorBorder: AppColors.primary,
                    space: 10.w,
                    radius: 8.r,
                    widthImage: 16.w,
                    heightImage: 16.h,
                    function: () {
                      // navigateTo(
                      //     context,
                      //     GovernanceRiskAndComplianceDetails(
                      //       mode: GrcPageMode.restore,
                      //     ));
                    },
                    title: 'Policy',
                    textStyle: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.textButton),
                    image: 'assets/icons/add.svg',
                    color: AppColors.primary,
                    width: 140.w,
                    height: 36.h,
                    svgColor: AppColors.textButton),
              ],
            ),
            SizedBox(height: 15.h),
            Row(children: [
              customButton(
                  title: "Policy Weight Issue".tr,
                  function: () {},
                  width: 180.w,
                  height: 38.h,
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.textButton)),
              Spacer(),
              Container(
                width: 38.sp,
                height: 38.sp,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/tableView.svg",
                    width: 20.sp,
                    height: 20.sp,
                    fit: BoxFit.scaleDown,
                    semanticsLabel: 'Table View',
                    color: AppColors.black,
                  ),
                ),
              ),
              SizedBox(width: 8.sp),
              Container(
                width: 38.sp,
                height: 38.sp,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/gridView.svg",
                    width: 20.sp,
                    height: 20.sp,
                    fit: BoxFit.scaleDown,
                    semanticsLabel: 'Table View',
                    color: AppColors.black,
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
