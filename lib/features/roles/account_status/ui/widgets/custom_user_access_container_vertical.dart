// ignore_for_file: unrelated_type_equality_checks, unnecessary_string_interpolations

import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/features/roles/widgets/dialogs/reschedule_dialog.dart';
import 'package:demo_app/features/roles/core_widgets/buttons/main_custom_button.dart';
import 'package:demo_app/features/roles/account_status/ui/widgets/custom_calender_time_widget.dart';
import 'package:demo_app/features/roles/core_widgets/form_fields/profile_textfield.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/features/roles/helper/expiration_calculation.dart';

import 'package:demo_app/core/haptic/haptic_controller.dart';

import 'package:demo_app/core/theme/app_font_size.dart';

import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/features/roles/account_status/ui/widgets/custom_user_access_menu.dart';

import 'package:demo_app/features/onboarding/authentication/domain/enums/employee_status_enum.dart';
import 'package:demo_app/features/roles/account_status/domain/entity/account_status_access_entity.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_controller.dart';
import 'user_image.dart';

/// Date Created :12/May/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :12/May/2023
/// Objectives: this widget is responsible for all the users registered in the company, and also managing the requests of the users as well

class CustomUserAccessContainerVertical extends StatefulWidget {
  AccountStatusAccessEntity accountStatusEntity;

  CustomUserAccessContainerVertical({required this.accountStatusEntity});

  @override
  State<CustomUserAccessContainerVertical> createState() =>
      _CustomUserAccessContainerVerticalState();
}

