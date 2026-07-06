import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/project_screen/project_screen.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/custom_drawer.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';

class TaskDetailsAppBarTablet extends StatefulWidget {
  final String taskName;
  final String listName;
  final String projectName;
  final List<CardModel> cards;
  final BoardModel boardModel;

  const TaskDetailsAppBarTablet({
    super.key,
    required this.taskName,
    required this.listName,
    required this.projectName,
    required this.cards,
    required this.boardModel,
  });

  @override
  State<TaskDetailsAppBarTablet> createState() =>
      _TaskDetailsAppBarTabletState();
}

class _TaskDetailsAppBarTabletState extends State<TaskDetailsAppBarTablet> {
  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = Get.put(HapticController());
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    TextStyle breadCrumbsTextStyle = TextStyle(
      fontSize: orientation
          ? FontConstants.fontSize018.h
          : FontConstants.fontSize025.h,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.inverseSurface,
      height: orientation ? 1.6 : 0.002.h,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: orientation ? 0.8.w : 0.8.w,
          child: Row(
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
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: orientation ? 0.005.w : 0.015.h,
              ),
              SvgPicture.asset(
                matchTextDirection: Get.locale?.languageCode == 'ar',
                'assets/icons_assets/main_icons_assets/images_arrow.svg',
                height: orientation ? 0.025.h : 0.04.h,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              SizedBox(
                width: orientation ? 0.005.w : 0.015.h,
              ),
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
                        screens: [
                          Container(),
                          ProjectScreen(
                            boardModel: widget.boardModel,
                            projectName: widget.projectName,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Text(
                  widget.projectName.tr.capitalize as String,
                  style: breadCrumbsTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: orientation ? 0.005.w : 0.015.h,
              ),
              SvgPicture.asset(
                matchTextDirection: Get.locale?.languageCode == 'ar',
                'assets/icons_assets/main_icons_assets/images_arrow.svg',
                height: orientation ? 0.025.h : 0.04.h,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              SizedBox(
                width: orientation ? 0.005.w : 0.015.h,
              ),
              Expanded(
                child: Text(
                  widget.taskName.tr.capitalize as String,
                  style: breadCrumbsTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 0.03.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.taskName.tr.capitalize as String,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: orientation
                        ? FontConstants.fontSize028.h
                        : FontConstants.fontSize035.h,
                    color:
                        themeController.currentTheme == AppColors.lightTheme
                            ? AppColors.colorBlack
                            : AppColors.colorWhiteDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: null,
                ),
              ),

              // Spacer(),
              // GestureDetector(
              //   onTap: () {
              //     hapticController.triggerHapticFeedback(
              //       vibration: VibrateType.heavyImpact,
              //       hapticFeedback: HapticFeedback.heavyImpact,
              //     );
              //     // Add your functionality for deleting the task
              //   },
              //   child: SvgPicture.asset(
              //     'assets/icons_assets/task_assets/threeDotsHori.svg',
              //     width: 0.03.h,
              //    color: themeController.currentTheme == AppColors.lightTheme
              //       ? AppColors.colorBlack
              //       : AppColors.colorWhiteDark,
              //   ),
              // ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            style: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: orientation
                  ? FontConstants.fontSize020.h
                  : FontConstants.fontSize027.h,
              fontWeight: FontWeight.w600,
            ),
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Text(
                  "In list ".tr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: orientation
                        ? FontConstants.fontSize018.h
                        : FontConstants.fontSize025.h,
                    color:
                        themeController.currentTheme == AppColors.lightTheme
                            ? Colors.grey
                            : Colors.grey[300],
                  ),
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Text(
                  " ${widget.listName.tr.capitalize as String} ",
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: orientation
                        ? FontConstants.fontSize018.h
                        : FontConstants.fontSize025.h,
                    color:
                        themeController.currentTheme == AppColors.lightTheme
                            ? AppColors.colorBlack
                            : AppColors.colorGrey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 0.02.h,
        ),
      ],
    );
  }
}
