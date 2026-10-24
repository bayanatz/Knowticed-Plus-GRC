import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/presentation/ui/widgets/upload_evidence_dialog.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';

class UploadEvidence extends StatelessWidget {
  const UploadEvidence({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.sp,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons_assets/main_icons_assets/ic_cloud_upload.svg',
            width: 100.sp,
            height: 100.sp,
          ),
          SizedBox(height: 30.sp),
          customButtonWithSvg(
            radius: 4.r,
            width: 215.sp,
            title: "رفع المستند",
            image: "assets/icons_assets/qiyas_assets/ic_action_bulk_upload.svg",
            function: () {
              debugPrint("Upload button pressed");
              UploadEvidenceDialog().show(context);
            },
            color: AppColors.primary,
            colorBorder: AppColors.transparent,
            widthImage: 20.sp,
            heightImage: 20.sp,
            svgColor: AppColors.textButton,
            textStyle: StyleText.fontSize16Weight400.copyWith(
                color: AppColors.textButton, fontWeight: FontWeight.w400),
          )
        ],
      ),
    );
  }
}
