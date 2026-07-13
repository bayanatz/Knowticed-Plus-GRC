/// ************************ FILe INFO ********************************///
/// File Name: home_appbar_section.dart
/// Purpose: Contains the appbar section for the home screen
/// Author: Mohamed Elrashidy
/// Refactored at: 9/2/2025

import 'package:demo_app/core/custom/preview.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/timeline_widget.dart';
import 'package:demo_app/core/enums/enum.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/inventory_module/core/navigate.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/gradiant_container.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
// REMOVED_MODULE: import 'package:demo_app/external/services_mangment_module/core/new_theme.dart';
// REMOVED_MODULE: import 'package:demo_app/external/todo_new_module/external/tasks_module/category/presentation/screens/to_do_list/details_screen/hr_module/add_new_employee_screen.dart';
// REMOVED_MODULE: import 'package:demo_app/external/todo_new_module/external/tasks_module/category/presentation/screens/to_do_list/details_screen/hr_module/hr_dashboard.dart';
import 'package:demo_app/features/home/app_drawer/presentation/controller/drawer_controller.dart';
import 'package:demo_app/core/twillo/twilio_constants.dart';
import 'package:demo_app/core/twillo/twilio_repository.dart';
import 'package:demo_app/features/home/home_page/presentation/controller/home_cubit.dart';
import 'package:demo_app/features/home/home_page/presentation/controller/skeleton_home_controller.dart';

class HomeAppbarSection extends StatelessWidget {
  HomeAppbarSection({Key? key}) : super(key: key);
  SkeletonHomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final homeCubit = context.read<AppHomeCubit>();
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: EdgeInsets.only(top: 25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(
                        "assets/icons_assets/home_assets/homeCalen.svg",
                        height: orientation ? 20.h : 25.h,
                        color: lightMode ? AppColors.blackButton : AppColors.white
                      ),
                    ),
                    SizedBox(width: 10.sp),
                    GestureDetector(
                      onTap: (){
                     //   navigateTo(context, AnimationsShowcaseScreen());
                      },
                      child: Text(
                        controller.getCurrentDate(),
                        style: StyleText.fontSize20Weight600.copyWith(
                          color: lightMode ? AppColors.blackButton : AppColors.white
                        )
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),
              // Header icons
              if (homeCubit.selectedHeaderIcons.isNotEmpty)
                Row(
                  spacing: 8.sp,
                  children: [
                    for (var icon in homeCubit.selectedHeaderIcons)
                      InkWell(
                        onTap: () {
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => icon.navigateTo(context),
                          //   ),
                          // );
                        },
                        child: Container(
                          width: 48.sp,
                          height: 48.sp,
                          padding: EdgeInsets.all(8.sp),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: CustomSvg(
                            assetPath: icon.svgPath,
                            fit: BoxFit.contain,
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: (){
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) =>  HrDashboard()),
              // );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PreviewAllCustomPage()),
              );
            },
            child: Text(
              "${DateTime.now().hour < 12 ? 'Good Morning'.tr : DateTime.now().hour < 14 ? 'Good Afternoon'.tr : 'Good Evening'.tr} ${Get.locale.toString().contains('en') ? employee!.firstName!.last!.capitalize : employee!.firstNameInArabic!.last!}",
              style: StyleText.fontSize24Weight600.copyWith(
                color: lightMode ? AppColors.blackButton : AppColors.white
              )
            ),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
              onTap: () async {
               // // final locale = context.read<ThemeCubit>().isArabic ? 'ar' : 'en';
               //  await TwilioRepository().sendOTP("amrmesbah33@gmail.com", "email", 'en');
               //  await TwilioRepository().sendOTP("+201124753420", "sms", 'en');
               //
               //
               //  //  await TwilioRepository().testTwilioAuth();
              },
              child: GradientContainer()),
        ],
      ),
    );
  }
}
