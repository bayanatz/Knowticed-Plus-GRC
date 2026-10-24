import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/presentation/controller/qiyas_champigan_tasks_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/attatchment_widget.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_log_service.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class UploadEvidenceDialog {
  void show(BuildContext context) {
    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          child: UploadEvidenceDialogContent(),
        );
      },
    );
  }
}

class UploadEvidenceDialogContent extends StatefulWidget {
  const UploadEvidenceDialogContent({super.key});

  @override
  State<UploadEvidenceDialogContent> createState() =>
      _UploadEvidenceDialogContentState();
}

class _UploadEvidenceDialogContentState
    extends State<UploadEvidenceDialogContent> {
  QiyasChampiganTasksCubit controller = sl();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.initUploadControllers();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    return BlocProvider.value(
      value: controller,
      child: Form(
        key: formKey,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            width: isTablet ? 600.w : 300.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 15./16./16. row.
                CustomDialogHeader(
                    title: 'تفاصيل المستند',
                    icon:
                        "assets/icons_assets/main_icons_assets/ic_action_upload.svg"),
                SizedBox(height: 25.sp),
                Text("الملف", style: StyleText.fontSize14Weight500),
                SizedBox(height: 8.sp),
                BlocBuilder<QiyasChampiganTasksCubit, QiyasTasksState>(
                  builder: (context, state) {
                    return (controller.selectedFile == null)
                        ? customButtonWithSvg(
                            radius: 4.r,
                            width: double.infinity,
                            title: "رفع المستند",
                            image:
                                "assets/icons_assets/qiyas_assets/ic_action_bulk_upload.svg",
                            function: () {
                              controller.selectDocument();
                            },
                            color: AppColors.primary,
                            colorBorder: AppColors.transparent,
                            widthImage: 20.sp,
                            heightImage: 20.sp,
                            svgColor: AppColors.textButton,
                            textStyle: StyleText.fontSize16Weight400.copyWith(
                                color: AppColors.textButton,
                                fontWeight: FontWeight.w400),
                          )
                        : documentWidget();
                  },
                ),
                SizedBox(height: 40.sp),
                CustomTextField(
                  textDirection: TextDirection.rtl,
                  height: 72,
                  label: 'ملاحظة حول التقديم',
                  maxLines: 3,
                  showCharCount: true,
                  maxLength: 500,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال ملاحظة حول التقديم';
                    }
                    return null;
                  },
                  controller: controller.uploadNotesController,
                ),
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    customButton(
                      title: "إرسال ",
                      function: () {
                        if (formKey.currentState!.validate()) {
                          CustomDialogManager.showDialogFlow(
                            context: context,
                            confirmLottie:
                                "assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json",
                            confirmTitle: "تاكيد رفع المستند",
                            confirmSubtitle:
                                'هل انت متاكد من انك تريد رفع المستند؟',
                            confirmYesText: 'نعم',
                            confirmNoText: 'لا',
                            onConfirm: () async {
                              QiyasLogService.log('qiyas upload evidence');
                              await controller.submitEvidence();
                              return true;
                            },
                            successLottie:
                                "assets/lottie_assets/main_lottie_assets/lot_status_success.json",
                            successTitle: "تم تقديم المستند بنجاح",
                            successSubtitle:
                                "لقد نجحت في تقديم المستند لهذا المنظور",
                            onSuccessComplete: () {
                              if (context.mounted) Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                      width: 150.sp,
                      height: 38.h,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget documentWidget() {
    String fileName = controller.selectedFile!.path.split('/').last;
    String formatted = intl.DateFormat('d MMMM y', 'ar').format(DateTime.now());
    return AttatchmentWidget(
      fileName: fileName,
      filePath: controller.selectedFile!.path,
      fileSize: '${controller.fileSize?.toStringAsFixed(2) ?? 0} MB',
      uploadDate: formatted,
      onTap: () {
        controller.removeSelectedFile();
      },
    );
  }
}
