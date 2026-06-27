// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/custom_button_widget.dart';

// ─────────────────────────────────────────────
// customButtonWithImage
// ─────────────────────────────────────────────
Widget customButtonWithImage({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  double? width,
  double? height,
  double? space,
  double? radius,
  Color? color,
  required String image,
  double? widthImage,
  double? heightImage,
  Color? colorBorder,
  Color? svgColor,
  EdgeInsetsGeometry? padding,
}) {
  return GestureDetector(
    onTap: function,
    child: Container(
      width: width ?? 135.sp,
      height: height ?? 38.sp,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? 8.r),
        border: colorBorder != null && colorBorder != Colors.transparent
            ? Border.all(color: colorBorder)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            image,
            height: heightImage ?? 20.sp,
            width: widthImage ?? 20.sp,
            colorFilter: svgColor != null
                ? ColorFilter.mode(svgColor, BlendMode.srcIn)
                : null,
            fit: BoxFit.fill,
          ),
          SizedBox(width: space ?? 8.sp),
          Text(title, style: textStyle),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// PopupOption
// ─────────────────────────────────────────────
class PopupOption {
  final String value;
  final String label;
  PopupOption({required this.value, required this.label});
}

// ─────────────────────────────────────────────
// CustomPopupMenuButton
// ─────────────────────────────────────────────
class CustomPopupMenuButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final List<PopupOption> options;
  final Function(String) onSelected;
  final Color backgroundColor;
  final Color iconColor;
  final double width;
  final double height;

  const CustomPopupMenuButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.options,
    required this.onSelected,
    required this.backgroundColor,
    required this.iconColor,
    this.width = 155,
    this.height = 38,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "",
      onSelected: onSelected,
      offset: Offset(0, height + 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      color: AppColors.card,
      itemBuilder: (context) => options
          .map((o) => PopupMenuItem<String>(
                value: o.value,
                child: Text(o.label,
                    style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.text)),
              ))
          .toList(),
      child: Container(
        width: title.isEmpty ? 38.sp : width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.5.sp),
        child: title.isEmpty
            ? Center(
                child: SvgPicture.asset(iconPath,
                    width: 16.sp, height: 16.sp,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(iconPath,
                      width: 16.sp, height: 16.sp,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
                  SizedBox(width: 8.sp),
                  Text(title,
                      style: StyleText.fontSize16Weight500
                          .copyWith(color: iconColor)),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CustomConfirmationDialog
// ─────────────────────────────────────────────
class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? lottieAsset;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final double? width;
  final double? lottieSize;

  const CustomConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.lottieAsset,
    this.confirmText = 'Yes',
    this.cancelText = 'No',
    this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.titleStyle,
    this.messageStyle,
    this.width,
    this.lottieSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: SizedBox(
          width: width ?? 411.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lottieAsset != null)
                Lottie.asset(lottieAsset!,
                    width: lottieSize ?? 70.sp,
                    height: lottieSize ?? 70.sp,
                    fit: BoxFit.scaleDown),
              Text(title,
                  textAlign: TextAlign.center,
                  style: titleStyle ??
                      StyleText.fontSize20Weight500
                          .copyWith(color: AppColors.text)),
              SizedBox(height: 18.sp),
              Text(message,
                  textAlign: TextAlign.center,
                  style: messageStyle ??
                      StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.secondaryText)),
              SizedBox(height: 20.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customButton(
                    title: cancelText,
                    function: onCancel ?? () => Navigator.pop(context, false),
                    textStyle: StyleText.fontSize15Weight500
                        .copyWith(color: Colors.black),
                    width: 120.sp,
                    height: 38.sp,
                    radius: 4.r,
                    color: cancelButtonColor ?? AppColors.grey,
                  ),
                  SizedBox(width: 15.sp),
                  customButton(
                    title: confirmText,
                    function: onConfirm ?? () => Navigator.pop(context, true),
                    textStyle: StyleText.fontSize15Weight500.copyWith(
                        color: AppColors.textButton),
                    width: 120.sp,
                    height: 38.sp,
                    radius: 4.r,
                    color: confirmButtonColor ?? AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String? lottieAsset,
    String confirmText = 'Yes',
    String cancelText = 'No',
    Color? confirmButtonColor,
    Color? cancelButtonColor,
    bool barrierDismissible = false,
    double? lottieSize,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomConfirmationDialog(
        title: title,
        message: message,
        lottieAsset: lottieAsset,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmButtonColor: confirmButtonColor,
        cancelButtonColor: cancelButtonColor,
        lottieSize: lottieSize,
      ),
    );
    return result == true;
  }
}

// ─────────────────────────────────────────────
// showSuccessMaster
// ─────────────────────────────────────────────
Future<bool?> showSuccessMaster(
  BuildContext context, {
  required String lottiePath,
  required String title,
  required String message,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: 411.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(lottiePath,
                  width: 70.sp, height: 70.sp, fit: BoxFit.scaleDown),
              SizedBox(height: 20.sp),
              Text(title,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize20Weight500.copyWith(color: AppColors.text)),
              SizedBox(height: 18.sp),
              Text(message,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText)),
              SizedBox(height: 20.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customButton(
                    title: 'OK',
                    function: onConfirm ?? () => Navigator.pop(context, true),
                    textStyle: StyleText.fontSize15Weight500.copyWith(
                        color: AppColors.textButton),
                    width: 120.sp,
                    height: 38.sp,
                    radius: 4.r,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
