import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/app_size.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
import 'package:demo_app/core/utils/app_image_provider.dart';

class PersonListTile extends StatefulWidget {
  final String imageUrl;
  final String fullName;
  final String department;
  final String departmentMember;
  final String date;
  final bool? isTaskOwner;

  const PersonListTile({
    super.key,
    required this.imageUrl,
    required this.fullName,
    required this.department,
    required this.departmentMember,
    required this.date,
    this.isTaskOwner = false,
  });

  @override
  State<PersonListTile> createState() => _PersonListTileState();
}

class _PersonListTileState extends State<PersonListTile> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Container(
      padding: EdgeInsets.all(AppSize.h10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(AppSize.radius)),
        color: themeController.currentTheme == AppColors.lightTheme
            ? AppColors.moreLightGrey
            : AppColors.moreLightGrey,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: appImageProvider(widget.imageUrl),
            radius: isTablet ? (isPortrait ? 0.02.h : 0.025.h) : 0.02.h,
          ),
          SizedBox(
            width: isTablet ? (isPortrait ? 0.02.w : 0.02.h) : 0.02.w,
          ),
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               children: [
                 Text(
                   '${widget.fullName.capitalize}  ',
                   style: AppTextStyles.font12BlackCairo,
                 ),
                 if (widget.isTaskOwner == true)
                   Text(
                     '(Task Owner)'.tr,
                     style: AppFontStyle.cairoRegularStyle.copyWith(
                       fontSize: isTablet
                           ? (isPortrait
                           ? FontConstants.fontSize016.h
                           : FontConstants.fontSize018.h)
                           : FontConstants.fontSize016.h,
                       fontWeight: FontWeight.w400,
                       height: isTablet ? (isPortrait ? 1.4 : 0.002.h) : 0.002.h,
                       color: themeController.currentTheme == AppColors.lightTheme
                           ? AppColors.colorDarkGrey
                           : AppColors.colorWhiteDark,
                     ),
                   ),
               ],
             ),

             Text(
               //'${widget.fullName.isAlphabetOnly}',
               widget.department,
               style: AppTextStyles.font10BlackCairoRegular,
             ),
             SizedBox(height: 1,),
             Text(
               //'${widget.fullName.isAlphabetOnly}',
               widget.departmentMember,
               style: AppTextStyles.font10BlackCairoRegular,
             ),
           ],
         ),

          if (widget.isTaskOwner == true)
            SizedBox(
              width: isTablet ? 0.02.h : 0.02.w,
            ),

          const Spacer(),
        Column(

          children: [
            SizedBox(height: 15,),
            Container(
              height: (!isPortrait ? 20.h : 20.h),
              width: isPortrait ? 30.w : 30.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSize.radius /2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/Chat Dots.svg",
                  ),
                ],
              ),
            )
          ],
        )
        ],
      ),
    );
  }
}
