import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/nav_bar_package.dart/functions.dart';
import 'package:demo_app/core/nav_bar_package.dart/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/mode_changer.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/features/home/helper/task_management_module/borad/view/board_create/create_board_screen.dart';
import 'package:demo_app/features/home/helper/task_management_module/core/components/dialogs/create_board_dialog.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/rounded_image_text_container.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/role_responsive_page.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/role_screen.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/home/app_drawer/presentation/controller/drawer_controller.dart';
import 'package:demo_app/features/home/nav_bar/presentation/controller/nav_bar_controller.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/home/home_page/presentation/controller/skeleton_home_controller.dart';

class ActionButtonsRow extends StatelessWidget {
  ActionButtonsRow({super.key});

  SkeletonHomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final HapticController hapticController = Get.find();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Mode.owner != false ? 0 : 25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Mode.owner)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 25.h),
              child: Text(
                "Quick Actions".tr,
                style: isTablet
                    ? orientation
                        ? AppTextStyles.font20BlackCairoMedium
                        : AppTextStyles.font22BlackCairoMedium
                    : AppTextStyles.font18BlackCairoMedium,
              ),
            ),
          Row(
            children: [
              controller.modules.contains(Modules.tasks)
                  ? Expanded(
                      child: InkWell(
                        onTap: () {
                          isTablet
                              ? showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CreateBoardDialog(
                                      dropDownValueState: (value) {
                                        hapticController.triggerHapticFeedback(
                                          vibration: VibrateType.mediumImpact,
                                          hapticFeedback:
                                              HapticFeedback.mediumImpact,
                                        );
                                      },
                                    );
                                  },
                                )
                              : PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.fade,
                                  withNavBar: false,
                                  screen: const CreateBoardScreenMobile(),
                                );
                        },
                        child: RoundedImageTextContainer(
                          imagePath: "assets/icons_assets/home_assets/file_new2.svg",
                          text: "Create Tasks",
                          imageIcon: AppColors.primary,
                        ),
                      ),
                    )
                  : const SizedBox(),
              controller.modules.contains(Modules.tasks)
                  ? SizedBox(width: 20.w)
                  : const SizedBox.shrink(),
              Expanded(
                child: InkWell(
                  onTap: () {
                    hapticController.triggerHapticFeedback(
                        vibration: VibrateType.lightImpact,
                        hapticFeedback: HapticFeedback.lightImpact);
                    /*               showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CreateEditTodoDialog(searchText: "");
                      },
                    ); */
                  },
                  child: RoundedImageTextContainer(
                    imagePath: "assets/icons_assets/home_assets/todo_final.svg",
                    text: "Create To Do's",
                    imageIcon: AppColors.primary,
                  ),
                ),
              ),
              controller.modules.contains(Modules.messages)
                  ? SizedBox(width: 20.w)
                  : const SizedBox.shrink(),
              controller.modules.contains(Modules.messages)
                  ? Expanded(
                      child: InkWell(
                        onTap: () {
                          hapticController.triggerHapticFeedback(
                              vibration: VibrateType.lightImpact,
                              hapticFeedback: HapticFeedback.lightImpact);
                          if (isTablet) {
                            Get.find<AppDrawerController>().updateSelectedIndex(
                                Get.find<AppDrawerController>()
                                    .allowedDrawerModules
                                    .indexOf(Modules.messages));
                          } else {
                            Mode.controller.jumpToTab(
                                Get.find<NavBarController>()
                                    .navBarModules
                                    .indexOf(Modules.messages));
                          }
                        },
                        child: RoundedImageTextContainer(
                          imagePath: "assets/icons_assets/home_assets/messages_home.svg",
                          text: "Send Messages",
                          imageIcon: AppColors.primary,
                        ),
                      ),
                    )
                  : const SizedBox(),
              if (Mode.owner) SizedBox(width: 20.w),
              if (Mode.owner)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      hapticController.triggerHapticFeedback(
                          vibration: VibrateType.lightImpact,
                          hapticFeedback: HapticFeedback.lightImpact);
                      isTablet
                          ? Get.find<AppDrawerController>().updateSelectedIndex(
                              Get.find<AppDrawerController>()
                                  .allowedDrawerModules
                                  .indexOf(Modules.settings))
                          : Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: SettingsScreen(),
                              ));
                    },
                    child: RoundedImageTextContainer(
                      imagePath: "assets/icons_assets/home_assets/update_info.svg",
                      text: "Update Info's",
                      imageIcon: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (Mode.owner)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 25.h),
              child: Text(
                "System Managements".tr,
                style: isTablet
                    ? orientation
                        ? AppTextStyles.font20BlackCairoMedium
                        : AppTextStyles.font22BlackCairoMedium
                    : AppTextStyles.font18BlackCairoMedium,
              ),
            ),
          if (Mode.owner != false)
            Row(
              children: [
                if (!isTablet) const Expanded(flex: 1, child: SizedBox()),
                Expanded(
                  flex: isTablet ? 1 : 2,
                  child: InkWell(
                    onTap: () {
                      hapticController.triggerHapticFeedback(
                          vibration: VibrateType.lightImpact,
                          hapticFeedback: HapticFeedback.lightImpact);
                      isTablet
                          ? Get.find<AppDrawerController>().updateSelectedIndex(
                              Get.find<AppDrawerController>()
                                  .allowedDrawerModules
                                  .indexOf(Modules.roles))
                          : Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: RoleResponsivePage(),
                              ),
                            );
                    },
                    child: RoundedImageTextContainer(
                      imagePath: "assets/icons_assets/home_assets/create_role_new1.svg",
                      text: "Create Roles",
                      imageIcon: Color(0xFF4BB609),
                    ),
                  ),
                ),
                controller.modules.contains(Modules.employees)
                    ? SizedBox(width: !isTablet ? 20.w : 20.w)
                    : const SizedBox.shrink(),
                controller.modules.contains(Modules.employees)
                    ? Expanded(
                        flex: isTablet ? 1 : 2,
                        child: InkWell(
                          onTap: () {},
                          child: RoundedImageTextContainer(
                            imagePath: "assets/icons_assets/home_assets/add_employee_new1.svg",
                            text: "Add Employees",
                            imageIcon: AppColors.primary,
                          ),
                        ),
                      )
                    : const SizedBox(),
                SizedBox(width: !isTablet ? 20.w : 20.w),
                Expanded(
                  flex: isTablet ? 1 : 2,
                  child: InkWell(
                    onTap: () {
                      hapticController.triggerHapticFeedback(
                          vibration: VibrateType.lightImpact,
                          hapticFeedback: HapticFeedback.lightImpact);
                      if (isTablet) {
                        Get.find<AppDrawerController>().updateSelectedIndex(
                            Get.find<AppDrawerController>()
                                .allowedDrawerModules
                                .indexOf(Modules.roles),
                            isOnlyDrawer: true);
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: RoleScreen(
                              selectedIndex: 2,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: RoleResponsivePage(
                                //selectedIndex: 2,
                                ),
                          ),
                        );
                      }
                    },
                    child: RoundedImageTextContainer(
                      imagePath: "assets/icons_assets/home_assets/deactivate1.svg",
                      text: "Deactivate Users",
                      imageIcon: Color(0xFFB81512),
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                if (isTablet)
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.lightImpact,
                            hapticFeedback: HapticFeedback.lightImpact);
                        Get.find<AppDrawerController>().updateSelectedIndex(
                            Get.find<AppDrawerController>()
                                .allowedDrawerModules
                                .indexOf(Modules.roles),
                            isOnlyDrawer: true);
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: RoleScreen(selectedIndex: 4),
                          ),
                        );
                      },
                      child: RoundedImageTextContainer(
                        imagePath: "assets/icons_assets/home_assets/export_loggs.svg",
                        text: "Export logs",
                        imageIcon: AppColors.primary,
                      ),
                    ),
                  ),
                if (!isTablet) const Expanded(flex: 1, child: SizedBox())
              ],
            ),
        ],
      ),
    );
  }
}
