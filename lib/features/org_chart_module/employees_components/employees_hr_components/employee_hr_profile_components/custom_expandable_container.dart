import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';

class ExpandableContainer extends StatefulWidget {
  final bool expanded;
  final String title;
  final Color? color;
  final Color? textColor;
  final double? paddingV;
  final bool isOpened;

  const ExpandableContainer(
      {Key? key,
      required this.expanded,
      required this.title,
      this.color,
      this.paddingV,
      this.isOpened = false,
      this.textColor})
      : super(key: key);

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Container(
      decoration: BoxDecoration(

        borderRadius:   widget.expanded == false 
            ? BorderRadius.all(
                Radius.circular(4),
              )
            : BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(4),
                 bottomRight: Radius.circular(4),
              ),
        color: widget.color ?? AppColors.colorBlack,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isPortrait ? 0.02.w : 0.02.h,
        vertical: widget.paddingV ?? (isPortrait ? 0.007.h : 0.012.h),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: isTablet
                      ? isPortrait
                          ? FontConstants.fontSize018.h
                          : FontConstants.fontSize024.h
                      : FontConstants.fontSize018.h,
                  // ignore: unrelated_type_equality_checks
                  color: widget.textColor ??
                      (themeController.currentTheme == AppColors.lightTheme
                          ? AppColors.colorWhite
                          : AppColors.colorGreydark),
                  fontWeight: FontWeight.w500,
                  height: 1.6),
            ),
            widget.expanded
                ? SvgPicture.asset(
                    'assets/icons_assets/organization_chart_assets/AltArrowUp.svg',
                    // ignore: deprecated_member_use
                    color: widget.textColor,
                    height: isPortrait ? 0.4.h : null,
                  )
                : Transform.rotate(
                    angle: 3.14159,
                    child: SvgPicture.asset(
                      'assets/icons_assets/organization_chart_assets/AltArrowUp.svg',
                      height: isPortrait ? 0.4.h : null,
                      // ignore: deprecated_member_use
                      color: widget.textColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
