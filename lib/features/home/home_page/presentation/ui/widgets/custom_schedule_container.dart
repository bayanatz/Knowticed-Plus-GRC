import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/get_photo_asset.dart';
import 'package:demo_app/features/home/home_page/presentation/utils/capitalization_functions.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';

/// Date Created : 11/Sep/2024
/// Developer Name : Bassem Mohamed
/// App Version : demo_app Plus
/// Date of Last Edit : 11/Sep/2024 By Bassem
/// Objectives: this widget is for showing the events , todo list, boards, or services names.
/// This widget consist of description and start time for each one in addition to images of the participants and the total number of the members enrolled in this event

class CustomScheduleContainer extends StatelessWidget {
  final String cardTitle;
  final String eventType;
  final String description;
  final String? dueDate;
  final List<String?>? imagesList;

  const CustomScheduleContainer({
    super.key,
    required this.eventType,
    required this.cardTitle,
    required this.description,
    required this.dueDate,
    List<String?>? imagesList,
  }) : imagesList = imagesList ?? const [""];

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    double imageHight = 0.018.h;
    double imageSize = isTablet ? (isPortrait? 0.05.w :0.02.w) : 0.08.w;
    // Convert the totalImagesNum to a string, handling the 1000+ case
    
    String displayTotalImagesNum = '';
    if (imagesList != null && imagesList!.isNotEmpty) {
      displayTotalImagesNum =
          imagesList!.length >= 1000 ? '+1K'.tr : '+${imagesList!.length - 2}';
    }
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.008.h),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                vertical: 0.015.h, horizontal: isTablet ? ( isPortrait? 0.02.w :0.008.w) : 0.03.w),
            decoration: BoxDecoration(
              // ignore: unrelated_type_equality_checks
              color: isPortrait
                  ? (themeController.currentTheme == AppColors.lightTheme
                      ? AppColors.colorWhite
                      : AppColors.dark)
                  : (Theme.of(context).colorScheme.inversePrimary),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    /// Photo container for each type
                    getPhotoAsset(eventType),
                  ],
                ),
                SizedBox(width: isTablet ? (isPortrait? 0.02.w : 0.01.w) : 0.02.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                  //    color: Colors.amber,
                      width: isTablet ? (isPortrait? 0.68.w : 0.17.w) : 0.73.w,
                      child: Text(
                        cardTitle.capitalize as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize018.h,
                            // ignore: unrelated_type_equality_checks
                            color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhiteDark,
                            fontWeight: FontWeight.w600,
                            height: 1.4),
                      ),
                    ),
                    SizedBox(height: 0.005.h),
                    Container(
                      //   color: Colors.amber,
                      width: isTablet ? (isPortrait? 0.68.w : 0.17.w) : 0.73.w,
                      child: Text(
                        description.capitalize!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: FontConstants.fontSize016.h,
                          // ignore: unrelated_type_equality_checks
                          color: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorDarkGrey
                              : AppColors.colorGreydark,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 0.03.h),
                    Container(
                      // color: Colors.amber,
                      width: isTablet ? (isPortrait? 0.4.w : 0.14.w) : 0.5.w,
                      child: Text(
                        Get.locale.toString().contains('en')
                            ? "${"Due Date"} ${capitalizeMonth("$dueDate")}"
                            : "${"Due Date".tr} ${translateDate(capitalizeMonth("$dueDate"))}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: FontConstants.fontSize015.h,
                          // ignore: unrelated_type_equality_checks
                          color: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorBlack
                              : AppColors.colorWhiteDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (imagesList!.length > 2 &&
            imagesList != null &&
            imagesList!.isNotEmpty)
          Positioned(
            bottom: imageHight,
            right: Get.locale.toString().contains('en') ? ((isTablet && isPortrait)? 0.015.h : 0.01.h) : null,
            left: Get.locale.toString().contains('ar') ? ((isTablet && isPortrait)? 0.015.h : 0.01.h) : null,
            child: Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightPrimary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    localizeNumber(displayTotalImagesNum),
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize010.h,
                        color: AppColors.textButton,
                        fontWeight: FontWeight.w600,
                        height: isTablet ? (1.5) : 2),
                  ),
                  SizedBox(
                    width: isTablet ? (isPortrait? 0.006.w : 0.003.w) : 0.012.w,
                  ),
                ],
              ),
            ),
          ),
        if (imagesList!.isNotEmpty && imagesList != null)
          Positioned(
            bottom: imageHight,
            right: Get.locale.toString().contains('en') ? 0.04.h : null,
            left: Get.locale.toString().contains('ar') ? 0.04.h : null,
            child: Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightPrimary,
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 0.03.h,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage(imagesList![0]!),
                ),
              ),
            ),
          ),
        if (imagesList!.length > 1 && imagesList != null)
          Positioned(
            bottom: imageHight,
            right: Get.locale.toString().contains('en') ? 0.065.h : null,
            left: Get.locale.toString().contains('ar') ? 0.065.h : null,
            child: Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightPrimary,
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 0.03.h,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage(imagesList![1]!),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
