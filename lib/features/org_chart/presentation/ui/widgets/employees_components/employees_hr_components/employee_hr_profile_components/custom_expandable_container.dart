import 'package:grc_module/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/extensions/screen_fraction_extension.dart';
import 'package:grc_module/core/theme/app_colors.dart';

class ExpandableContainer extends StatefulWidget {
  final bool expanded;
  final String title;
  final Color? color;
  final Color? textColor;
  final double? paddingV;
  final bool isOpened;

  const ExpandableContainer(
      {super.key,
      required this.expanded,
      required this.title,
      this.color,
      this.paddingV,
      this.isOpened = false,
      this.textColor});

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.expanded == false
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
      // FIXED 8/9/2026 — "A RenderFlex overflowed by 89 pixels on the right."
      //
      // The chevron was sized `height: isPortrait ? 0.4.h : null`. In this file
      // `.h` is the fraction extension from app_font_size.dart, NOT
      // flutter_screenutil: `0.4.h` is forty percent of the SCREEN HEIGHT. On a
      // phone that is a ~350px-tall arrow, and SvgPicture preserves the aspect
      // ratio, so it also claimed ~350px of width inside a row roughly 355px
      // wide. The title took the remainder and the Row overflowed.
      //
      // It looked phone-only because the landscape branch is `null` (the
      // asset's natural size) and a tablet is normally landscape — the same
      // 0.4.h would break a tablet held in portrait just as badly.
      //
      // 0.024.h is ~21px on a phone and ~25px on a tablet in portrait, which
      // sits with the title beside it and with the natural size landscape uses.
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Expanded so the title yields to the chevron rather than pushing
            // it out of the row. This widget takes an arbitrary caller-supplied
            // title, so a long or translated one could overflow on its own even
            // with the icon sized correctly.
            Expanded(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize16Weight400.copyWith(
                    fontSize: isTablet
                        ? isPortrait
                            ? 14.sp
                            : 20.sp
                        : 14.sp,
                    color: widget.textColor ??
                        (!AppTheme.isDark
                            ? AppColors.colorWhite
                            : AppColors.darkerGrey),
                    fontWeight: FontWeight.w500,
                    height: 1.6),
              ),
            ),
            SizedBox(width: 0.01.w),
            widget.expanded
                ? CustomSvgImage.natural(
                    assetPath:
                        'assets/icons_assets/org_chart_assets/ic_nav_chevron_up.svg',
                    // ignore: deprecated_member_use
                    color: widget.textColor,
                    height: isPortrait ? 0.024.h : null,
                  )
                : Transform.rotate(
                    angle: 3.14159,
                    child: CustomSvgImage.natural(
                      assetPath:
                          'assets/icons_assets/org_chart_assets/ic_nav_chevron_up.svg',
                      height: isPortrait ? 0.024.h : null,
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
