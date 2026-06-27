import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/constants/image_paths.dart';
import 'package:demo_app/core/enums/enum.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/home/app_drawer/presentation/ui/pages/custom_drawer.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/core/helper/employees/core_widgets/main_widget/timeline_widget.dart';

class AddNewEmployeePageTitle extends StatelessWidget {
  const AddNewEmployeePageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        IconButton(
          onPressed: () {
/*            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: CustomDrawer(initialIndex: 2),
              ),
            );*/

            hapticController.triggerHapticFeedback(
                vibration: VibrateType.lightImpact,
                hapticFeedback: HapticFeedback.lightImpact);
          },
          icon: Transform.translate(
            offset: Get.locale.toString().contains('en')
                ? Offset(-0.006.w, -0.0015.h)
                : Offset(-0.006.w, 0.001.h),
            child: Transform.rotate(
              angle: Get.locale.toString().contains('ar') ? 3.13 : 0,
              child: Transform.scale(
                scale: 0.0023.h,
                child: SvgPicture.asset(
                  // ignore: deprecated_member_use
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  ImagePaths.getImagePath(context, 'back_icon'),
                ),
              ),
            ),
          ),
        ),
        Text(
          "Add New Employees".tr,
          style: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: FontConstants.fontSize038.h,
              fontWeight: Get.locale.toString().contains('en')
                  ? FontWeight.w600
                  : FontWeight.w500,
              letterSpacing: Get.locale.toString().contains('en') ? 1.1 : null,
              height: 0.0018.h,
              color: Theme.of(context).colorScheme.inverseSurface),
        ),
      ],
    );
  }
}
