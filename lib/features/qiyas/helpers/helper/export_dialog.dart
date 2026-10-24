import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class ExportDialog extends StatelessWidget {
  ExportDialog({required this.onDownloadFile, super.key});
  final TextEditingController controller = TextEditingController();
  final Function(String fileName) onDownloadFile;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.all(15.sp),
          width: isTablet ? 400.w : 300.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0.r),
            color: AppColors.card,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 25.sp,
            children: [
              // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 15./16./16. row.
              CustomDialogHeader(
                  title: 'تصدير',
                  icon:
                      "assets/icons_assets/main_icons_assets/ic_action_export.svg"),
              CustomTextField(
                controller: controller,
                label: 'اسم الملف',
                hint: 'اكتب هنا',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عنوان الملف';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customButton(
                      color: !(AppTheme.isDark)
                          ? AppColors.grey
                          : AppColors.darkGrey,
                      textStyle: StyleText.fontSize16Weight400,
                      width: isTablet ? 150 : 120,
                      title: 'لا',
                      function: () {
                        Navigator.of(context).pop();
                      }),
                  customButton(
                      width: isTablet ? 150 : 120,
                      title: 'نعم',
                      textStyle: StyleText.fontSize16Weight400
                          .copyWith(color: AppColors.textButton),
                      function: () async {
                        Navigator.of(context).pop();
                        if (formKey.currentState!.validate()) {
                          //    showLoadingIndicator();

                          await onDownloadFile(controller.text);
                          //   MediaHandler().downloadFile(filePath, controller.text);
                          //   hideLoadingIndicator();
                        }
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
