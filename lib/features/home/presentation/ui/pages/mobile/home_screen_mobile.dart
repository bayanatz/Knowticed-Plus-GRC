import 'package:demo_app/core/nav_bar_package.dart/functions.dart';
import 'package:demo_app/core/nav_bar_package.dart/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_appbar_mobile.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/inventory_module/core/navigate.dart';
import 'package:demo_app/features/home/presentation/ui/widgets/gradiant_container.dart';
import 'package:demo_app/features/home/presentation/ui/widgets/upcoming_schedule_listview.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/home/presentation/ui/widgets/action_button_row.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/timeline_widget.dart';
import 'package:demo_app/features/settings/mode_changer.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../nav_bar/presentation/controller/nav_bar_controller.dart';
import '../../../../../notification/notification_control.dart';
import '../../../../data/models/home_component_model.dart';
import '../../../controller/home_cubit.dart';
import '../../../controller/home_state.dart';
import '../../../controller/skeleton_home_controller.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import '../../../../utils/home_constants.dart';



/// Date Created :12/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :27/May/2024
/// Objectives: this screen is the home page, this page consist of multiple widgets:

class HomeScreenMobile extends StatefulWidget {
  const HomeScreenMobile({super.key});

  @override
  State<HomeScreenMobile> createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends State< HomeScreenMobile> {
  SkeletonHomeController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    final homeCubit = context.read<AppHomeCubit>();

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<AppHomeCubit, HomeState>(
        buildWhen: (_, __) {
          return true;
        },
    builder: (context, state) {
      return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Container(
            color:AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomAppBarMobile(
                  showIcon: false,
                  isHome: true,
                  showMoreIcon: true,
                  showNotification: true,
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: Container(
                         color: AppColors.background,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              // ElevatedButton(onPressed: (){
                              //   navigateTo(context, NotificationControlPage());
                              // }, child: Text("data")),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/CalendarHome.svg",
                                    color: AppColors.icon,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    controller.getCurrentDate(),
                                    style:
                                    AppTextStyles.font20SecondaryBlackMediumCairo
                                        .copyWith(
                                      height:1.8,
                                        color: AppColors.icon)
                                  ,
                                  ),
                                ],
                              ),
                              controller.modules.contains(Modules.employees)
                                  ? GestureDetector(
                                      onTap: () {
                                        hapticController.triggerHapticFeedback(
                                            vibration: VibrateType.lightImpact,
                                            hapticFeedback: HapticFeedback.lightImpact);
                                        if(Get.find<NavBarController>().navBarModules.contains(Modules.employees)) {
                                          Mode.controller.jumpToTab(Get.find<NavBarController>()
                                            .navBarModules
                                            .indexOf(Modules.employees));
                                        } else {
                                          PersistentNavBarNavigator.pushNewScreen(context,
                                              pageTransitionAnimation:
                                              PageTransitionAnimation.fade,
                                              withNavBar: true,
                                              screen: Modules.employees.widget)    ;                                  }
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.signOut,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.all(8.h),
                                          child: SvgPicture.asset(
                                            "assets/icons/orgIconHome.svg",
                                            color: AppColors.black,
                                          )),
                                    )
                                  : const SizedBox()
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "${DateTime.now().hour < 12 ? 'Good Morning'.tr : DateTime.now().hour < 14 ? 'Good Afternoon'.tr : 'Good Evening'.tr} ${Get.locale.toString().contains('en') ? employee!.firstName!.last!.capitalize : employee!.firstNameInArabic!.last!.capitalize}",
                            style:
                            AppTextStyles.font25BlackSemiBoldCairo
                                .copyWith(height: 1.4),
                          ),
                          SizedBox(height: 15.h),
                          GradientContainer(),
                          SizedBox(height: 15.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10.sp,
                            children: [
                              for (int rowIndex = 0;
                              rowIndex < HomeConstants.NUMBER_OF_ROWS;
                              rowIndex++)
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    spacing: 10.sp,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (HomeComponentModel component in homeCubit
                                          .getActiveRowComponents(rowIndex))
                                        component.component.widget(component) ??
                                            Container()
                                    ],
                                  ),
                                ),
                            ],
                          ),



                       //   ActionButtonsRow(),
                        //  SizedBox(height: 20.h),
                          // Padding(
                          //   padding: EdgeInsets.symmetric(vertical: 10.h),
                          //   child: Text(
                          //     "Upcoming Schedule".tr,
                          //     style:AppTextStyles.font20BlackCairoMedium,
                          //   ),
                          // ),
                          // UpcomingScheduleListview(
                          //     selectedDate: [DateTime.now()]),
                          // SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    );
  }
}
