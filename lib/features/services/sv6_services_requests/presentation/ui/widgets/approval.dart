/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approval.dart
/// Purpose: The approval cycle of a service: vertical list (phone) and rows of
///          approvers with arrows (larger screens).
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

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';

Widget buildApprovalCycle(
  BuildContext context,
  List<ServiceEmployeeModel> innerApprovalList,
  String? imagePerson,
) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  final approvalList = innerApprovalList;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(approvalList.length, (index) {
      final item = approvalList[index];
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index != 0)
                Padding(
                  padding: EdgeInsets.only(
                    left: 25.sp,
                    right: 20.sp,
                    bottom: 0.sp,
                  ),
                  child: CustomPaint(
                    size: Size(0, 60),
                    painter: CurvedArrowPainter(
                      color: AppColors.text,
                      isArabic: isRtl,
                    ),
                  ),
                )
              else
                SizedBox(
                  width: 2.sp,
                ), // Reserve equal width to align with arrow size
              Padding(
                padding: EdgeInsets.only(top: 14.sp),
                child: ClipOval(
                  child: CustomSvgImage.natural(
                    assetPath: imagePerson!,
                    semanticsLabel: 'Dart Logo',
                    fit: BoxFit.scaleDown,
                    width: 25.sp,
                    height: 25.sp,
                  ),
                ),
              ),

              SizedBox(width: 8.sp),
              Padding(
                padding: EdgeInsets.only(top: 12.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.capitalize(
                        context.svcPick(
                          "${item.firstName ?? ''} ${item.lastName ?? ''}",
                          "${item.firstNameInArabic ?? ''} ${item.lastNameInArabic ?? ''}",
                        ),
                      ),
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    Text(
                      FormatHelper.capitalize(
                        context.svcPick(
                          item.title ?? '',
                          item.titleInArabic ?? '',
                        ),
                      ),
                      style: StyleText.fontSize10Weight400.copyWith(
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

Widget approvalCycleViewTablet(
  List<ServiceEmployeeModel> innerApprovalList,
  BuildContext context,
) {
  final approvalList = innerApprovalList;
  var themeMode = Theme.of(context).brightness == Brightness.light;
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  final screenWidth = MediaQuery.of(context).size.width;

  // Each item needs: avatar(38) + spacing(6) + text(~150) + arrow(~45) = ~240 min width
  const double minItemWidth = 220.0;
  final int itemsPerRow = (screenWidth / minItemWidth).floor().clamp(
        1,
        approvalList.length,
      );

  final rows = <List<ServiceEmployeeModel>>[];
  for (var i = 0; i < approvalList.length; i += itemsPerRow) {
    rows.add(
      approvalList.sublist(i, (i + itemsPerRow).clamp(0, approvalList.length)),
    );
  }

  return SizedBox(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(rows.length, (rowIndex) {
        final rowItems = rows[rowIndex];

        return Padding(
          padding: EdgeInsets.only(top: rowIndex == 0 ? 0.h : 16.h),
          child: Row(
            mainAxisSize: MainAxisSize.min, // only take needed width
            children: List.generate(rowItems.length, (i) {
              final approver = rowItems[i];
              (rowIndex * itemsPerRow) + i;

              final fullName = context.svcPick(
                "${approver.firstName ?? ''} ${approver.lastName ?? ''}",
                "${approver.firstNameInArabic ?? ''} ${approver.lastNameInArabic ?? ''}",
              );

              final title = context.svcPick(
                approver.title ?? '',
                approver.titleInArabic ?? '',
              );

              return Row(
                mainAxisSize: MainAxisSize.min, // only take needed width
                children: [
                  ClipOval(
                    child: CustomSvgImage.natural(
                      assetPath: approver.gender == "male"
                          ? "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png"
                          : "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png",
                      fit: BoxFit.scaleDown,
                      semanticsLabel: 'User Icon',
                      width: 38.sp,
                      height: 38.sp,
                    ),
                  ),
                  SizedBox(width: 6.sp),
                  // ConstrainedBox instead of Flexible/Expanded
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
                        SizedBox(height: 5.sp),
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
                  // Arrow between items only
                  if (i != rowItems.length - 1)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.sp),
                      child: Transform.rotate(
                        angle: isRtl ? pi : 0,
                        child: CustomSvgImage.natural(
                          assetPath:
                              "assets/icons_assets/services_assets/ic_nav_arrow_right_solid.svg",
                          width: 25.sp,
                          fit: BoxFit.scaleDown,
                          color: themeMode
                              ? AppColors.blackButton
                              : AppColors.whiteShadow,
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
    ),
  );
}
