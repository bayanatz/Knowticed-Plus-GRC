/// Module: services / presentation / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approvals.dart
/// Purpose: The approval cycle of a request on the requester and approver
///          pages: vertical list (phone) and rows of approvers with their
///          states (larger screens).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/cards/custom_approval_shape.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';

Color _getBorderColor(String? state) {
  final s = state?.toLowerCase().trim() ?? '';
  switch (s) {
    case 'pending':
      return AppColors.orange; // Orange
    case 'approved':
    case 'done':
      return AppColors.lightGreen; // Green
    case 'rejected':
    case 'cancel':
      return AppColors.block; // Red
    case 'inprogress':
      return AppColors.secondaryPrimary; // Yellow
    case 'breached sla':
      return AppColors.block; // Dark red
    case 'normal':
      return AppColors.lightGrey; // Unassigned/skipped
    default:
      return AppColors.grey; // Fallback
  }
}

Widget buildApprovalCycleMyRequest(
  BuildContext context,
  bool isCanceledAction,
  List<ServiceEmployeeModel> listOne,
  List<ServiceEmployeeModel> listTwo,
) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  final isCanceled = isCanceledAction;
  final approvalList = isCanceled ? listOne : listTwo;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(approvalList.length, (index) {
      final employee = approvalList[index];
      final approvalState = employee.state?.toLowerCase() ?? 'pending';

      //  employee.gender == "male"
      //                           ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
      //                           : "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png",
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0)
                Padding(
                  padding: EdgeInsets.only(
                    left: 25.sp,
                    right: 25.sp,
                    bottom: 0.sp,
                  ),
                  child: CustomPaint(
                    size: Size(0, 75),
                    painter: CurvedArrowPainter(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.whiteShadow,
                      isArabic: isRtl,
                    ),
                  ),
                )
              else
                SizedBox(
                  width: 0.sp,
                ), // Reserve equal width to align with arrow size
              Padding(
                padding: EdgeInsets.only(top: 14.sp),
                child: Container(
                  width: 32.sp,
                  height: 33.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: approvalState == 'cancel'
                          ? AppColors.red
                          : _getBorderColor(approvalState),
                      width: 2.w,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomSvgImage.natural(
                      assetPath: employee.gender == "male"
                          ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                          : "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png",
                      fit: BoxFit.scaleDown,
                      width: 28.sp,
                      height: 28.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.sp),
              Padding(
                padding: EdgeInsets.only(top: 15.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.capitalize(
                        context.svcPick(
                          "${employee.firstName ?? ''} ${employee.lastName ?? ''}",
                          "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}",
                        ),
                      ),
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackButton,
                      ),
                    ),
                    Text(
                      FormatHelper.capitalize(
                        context.svcPick(employee.title, employee.titleInArabic),
                      ),
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }),
  );
}

Widget approvalCycleViewLogic(
  BuildContext context,
  List<ServiceEmployeeModel> listThree,
) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  final approvalList = listThree;
  final themeMode = Theme.of(context).brightness == Brightness.light;
  const itemsPerRow = 3;

  final rows = <List<int>>[];
  for (var i = 0; i < approvalList.length; i += itemsPerRow) {
    rows.add(
      List.generate(
        (i + itemsPerRow).clamp(0, approvalList.length) - i,
        (j) => i + j,
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(rows.length, (rowIndex) {
      final rowItems = rows[rowIndex];

      return Padding(
        padding: EdgeInsets.only(top: rowIndex == 0 ? 0.h : 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(rowItems.length, (i) {
            final index = rowItems[i];
            final employee = approvalList[index];
            final approvalState = employee.state?.toLowerCase() ?? 'pending';

            final fullName = context.svcPick(
              "${employee.firstName ?? ''} ${employee.lastName ?? ''}",
              "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}",
            );

            final title = context.svcPick(
              employee.title ?? '',
              employee.titleInArabic ?? '',
            );

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getBorderColor(approvalState),
                      width: 2.w,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomSvgImage.natural(
                      assetPath: employee.gender == "male"
                          ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                          : "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png",
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 150.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        FormatHelper.capitalize(fullName),
                        style: StyleText.fontSize13Weight500
                            .copyWith(color: AppColors.secondaryBlack)
                            .copyWith(
                              color: themeMode
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.sp),
                      Text(
                        FormatHelper.capitalize(title),
                        style: StyleText.fontSize10Weight400
                            .copyWith(color: AppColors.secondaryBlack)
                            .copyWith(
                              color: themeMode
                                  ? AppColors.secondaryText
                                  : AppColors.grey,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (index != approvalList.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Transform.rotate(
                      angle: isRtl ? pi : 0,
                      child: CustomSvgImage.natural(
                        assetPath:
                            "assets/icons_assets/services_assets/ic_nav_arrow_right_solid.svg",
                        width: 25.w,
                        fit: BoxFit.scaleDown,
                        color: _getBorderColor(approvalState),
                        semanticsLabel: 'Arrow Icon',
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      );
    }),
  );
}
