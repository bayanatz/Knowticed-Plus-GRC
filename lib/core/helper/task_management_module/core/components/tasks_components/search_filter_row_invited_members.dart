import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/app_size.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_search.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';

class SearchFilterRowInvitedMembers extends StatelessWidget {
  final bool filterColor;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onEditPressed;

  const SearchFilterRowInvitedMembers({
    super.key,
    required this.filterColor,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SizedBox(
            height: (!isPortrait ? 35.h : 35.h),
            child: CustomSearchFiled2(
              secondActionIcon: 'assets/icons/g4581.svg',
              secondActionIconColor: AppColors.colorLightGrey,
              fillColor: themeController.currentTheme == AppColors.lightTheme
                  ? AppColors.moreLightGrey
                  : Theme.of(context).colorScheme.inversePrimary,
              hint: "Search".tr,
              onChanged: onSearchChanged, // Use the passed function

              hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: isPortrait
                    ? FontConstants.fontSize018.h
                    : FontConstants.fontSize014.w,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.scrim,
              ),
              keyBoardType: TextInputType.text,
            ),
          ),
        ),
        SizedBox(width: 0.02.w),
        GestureDetector(
          onTap: onEditPressed,
          child: Container(
            height: (!isPortrait ? 35.h : 35.h),
            width: isPortrait ? 35.w : 35.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSize.radius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/Pen_New.svg",
                  color: filterColor
                      ? AppColors.textButton
                      : Theme.of(context).colorScheme.scrim,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
