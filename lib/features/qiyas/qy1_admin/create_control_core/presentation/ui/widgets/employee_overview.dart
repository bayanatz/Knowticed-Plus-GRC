import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';

class EmployeeOverview extends StatefulWidget {
  const EmployeeOverview({super.key});

  @override
  State<EmployeeOverview> createState() => _EmployeeOverviewState();
}

class _EmployeeOverviewState extends State<EmployeeOverview> {
  late ControlCoreCubit controller;
  late bool isTablet;
  @override
  Widget build(BuildContext context) {
    controller = context.read<ControlCoreCubit>();
    isTablet = !kpIsPhoneLayout(context);

    return Stack(
      alignment: AlignmentGeometry.topLeft,
      children: [
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(8.r)),
          child: Row(
            spacing: 10.sp,
            crossAxisAlignment: (isTablet)
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.center,
            children: [
              // was PersonImage(...) — it ignored its `image` argument and
              // always rendered the static male avatar, so it is inlined here.
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Center(
                  child: CustomSvgImage(
                    assetPath:
                        "assets/icons_assets/qiyas_assets/ic_user_male.svg",
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Expanded(child: personDetails()),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.sp),
          child: SizedBox(
            height: isTablet ? 80.r : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                customButtonWithSvg(
                  width: context.isPhone ? 38.w : 100,
                  height: 28.h,
                  title: context.isPhone ? "" : "رسالة",
                  image:
                      "assets/icons_assets/qiyas_assets/ic_comms_message_new.svg",
                  function: () {
                    // MessageInterfaceConsumer.openSingleChat(
                    //     controller.personDetails!.id, context);
                  },
                  color: AppColors.primary,
                  colorBorder: AppColors.transparent,
                  widthImage: 20.sp,
                  heightImage: 20.sp,
                  svgColor: AppColors.textButton,
                  textStyle: StyleText.fontSize16Weight400.copyWith(
                      color: AppColors.textButton, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget personDetails() {
    if (isTablet) {
      return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: mainDetails()),
        SizedBox(width: 10.sp),
        Expanded(child: secondaryDetails())
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [mainDetails(), SizedBox(height: 10.sp), secondaryDetails()],
    );
  }

  Widget mainDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.sp,
      children: [
        Text(controller.personDetails!.name,
            style: StyleText.fontSize16Weight500
                .copyWith(color: AppColors.secondaryText)),
        iconText("assets/icons_assets/qiyas_assets/ic_job_briefcase.svg",
            'المسمي الوظيفي', controller.personDetails!.title),
        iconText("assets/icons_assets/main_icons_assets/ic_building_office.svg",
            'القسم', controller.personDetails!.departmentName),
      ],
    );
  }

  Widget secondaryDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.sp,
      children: [
        // ✅ After — if phone is List<String>
        iconText(
            "assets/icons_assets/main_icons_assets/ic_comms_phone.svg",
            'رقم الهاتف',
            controller.personDetails!.phone is List
                ? (controller.personDetails!.phone as List).join(', ')
                : controller.personDetails!.phone.toString()),
        iconText("assets/icons_assets/main_icons_assets/ic_comms_email.svg",
            'البريد الإلكتروني', controller.personDetails!.id),
      ],
    );
  }

  Widget iconText(String icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(icon, width: 12.sp, height: 12.sp),
        SizedBox(width: 10.sp),
        Text(
          '$title: ',
          style: StyleText.fontSize12Weight500,
        ),
        Expanded(
          child: Text(
            value,
            style: StyleText.fontSize12Weight500
                .copyWith(color: AppColors.secondaryBlack)
                .copyWith(color: AppColors.secondaryText),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
