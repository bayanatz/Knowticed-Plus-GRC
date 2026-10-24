import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_tasks/presentation/controller/qiyas_owner_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_log_service.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class RejectionDialog {
  void show(
    BuildContext context,
    String submissionId, {
    VoidCallback? onConfirmed, // ← NEW
  }) {
    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          child: RejectionDialogContent(
            submissionId: submissionId,
            onConfirmed: onConfirmed, // ← NEW
          ),
        );
      },
    );
  }
}

class RejectionDialogContent extends StatefulWidget {
  const RejectionDialogContent({
    required this.submissionId,
    this.onConfirmed, // ← NEW
    super.key,
  });

  final String submissionId;
  final VoidCallback? onConfirmed; // ← NEW

  @override
  State<RejectionDialogContent> createState() => _RejectionDialogContentState();
}

class _RejectionDialogContentState extends State<RejectionDialogContent> {
  QiyasOwnerTasksCubit controller = sl();

  @override
  void initState() {
    super.initState();
    controller.initRejectionControllers();
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
            width: isTablet ? 600.sp : 300.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 15./16./16. row.
                CustomDialogHeader(
                    title: 'تعديل تفاصيل المستند',
                    icon:
                        "assets/icons_assets/main_icons_assets/ic_action_upload.svg"),
                SizedBox(height: 25.sp),
                CustomTextField(
                  textDirection: TextDirection.rtl,
                  label: 'ملاحظة حول التقديم',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء ادخال سبب الرفض';
                    }
                    return null;
                  },
                  minLines: 3,
                  showCharCount: true,
                  maxLength: 500,
                  controller: controller.rejectNotes,
                ),
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    customButton(
                      title: "إرسال ",
                      function: () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.of(context).pop();
                          QiyasLogService.log(
                              'qiyas owner submit reject reason');
                          await controller.updateTaskStatus(
                            submissionId: widget.submissionId,
                            status: EvidenceSubmissionStatus.rejected,
                          );
                          widget.onConfirmed
                              ?.call(); // ← NEW: fire after rejection saved
                        }
                      },
                      width: 150.sp,
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
}
