// ignore_for_file: sdk_version_since
/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: custom_appbar.dart
/// Purpose: Declares `CustomAppBar`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/features/notification/presentation/controller/app_notification_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/navigation/notification_bell.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

// REMOVED_MODULE: import 'package:knowticed_plus/features/skeleton/controllers/notification_controller.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/pages/settings_screen.dart';

import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

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

AppNotificationCubit appNotificationController =
    Get.put(AppNotificationCubit());

class _CustomAppBarState extends State<CustomAppBar> {
  final HapticController hapticController = Get.put(HapticController());

  AppDrawerCubit drawerController = Get.find();
  @override
  Widget build(BuildContext context) {
    Theme.of(context).brightness == Brightness.light;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<AppDrawerCubit, AppDrawerState>(
      bloc: Get.find<AppDrawerCubit>(),
      builder: (context, _) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.transparent),
            color: AppColors.card,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0.r),
            ),
          ),
          height: 90.sp,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.mediumImpact,
                      hapticFeedback: HapticFeedback.mediumImpact);

                  // Update the drawer to show notifications instead of navigating
                  drawerController
                      .updateSelectedIndex(NotificationRouting.inboxShellIndex);
                },
                child: Container(
                  width: (isPortrait ? 40.h : 60.h),
                  height: (isPortrait ? 40.h : 60.h),
                  decoration: BoxDecoration(
                      color: drawerController.selectedIndex ==
                              NotificationRouting.inboxShellIndex
                          ? AppColors.transparent
                          : null,
                      borderRadius: BorderRadius.circular(8)),
                  // 22/10/2026 — Owner: one bell, the count inside it (see
                  // NotificationBell).
                  child: Center(
                    child: NotificationBell(
                        controller: appNotificationController, size: 35.w),
                  ),
                ),
              ),
              SizedBox(width: orientation ? 20.w : 40.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10.sp,
                    children: [
                      Text(
                          '${context.isEnglish ? employee!.firstName.last.capitalize : employee!.firstNameInArabic.last} ${context.isEnglish ? employee!.lastName.last.capitalize : employee!.lastNameInArabic.last}',
                          style: StyleText.fontSize18Weight500
                              .copyWith(color: AppColors.text)),
                      Text(
                          FormatHelper.capitalize(
                            ContextExtension(context).isArabic
                                ? employee!.titleInArabic.lastOrNull ?? ''
                                : employee!.title.lastOrNull ?? '',
                          ),
                          style: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.text)),
                    ],
                  ),
                  SizedBox(width: 20.h),
                  employee?.photo == null ||
                          employee!.photo.isEmpty ||
                          employee!.photo.last.isEmpty
                      ? CircleAvatar(
                          radius: orientation ? 20.h : 30.h,
                          backgroundColor: AppColors.transparent,
                          backgroundImage: AssetImage(employee!
                                      .gender.lastOrNull ==
                                  'female'
                              ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png'
                              : 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'),
                        )
                      : CircleAvatar(
                          backgroundColor: AppColors.transparent,
                          radius: orientation ? 20.h : 30.h,
                          backgroundImage: NetworkImage(employee!.photo.last),
                        )

                  // Texts
                ],
              ),
              SizedBox(width: 15.w),
            ],
          ),
        );
      },
    );
  }
}
