import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/constants/image_paths.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_additional_info.dart';

import 'package:demo_app/core/custom/33-custom_haptic.dart';

Row titleRow(
    BuildContext context, bool orientation, String title, Function()? onTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () {
          onTap!();
          hapticController.triggerHapticFeedback(
              vibration: VibrateType.lightImpact,
              hapticFeedback: HapticFeedback.lightImpact);
        },
        child: Transform.rotate(
          angle: Get.locale.toString().contains('ar') ? 3.13 : 0,
          child: Transform.scale(
            scale: orientation ? 0.0014.h : 0.0023.h,
            child: SvgPicture.asset(
              // ignore: deprecated_member_use
              color: Theme.of(context).colorScheme.onInverseSurface,
              ImagePaths.getImagePath(
                context,
                'back_icon',
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        width: 0.01.w,
      ),
      Text(
        title.tr,
        style: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: orientation
              ? FontConstants.fontSize024.h
              : FontConstants.fontSize038.h,
          fontWeight: FontWeight.w600,
          letterSpacing: Get.locale.toString().contains('en') ? 1.1 : null,
          height: 1.8,
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
      ),
    ],
  );
}
