import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drawer.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';

class BreadCrumbsNavigationMembers extends StatelessWidget {
  const BreadCrumbsNavigationMembers({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    TextStyle breadCrumbsTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isPortrait
          ? FontConstants.fontSize018.h
          : FontConstants.fontSize025.h,
      fontWeight: FontWeight.w600,
      overflow: TextOverflow.ellipsis,
      color: Theme.of(context).colorScheme.inverseSurface,
      height: isPortrait ? 1.6 : 0.002.h,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            hapticController.triggerHapticFeedback(
                vibration: VibrateType.lightImpact,
                hapticFeedback: HapticFeedback.lightImpact);

            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: CustomDrawer(
                  initialIndex: 1,
                ),
              ),
            );
          },
          child: Text(
            "Board".tr,
            style: breadCrumbsTextStyle,
          ),
        ),
        SizedBox(
          width: isPortrait ? 0.005.w : 0.015.h,
        ),
        SvgPicture.asset(
          matchTextDirection: Get.locale?.languageCode == 'ar',
          'assets/icons_assets/main_icons_assets/images_arrow.svg',
          height: isPortrait ? 0.025.h : 0.04.h,
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
        SizedBox(
          width: isPortrait ? 0.005.w : 0.015.h,
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            "Project".tr.capitalize as String,
            style: breadCrumbsTextStyle,
          ),
        ),
        SizedBox(
          width: isPortrait ? 0.005.w : 0.015.h,
        ),
        SvgPicture.asset(
          matchTextDirection: Get.locale?.languageCode == 'ar',
          'assets/icons_assets/main_icons_assets/images_arrow.svg',
          height: isPortrait ? 0.025.h : 0.04.h,
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
        Text(
          "Members".tr,
          style: breadCrumbsTextStyle,
        ),
      ],
    );
  }
}
