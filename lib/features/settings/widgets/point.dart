import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:demo_app/core/theme/app_font_size.dart';


///  Developer's Name: Bassel Attia
///  Date: 21/7/2023
///  App Version : demo_app V1
///  Date of Last Edit: 27/7/2023
///
/// Shows text with a tick beside it. Each point describes the plan.
class Point extends StatelessWidget {
  const Point(
      {required this.text,
      this.isTickColorBlack = false,
      this.fontSizeMultiplicationFactor = 1,
      this.isPopup = false,
      super.key});
  final String text;
  final bool isTickColorBlack;
  final double fontSizeMultiplicationFactor;
  final bool isPopup;
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top:isTickColorBlack ? 0.007.h : 0.006.h ),
          child: isTickColorBlack
              ? SvgPicture.asset(
                  'assets/icons_assets/main_icons_assets/tick-circle.svg',
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onInverseSurface,
                      BlendMode.srcIn),
                )
              : SvgPicture.asset(
                    'assets/icons_assets/main_icons_assets/tick-circle-green.svg',
                ),
        ),
        SizedBox(
          width: 0.014.w,
        ),
        Flexible(
          child: MediaQuery.of(context).size.shortestSide > 600
            ? Text(
            text,
            style: AppFontStyle.cairoRegularStyle.copyWith(
              height: (isTickColorBlack
                      ? 0.00226.h
                      : isPopup
                          ? 0.0024.h
                          :orientation == Orientation.portrait
                             ?  0.0016.h :0.0023.h ) ,
              fontSize: (isTickColorBlack
                      ? 0.043.w
                      : isPopup
                          ? 0.042.w
                          : 0.047.w) *
                  fontSizeMultiplicationFactor,
              color: isTickColorBlack
                  ? Theme.of(context).colorScheme.onInverseSurface
                  : Theme.of(context).colorScheme.scrim,
              fontWeight: FontWeight.w400,
            ),
          ) :
          Text(
            text,
            style: AppFontStyle.cairoRegularStyle.copyWith(
              height: (isTickColorBlack
                      ? 0.00226.h
                      : isPopup
                          ? 0.0024.h
                          : 0.0024.h) ,
              fontSize: (isTickColorBlack
                      ? 0.043.w
                      : isPopup
                          ? 0.042.w
                          : 0.047.w) *
                  fontSizeMultiplicationFactor,
              color: isTickColorBlack
                  ? Theme.of(context).colorScheme.onInverseSurface
                  : Theme.of(context).colorScheme.scrim,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
