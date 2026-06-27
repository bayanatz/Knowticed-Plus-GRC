import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/employees_hr_appbar.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/custom_container_photo.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';

import 'package:demo_app/core/theme/app_colors.dart';

// ignore: must_be_immutable
class ButtonsBesideTitle extends StatefulWidget {
  ButtonsBesideTitle(
      {super.key,
      required this.chartSelected,
      required this.chartSelectedState,
      required this.orgSelected,
      required this.orgSelectedState});
  bool chartSelected;
  ValueChanged<bool> chartSelectedState;
  bool orgSelected;
  ValueChanged<bool> orgSelectedState;

  @override
  State<ButtonsBesideTitle> createState() => _ButtonsBesideTitleState();
}

class _ButtonsBesideTitleState extends State<ButtonsBesideTitle> {
  final HapticController hapticController = Get.put(HapticController());
  @override
  Widget build(BuildContext context) {

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Row(
      mainAxisAlignment:
          isTablet ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
      children: <Widget>[
    /*     GestureDetector(
                onTap: () {
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.lightImpact,
                      hapticFeedback: HapticFeedback.lightImpact);
                  setState(() {
                    if (widget.chartSelected == false) {
                      widget.orgSelected = false;
                      widget.orgSelectedState(widget.orgSelected);
                      widget.chartSelected = !widget.chartSelected;
                      widget.chartSelectedState(widget.chartSelected);
                    }
                  });
                },
                child: CustomPhotoContainer(
                    imageUrl: "assets/images/chart.svg",
                    backColor: widget.chartSelected
                        ? AppColors.signOut
                        : Theme.of(context).colorScheme.inversePrimary,
                   borderColor: Colors.transparent,
                    photoColor: widget.chartSelected
                        ? AppColors.textButton
                        : Theme.of(context).colorScheme.scrim),
              )
           ,*/
        Padding(
            padding: EdgeInsets.only(
                left: Get.locale.toString().contains('en')
                    ? isPortrait
                        ? 0.025.w
                        : 0.015.w
                    : 0,
                right: Get.locale.toString().contains('en')
                    ? 0
                    : isPortrait
                        ? 0.025.w
                        : 0.015.w),
            child: GestureDetector(
              onTap: () {
                hapticController.triggerHapticFeedback(
                    vibration: VibrateType.lightImpact,
                    hapticFeedback: HapticFeedback.lightImpact
                );
                setState(() {
                  if (widget.orgSelected == false) {
                    widget.chartSelected = false;
                    widget.chartSelectedState(widget.chartSelected);
                    widget.orgSelected = !widget.orgSelected;
                    widget.orgSelectedState(widget.orgSelected);
                  }
                });
              },
              child: CustomPhotoContainer(
                  imageUrl: "assets/images/Org2.svg",
                  backColor: AppColors.primary,
                  borderColor: Colors.transparent,

                  photoColor: widget.orgSelected
                      ? AppColors.textButton
                      : Theme.of(context).colorScheme.scrim),
            )),
      ],
    );
  }
}