class _CustomUserAccessContainerVerticalState
    extends State<CustomUserAccessContainerVertical> {
  final HapticController hapticController = Get.put(HapticController());
  EmployeeController addEmployeeController = Get.find();

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final TextStyle blackTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: isPortrait
            ? FontConstants.fontSize015.h
            : FontConstants.fontSize020.h,
        color: themeController.currentTheme == AppColors.lightTheme
            ? AppColors.colorBlack
            : AppColors.colorWhiteDark,
        fontWeight: Get.locale.toString().contains('en')
            ? FontWeight.w400
            : FontWeight.w300,
        height: 1.2);

    final TextStyle greyTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isPortrait
          ? FontConstants.fontSize015.h
          : FontConstants.fontSize024.h,
      color: themeController.currentTheme == AppColors.lightTheme
          ? AppColors.colorDarkGrey
          : AppColors.colorGreydark,
      fontWeight: Get.locale.toString().contains('en')
          ? FontWeight.w600
          : FontWeight.w500,
    );

    final TextStyle fieldsTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: isPortrait
            ? FontConstants.fontSize016.h
            : FontConstants.fontSize026.h,
        color: themeController.currentTheme == AppColors.lightTheme
            ? AppColors.colorBlack
            : AppColors.colorWhiteDark,
        fontWeight: FontWeight.w600,
        height: 1.4);
    return Padding(
      padding: EdgeInsets.only(
          top: isPortrait ? 0 : 0.03.h,
          bottom: isTablet ? (isPortrait ? 0.015.h : 0) : 0.02.h),
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(
              vertical: isPortrait ? 0.01.h : 0.02.h,
              horizontal: isPortrait ? 0.02.w : 0.02.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserImage(imageUrl: widget.accountStatusEntity.photoUrl!),
                  SizedBox(width: isPortrait ? 0.02.w : 0.02.h),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: isTablet ? 0.55.w : 0.6.w,
                                  child: Text(
                                    Get.locale.toString().contains("en")
                                        ? capitalize(widget
                                            .accountStatusEntity.englishName)
                                        : capitalize(widget
                                            .accountStatusEntity.arabicName),
                                    style: AppFontStyle.cairoRegularStyle
                                        .copyWith(
                                            fontSize: isPortrait
                                                ? FontConstants.fontSize016.h
                                                : FontConstants.fontSize030.h,
                                            color: themeController
                                                        .currentTheme ==
                                                    AppColors.lightTheme
                                                ? AppColors.colorBlack
                                                : AppColors.colorWhiteDark,
                                            fontWeight: FontWeight.w600,
                                            height: 1.8),
                                  ),
                                ),
                                if (widget
                                    .accountStatusEntity.willBeDeactivated)
                                  SizedBox(
                                    width: isTablet ? 0.55.w : 0.63.w,
                                    child: Text(
                                      '\u2022 ${widget.accountStatusEntity.isInactive ? "Inactive For Now".tr : "Active For Now".tr}',
                                      style: blackTextStyle.copyWith(
                                          color: widget.accountStatusEntity
                                                  .isInactive
                                              ? AppColors.colorDarkGrey
                                              : AppColors.unBlock),
                                    ),
                                  ),
                                if(widget.accountStatusEntity.willBeActivated)
                                SizedBox(
                                  width: isTablet ? 0.55.w : 0.6.w,
                                  child: Text(
                                    widget.accountStatusEntity.isDeactivated
                                        ? '\u2022 ${"Deactivated For Now".tr}'
                                        : '\u2022 ${EmployeeStatusEnum.willBeActivated.name.tr.capitalize} ${Get.locale.toString().contains('en') ? widget.accountStatusEntity.reactivationDate : widget.accountStatusEntity.deactivationDateDate != null ? dateforamtToArabic(widget.accountStatusEntity.reactivationDate.toString()) : ''}',
                                    style: blackTextStyle.copyWith(
                                        height: widget.accountStatusEntity
                                                    .willBeDeactivated ||
                                                widget.accountStatusEntity
                                                    .isDeactivated
                                            ? 1.6
                                            : null,
                                        color: widget
                                                .accountStatusEntity.isInactive
                                            ? AppColors.colorDarkGrey
                                            : widget.accountStatusEntity
                                                    .isActive
                                                ? AppColors.unBlock
                                                : widget.accountStatusEntity
                                                        .willBeDeactivated
                                                    ? AppColors.warning
                                                    : AppColors.delete),
                                  ),
                                ),
                                if (widget.accountStatusEntity.willBeActivated)
                                  Container(
                                    width: isTablet ? 0.55.w : 0.6.w,
                                    child: Text(
                                      '\u2022 ${"Will Be Reactivated At".tr} ${Get.locale.toString().contains('en') ? widget.accountStatusEntity.reactivationDate ?? "" : widget.accountStatusEntity.reactivationDate != null ? dateforamtToArabic(widget.accountStatusEntity.reactivationDate.toString()) : ''}',
                                      style: blackTextStyle.copyWith(
                                          height: 1.6,
                                          color: AppColors.warning),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: 0.02.w),
                            if (widget.accountStatusEntity.status !=
                                    EmployeeStatusEnum.lockedWithRequest ||
                                widget.accountStatusEntity.status !=
                                    EmployeeStatusEnum.resetPassword)
                              Spacer(),
                            if (widget.accountStatusEntity.status !=
                                    EmployeeStatusEnum.lockedWithRequest ||
                                widget.accountStatusEntity.status !=
                                    EmployeeStatusEnum.resetPassword)
                              InkWell(
                                onTapUp: (details) async {
                                  hapticController.triggerHapticFeedback(
                                      vibration: VibrateType.lightImpact,
                                      hapticFeedback:
                                          HapticFeedback.lightImpact);
                                  final iconPosition = details.globalPosition;
                                  CustomUserAccessMenu sortMenu =
                                      CustomUserAccessMenu();
                                  await sortMenu.showSortMenu(
                                    context,
                                    iconPosition,
                                    widget.accountStatusEntity.status.name,
                                    (String selectedDateTime) {
                                      if (widget
                                          .accountStatusEntity.isDeactivated) {
                                        Get.find<AccountStatusController>()
                                            .scheduleReactivation(
                                                widget.accountStatusEntity,
                                                selectedDateTime);
                                      } else {
                                        Get.find<AccountStatusController>()
                                            .scheduleDeactivation(
                                                widget.accountStatusEntity,
                                                selectedDateTime);
                                      }
                                    },
                                    (String seletecdItem) {
                                      Get.find<AccountStatusController>()
                                          .updateAccountStatus(
                                              widget.accountStatusEntity);
                                    },
                                  );
                                },
                                child: Container(
                                  height: 0.03.h,
                                  alignment: Alignment.topCenter,
                                  width: isTablet ? 0.05.w : 0.07.w,
                                  padding: EdgeInsets.all(0.005.h),
                                  child: SvgPicture.asset(
                                    'assets/icons_assets/main_icons_assets/threeDotsDialog.svg',
                                    color: themeController.currentTheme ==
                                            AppColors.lightTheme
                                        ? AppColors.colorBlack
                                        : AppColors.colorWhiteDark,
                                    height: 0.007.h,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.02.h),
              Row(
                children: [
                  _dateWidget(
                      '${'First Login'.tr}: ',
                      widget.accountStatusEntity.firstLoginDate,
                      widget.accountStatusEntity.firstLoginTime,
                      greyTextStyle),
                  Spacer(),
                  _dateWidget(
                      '${'Last Login'.tr}: ',
                      widget.accountStatusEntity.lastLoginDate,
                      widget.accountStatusEntity.lastLoginTime,
                      greyTextStyle),
                ],
              ),
              SizedBox(height: 0.015.h),
              Row(
                children: [
                  SizedBox(
                    width: isTablet ? 0.35.w : 0.47.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expiration Time of Password'.tr,
                            style: fieldsTextStyle),
                      ],
                    ),
                  ),
                  SizedBox(width: 0.02.w),
                  Expanded(
                    child: SizedBox(
                      height: isTablet ? null : null,
                      child: textfieled(
                        context,

                        (value) {},
                        (value) {},
                        'Enter Expiration Time'.tr, // hintText
                        Get.locale.toString().contains('en')
                            ? "${widget.accountStatusEntity.expirationTimeOfPassword} ${"Weeks".tr}"
                            : "${convertNumberToArabic(widget.accountStatusEntity.expirationTimeOfPassword)} ${"Weeks".tr}",
                        null, // prefixIcon
                        controller: null,
                        isReadOnly: false,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: isTablet ? 0.35.w : 0.47.w,
                    child: Text('Default Password'.tr, style: fieldsTextStyle),
                  ),
                  SizedBox(width: 0.02.w),
                  Expanded(
                    child: SizedBox(
                      height: isTablet ? null : null,
                      child: textfieled(
                        context,
                        (value) {},
                        (value) {},
                        'Enter Default Password'.tr, // hintText
                        Get.locale.toString().contains('en')
                            ? widget.accountStatusEntity.tempPassword
                            : convertNumberToArabic(
                                widget.accountStatusEntity.tempPassword),
                        null, // prefixIcon
                        controller: null,
                        isReadOnly: true,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.accountStatusEntity.isRequestToReset)
                Row(
                  children: [
                    SizedBox(
                      width: isTablet ? 0.35.w : 0.47.w,
                      child: Text('Requested To Reset Password ?'.tr,
                          style: fieldsTextStyle),
                    ),
                    SizedBox(width: 0.02.w),
                    Expanded(
                      child: SizedBox(
                        height: isTablet ? null : null,
                        child: textfieled(
                          context,
                          (value) {},
                          (value) {},
                          ''.tr, // hintText
                          widget.accountStatusEntity.isRequestToReset
                              ? "Yes"
                              : "No",
                          null, // prefixIcon
                          controller: null,
                          isReadOnly: true,
                        ),
                      ),
                    ),
                  ],
                ),
              if (widget.accountStatusEntity.isRequestToReset ||
                  widget.accountStatusEntity.isLockedWithRequest)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.01.h),
                  child: MainCustomButton(
                    buttonText: widget.accountStatusEntity.isRequestToReset
                        ? 'Approve Request'.tr
                        : widget.accountStatusEntity.isLockedWithRequest
                            ? "Unlock Account".tr
                            : "",
                    onPressed: () {
                      if (widget.accountStatusEntity.isRequestToReset) {
                        Get.find<AccountStatusController>()
                            .approveRequestToResetPassword(
                                widget.accountStatusEntity);
                      } else if (widget
                          .accountStatusEntity.isLockedWithRequest) {
                        Get.find<AccountStatusController>()
                            .updateAccountStatus(widget.accountStatusEntity);
                      }
                    },
                  ),
                ),
            ],
          )),
    );
  }

  Column _dateWidget(String text, String date, String time, TextStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: style),
        SizedBox(height: 0.005.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: customCalendarTimeWidget(
                context: context,
                text: date,
                svgPath: 'assets/icons_assets/main_icons_assets/SmallCalendar.svg',
              ),
            ),
            SizedBox(height: 0.005.h),
            Container(
              child: customCalendarTimeWidget(
                context: context,
                text: time,
                svgPath: 'assets/icons_assets/main_icons_assets/ClockCircleSmall.svg',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
