/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_bulk_buttons.dart
/// Purpose: Provides bulk action buttons ("Cancel" and "Activate") for the Qiyas vision upload workflow.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget renders two main buttons:
///              - "Cancel" to close the current screen.
///              - "Activate" to submit vision data using the bulk upload controller
///                and navigate to the Qiyas home screen upon success.
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:page_transition/page_transition.dart';

import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/tablet/qiyas_home_screen_tablet.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_visions_controller.dart';

class QiyasBulkButtons extends StatelessWidget {
  const QiyasBulkButtons({
    super.key,
    required this.controller,
  });
  final QiyasBulkVisionsController controller;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.02.h),
      child: Row(
        textDirection: TextDirection
            .ltr, // X-73: Cancel left, action right in both languages

        children: [
          customButton(
            title: "إلغاء",
            function: () {
              Navigator.pop(context);
            },
            width: 150.w,
            height: 38.h,
            textStyle: StyleText.fontSize16Weight400
                .copyWith(color: lightMode ? Colors.black : Colors.white),
            radius: 8.r,
            color: lightMode ? Colors.grey[400] : Colors.grey[700],
          ),
          Spacer(),

          customButton(
            title: "تفعيل",
            function: () async {
              await controller.addVisionBulkUpload(controller.visionData).then(
                (value) {
                  Get.delete<QiyasBulkVisionsController>();
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: const QiyasHomeScreenTablet()),
                  );
                },
              );
            },
            width: 150.w,
            height: 38.h,
            textStyle: StyleText.fontSize16Weight400
                .copyWith(color: AppColors.textButton),
            radius: 8.r,
            color: AppColors.primary,
          ),

          // SizedBox(
          //   width: 150,
          //   height: 38,
          //   child: CustomIconButton(
          //       buttonText: "تفعيل",
          //       hasIcon: false,
          //       imagePath: "assets/icons_assets/main_icons_assets/icons_List.svg",
          //       onPressed: () async {
          //         await controller
          //             .addVisionBulkUpload(controller.visionData)
          //             .then(
          //           (value) {
          //             Get.delete<QiyasBulkVisionsController>();
          //             Navigator.push(
          //               context,
          //               PageTransition(
          //                   type: PageTransitionType.fade,
          //                   child: const QiyasHomeScreenTablet()),
          //             );
          //           },
          //         );
          //       }),
          // ),
        ],
      ),
    );
  }
}
