/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: build_services_card.dart
/// Purpose: The phone cards of the dashboard details request list. Texts
///          come from ServiceRequestRow.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/helpers/services_status_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/dashboard/service_request_row.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ServiceRequestMobileCard extends StatelessWidget {
  final List<Map<String, dynamic>> displayedItems;
  final String locale;
  final Map<String, String> enToArDepartments;
  final void Function(Map<String, dynamic> item)? onTap;

  const ServiceRequestMobileCard({
    super.key,
    required this.displayedItems,
    required this.locale,
    required this.enToArDepartments,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildServiceCards(context),
    );
  }

  List<Widget> _buildServiceCards(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return List.generate(displayedItems.length, (index) {
      final item = displayedItems[index];
      // The details rows carry no model; read everything from the row.
      final row = ServiceRequestRow(
        item,
        index,
        enToArDepartments: enToArDepartments,
      );
      final status = row.status;
      final statusColor = ServicesStatusColors.of(status);
      final localizedStatus = row.statusLabel(context);
      final localizedServiceName = row.serviceName(context);
      final requestorName = row.requesterName(context);
      final providerName = row.providerName(context);
      final department = row.department(context);
      final requestDate = row.requestDate(context);

      return GestureDetector(
        onTap: withHaptic(() => onTap?.call(item), HapticLevel.low),
        child: Container(
          width: 345.sp,
          margin: EdgeInsets.only(bottom: 15.sp),
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                context,
                localizedServiceName,
                localizedStatus,
                statusColor,
                lightMode,
              ),
              SizedBox(height: 9.sp),
              _buildRequester(context, requestorName, lightMode),
              SizedBox(height: 8.sp),
              _buildDepartment(context, department, lightMode),
              SizedBox(height: 6.sp),
              _buildProvider(context, providerName, lightMode),
              _buildRequestDate(context, requestDate, lightMode),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(
    BuildContext context,
    String serviceName,
    String status,
    Color statusColor,
    bool lightMode,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 5.sp),
        // Service name
        Padding(
          padding: EdgeInsets.only(top: 5.sp),
          child: SizedBox(
            width: 165.sp,
            child: Text(
              FormatHelper.capitalize(serviceName),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ),
        ),
        Spacer(),
        // Status
        Padding(
          padding: EdgeInsets.only(top: 3.sp),
          child: CustomSvgImage.natural(
            assetPath: "assets/icons_assets/main_icons_assets/ic_status.svg",
            fit: BoxFit.contain,
            width: 10.sp,
            height: 10.sp,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          FormatHelper.capitalize("${S.of(context).status} : "),
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          FormatHelper.capitalize(status),
          style: StyleText.fontSize12Weight400.copyWith(color: statusColor),
        ),
      ],
    );
  }

  Widget _buildRequester(
    BuildContext context,
    String requestorName,
    bool lightMode,
  ) {
    return Row(
      children: [
        CustomSvgImage.natural(
          assetPath:
              "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
          fit: BoxFit.scaleDown,
        ),
        SizedBox(width: 6.w),
        Text(
          FormatHelper.capitalize("${S.of(context).serviceRequester} : "),
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        SizedBox(width: 2.w),
        ClipOval(
          child: CustomSvgImage.natural(
            assetPath:
                "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
            width: 25.sp,
            height: 25.sp,
            fit: BoxFit.scaleDown,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            FormatHelper.capitalize(requestorName),
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.blackButton,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartment(
    BuildContext context,
    String department,
    bool lightMode,
  ) {
    return Row(
      children: [
        CustomSvgImage.natural(
          assetPath:
              "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
          fit: BoxFit.scaleDown,
          color: AppColors.secondaryText,
        ),
        SizedBox(width: 6.w),
        Text(
          FormatHelper.capitalize("${S.of(context).department}: "),
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          FormatHelper.capitalize(department),
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
      ],
    );
  }

  Widget _buildProvider(
    BuildContext context,
    String providerName,
    bool lightMode,
  ) {
    return Row(
      children: [
        CustomSvgImage.natural(
          assetPath:
              "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
          fit: BoxFit.scaleDown,
        ),
        SizedBox(width: 6.w),
        Text(
          FormatHelper.capitalize("${S.of(context).serviceProvider}: "),
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        SizedBox(width: 2.w),
        ClipOval(
          child: CustomSvgImage.natural(
            assetPath:
                "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
            width: 25.sp,
            height: 25.sp,
            fit: BoxFit.scaleDown,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            providerName.isNotEmpty
                ? FormatHelper.capitalize(providerName)
                : S.of(context).notAvailable,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.blackButton,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestDate(
    BuildContext context,
    String requestDate,
    bool lightMode,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Spacer(),
        Text(
          FormatHelper.capitalize("${S.of(context).RequestedDate} "),
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          requestDate,
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
      ],
    );
  }
}
