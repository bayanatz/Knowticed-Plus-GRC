/// ************************ FILE INFO ********************************///
/// File Name: side_frame_master_services.dart
/// Purpose: Shared responsive master/detail frame (mobile scaffold + tablet
///          side-frame layout) used across features. Previously duplicated
///          byte-for-byte as settings/widgets/W3_Frame_Screen_tablet.dart and
///          roles/widgets/w3_frame_screen_tablet.dart — consolidated here.
/// Module: core / local_widgets / main_widget
/// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/helper/main_helper/app_haptics.dart';


class SideFrameMasterServices extends StatelessWidget {
  final String titleText;
  final String? secondTitle;
  final String? thirdTitle;
  final String? fourthTitle;
  final Widget? child;

  final VoidCallback? onFirstTap;
  final VoidCallback? onSecondTap;
  final VoidCallback? onThirdTap;
  final VoidCallback? onFourthTap;

  const SideFrameMasterServices({
    super.key,
    required this.titleText,
    this.secondTitle,
    this.thirdTitle,
    this.fourthTitle,
    this.onFirstTap,
    this.onSecondTap,
    this.onThirdTap,
    this.onFourthTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    final bool isTablet = context.isTablet;
    final bool isLandscape = context.isLandscape;
    final bool isVerticalTablet = isTablet && !isLandscape;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    if (isMobile) {
      var lightMode = Theme.of(context).brightness == Brightness.light;
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: EdgeInsets.only(top: 0.h),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (secondTitle != null || thirdTitle != null || fourthTitle != null)
                      GestureDetector(
                        onTap: () {
                          AppHaptics.low(); // top-of-page navigation
                          Navigator.of(context).maybePop(); // Go back
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 3.sp, top: 15.sp),
                          child: Transform.rotate(
                            angle: isArabic ? 0 : 3.1416,
                            child: SvgPicture.asset(
                                'assets/icons_assets/main_icons_assets/images_arrow.svg',
                                width: 24.sp,
                                height: 24.sp,
                                color:AppColors.text
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding:  EdgeInsets.symmetric( vertical: thirdTitle == null  && secondTitle  == null && fourthTitle  == null ? 10.h : 0.sp ,horizontal:  thirdTitle == null  && secondTitle  == null && fourthTitle  == null ? 15 : 0),
                        child: GestureDetector(
                          onTap: () {
                            AppHaptics.low(); // top-of-page navigation
                            (onFourthTap ?? onThirdTap ?? onSecondTap ?? onFirstTap)?.call();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 15.sp),
                            child: Text(
                              fourthTitle ?? thirdTitle ?? secondTitle ?? titleText,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppTextStyles.font23BlackRegularCairo.copyWith(
                                  color: AppColors.text
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 15.sp,vertical: 0),
                  child: Column(
                    children: [
                      SizedBox(height: 20.sp),
                      if (child != null) child!,
                    ],
                  ),
                )


              ],
            ),
          ),
        ),
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.background
                        : AppColors.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------- Fixed (non-scrollable) header/breadcrumb ----------
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
                          child: Row(
                            children: () {
                              List<String?> titles = [titleText, secondTitle, thirdTitle, fourthTitle];
                              List<VoidCallback?> taps = [onFirstTap, onSecondTap, onThirdTap, onFourthTap];

                              List<MapEntry<String, VoidCallback?>> valid = [];
                              for (int i = 0; i < titles.length; i++) {
                                if (titles[i] != null) {
                                  valid.add(MapEntry(titles[i]!, taps[i]));
                                }
                              }



                              if (isVerticalTablet && valid.length > 2) {
                                valid = valid.sublist(valid.length - 2); // last 2 items in vertical tablet
                              } else if (!isVerticalTablet && valid.length > 3) {
                                valid = valid.sublist(valid.length - 3); // last 3 items in horizontal mode
                              }

                              List<Widget> widgets = [];

                              for (int i = 0; i < valid.length; i++) {
                                if (i != 0) {
                                  widgets.add(SizedBox(width: 10.sp));
                                  widgets.add(
                                    Transform.rotate(
                                      angle: isArabic ? 3.1416 : 0,
                                      child: Padding(
                                        padding: isArabic
                                            ? EdgeInsets.only(bottom: 7.sp)
                                            : EdgeInsets.only(top: 3.sp),
                                        child: SvgPicture.asset(
                                          'assets/icons_assets/main_icons_assets/images_arrow.svg',
                                          width: 30.sp,
                                          height: 30.sp,
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? AppColors.blackButton
                                              : AppColors.whiteShadow,
                                        ),
                                      ),
                                    ),
                                  );
                                  widgets.add(SizedBox(width: 10.sp));
                                }

                                widgets.add(
                                  GestureDetector(
                                    onTap: () {
                                      AppHaptics.low(); // top-of-page navigation
                                      valid[i].value?.call();
                                    },
                                    child: Text(
                                      valid[i].key,
                                      style: AppTextStyles.font28BlackMediumCairo.copyWith(
                                        color: Theme.of(context).brightness == Brightness.light
                                            ? AppColors.blackButton
                                            : AppColors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return widgets;
                            }(),
                          ),
                        ),

                        // ---------- Scrollable content ----------
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 0.sp), // same spacing that was under the breadcrumb
                                if (child != null) Expanded(child: child!),  // ← give the screen area a bounded height

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      );
    }
  }
}
