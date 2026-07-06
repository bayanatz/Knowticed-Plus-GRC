import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomIconButton extends StatefulWidget {
  final String buttonText;
  final String imagePath;
  final VoidCallback onPressed;
  final bool isOwnerHome;
  final Color? buttonColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? imageColor;
  final bool isReviewPage;
  final bool hasIcon;
  final bool? smallHeight;
  final double? radius;
  final double? buttonHeight;

  const CustomIconButton({
    required this.buttonText,
    required this.imagePath,
    required this.onPressed,
    this.isReviewPage = false,
    this.buttonColor,
    this.textColor,
    this.borderColor,
    this.imageColor,
    this.radius,
    this.buttonHeight,
    this.isOwnerHome = false,
    this.hasIcon = true,
    this.smallHeight = false,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: AppColors.colorBlack,
        backgroundColor: widget.buttonColor ?? AppColors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? (orientation ? 0.015.w : 0.02.h) : 0.025.w,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(widget.radius ?? (isTablet ? 8 : 8)),
          side: BorderSide(
            color: widget.borderColor ?? Colors.transparent,
            width: 1.0,
          ),
        ),
      ),
      onPressed: widget.onPressed,
      child: SizedBox(
        height: widget.buttonHeight ?? 38.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.hasIcon
                ? SvgPicture.asset(
              widget.imagePath,
              height: widget.isOwnerHome == true
                  ? isTablet
                  ? 0.04.h
                  : null
                  : orientation
                  ? 0.02.h
                  : 0.025.h,
              color: widget.imageColor ?? AppColors.textButton,
            )
                : const SizedBox.shrink(),
            widget.hasIcon
                ? SizedBox(
                width: isTablet
                    ? (orientation ? 0.015.w : 0.02.h)
                    : widget.isReviewPage == true
                    ? 0.02.w
                    : 0.01.w)
                : const SizedBox.shrink(),
            Text(
              widget.buttonText.tr,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: isTablet
                    ? widget.isReviewPage == true
                    ? (orientation
                    ? FontConstants.fontSize024.w
                    : FontConstants.fontSize021.h)
                    : (orientation
                    ? FontConstants.fontSize016.h
                    : FontConstants.fontSize022.h)
                    : widget.isReviewPage == true
                    ? FontConstants.fontSize020.h
                    : FontConstants.fontSize018.h,
                color: widget.textColor ?? AppColors.textButton,
                fontWeight: isTablet ? FontWeight.w500 : FontWeight.w500,
                height: isTablet
                    ? 1.6
                    : widget.isReviewPage == true && !isTablet
                    ? 1.7
                    : 1.8,
              ),
              overflow: TextOverflow.visible,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}