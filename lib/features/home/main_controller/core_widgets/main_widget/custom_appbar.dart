// ignore_for_file: sdk_version_since

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/notification/presentation/controller/app_notification_cubit.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/date_time_in_arabic.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';


// REMOVED_MODULE: import 'package:grc_module/features/skeleton/controllers/notification_controller.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';

import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:grc_module/features/notification/presentation/ui/pages/notification_page.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/helper/main_helper/arabic_number_format.dart';
import 'package:grc_module/core/helper/main_helper/extensions.dart' hide ContextExtension;

// ignore: must_be_immutable
class CustomAppBar extends StatefulWidget {
  final bool isNotifications;
  ValueChanged<bool>? isNotState;

  CustomAppBar({
    Key? key,
    this.isNotifications = false,
    this.isNotState,
  }) : super(key: key);

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
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<AppDrawerCubit, AppDrawerState>(
      bloc: Get.find<AppDrawerCubit>(),
      builder: (context, _) {
        print("updated");
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
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
                  drawerController.updateSelectedIndex(19);
                },
                child: Container(
                  width: (isPortrait ? 40.h : 60.h),
                  height: (isPortrait ? 40.h : 60.h),
                  decoration: BoxDecoration(
                      color: drawerController.selectedIndex == 19
                          ? Colors.transparent
                          : null,
                      borderRadius: BorderRadius.circular(8)),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: appNotificationController
                        .getUnseenNotificationsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: SvgPicture.asset(
                            width: 35.w,
                            height: 35.h,
                            fit: BoxFit.fill,
                            'assets/icons_assets/main_icons_assets/notification_bell_badge_red.svg',
                            color: drawerController.selectedIndex == 19
                                ? AppColors.textButton
                                : Theme.of(context).colorScheme.scrim,
                          ),
                        );
                      } else if (snapshot.hasError ||
                          snapshot.data?.docs.isEmpty == true) {
                        return Center(
                          child: SvgPicture.asset(
                            width: 35.w,
                            height: 35.h,
                            fit: BoxFit.fill,
                            'assets/icons_assets/main_icons_assets/notification_bell_badge_red.svg',
                            // color: drawerController.selectedIndex == 19
                            //     ? AppColors.textButton
                            //     : Theme.of(context).colorScheme.scrim,
                          ),
                        );
                      } else {
                        final unseenCount = snapshot.data?.docs.length ?? 0;
                        return Badge(
                          textColor: Colors.white,
                          label: Text(
                            Get.locale.toString().contains('en')
                                ? '$unseenCount'
                                : ArabicDigits('$unseenCount').toArabicNumbers(),
                          ),
                          largeSize: isPortrait
                              ? 19
                              : 25.h, //  largeSize:isPortrait? 0.02.h : 0.025.h,
                          textStyle: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: isPortrait
                                ? FontConstants.fontSize012.h
                                : FontConstants.fontSize018.h,
                            fontWeight: FontWeight.w600,
                            height: isPortrait ? 1.3 : 1.2,
                            color:
                            Theme.of(context).colorScheme.inverseSurface,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              width: 35.w,
                              height: 35.h,
                              fit: BoxFit.fill,
                              'assets/icons_assets/main_icons_assets/notification_bell.svg',
                              // color: drawerController.selectedIndex == 19
                              //     ? AppColors.textButton
                              //     : Theme.of(context).colorScheme.scrim,
                            ),
                          ),
                        );
                      }
                    },
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
                        '${Get.locale.toString().contains('en') ? employee!.firstName!.last!.capitalize : employee!.firstNameInArabic!.last!} ${Get.locale.toString().contains('en') ? employee!.lastName!.last!.capitalize : employee!.lastNameInArabic!.last!}',
                          style:StyleText.fontSize18Weight500.copyWith(
                              color: AppColors.text
                          )
                      ),
                      Text(
                        FormatHelper.capitalize(
                          ContextExtension(context).isArabic
                              ? employee!.titleInArabic
                              ?.lastOrNull ??
                              ''
                              : employee!.title?.lastOrNull ?? '',
                        ),
                        style:StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.text
                        )
                      ),
                    ],
                  ),
                  SizedBox(width: 20.h),
                  employee?.photo == null ||
                      employee!.photo!.isEmpty ||
                      employee!.photo!.last == null ||
                      employee!.photo!.last!.isEmpty
                      ? CircleAvatar(
                    radius: orientation ? 20.h : 30.h,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage(
                        employee!.gender?.lastOrNull == 'female'
                            ? 'assets/icons_assets/main_icons_assets/female_avatar.png'
                            : 'assets/icons_assets/main_icons_assets/male_avatar.png'),
                  )
                      : CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: orientation ? 20.h : 30.h,
                    backgroundImage: NetworkImage(employee!.photo!.last!),
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