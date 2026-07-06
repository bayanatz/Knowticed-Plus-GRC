import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';

class BreadCrumbsComponent extends StatefulWidget {
  BreadCrumbsComponent({
    super.key,
    required this.titles,
    required this.onTaps,
  });

  final List<String> titles; // List of titles
  final List<Function()?> onTaps; // List of onTap callbacks

  @override
  State<BreadCrumbsComponent> createState() => _BreadCrumbsComponentState();
}

class _BreadCrumbsComponentState extends State<BreadCrumbsComponent> {
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    TextStyle breadCrumbsTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isPortrait
          ? FontConstants.fontSize017.h
          : FontConstants.fontSize016.w,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.inverseSurface,
      height: isPortrait ? 1.5 : 1.6,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(widget.titles.length, (index) {
          return Row(
            children: [
              GestureDetector(
                onTap: widget.onTaps[index],
                child: Text(
                  widget.titles[index].tr,
                  style: breadCrumbsTextStyle,
                ),
              ),
              // Add separator and arrow only between items
              if (index < widget.titles.length - 1) ...[
                SizedBox(
                  width: isPortrait ? 0.002.w : 0.015.h,
                ),
                Transform.rotate(
                  angle: Get.locale.toString().contains('en') ? 0 : 3.14,
                  child: SvgPicture.asset(
                    'assets/icons_assets/main_icons_assets/images_arrow.svg',
                    height: isPortrait ? 0.03.h : 0.04.h,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
                SizedBox(
                  width: isPortrait ? 0.002.w : 0.01.h,
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}
