/// Module: GRC (Governance, Risk, and Compliance)
/// Description: This module provides a comprehensive framework for managing governance, risk, and compliance within an organization. It includes features for creating, editing, viewing, and restoring GRC modules, as well as action buttons for user interactions.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-28
/// Dependencies:  FireStore , Flutter SDK, Bloc for state management, and other core libraries.
/// Revision History: 2026-06-28 .
library;

import 'dart:developer';

import 'package:demo_app/core/constants/app_assets.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/custom/37-custom_navigate.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/grc_details_page.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/grc_module_details_page.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/app_dropdown.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/responsive_helper.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../settings/core_widgets/main_widget/custom_button_widget.dart';

class GrcResponsivePage extends StatelessWidget {
  const GrcResponsivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper(
        mobileWidget: GovernanceRiskAndCompliancePage(),
        tabletWidget: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) {
                return GovernanceRiskAndCompliancePage();
              },
            );
          },
        ));
  }
}

class GovernanceRiskAndCompliancePage extends StatefulWidget {
  const GovernanceRiskAndCompliancePage({super.key});

  @override
  State<GovernanceRiskAndCompliancePage> createState() =>
      _GovernanceRiskAndCompliancePageState();
}

class _GovernanceRiskAndCompliancePageState
    extends State<GovernanceRiskAndCompliancePage> {
  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, Map<String, dynamic>>> status = [
      MapEntry('all', {'num': 10, 'color': AppColors.textButton}),
      MapEntry('Active', {'num': 5, 'color': AppColors.green}),
      MapEntry('Inactive', {'num': 3, 'color': AppColors.red}),
      MapEntry('Removed', {'num': 2, 'color': AppColors.colorGrey}),
    ];
    String selectedStatus = 'all';
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaginationAppBar(
                screensTitles: ["Governance, Risk, and Compliance".tr]),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                customButton(
                    title: "Dashboard".tr,
                    function: () {
                      navigateTo(context, GrcModuleDetailsPage());
                    },
                    width: 135.w,
                    height: 38.h,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton)),
              ],
            ),
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
                      onTap: () {
                        setState(() {
                          selectedStatus = roleEntry.key;
                        });
                        log("Selected Status: $selectedStatus");
                      },
                      isSelected: selectedStatus == roleEntry.key,
                    ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              spacing: 10.w,
              children: [
                AppSearchTextField(
                  onChanged: (value) {},
                  hintText: "Search".tr,
                  controller: TextEditingController(),
                ),
                SizedBox(
                  width: 50.w,
                  child: AppDropdown(
                    items: ["ASC", "DES", "Creation Date", 'Last Update']
                        .map((option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                    onChanged: (value) {
                      // Handle the selected value here
                    },
                    textButton: null,

                    borderRadius: 8.r,
                    isAllCornersRounded: true,
                    value: null,
                    width: 150.sp,
                    menuWidth: 150.sp, // Increased for Arabic text
                    fillColor: AppColors.field,
                    menuItemHeight: 35.h,
                    customButton: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.field,
                      ),
                      child: SvgPicture.asset(
                        AppAssets.sort,
                        width: 20.w,
                        height: 20.h,
                      ),
                    ),
                  ),
                ),
                customButtonWithSvg(
                    colorBorder: AppColors.primary,
                    space: 10.w,
                    function: () {
                      navigateTo(
                          context,
                          GovernanceRiskAndComplianceDetails(
                            mode: GrcPageMode.create,
                          ));
                    },
                    title: 'Create GRC Module',
                    textStyle: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.textButton),
                    image: 'assets/icons_drawer_news/grc_new.svg',
                    widthImage: 16.w,
                    heightImage: 16.h,
                    color: AppColors.primary,
                    width: 200.w,
                    height: 36.h,
                    radius: 8.r,
                    svgColor: AppColors.textButton),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
