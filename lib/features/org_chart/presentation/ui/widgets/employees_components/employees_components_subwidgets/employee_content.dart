// Date Created :21/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :21/November/2023
// Objectives: this is a widget to customize the title and the value in the employee content container
import 'package:grc_module/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:get/get.dart';

class EmployeeContent extends StatelessWidget {
  const EmployeeContent(
      {super.key,
      required this.title,
      required this.value,
      this.isAssets = false,
      this.textColor,
      this.isEmployeeProfile = false});
  final String title;
  final String? value;
  final bool isAssets;
  final bool isEmployeeProfile;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Row(
      children: <Widget>[
        Text(
          "$title: ",
          style: StyleText.fontSize16Weight400.copyWith(
            fontSize: isAssets == true
                ? isTablet
                    ? isPortrait
                        ? 14.sp
                        : 10.sp
                    : 10.sp
                : isPortrait
                    ? 14.sp
                    : 10.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.scrim,
          ),
        ),
        if (isEmployeeProfile == false)
          Flexible(
            child: Text(
              value?.capitalize ?? '',
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: isAssets == true
                    ? isTablet
                        ? isPortrait
                            ? 14.sp
                            : 10.sp
                        : 12.sp
                    : isPortrait
                        ? 14.sp
                        : 10.sp,
                fontWeight: isAssets ? FontWeight.w600 : FontWeight.w500,
                color:
                    textColor ?? Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
          ),
        if (isEmployeeProfile == true)
          Flexible(
            child: Text(
              value!,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: isAssets == true ? 10.sp : 10.sp,
                fontWeight: isAssets ? FontWeight.w600 : FontWeight.w500,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
          ),
      ],
    );
  }
}
