/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: requests_widget.dart
/// Purpose: The phone layout of the admin dashboard's request list — one
///          card per request with service, requester, department, provider,
///          status and request date. Texts come from ServiceRequestRow.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/services/helpers/services_status_colors.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/dashboard/service_request_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestsListWidget extends StatelessWidget {
  final bool isLoadingRequests;
  final List<Map<String, dynamic>> displayedItems;
  final Map<String, String> enToArDepartments;
  final void Function(Map<String, dynamic>)? onItemTap;

  const RequestsListWidget({
    super.key,
    required this.isLoadingRequests,
    required this.displayedItems,
    required this.enToArDepartments,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingRequests) {
      return const Center(child: CircleProgressMaster());
    }
    if (displayedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64.sp,
              color: AppColors.secondaryText,
            ),
            SizedBox(height: 16.sp),
            Text(
              S.of(context).sm_noRequestsFound,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: displayedItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => RequestItemCard(
        row: ServiceRequestRow(
          displayedItems[index],
          index,
          enToArDepartments: enToArDepartments,
        ),
        onTap: onItemTap,
      ),
    );
  }
}

class RequestItemCard extends StatelessWidget {
  final ServiceRequestRow row;
  final void Function(Map<String, dynamic>)? onTap;

  const RequestItemCard({super.key, required this.row, this.onTap});

  static const String _maleAvatar =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png';
  static const String _femaleAvatar =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png';
  static const String _personIcon =
      'assets/icons_assets/main_icons_assets/ic_user_profile.svg';

  @override
  Widget build(BuildContext context) {
    final status = row.status;
    final statusColor = ServicesStatusColors.of(status);
    final tap = onTap;

    // SVC-DASH-18: only react (haptic) when tapping does something.
    return GestureDetector(
      onTap: tap == null
          ? null
          : () {
              HapticController.low();
              tap(row.item);
            },
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 6.sp),
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _serviceName(context),
                SizedBox(height: 6.sp),
                _person(
                  context,
                  S.of(context).ServiceRequestor,
                  row.requesterName(context),
                  row.isRequesterMale,
                ),
                SizedBox(height: 6.sp),
                _department(context),
                SizedBox(height: 6.sp),
                _person(
                  context,
                  S.of(context).serviceProvider,
                  row.providerName(context),
                  row.isProviderMale,
                ),
                _labelled(
                  S.of(context).RequestedDate,
                  row.requestDate(context),
                  AppColors.blackButton,
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 10.h,
            end: 10.w,
            child: _labelled(
              S.of(context).Status,
              status.isEmpty ? '-' : context.svcStatus(status),
              statusColor,
            ),
          ),
        ],
      ),
    );
  }

  /// "Label: value" in the small caption style, at the reading end.
  Widget _labelled(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${FormatHelper.capitalize(label)}: ',
          style: StyleText.fontSize8Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          value,
          style: StyleText.fontSize8Weight400.copyWith(color: valueColor),
        ),
      ],
    );
  }

  Widget _serviceName(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30.sp,
          height: 30.sp,
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: CustomSvgImage.natural(
            assetPath:
                'assets/icons_assets/main_icons_assets/ic_comms_customer_service.svg',
            width: 12.sp,
            height: 12.sp,
            fit: BoxFit.scaleDown,
          ),
        ),
        SizedBox(width: 5.sp),
        Expanded(
          child: Text(
            FormatHelper.capitalize(row.serviceName(context)),
            style: StyleText.fontSize12Weight500.copyWith(
              color: AppColors.blackButton,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _person(BuildContext context, String label, String name, bool isMale) {
    return Row(
      children: [
        CustomSvgImage.natural(
          assetPath: _personIcon,
          width: 12.sp,
          height: 12.sp,
          fit: BoxFit.scaleDown,
        ),
        SizedBox(width: 6.sp),
        Text(
          '${FormatHelper.capitalize(label)}: ',
          style: StyleText.fontSize10Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        ClipOval(
          child: CustomSvgImage.natural(
            assetPath: isMale ? _maleAvatar : _femaleAvatar,
            width: 20.sp,
            height: 20.sp,
            fit: BoxFit.scaleDown,
          ),
        ),
        SizedBox(width: 4.sp),
        Expanded(
          child: Text(
            FormatHelper.capitalize(name),
            style: StyleText.fontSize10Weight400.copyWith(
              color: AppColors.blackButton,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _department(BuildContext context) {
    return Row(
      children: [
        CustomSvgImage.natural(
          assetPath:
              'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg',
          width: 12.sp,
          height: 12.sp,
          fit: BoxFit.scaleDown,
          color: AppColors.secondaryText,
        ),
        SizedBox(width: 6.sp),
        Text(
          '${FormatHelper.capitalize(S.of(context).Department)}: ',
          style: StyleText.fontSize10Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        SizedBox(width: 2.sp),
        Expanded(
          child: Text(
            FormatHelper.capitalize(row.department(context)),
            style: StyleText.fontSize10Weight400.copyWith(
              color: AppColors.blackButton,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
