/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: filters_appbar.dart
/// Purpose: Declares `FiltersAppBar`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// Date Created :14/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :14/November/2023
// Objectives: this is a widget to customize the filters of the appbar
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';

class FiltersAppBar extends StatelessWidget {
  const FiltersAppBar(
      {super.key,
      required this.imageUrl,
      required this.title,
      this.hideIcon,
      this.iconColor,
      this.padding,
      this.titleLineHeight});
  final String imageUrl;
  final String title;
  final bool? hideIcon;
  final Color? iconColor;

  /// Overrides the header's own padding. Null keeps the historical
  /// `EdgeInsets.all(15.sp)`, so every existing caller is untouched.
  ///
  /// ADDED 15/8/2026 for compact dialogs that need to own the gap between the
  /// heading and the first field instead of inheriting a screen-sized one.
  final EdgeInsetsGeometry? padding;

  /// Overrides the title's line-height multiplier. Null keeps the historical
  /// 1.8 on tablet.
  ///
  /// 1.8 on a 28px title is a ~50px line box, so ~22px of leading is painted
  /// as empty space around the word. Invisible on a full screen; glaring
  /// inside a small dialog. Pass ~1.2 there.
  final double? titleLineHeight;

  double getIconSize(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;

    if (isDesktop && screenHeight >= 611 && screenHeight < 810) {
      return 0.8;
    } else if (isDesktop && screenHeight >= 810 && screenHeight < 900) {
      return 0.9;
    } else if (isDesktop && screenHeight >= 900 && screenHeight < 950) {
      return 1;
    } else if (isDesktop && screenHeight >= 950 && screenHeight < 1000) {
      return 1.2;
    } else if (isDesktop && screenHeight >= 1000) {
      return 1.3;
    }

    return 1.1;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(15.sp),
      child: Column(
        children: [
          // 22/10/2026 — Owner: one dialog header everywhere — the core
          // CustomDialogHeader (30 circle · 16 icon · 18/500 title). Was a
          // 30 circle with a 12 icon scaled 0.7–1.3 by device, title 16/500.
          CustomDialogHeader(
            title: title,
            icon: imageUrl.isEmpty ? AppAssets.filter : imageUrl,
          ),
          SizedBox(height: 20.sp),
        ],
      ),
    );
  }
}
