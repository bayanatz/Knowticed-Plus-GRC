import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/extension/context_extensions.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';

import 'package:demo_app/core/theme/app_font_size.dart';


class SideFrameMaster extends StatelessWidget {
  final String titleText;
  final String? secondTitle;
  final String? thirdTitle;
  final String? fourthTitle;
  final Widget? child;

  final VoidCallback? onFirstTap;
  final VoidCallback? onSecondTap;
  final VoidCallback? onThirdTap;
  final VoidCallback? onFourthTap;

  const SideFrameMaster({
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
    final bool isTablet = ContextExtension(context).isTablet;
    final bool isLandscape = ContextExtension(context).isLandscape;
    final bool isVerticalTablet = isTablet && !isLandscape;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.sp, vertical: 0.sp),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (secondTitle != null || thirdTitle != null || fourthTitle != null)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).maybePop(); // Go back
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.sp,right: 8.sp,left: 8.sp),
                          child: Transform.rotate(
                            angle: isArabic ? 0 : 3.1416,
                            child: SvgPicture.asset(
                              'assets/svg/arrow.svg',
                              width: 24.sp,
                              height: 24.sp,
                              color: AppColors.text
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding:  EdgeInsets.only( top: 10.sp ,right:  thirdTitle == null  && secondTitle  == null && fourthTitle  == null ? 8.0 : 0,left:  thirdTitle == null  && secondTitle  == null && fourthTitle  == null ? 8.0 : 0),
                        child: GestureDetector(
                          onTap: onFourthTap ?? onThirdTap ?? onSecondTap ?? onFirstTap,
                          child: Text(
                            fourthTitle ?? thirdTitle ?? secondTitle ?? titleText,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: StyleText.fontSize24Weight600.copyWith(
                              color: AppColors.text
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 15.sp),
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
          // Container(
          //   width: 80.sp,
          //   color: Theme.of(context).brightness == Brightness.light
          //       ? AppColors.white
          //       : AppColors.chatBackground,
          //   child: Column(
          //     children: [
          //       SizedBox(height: 26.sp),
          //       SvgPicture.asset(
          //         "assets/icons_assets/main_icons_assets/branding.svg",
          //         width: 49.sp,
          //         height: 38.sp,
          //         semanticsLabel: 'Branding Logo',
          //       ),
          //       SizedBox(height: 44.sp),
          //       Container(
          //         width: 55.sp,
          //         height: 55.sp,
          //         decoration: BoxDecoration(
          //           color: AppColors.secondaryPrimary,
          //           borderRadius: BorderRadius.circular(14.r),
          //         ),
          //         child: SvgPicture.asset(
          //           "assets/icons_assets/main_icons_assets/logoApp.svg",
          //           width: 24.sp,
          //           height: 24.sp,
          //           fit: BoxFit.scaleDown,
          //           semanticsLabel: 'App Logo',
          //         ),
          //       ),
          //       SizedBox(height: 44.sp),
          //       GestureDetector(
          //         onTap: (){
          //         //  navigateTo(context, SettingsPage());
          //         },
          //         child: Container(
          //           width: 55.sp,
          //           height: 55.sp,
          //           decoration: BoxDecoration(
          //             color: AppColors.secondaryPrimary,
          //             borderRadius: BorderRadius.circular(14.r),
          //           ),
          //           child: Icon(Icons.settings)
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: Column(
              children: [
                // Container(
                //   width: MediaQuery.sizeOf(context).width,
                //   height: 90.sp,
                //   color: Theme.of(context).brightness == Brightness.light
                //       ? AppColors.white
                //       : AppColors.chatBackground,
                //   child: Row(
                //     children: [
                //       const Spacer(),
                //       SvgPicture.asset(
                //         "assets/icons_assets/main_icons_assets/Bell.svg",
                //         semanticsLabel: 'Notification Icon',
                //         color: Theme.of(context).brightness == Brightness.light
                //             ? Colors.grey
                //             : Colors.white,
                //       ),
                //       SizedBox(width: 30.sp),
                //       Row(
                //         children: [
                //           SvgPicture.asset(
                //             "assets/icons_assets/main_icons_assets/PersonStatic.svg",
                //             width: 40.sp,
                //             height: 40.sp,
                //             semanticsLabel: 'User Icon',
                //           ),
                //           SizedBox(width: 10.sp),
                //           Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 "Amro Handousa",
                //                 style: StyleText.fontSize16Weight500.copyWith(
                //                   color: Theme.of(context).brightness == Brightness.light
                //                       ? AppColors.blackButton
                //                       : AppColors.white,
                //                 ),
                //               ),
                //               Text(
                //                 "Employee",
                //                 style: StyleText.fontSize14Weight500.copyWith(
                //                   color: Theme.of(context).brightness == Brightness.light
                //                       ? AppColors.secondaryText
                //                       : AppColors.white,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //       SizedBox(width: 18.sp),
                //     ],
                //   ),
                // ),
                // ⬇️ Replace your whole Expanded(...) block with this:
                Expanded(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    color: AppColors.background,
                    // ;;;
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------- Fixed (non-scrollable) header/breadcrumb ----------
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical:15.sp),
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
                                          'assets/images/arrow.svg',
                                          width: 30.sp,
                                          height: 30.sp,
                                          color: AppColors.text
                                        ),
                                      ),
                                    ),
                                  );
                                  widgets.add(SizedBox(width: 10.sp));
                                }

                                widgets.add(
                                  GestureDetector(
                                    onTap: valid[i].value,
                                    child: Text(
                                      valid[i].key,
                                      style: StyleText.fontSize28Weight600.copyWith(
                                        color: AppColors.text
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
                            padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20.sp), // same spacing that was under the breadcrumb
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
    final bool isTablet = ContextExtension(context).isTablet;
    final bool isLandscape = ContextExtension(context).isLandscape;
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
                          Navigator.of(context).maybePop(); // Go back
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 3.sp, top: 15.sp),
                          child: Transform.rotate(
                            angle: isArabic ? 0 : 3.1416,
                            child: SvgPicture.asset(
                                'assets/images/arrow.svg',
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
                          onTap: onFourthTap ?? onThirdTap ?? onSecondTap ?? onFirstTap,
                          child: Padding(
                            padding: EdgeInsets.only(top: 15.sp),
                            child: Text(
                              fourthTitle ?? thirdTitle ?? secondTitle ?? titleText,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: StyleText.fontSize24Weight600.copyWith(
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
          // Container(
          //   width: 80.sp,
          //   color: Theme.of(context).brightness == Brightness.light
          //       ? AppColors.white
          //       : AppColors.chatBackground,
          //   child: Column(
          //     children: [
          //       SizedBox(height: 26.sp),
          //       SvgPicture.asset(
          //         "assets/icons_assets/main_icons_assets/branding.svg",
          //         width: 49.sp,
          //         height: 38.sp,
          //         semanticsLabel: 'Branding Logo',
          //       ),
          //       SizedBox(height: 44.sp),
          //       Container(
          //         width: 55.sp,
          //         height: 55.sp,
          //         decoration: BoxDecoration(
          //           color: AppColors.secondaryPrimary,
          //           borderRadius: BorderRadius.circular(14.r),
          //         ),
          //         child: SvgPicture.asset(
          //           "assets/icons_assets/main_icons_assets/logoApp.svg",
          //           width: 24.sp,
          //           height: 24.sp,
          //           fit: BoxFit.scaleDown,
          //           semanticsLabel: 'App Logo',
          //         ),
          //       ),
          //       SizedBox(height: 44.sp),
          //       GestureDetector(
          //         onTap: (){
          //         //  navigateTo(context, SettingsPage());
          //         },
          //         child: Container(
          //           width: 55.sp,
          //           height: 55.sp,
          //           decoration: BoxDecoration(
          //             color: AppColors.secondaryPrimary,
          //             borderRadius: BorderRadius.circular(14.r),
          //           ),
          //           child: Icon(Icons.settings)
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: Column(
              children: [
                // Container(
                //   width: MediaQuery.sizeOf(context).width,
                //   height: 90.sp,
                //   color: Theme.of(context).brightness == Brightness.light
                //       ? AppColors.white
                //       : AppColors.chatBackground,
                //   child: Row(
                //     children: [
                //       const Spacer(),
                //       SvgPicture.asset(
                //         "assets/icons_assets/main_icons_assets/Bell.svg",
                //         semanticsLabel: 'Notification Icon',
                //         color: Theme.of(context).brightness == Brightness.light
                //             ? Colors.grey
                //             : Colors.white,
                //       ),
                //       SizedBox(width: 30.sp),
                //       Row(
                //         children: [
                //           SvgPicture.asset(
                //             "assets/icons_assets/main_icons_assets/PersonStatic.svg",
                //             width: 40.sp,
                //             height: 40.sp,
                //             semanticsLabel: 'User Icon',
                //           ),
                //           SizedBox(width: 10.sp),
                //           Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 "Amro Handousa",
                //                 style: StyleText.fontSize16Weight500.copyWith(
                //                   color: Theme.of(context).brightness == Brightness.light
                //                       ? AppColors.blackButton
                //                       : AppColors.white,
                //                 ),
                //               ),
                //               Text(
                //                 "Employee",
                //                 style: StyleText.fontSize14Weight500.copyWith(
                //                   color: Theme.of(context).brightness == Brightness.light
                //                       ? AppColors.secondaryText
                //                       : AppColors.white,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //       SizedBox(width: 18.sp),
                //     ],
                //   ),
                // ),
                // ⬇️ Replace your whole Expanded(...) block with this:
                Expanded(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    color: AppColors.background,
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
                                          'assets/images/arrow.svg',
                                          width: 30.sp,
                                          height: 30.sp,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ),
                                  );
                                  widgets.add(SizedBox(width: 10.sp));
                                }

                                widgets.add(
                                  GestureDetector(
                                    onTap: valid[i].value,
                                    child: Text(
                                      valid[i].key,
                                      style: StyleText.fontSize28Weight600.copyWith(
                                        color: AppColors.text
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
