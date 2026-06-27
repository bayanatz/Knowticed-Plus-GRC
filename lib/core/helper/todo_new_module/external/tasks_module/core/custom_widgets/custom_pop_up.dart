import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/custom/32-custom_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';


class CustomPopupMenuButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final List<PopupOption> options;
  final Function(String?) onSelected;
  final Color backgroundColor;
  final Color iconColor;
  final double width;
  final double height;
  final String? selectedValue;
  final bool keepOpenOnSelect;

  const CustomPopupMenuButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.options,
    required this.onSelected,
    required this.backgroundColor,
    required this.iconColor,
    this.width = 135,
    this.height = 38,
    this.selectedValue,
    this.keepOpenOnSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness ==  Brightness.light;
    final isMobile = context.isPhone;
    return PopupMenuButton<String>(
      tooltip: '',
      onSelected: (value) => onSelected(value),
      offset: Offset(0, height + 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : AppColors.chatBackground,
      itemBuilder: (context) => options.map((option) {
        return HoverablePopupMenuItem(
          value: option.value,
          label: option.label,
          isSelected: selectedValue == option.value,
          keepOpenOnSelect: keepOpenOnSelect,
          onSelected: onSelected,
        );
      }).toList(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: (selectedValue != null && selectedValue != '-1')
              ? AppColors.primary
              : backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.transparent),
        ),
        padding: EdgeInsets.symmetric(horizontal: 0.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvg(
              assetPath: iconPath,
              width: isMobile ? 14.w : 23.w,
              height: isMobile ? 14.h : 23.h,
                color:  AppColors.secondaryText
            ),
            isMobile ? SizedBox(width: 0.sp) : SizedBox(width: 8.sp),
            Text(
              title,
              style: isMobile
                  ? AppTextStyles.font14BlackCairoMedium.copyWith(
                color:  AppColors.secondaryText
                    )
                  : AppTextStyles.font16BlackMediumCairo.copyWith(
                  color:  AppColors.secondaryText                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopupOption {
  final String value;
  final String label;

  PopupOption({required this.value, required this.label});
}

class HoverablePopupMenuItem extends StatefulWidget
    implements PopupMenuEntry<String> {
  final String value;
  final String label;
  final double _height;
  final bool isSelected;
  final bool keepOpenOnSelect;
  final Function(String?) onSelected;

  const HoverablePopupMenuItem({
    super.key,
    required this.value,
    required this.label,
    required this.onSelected,
    double height = kMinInteractiveDimension,
    this.isSelected = false,
    this.keepOpenOnSelect = false,
  }) : _height = height;

  @override
  _HoverablePopupMenuItemState createState() => _HoverablePopupMenuItemState();

  @override
  double get height => _height;

  @override
  bool represents(String? value) => value == this.value;
}

class _HoverablePopupMenuItemState extends State<HoverablePopupMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return InkWell(
      onTap: () {
        if (widget.isSelected) {
          widget.onSelected(null);
          Navigator.pop(context);
        } else {
          widget.onSelected(widget.value);
          Navigator.pop(context);
        }
      },
      onHover: (hovering) {
        setState(() {
          isHovered = hovering;
        });
      },
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: 80.w,
        padding: EdgeInsets.symmetric(vertical: 10.sp,),
        decoration: BoxDecoration(
          color: isHovered
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Center(
          //list of sort
          child: Text(
            widget.label,
            style: AppTextStyles.font12BlackMediumCairo.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
