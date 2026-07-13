import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/data_grc_module/core/extensions/extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_controller.dart';
import 'package:demo_app/features/onboarding/authentication/domain/enums/employee_status_enum.dart';


import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/roles/user_access_permission.dart';
import 'package:demo_app/features/roles/account_status/domain/entity/account_status_access_entity.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_cubit.dart';
import 'action_dropdown.dart';
import 'custom_user_access_menu.dart';

/// Date Created :12/May/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :28/May/2026

class CustomUserAccessContainer extends StatefulWidget {
  final AccountStatusAccessEntity accountStatusEntity;

  const CustomUserAccessContainer({
    Key? key,
    required this.accountStatusEntity,
  }) : super(key: key);

  @override
  State<CustomUserAccessContainer> createState() =>
      _CustomUserAccessContainerState();
}

class _CustomUserAccessContainerState
    extends State<CustomUserAccessContainer> {
  late final MainCoreEmployeeController employeeController;
  late final bool hasDeactivatePermission;
  late final bool hasExpirationPermission;
  late final bool hasPasswordPermission;
  late final Color borderColor;

  @override
  void initState() {
    super.initState();
    employeeController = Get.find<MainCoreEmployeeController>();

    hasDeactivatePermission = employeeController.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: UserAccess.deactivateUser,
    );
    hasExpirationPermission = employeeController.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: UserAccess.changeExpirationDate,
    );
    hasPasswordPermission = employeeController.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: UserAccess.changeDefaultPassword,
    );

    borderColor = widget.accountStatusEntity.willBeActivated
        ? EmployeeStatusEnum.willBeActivated.color
        : widget.accountStatusEntity.willBeDeactivated
        ? EmployeeStatusEnum.willBeDeactivated.color
        : widget.accountStatusEntity.status.color;
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isArabic = context.isArabic;

    return Container(
      padding: EdgeInsets.symmetric(horizontal:  10.sp),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor, width: 1.sp),
      ),
      child: Column(
        spacing: 10.sp,
        children: [
          _buildHeader(isArabic),
          if (!isPortrait) _buildLandscapeInfo() else _buildPortraitInfo(),
          SizedBox(height: 5.sp,)
        ],
      ),
    );
  }

  Widget _buildHeader(bool isArabic) {
    return Row(
      spacing: 10.sp,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RepaintBoundary(
          child: CircleAvatar(
            radius: 20.r,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: widget.accountStatusEntity.photoUrl!.contains('http')
                  ? Image.network(
                widget.accountStatusEntity.photoUrl!,
                cacheWidth: 80,
                cacheHeight: 80,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 20.r),
              )
                  : Image.asset(widget.accountStatusEntity.photoUrl!),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 60.h,
            child: Column(
              spacing: 2.sp,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        FormatHelper.capitalize(
                          isArabic
                              ? widget.accountStatusEntity.arabicName
                              : widget.accountStatusEntity.englishName,
                        ),
                        style: AppTextStyles.font14BlackCairoMedium.copyWith(
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasDeactivatePermission)
                      ActionDropdown(
                          accountStatusEntity: widget.accountStatusEntity),
                  ],
                ),
                Text(
                  widget.accountStatusEntity.departmentName(isArabic),
                  style:
                  AppTextStyles.font12SecondaryBlackCairoRegular.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  FormatHelper.capitalize(
                    isArabic
                        ? widget.accountStatusEntity.arabicTitle
                        : widget.accountStatusEntity.englishTitle,
                  ),
                  style:
                  AppTextStyles.font12SecondaryBlackCairoRegular.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (hasExpirationPermission) expirationTime() else const SizedBox(),
        if (hasPasswordPermission) defaultPassword(),
        firstLogin(),
        lastLogin(),
      ],
    );
  }

  Widget _buildPortraitInfo() {
    return Column(
      spacing: 5.sp,
      children: [
        if (hasExpirationPermission) expirationTime(),
        if (hasPasswordPermission) defaultPassword(),
        firstLogin(),
        lastLogin(),
      ],
    );
  }

  Widget expirationTime() {
    final isMobile = ContextExtension(context).isPhone;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5.sp,
      children: [
        Text(
          S.of(context).expirationDate,
          style: AppTextStyles.font14BlackCairoRegular.copyWith(
            color: AppColors.text,
          ),
        ),
        Row(
          spacing: 5.sp,
          children: [
            _buildInfoContainer(
              text: widget.accountStatusEntity.expirationTimeOfPassword,
              width: null,
            ),
            isMobile
                ? Expanded(
              child: _buildInfoContainer(
                text: widget.accountStatusEntity.expirationTimeUnit.tr,
                width: null,
              ),
            )
                : _buildInfoContainer(
              text: widget.accountStatusEntity.expirationTimeUnit.tr,
              width: isPortrait ? 275.sp : 130.w,
            ),
          ],
        ),
      ],
    );
  }

  Widget defaultPassword() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5.sp,
      children: [
        Text(
          'Default Password'.tr,
          style: AppTextStyles.font14BlackCairoRegular.copyWith(
            color: AppColors.text,
          ),
        ),
        _buildInfoContainer(
          text: widget.accountStatusEntity.tempPassword,
          width: isPortrait ? double.infinity : 185.w,
        ),
      ],
    );
  }

  Widget firstLogin() {
    final isMobile = ContextExtension(context).isPhone;
    final isArabic = context.isArabic;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final timeParts = widget.accountStatusEntity.firstLoginTime.split(' ');

    // ✅ Uses DateTime directly — guaranteed Western numerals + correct language
    final formattedDate =
    widget.accountStatusEntity.firstLoginDateFormatted(isArabic);

    return Column(
      spacing: 5.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'First Login'.tr,
          style: AppTextStyles.font14BlackCairoRegular.copyWith(
            color: AppColors.text,
          ),
        ),
        Row(
          spacing: 5.sp,
          children: [
            isMobile
                ? Expanded(
              child: _buildDateContainer(
                formattedDate,
                showIcon: true,
              ),
            )
                : _buildDateContainer(
              formattedDate,
              width: isPortrait ? 207.sp : 110.w,
              showIcon: true,
            ),
            if (!isMobile) ...[
              _buildTimeContainer(timeParts[0]),
              _buildTimeContainer(
                  timeParts.length > 1 ? timeParts[1] : ''),
            ],
          ],
        ),
      ],
    );
  }

  Widget lastLogin() {
    final isMobile = ContextExtension(context).isPhone;
    final isArabic = context.isArabic;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final timeParts = widget.accountStatusEntity.lastLoginTime.split(' ');

    // ✅ Uses DateTime directly — guaranteed Western numerals + correct language
    final formattedDate =
    widget.accountStatusEntity.lastLoginDateFormatted(isArabic);

    return Column(
      spacing: 5.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Login'.tr,
          style: AppTextStyles.font14BlackCairoRegular.copyWith(
            color: AppColors.text,
          ),
        ),
        Row(
          spacing: 5.sp,
          children: [
            isMobile
                ? Expanded(
              child: _buildDateContainer(
                formattedDate,
                showIcon: true,
              ),
            )
                : _buildDateContainer(
              formattedDate,
              width: isPortrait ? 207.sp : 110.w,
              showIcon: true,
            ),
            if (!isMobile) ...[
              _buildTimeContainer(timeParts[0]),
              _buildTimeContainer(
                  timeParts.length > 1 ? timeParts[1] : ''),
            ],
          ],
        ),
      ],
    );
  }

  // ── Reusable helper widgets ───────────────────────────────────────────────

  Widget _buildInfoContainer({required String text, double? width}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      padding: EdgeInsets.all(8.sp),
      child: Row(
        children: [
          Text(
            text,
            style: AppTextStyles.font12SecondaryBlackCairoRegular.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateContainer(
      String text, {
        double? width,
        bool showIcon = false,
      }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      padding: EdgeInsets.all(6.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: AppTextStyles.font12SecondaryBlackCairoRegular.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          if (showIcon)
            RepaintBoundary(
              child: SvgPicture.asset(
                'assets/icons/calendar.svg',
                width: 16.sp,
                color: AppColors.secondaryText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeContainer(String text) {
    return Container(
      width: 60.w,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      padding: EdgeInsets.all(8.sp),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.font12SecondaryBlackCairoRegular.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}