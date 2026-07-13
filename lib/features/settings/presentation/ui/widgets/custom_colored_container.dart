import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';

import 'package:demo_app/core/haptic/haptic_controller.dart';

import 'package:demo_app/core/theme/app_font_size.dart';

class CustomColoredContainer extends StatelessWidget {
  final bool isSelected;
  final String labelText;
  final VoidCallback onTap;
  final BorderRadiusGeometry? borderRadius;
  final double? horizontalPadding;

  const CustomColoredContainer({
    super.key,
    required this.isSelected,
    required this.labelText,
    required this.onTap,
    this.borderRadius,
    this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = Get.put(HapticController());

    final backgroundColor = isSelected
        ? AppColors.signOut
        : Theme.of(context).colorScheme.inversePrimary;
    final textColor = Colors.black;
    final orientation = MediaQuery.of(context).orientation;

    

    List<String> arabicWords = [];

    

    return Expanded(
      child: GestureDetector(
        onTap: () {
          hapticController.triggerHapticFeedback(
              vibration: VibrateType.lightImpact,
              hapticFeedback: HapticFeedback.lightImpact);
          onTap();
        },
        child: Container(
          // width: orientation == Orientation.portrait
          //     ? horizontalPadding /*0.101.w*/
          //     : 0.286.h,
          height: orientation == Orientation.portrait ? 0.052.h : 0.072.h,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius ?? BorderRadius.circular(0),
          ),
          child:   Row(
                  // Display text in a row for other languages
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          labelText.tr,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize022.h,
                            color: isSelected == true
                                ? AppColors.colorBlack
                                : Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                            fontWeight: Get.locale.toString().contains('en')
                                ?   isSelected == true
                                  ? FontWeight.w600 :FontWeight.w400
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}