// ignore_for_file: sdk_version_since

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/screen_size.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/notification/presentation/controller/notification_controller.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drawer.dart';
import 'package:demo_app/core/utils/app_image_provider.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatefulWidget {
  final bool isNotifications;
  ValueChanged<bool>? isNotState;

  CustomAppBar({
    super.key,
    this.isNotifications = false,
    this.isNotState,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

MainCoreNotificationController appNotificationController =
    Get.put(MainCoreNotificationController());

class _CustomAppBarState extends State<CustomAppBar> {
  final HapticController hapticController = Get.put(HapticController());
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return 
  Container();
    /* Container(
      width: double.infinity,
      color: Theme.of(context)
          .colorScheme
          .inversePrimary, // Background color inversePrimary
      padding: EdgeInsets.symmetric(
          horizontal: orientation ? 0.02.w : 0.06.h,
          vertical: orientation ? 0.01.h : 0.02.h),
      child: GestureDetector(
        onTap: () {
          hapticController.triggerHapticFeedback(
              vibration: VibrateType.mediumImpact,
              hapticFeedback: HapticFeedback.mediumImpact);
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: CustomDrawer(
                initialIndex: 18,
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 0.02.h),
            //   child: GestureDetector(
            //     onTap: () {
            //       hapticController.triggerHapticFeedback(
            //           vibration: VibrateType.mediumImpact,
            //           hapticFeedback: HapticFeedback.mediumImpact);
            //       widget.isNotifications == false
            //           ? Navigator.push(
            //               context,
            //               PageTransition(
            //                 type: PageTransitionType.fade,
            //                 child: CustomDrawer(
            //                   initialIndex: 19,
            //                 ),
            //               ),
            //             )
            //           : Navigator.pop(context);
            //     },
            //     child: Container(
            //       width: widget.isNotifications
            //           ? (isPortrait ? 0.04.h : 0.06.h)
            //           : .04.h,
            //       height: widget.isNotifications
            //           ? (isPortrait ? 0.04.h : 0.06.h)
            //           : .04.h,
            //       decoration: BoxDecoration(
            //           color: widget.isNotifications
            //               ? AppColors.lightPrimary
            //               : null,
            //           borderRadius: BorderRadius.circular(8)),
            //       child: StreamBuilder<QuerySnapshot>(
            //         stream: appNotificationController
            //             .getUnseenNotificationsStream(),
            //         builder: (context, snapshot) {
            //           if (snapshot.connectionState == ConnectionState.waiting) {
            //             return Center(
            //               child: SvgPicture.asset(
            //                 'assets/icons_assets/main_icons_assets/Bell.svg',
            //                 // ignore: deprecated_member_use
            //                 color: widget.isNotifications
            //                     ? AppColors.textButton
            //                     : Theme.of(context).colorScheme.scrim,
            //               ),
            //             );
            //           } else if (snapshot.hasError ||
            //               snapshot.data?.docs.isEmpty == true) {
            //             return Center(
            //               child: SvgPicture.asset(
            //                 'assets/icons_assets/main_icons_assets/Bell.svg',
            //                 // ignore: deprecated_member_use
            //                 color: widget.isNotifications
            //                     ? AppColors.textButton
            //                     : Theme.of(context).colorScheme.scrim,
            //               ),
            //             );
            //           } else {
            //             final unseenCount = snapshot.data?.docs.length ?? 0;
            //             return Badge(
            //               textColor: Colors.white,
            //               label: Text(
            //                 Get.locale.toString().contains('en')
            //                     ? '$unseenCount'
            //                     : convertNumberToArabic('$unseenCount'),
            //               ),
            //               largeSize: isPortrait
            //                   ? 19
            //                   : 0.025.h, //  largeSize:isPortrait? 0.02.h : 0.025.h,
            //               textStyle: AppFontStyle.cairoRegularStyle.copyWith(
            //                 fontSize: isPortrait
            //                     ? FontConstants.fontSize012.h
            //                     : FontConstants.fontSize018.h,
            //                 fontWeight: FontWeight.w600,
            //                 height: isPortrait
            //                   ? 1.3 :1.2,
            //                 color: Theme.of(context).colorScheme.inverseSurface,
            //               ),
            //               child: Center(
            //                 child: SvgPicture.asset(
            //                   'assets/icons_assets/main_icons_assets/Bell.svg',
            //                   // ignore: deprecated_member_use
            //                   color: widget.isNotifications
            //                       ? AppColors.textButton
            //                       : Theme.of(context).colorScheme.scrim,
            //                 ),
            //               ),
            //             );
            //           }
            //         },
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(
              width: orientation ? 0.02.w : 0.04.h,
            ),
            // Circular image
            Get.find<MainCoreEmployeeController>().employeeEntity?.photo == null
                ? CircleAvatar(
                    radius: orientation ? 0.02.h : 0.03.h,
                    backgroundColor: Colors.transparent,
                    backgroundImage: appImageProvider(
                        Get.find<MainCoreEmployeeController>()
                                    .employeeEntity
                                    ?.gender ==
                                'female'
                            ? 'assets/icons_assets/main_icons_assets/images_female.svg'
                            : 'assets/icons_assets/main_icons_assets/assets_male.svg'),
                  )
                : CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: orientation ? 0.02.h : 0.03.h,
                    backgroundImage: NetworkImage(
                        Get.find<MainCoreEmployeeController>()
                            .employeeEntity!
                            .photo!),
                  ),
            SizedBox(
              width: 0.02.h,
            ),
            // Texts
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Get.find<MainCoreEmployeeController>().getEmployeeName(
                      Get.find<MainCoreEmployeeController>().employeeEntity!.email!),
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: orientation
                          ? FontConstants.fontSize016.h
                          : FontConstants.fontSize018.h,
                      color:
                          themeController.currentTheme == AppColors.lightTheme
                              ? AppColors.colorBlack
                              : AppColors.colorWhiteDark,
                      fontWeight: FontWeight.w600,
                      height: orientation ? 2 : 0.002.h),
                ),
                Text(
                  // Mode.hr
                  //     ? 'HR'.tr
                  //     : Mode.owner
                  //         ? 'Owner'.capitalize as String
                  // :
                  Get.find<MainCoreEmployeeController>().employeeEntity!.role! ==
                          'ceo'
                      ? 'CEO'.tr
                      : Get.find<MainCoreEmployeeController>()
                          .employeeEntity!
                          .role!
                          .capitalize!
                          .tr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: orientation
                        ? FontConstants.fontSize014.h
                        : FontConstants.fontSize016.h,
                    color:
                        themeController.currentTheme == AppColors.lightTheme
                            ? AppColors.colorDarkGrey
                            : AppColors.colorGreydark,
                    fontWeight: FontWeight.w400,
                    height: orientation ? 1 : 0.0015.h,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
 */  }
}
