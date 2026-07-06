import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';

class ReusableElevatedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final String? icon;
  final bool onTablet;
  final bool deleteButton;

  const ReusableElevatedButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.icon,
    this.onTablet = false,
    this.deleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.only(right: 10, left: 10),
        backgroundColor:
            deleteButton ? AppColors.delete : AppColors.bubbleColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Padding(
        padding: onTablet
            ? EdgeInsets.symmetric(horizontal: 30, vertical: 2)
            : EdgeInsets.all(3.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: SvgPicture.asset(
                      icon!,
                      width: 20,
                      color: deleteButton
                          ? AppColors.colorWhiteDark
                          : AppColors.colorBlack,
                    ),
                  )
                : SizedBox.shrink(),
            // isChat == true
            //     ? SvgPicture.asset(
            //         "assets/icons_assets/main_icons_assets/messageScreen.svg",
            //         height: 0.03.h,
            //       )
            //     : const SizedBox.shrink(),
            // isChat == true
            //     ? SizedBox(
            //         width: 0.02.w,
            //       )
            //     : const SizedBox.shrink(),
            Text(
              buttonText.tr,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: 16,
                color: deleteButton
                    ? AppColors.colorWhiteDark
                    : AppColors.colorBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
