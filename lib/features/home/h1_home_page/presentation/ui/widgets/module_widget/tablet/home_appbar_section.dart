/// ************************ FILe INFO ********************************///
/// File Name: home_appbar_section.dart
/// Purpose: Contains the appbar section for the home screen
/// Author: Amr Mesbah
/// Refactored at: 9/2/2025

import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/navigate.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/gradiant_container.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
// REMOVED_MODULE: import 'package:grc_module/external/services_mangment_module/core/new_theme.dart';
// REMOVED_MODULE: import 'package:grc_module/external/todo_new_module/external/tasks_module/category/presentation/screens/to_do_list/details_screen/hr_module/add_new_employee_screen.dart';
// REMOVED_MODULE: import 'package:grc_module/external/todo_new_module/external/tasks_module/category/presentation/screens/to_do_list/details_screen/hr_module/hr_dashboard.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:grc_module/core/twillo/twilio_constants.dart';
import 'package:grc_module/core/twillo/twilio_repository.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/skeleton_home_controller.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/generated/l10n.dart';
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
                        "assets/icons_assets/home_assets/todo_scheduled_calendar.svg",
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
                          child: CustomSvgImage(
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
            // onTap: (){
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) =>  HrDashboard()),
            //   );
            // },
            child: Text(
              "${DateTime.now().hour < 12 ? S.of(context).goodMorning : DateTime.now().hour < 14 ? S.of(context).goodAfternoon : S.of(context).goodEvening} ${Get.locale.toString().contains('en') ? employee!.firstName!.last!.capitalize : employee!.firstNameInArabic!.last!}",
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
