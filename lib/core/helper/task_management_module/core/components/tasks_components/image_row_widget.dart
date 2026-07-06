import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
import 'package:demo_app/core/utils/app_image_provider.dart';

class ImageRowWidget extends StatelessWidget {
  final List<String> checkListImages;
  final String memebrName;

  const ImageRowWidget(
      {super.key, required this.checkListImages, required this.memebrName});

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    TextStyle textStyle = AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: isTablet
            ? (isPortrait
                ? FontConstants.fontSize024.w
                : FontConstants.fontSize014.w)
            : FontConstants.fontSize016.h,
        color: themeController.currentTheme == AppColors.lightTheme
            ? AppColors.colorBlack
            : AppColors.colorWhiteDark,
        fontWeight: FontWeight.w400,
        height: 2);

    return (checkListImages.length == 1)
        ? Row(
            children: [
              _buildCircleAvatar(checkListImages[0]),
              SizedBox(
                width: 0.01.w,
              ),
              SizedBox(
                width: isPortrait ? null : 0.15.w,
                //  color: Colors.amber,
                child: Text(
                  memebrName,
                  style: textStyle,
                ),
              ),
            ],
          )
        : Row(
            children: [
              if (checkListImages.isNotEmpty)
                _buildCircleAvatar(checkListImages[0]),
              if (checkListImages.length > 1)
                _buildCircleAvatar(checkListImages[1]),
              if (checkListImages.length > 2)
                _buildCircleAvatar(checkListImages[2]),
              if (checkListImages.length >= 4)
                _buildMoreCircle(checkListImages.length - 3),
            ],
          );
  }

  Widget _buildCircleAvatar(String image) {
    return Container(
      width: 0.04.h,
      height: 0.04.h,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Center(
        child: image.isURL
            ? CircleAvatar(
                radius: 0.03.h,
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(image),
              )
            : CircleAvatar(
                radius: 0.03.h,
                backgroundColor: Colors.transparent,
                backgroundImage: appImageProvider(image),
              ),
      ),
    );
  }

  Widget _buildMoreCircle(int additionalCount) {
    return Container(
      width: 0.04.h,
      height: 0.04.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.colorGreydark,
      ),
      child: Center(
        child: Text(
          "+${Get.locale.toString().contains('en') ? checkListImages.length - 3 : convertNumberToArabic((checkListImages.length - 3).toString())}",
          style: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: FontConstants.fontSize014.h,
            height: 1.6,
            color: AppColors.colorDarkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
