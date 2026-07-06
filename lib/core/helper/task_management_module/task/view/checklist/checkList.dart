import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/checklist/widget/icon_item.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/checklist/widget/limit_time.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class Checklist extends StatelessWidget {
  const Checklist({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SvgPicture.asset(
                  "assets/icons_assets/task_assets/CheckSquareIcon.svg",
                  height: 18.h,
                  width: 18.w,
                ),
              ),
              SizedBox(width: 8),
              Text("Check List 2",
                  style: AppTextStyles.font16ButtonMediumCairo),
              Spacer(),
              IconItem(
                  color: AppColors.primary, icon: "assets/icons_assets/main_icons_assets/edit_icon.svg"),
              SizedBox(width: 10),
              IconItem(
                  color: AppColors.red, icon: "assets/icons/remove_icon.svg")
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('${(1 * 100).toInt()}%',
                  style: AppTextStyles.font16ButtonMediumCairo),
              SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Image.asset("assets/images/check_icon.png",
                  height: 20.h, width: 20.w),
              SizedBox(width: 10),
              Text(
                "Design 10 Screens",
                style: AppTextStyles.font18BlackCairoMedium
                    .copyWith(decoration: TextDecoration.lineThrough),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  "assets/icons_assets/main_icons_assets/edit_icon.svg",
                  height: 14.h,
                  width: 14.w,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Image.asset("assets/png_assets/images_person.png",
                  height: 30.h, width: 30.w),
              SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Amro Handousa Handousa",
                    style: AppTextStyles.font12BlackMediumCairo,
                  ),
                  SizedBox(height: 2),
                  Text("Marketing ",
                      style: AppTextStyles.font10BlackCairoRegular),
                  SizedBox(height: 2.5),
                  Text(
                    "Marketing Manger",
                    style: AppTextStyles.font10BlackCairoRegular,
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              TimeLimit(date: "12/05/2023", time: "12:00", isEnd: true),
              SizedBox(width: 15),
              TimeLimit(date: "12/05/2023", time: "12:00")
            ],
          ),
          SizedBox(height: 25),
          Divider(height: 1, color: AppColors.black),
          SizedBox(height: 15),
          Row(
            children: [
              Image.asset("assets/images/check_icon.png",
                  height: 20.h, width: 20.w),
              SizedBox(width: 10),
              Text(
                "Design 10 Screens",
                style: AppTextStyles.font18BlackCairoMedium.copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  "assets/icons_assets/main_icons_assets/edit_icon.svg",
                  height: 14.h,
                  width: 14.w,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              TimeLimit(date: "12/05/2023", time: "12:00"),
              SizedBox(width: 15),
              TimeLimit(
                  date: "12/05/2023",
                  time: "12:00",
                  isEnd: true,
                  isExceeded: true)
            ],
          ),
          SizedBox(height: 70),
          Row(
            children: [
              Container(
                  padding: EdgeInsets.symmetric(vertical: 9, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: AppColors.white),
                      SizedBox(width: 8),
                      Text(
                        "Item",
                        style: AppTextStyles.font16MediumDarkGreyCairo
                            .copyWith(color: AppColors.white),
                      )
                    ],
                  )),
              Spacer(),
              IconItem(
                  color: AppColors.primary, icon: "assets/icons/copy-alt.svg"),
              SizedBox(width: 7),
              IconItem(
                  color: AppColors.primary, icon: "assets/icons/dec_icon.svg"),
            ],
          ),
        ],
      ),
    );
  }
}
