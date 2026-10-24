import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/presentation/controller/qiyas_manager_approval_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_pic.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class SubmissionTimeFilterDialog {
  void show(BuildContext context) {
    showAppDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(child: SubmissionTimeFilter());
        });
  }
}

class SubmissionTimeFilter extends StatelessWidget {
  SubmissionTimeFilter({super.key});
  final QiyasManagerApprovalCubit controller = sl();
  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.all(15.sp),
        width: isTablet ? 360.w : 300.w,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.0.sp),
        ),
        child: Column(
          spacing: 20.sp,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 15./16./16. row.
            CustomDialogHeader(
                title: 'فرز',
                icon:
                    'assets/icons_assets/main_icons_assets/ic_action_filter.svg'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8.sp,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                    height: 38,
                    hint: "اختر تاريخ",
                    maxLines: 1,
                    readOnly: true,
                    textDirection: TextDirection.rtl,
                    onTap: () async {
                      final result = await DatePicker().showDatePicker(
                        context,
                        controller.filterDate != null
                            ? [controller.filterDate]
                            : [],
                        controller.filterDate ?? DateTime.now(),
                        CalendarDatePicker2Type.single,
                      );
                      if (result != null &&
                          result.isNotEmpty &&
                          result.first != null) {
                        controller.filterDate = result.first;
                        controller.dateController.text =
                            intl.DateFormat('dd MMMM yyyy', 'ar')
                                .format(result.first!);
                      }
                    },
                    fillColor: AppColors.background,
                    hintStyle: StyleText.fontSize12Weight500
                        .copyWith(height: 1)
                        .copyWith(color: AppColors.secondaryText),
                    suffixIcon: SvgPicture.asset(
                      "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                      height: 20.sp,
                      width: 20.sp,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                          AppColors.secondaryText, BlendMode.srcIn),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.sp, vertical: 12.sp),
                    controller: controller.dateController)
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              customButton(
                width: isTablet ? 150 : 120,
                title: 'إعادة',
                function: () {
                  Navigator.of(context).pop();
                  controller.filterDate = null;
                  controller.dateController.text = '';
                  controller.searchTasks();
                },
                color: AppColors.secondaryButton,
                textStyle: StyleText.fontSize14Weight600,
              ),
              customButton(
                width: isTablet ? 150 : 120,
                title: 'تطبيق',
                function: () {
                  Navigator.of(context).pop();
                  controller.searchTasks();
                },
              ),
            ])
          ],
        ),
      ),
    );
  }
}
