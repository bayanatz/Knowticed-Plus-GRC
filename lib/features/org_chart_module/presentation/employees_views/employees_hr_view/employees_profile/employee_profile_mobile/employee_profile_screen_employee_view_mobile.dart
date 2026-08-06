import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/theme/theme_controller.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/features/org_chart_module/employees_components/employee_profile_employee_view.dart';
import 'package:grc_module/features/org_chart_module/employees_components/employees_hr_components/employee_mobile_components/custom_employee_profile_header_mobile.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/features/org_chart_module/presentation/controller/employee_controller.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/features/org_chart_module/presentation/controller/employee_helper.dart';
import 'package:grc_module/core/custom/33-custom_haptic.dart';

import '../../../../../../home/h1_home_page/presentation/ui/widgets/custom_appbar_mobile.dart' show CustomAppBarMobile;



class EmployeeProfileScreenMobileEmployeeViewScreen extends StatefulWidget {
  final int? index;
  final NewEmployeeModelHistory employee;

  EmployeeProfileScreenMobileEmployeeViewScreen(
      {this.index, Key? key, required this.employee})
      : super(key: key);

  @override
  EmployeeProfileScreenMobileEmployeeViewScreenState createState() =>
      EmployeeProfileScreenMobileEmployeeViewScreenState();
}

class EmployeeProfileScreenMobileEmployeeViewScreenState
    extends State<EmployeeProfileScreenMobileEmployeeViewScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  int selectedContainerIndex = 0;
  @override
  void initState() {
    selectedContainerIndex = widget.index ?? 0;
    super.initState();
  }

  void setSelectedContainerIndex(int index) {
    setState(() {
      selectedContainerIndex = index;
    });
  }

  OrgChartEmployeeController addEmployeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());
  bool notificationEnabled = false;
  bool switchValue = false;
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Row(
          children: [

            Expanded(
              child: Container(
                child: _buildMobileLayout(orientation, themeController),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double imageHeight = 0.03.h;
  Widget _buildMobileLayout(
      Orientation orientation, ThemeController themeController) {
    var lightTheme = Theme.of(context).brightness == Brightness.light;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    return Column(
      children: [


        Padding(
          padding: EdgeInsets.all(15.sp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              GestureDetector(
                  onTap : (){
                    Navigator.pop(context);
                  },


                  child: Transform.rotate(
                    angle: isArabic ? 0 : 3.1416,
                    child: SvgPicture.asset(
                      'assets/icons_assets/main_icons_assets/images_arrow.svg',
                      width: 24.sp,
                      height: 24.sp,
                      color: AppColors.text,
                    ),
                  ),



              ),

              Text(S.of(context).employeeInfo,style: AppTextStyles.font22BlackCairoSemiBold.copyWith(

                color: lightTheme ? AppColors.blackButton : AppColors.white
              ),),
            ],
          ),
        ),
        SizedBox(height: 15.sp),
        CustomAppBarMobile(showIcon: true, title: "Employees"),
        CustomEmployeeAppBarMobile(
          isEmployeeView: true,
          jobtitle :  widget.employee.title?.lastOrNull ,
          profileImagePath: widget.employee.photo?.lastOrNull,
          bio: widget.employee.bio?.lastOrNull,
          jobtitleAr: widget.employee.titleInArabic?.lastOrNull,  // ✅ Pass Arabic job title
          userName: EmployeeHelper.getEmployeeFirstAndLastNames(
              employee: widget.employee),
          totalReview: 4.5,
          email: widget.employee.email!.last!,
          userProfession: EmployeeHelper.getEmployeeFirstAndLastNames(
              employee: widget.employee),
          userMobile: "${widget.employee.mobilePhone?.lastOrNull}" ??
              '' + "${widget.employee.mobilePhone!.last!}",
        ),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 0.04.w, vertical: 0.015.h),
        //   child: widget.employee.bio?.length == 0
        //       ? const SizedBox.shrink()
        //       : Container(
        //           width: double.infinity,
        //           decoration: BoxDecoration(
        //             color: Theme.of(context).colorScheme.inversePrimary,
        //             borderRadius: BorderRadius.circular(8),
        //           ),
        //           padding: EdgeInsets.symmetric(
        //               vertical: 0.015.h, horizontal: 0.02.w),
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(
        //                 "Bio:".tr,
        //                 style: AppFontStyle.cairoRegularStyle.copyWith(
        //                   fontSize: FontConstants.fontSize024.h,
        //                   fontWeight: FontWeight.w700,
        //                   color:
        //                       Theme.of(context).colorScheme.secondaryContainer,
        //                 ),
        //               ),
        //               SizedBox(height: 0.007.h),
        //               Text(
        //                 "${widget.employee.bio?.lastOrNull}",
        //                 style: AppFontStyle.cairoRegularStyle.copyWith(
        //                     fontSize: FontConstants.fontSize018.h,
        //                     fontWeight: FontWeight.w500,
        //                     color:
        //                         Theme.of(context).colorScheme.tertiaryContainer,
        //                     height: 1.5),
        //               ),
        //             ],
        //           ),
        //         ),
        // ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 0.04.w, vertical: 0.0.h),
              child: Column(
                children: [
                  EmployeeWorkInfoScreenEmployeeViewMobile(
                      employee: widget.employee),
                  SizedBox(height: 0.02.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
