import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';

class CustomCommentsTextField extends StatefulWidget {
  final String hintText;
  final String? profileImage;
  final Function() onPressed;
  final Function() onPressedImage;
  final TextEditingController controller;

  const CustomCommentsTextField({
    super.key,
    required this.hintText,
    required this.onPressed,
    required this.onPressedImage,
    required this.controller,
    this.profileImage,
  });

  @override
  State<CustomCommentsTextField> createState() =>
      _CustomCommentsTextFieldState();
}

class _CustomCommentsTextFieldState extends State<CustomCommentsTextField> {
  bool _isTextFieldNotEmpty = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateTextFieldState);
    _updateTextFieldState();
  }

  void _updateTextFieldState() {
    setState(() {
      _isTextFieldNotEmpty = widget.controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTextFieldState);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0.w),
      child: Row(
        children: [
          if ((isTablet && isPortrait) || !isTablet)
            ClipOval(
              child: (widget.profileImage != null && widget.profileImage!.isURL)
                  ? Image.network(
                      widget.profileImage!,
                      width: 0.04.h,
                      height: 0.04.h,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      widget.profileImage ?? 'assets/png_assets/profile1.png',
                      width: 0.04.h,
                      height: 0.04.h,
                      fit: BoxFit.cover,
                    ),
            ),
          if ((isTablet && isPortrait) || !isTablet)
            SizedBox(
              width: 0.02.w,
            ),
          Expanded(
            child: Container(
              width: 0.432.w,
              height: isTablet ? (isPortrait ? 0.044.h : 0.057.h) : 0.045.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      maxLength: 300,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      style: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: FontConstants.fontSize018.h,
                          color: AppColors.colorBlack,
                          fontWeight: FontWeight.w200,
                          height: isTablet ? null : null),
                      //height: isTablet ? (isPortrait ? 2.6 : 1.8) : 1),
                      decoration: InputDecoration(
                        counterText: "",
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0095.h, horizontal: 0.01.h),
                        hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize018.h,
                            color: AppColors.colorGrey,
                            fontWeight: FontWeight.w400,
                            height: isTablet ? (isPortrait ? 2.7 : 2) : 2.6),
                        //height: isTablet ? (isPortrait ? 2.6 : 1.8) : 1),
                        hintText: widget.hintText.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      cursorColor: AppColors.colorBlack,
                      cursorHeight: isPortrait ? 0.015.h : 0.015.h,
                      //cursorWidth: 0.002.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 0.01.w),
          GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: widget.controller.text.isEmpty
                      ? AppColors.colorGrey
                      : AppColors.lightPrimary,
                  border: Border.all(
                    color: widget.controller.text.isEmpty
                        ? AppColors.colorGrey
                        : AppColors.lightPrimary,
                  )),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        isTablet ? (isPortrait ? 0.02.w : 0.01.w) : 0.025.w,
                    vertical: isTablet ? 0.013.h : 0.009.h),
                child: SvgPicture.asset(
                  matchTextDirection: Get.locale?.languageCode == 'ar',
                  'assets/icons_assets/main_icons_assets/send.svg',
                  color: AppColors.textButton,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
