import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';

class CustomBlackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final bool isYellow;
  final String? icon;

  const CustomBlackButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.isYellow = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(isYellow == true
            ? AppColors.lightPrimary
            : AppColors.colorBlack),
        foregroundColor: WidgetStateProperty.all<Color>(AppColors.colorWhite),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon ?? "assets/icons_assets/main_icons_assets/images_plus.svg",
            height: isTablet ? (orientation ? 0.015.h : null) : null,
          ),
          SizedBox(
            width: isTablet ? (orientation ? 0.015.w : 0.02.h) : 0.02.w,
          ),
          Text(
            buttonText,
            maxLines: 1,
            style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: MediaQuery.of(context).size.shortestSide > 600
                    ? (orientation
                        ? FontConstants.fontSize017.h
                        : FontConstants.fontSize022.h)
                    : FontConstants.fontSize017.h,
                color: AppColors.colorWhite,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
