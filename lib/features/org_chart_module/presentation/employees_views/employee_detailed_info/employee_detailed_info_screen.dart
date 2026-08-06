import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/theme_controller.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/features/org_chart_module/presentation/employees_views/employee_detailed_info/employee_info_widget.dart';
import 'package:grc_module/features/org_chart_module/presentation/employees_views/employee_detailed_info/employee_work_info_widget.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';


import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/features/org_chart_module/presentation/controller/employee_helper.dart';
import 'package:grc_module/core/custom/33-custom_haptic.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

/// Date Created :3/Dec/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :14/Dec/2023
/// Objectives: this screen is responsible for showing the each employee profile, and in this screen, the hr can view his
/// personal info, performance, attendance rate, and the permissions

class EmployeeDetailedInfo extends StatefulWidget {
  final int? index;
  final double reviewRating;
  final NewEmployeeModelHistory employee;

  EmployeeDetailedInfo(
      {this.index, this.reviewRating = 5, required this.employee, Key? key})
      : super(key: key);

  @override
  EmployeeDetailedInfoState createState() => EmployeeDetailedInfoState();
}

class EmployeeDetailedInfoState extends State<EmployeeDetailedInfo> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  int selectedContainerIndexEmployee = 0;

  @override
  void initState() {
    selectedContainerIndexEmployee = widget.index ?? 0;
    super.initState();
  }

  void setSelectedContainerIndexEmployee(int index) {
    setState(() {
      selectedContainerIndexEmployee = index;
    });
  }

  bool notificationEnabled = false;
  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    final orientation = MediaQuery.of(context).orientation;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: _buildTabletLayout(orientation, themeController),
      ),
    );
  }

  Widget _buildTabletLayout(
      Orientation orientation, ThemeController themeController)
  {
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isLargeTablet = MediaQuery.of(context).size.shortestSide >= 1024;

    TextStyle breadCrumbsTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isVertical
          ? Get.locale.toString().contains("en")
          ? FontConstants.fontSize015.h
          : FontConstants.fontSize011.h
          : FontConstants.fontSize020.h,
      fontWeight: FontWeight.w600,
      overflow: TextOverflow.ellipsis,
      color: Theme.of(context).colorScheme.inverseSurface,
      height: isVertical
          ? Get.locale.toString().contains("en")
          ? 1.3
          : 1
          : 1.4,
    );

    return Column(
      children: [

        Row(
          children: [
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).organizationChart,
                style: AppTextStyles.font22BlackCairoSemiBold.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white),
              ),
            ),
            Transform.rotate(
              angle: isArabic ? 3.1416 : 0,
              child: Padding(
                padding: isArabic
                    ? EdgeInsets.only(bottom: 7.sp)
                    : EdgeInsets.only(top: 3.sp),
                child: SvgPicture.asset(
                  'assets/icons_assets/main_icons_assets/images_arrow.svg',
                  width: 30.sp,
                  height: 30.sp,
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.blackButton
                      : AppColors.whiteShadow,
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).employeeInfo,
                style: AppTextStyles.font22BlackCairoSemiBold.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white),
              ),
            )
          ],
        ),
        SizedBox(height: 30.sp),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: isVertical ? 2 : 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0.01.h),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 0.02.h),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0.015.w),
                              child: EmployeeInfoWidget(
                                employeeModel: widget.employee,
                                image: widget.employee.photo?.lastOrNull,
                                firstName:
                                Get.locale.toString().contains('en')
                                    ? widget.employee.firstName!.last!
                                    : widget.employee.firstNameInArabic!.last!,
                                lastName: Get.locale.toString().contains('en')
                                    ? widget.employee.lastName!.last!
                                    : widget.employee.lastNameInArabic!.last!,
                                profession: EmployeeHelper.getEmployeeJobTitle(
                                    employee: widget.employee),
                                reviewRating: widget.reviewRating,
                                email: widget.employee.email!.last!,
                                bio: widget.employee.bio?.lastOrNull,
                                phone:
                                "${widget.employee.mobilePhone?.lastOrNull ?? ""}",
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0.01.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              customButtonWithSvg(
                                space: ContextExtension(context).isPhone ? 0.sp : 8.sp,
                                colorBorder: Colors.transparent,
                                heightImage: 20.h,
                                widthImage: 20.w,
                                textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
                                  color: AppColors.textButton
                                ),
                                  title: S.current.chat,
                                  function: () {
                                    hapticController.triggerHapticFeedback(
                                        vibration: VibrateType.mediumImpact,
                                        hapticFeedback:
                                        HapticFeedback.mediumImpact);
                                    // TODO: wire up chat. The original app called
                                    // MessageInterfaceConsumer.openSingleChat(
                                    //     widget.employee.email!.last!, context);
                                    // skeleton_app has no messaging module yet.
                                  },
                                  color: AppColors.primary,
                                  width: 150.w,
                                  height: 38.h,
                                  radius: 4.r,
                                  image: 'assets/icons_assets/main_icons_assets/roles_icons_Messages.svg')
                            ],
                          ),
                        ),
                        SizedBox(height: 9.sp),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                  width: 15.w),
              Expanded(
                flex: 3,
                child: Container(

                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 0.0.h,
                      right: 0.02.w,
                      left: 0.02.w,
                  //    bottom: 0.09.h,
                    ),
                    child: EmployeeWorkInfoScreen(employee: widget.employee),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
