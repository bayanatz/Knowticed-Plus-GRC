/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: master_table_section.dart
/// Purpose: The list part of the department dashboard — the request table
///          (tablet) or request cards (phone), or the provider cards when
///          the employees tab is open. Row texts come from ServiceRequestRow.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/helpers/services_status_colors.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/dashboard/service_request_row.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/dashboard_master_cubit.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/dashboard_master_state.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/employee_card.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/table_dashboard.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MasterTableSection extends StatelessWidget {
  final DashboardMasterState state;
  final DashboardMasterCubit cubit;
  final bool isTabletLandscape;

  const MasterTableSection({
    super.key,
    required this.state,
    required this.cubit,
    required this.isTabletLandscape,
  });

  @override
  Widget build(BuildContext context) {
    if (state.showRequestedServices) {
      if (context.isPhone) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < state.displayedItems.length; i++)
              _ServiceCardMobile(
                row: ServiceRequestRow(
                  state.displayedItems[i],
                  i,
                  enToArDepartments: state.enToArDepartments,
                ),
              ),
          ],
        );
      }
      return ServicesDataTable(
        displayedItems: state.displayedItems,
        enToArDepartments: state.enToArDepartments,
      );
    }

    return EmployeeCardDashboard(
      filteredItems: state.filteredItems,
      enToArDepartments: state.enToArDepartments,
      getUniqueProviders: cubit.getUniqueProviderNames,
      calculateProviderStats: cubit.calculateProviderStats,
      servicesDoneText: S.of(context).ServicesDone,
      totalHoursText: S.of(context).svcPlannedHours,
      breachedSLAText: S.of(context).BreachedSLA,
      isTabletLandscape: isTabletLandscape,
      breachedBorderColor: AppColors.red,
    );
  }
}

/// One request on a phone: service and status, requester, department,
/// provider and request date.
class _ServiceCardMobile extends StatelessWidget {
  final ServiceRequestRow row;

  const _ServiceCardMobile({required this.row});

  static const String _personIcon =
      'assets/icons_assets/main_icons_assets/ic_user_profile.svg';

  @override
  Widget build(BuildContext context) {
    final provider = row.providerName(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          SizedBox(height: 16.h),
          _InfoRow(
            svgAsset: _personIcon,
            label: S.of(context).serviceRequester,
            value: row.requesterName(context),
            avatarMale: row.isRequesterMale,
          ),
          SizedBox(height: 10.h),
          _InfoRow(
            svgAsset:
                'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg',
            label: S.of(context).department,
            value: row.department(context),
          ),
          SizedBox(height: 10.h),
          _InfoRow(
            svgAsset: _personIcon,
            label: S.of(context).ServiceProvider,
            value: provider,
            // No avatar beside "-".
            avatarMale: provider == '-' ? null : row.isProviderMale,
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${S.of(context).RequestedDate}: ',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                row.requestDate(context),
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36.sp,
          height: 36.sp,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_module_support_headset.svg',
              width: 15.w,
              height: 15.h,
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(top: 8.h),
            child: Text(
              row.serviceName(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.text,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Padding(
          padding: EdgeInsetsDirectional.only(top: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomSvgImage(
                assetPath:
                    'assets/icons_assets/main_icons_assets/ic_status.svg',
                width: 14.sp,
                height: 14.sp,
                fit: BoxFit.scaleDown,
              ),
              SizedBox(width: 4.w),
              Text(
                '${S.of(context).status}: ',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                row.statusLabel(context),
                style: StyleText.fontSize12Weight500.copyWith(
                  color: ServicesStatusColors.of(row.status),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Label: value", with the person's avatar when [avatarMale] is given.
class _InfoRow extends StatelessWidget {
  final String svgAsset;
  final String label;
  final String value;
  final bool? avatarMale;

  const _InfoRow({
    required this.svgAsset,
    required this.label,
    required this.value,
    this.avatarMale,
  });

  @override
  Widget build(BuildContext context) {
    final male = avatarMale;
    return Row(
      children: [
        CustomSvgImage(
          assetPath: svgAsset,
          width: 16.sp,
          height: 16.sp,
          fit: BoxFit.scaleDown,
          color: AppColors.secondaryText,
        ),
        SizedBox(width: 6.w),
        Text(
          '$label: ',
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        if (male != null) ...[
          SizedBox(width: 4.w),
          ClipOval(
            child: CustomSvgImage.natural(
              assetPath: male
                  ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                  : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
              width: 22.sp,
              height: 22.sp,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 6.w),
        ],
        Expanded(
          child: Text(
            FormatHelper.capitalize(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize12Weight500.copyWith(
              color: AppColors.blackButton,
            ),
          ),
        ),
      ],
    );
  }
}
