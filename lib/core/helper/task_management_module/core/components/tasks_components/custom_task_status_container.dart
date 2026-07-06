import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/task_details_screen_tablet.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/utils/app_image_provider.dart';

/// Date Created :20/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/November/2023 By Bassem
/// Objectives:  this file represents the custom container for the tasks with its all detailes, it consist of a title , image, description, deadline for this task, total number of tasks finshed and the total tasks already finshed, and members in this task

class CustomStatusContainer extends StatefulWidget {
  final String? imagePath;
  final String title;
  final String projectName;
  final String listName;
  final String description;
  final DateTime? finalDate;
  final String? firstImage;
  final String? secondImage;
  final String? thirdImage;
  final int currentCount;
  final int totalCount;
  final int? totalAttachment;
  final int? totalComments;
  final List<CardModel> cards;
  final BoardModel boardModel;

  const CustomStatusContainer({
    super.key,
    this.imagePath,
    required this.title,
    required this.description,
    required this.projectName,
    required this.listName,
    this.finalDate,
    this.firstImage,
    this.secondImage,
    this.thirdImage,
    required this.currentCount,
    required this.totalCount,
    this.totalAttachment,
    this.totalComments,
    required this.cards,
    required this.boardModel,
  });

  @override
  State<CustomStatusContainer> createState() => _CustomStatusContainerState();
}

final HapticController hapticController = Get.put(HapticController());

class _CustomStatusContainerState extends State<CustomStatusContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hapticController.triggerHapticFeedback(
            vibration: VibrateType.mediumImpact,
            hapticFeedback: HapticFeedback.mediumImpact);
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: TaskDetailsTabletScreen(
              currentCard:
                  widget.cards.first, /////////////////////////////////////
              boardModel: widget.boardModel,
              cards: widget.cards,
              department: widget.boardModel.boardDeparment!.boardgDepartment!.last,
              projectName: widget.projectName,
              listName: widget.listName,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 0.02.h),
            child: Container(
              width: 0.283.w, //0.428.h,
              decoration: BoxDecoration(
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorWhite
                    : Theme.of(context).colorScheme.inversePrimary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding:
                  EdgeInsets.symmetric(horizontal: 0.02.h, vertical: 0.02.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.imagePath != null) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.0.h,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 0.18.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: appImageProvider(widget.imagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 0.01.h),
                  ],
                  Text(
                    widget.title.capitalize as String,
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize022.h,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.inverseSurface,
                        height: 0.0015.h),
                  ),
                  SizedBox(height: 0.005.h),
                  Text(
                    widget.description,
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize018.h,
                        fontWeight: FontWeight.w500,
                        color: themeController.currentTheme ==
                                AppColors.lightTheme
                            ? AppColors.colorDarkGrey
                            : AppColors.colorGreydark,
                        height: 0.0015.h),
                  ),
                  SizedBox(height: 0.01.h),
                  if (widget.finalDate != null && widget.finalDate != '') ...[
                    SizedBox(height: 0.01.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.lightPrimary,
                          width: 0.002.h,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.008.h,
                        // vertical: 0.005.h,
                      ),
                      child: Text(
                        DateFormat.yMMMd().format(widget.finalDate!),
                        textAlign: TextAlign.center,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: FontConstants.fontSize018.h,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.inverseSurface,
                          height: 0.0018.h,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 0.02.h),
                  if (widget.totalAttachment != null ||
                      widget.totalComments != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (widget.totalAttachment != null) ...[
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons_assets/task_assets/icons_Link.svg',
                              ),
                              SizedBox(width: 0.005.h),
                              Text(
                                widget.totalAttachment! > 1
                                    ? '${widget.totalAttachment} Attachments'
                                    : '${widget.totalAttachment} Attachment',
                                textAlign: TextAlign.center,
                                style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: FontConstants.fontSize016.h,
                                  fontWeight: FontWeight.w500,
                                  color: themeController.currentTheme ==
                                          AppColors.lightTheme
                                      ? AppColors.colorGrey
                                      : AppColors.colorGreydark,
                                  height: 0.002.h,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 0.005.h),
                          if (widget.totalComments != null)
                            Container(
                              width: 0.001.h,
                              height: 0.02.h,
                              color: themeController.currentTheme ==
                                      AppColors.lightTheme
                                  ? AppColors.colorGrey
                                  : AppColors.colorGreydark,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4), // Adjust the margin
                            ),
                          SizedBox(width: 0.005.h),
                        ],
                        if (widget.totalComments != null) ...[
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons_assets/task_assets/comments.svg',
                              ),
                              SizedBox(width: 0.005.h),
                              Text(
                                widget.totalComments! > 1
                                    ? '${widget.totalComments} Comments'
                                    : '${widget.totalComments} Comment',
                                textAlign: TextAlign.center,
                                style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: FontConstants.fontSize016.h,
                                  fontWeight: FontWeight.w500,
                                  color: themeController.currentTheme ==
                                          AppColors.lightTheme
                                      ? AppColors.colorGrey
                                      : AppColors.colorGreydark,
                                  height: 0.002.h,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                  SizedBox(height: 0.02.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 0.011.h, vertical: 0.001.h),
                        decoration: BoxDecoration(
                          color: (widget.currentCount == widget.totalCount)
                              ? AppColors.lightPrimary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons_assets/task_assets/CheckSquare.svg',
                              color: (widget.currentCount == widget.totalCount)
                                  ? AppColors.colorWhite
                                  : null,
                            ),
                            SizedBox(width: 0.01.h),
                            Text(
                              '${widget.currentCount}/${widget.totalCount}',
                              textAlign: TextAlign.center,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: FontConstants.fontSize018.h,
                                fontWeight: FontWeight.w500,
                                color:
                                    (widget.currentCount == widget.totalCount)
                                        ? AppColors.colorWhite
                                        : Theme.of(context)
                                            .colorScheme
                                            .inverseSurface,
                                height: 0.0018.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (widget.firstImage != null)
            Positioned(
              bottom: 0.02.h,
              left: Get.locale.toString().contains('en') ? 0.021.h : null,
              right: Get.locale.toString().contains('ar') ? 0.021.h : null,
              child: Container(
                width: 0.03.h,
                height: 0.03.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightPrimary,
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 0.03.h,
                    backgroundImage: appImageProvider(widget.firstImage!),
                  ),
                ),
              ),
            ),
          if (widget.secondImage != null)
            Positioned(
              bottom: 0.02.h,
              left: Get.locale.toString().contains('en') ? 0.041.h : null,
              right: Get.locale.toString().contains('ar') ? 0.041.h : null,
              child: Container(
                width: 0.03.h,
                height: 0.03.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightPrimary,
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 0.03.h,
                    backgroundImage: appImageProvider(widget.secondImage!),
                  ),
                ),
              ),
            ),
          if (widget.thirdImage != null)
            Positioned(
              bottom: 0.02.h,
              left: Get.locale.toString().contains('en') ? 0.061.h : null,
              right: Get.locale.toString().contains('ar') ? 0.061.h : null,
              child: Container(
                width: 0.03.h,
                height: 0.03.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightPrimary,
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 0.03.h,
                    backgroundImage: appImageProvider(widget.thirdImage!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
