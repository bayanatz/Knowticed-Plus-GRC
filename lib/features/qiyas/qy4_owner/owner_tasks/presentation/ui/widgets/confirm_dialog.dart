import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_tasks/presentation/ui/widgets/rejection_dialog.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_tasks/presentation/controller/qiyas_owner_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_log_service.dart';

class ConfirmDialog {
  void show(
    BuildContext context,
    EvidenceSubmissionStatus status,
    String submissionId, {
    VoidCallback? onConfirmed, // ← added
  }) {
    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          child: ConfirmDialogContent(
            status: status,
            submissionId: submissionId,
            onConfirmed: onConfirmed, // ← passed down
          ),
        );
      },
    );
  }
}

class ConfirmDialogContent extends StatefulWidget {
  const ConfirmDialogContent({
    required this.status,
    required this.submissionId,
    this.onConfirmed, // ← added
    super.key,
  });
  final EvidenceSubmissionStatus status;
  final String submissionId;
  final VoidCallback? onConfirmed; // ← added

  @override
  State<ConfirmDialogContent> createState() => _ConfirmDialogContentState();
}

class _ConfirmDialogContentState extends State<ConfirmDialogContent> {
  QiyasOwnerTasksCubit controller = sl();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    return BlocProvider.value(
      value: controller,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          width: isTablet ? 400.sp : 300.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25.sp,
                backgroundColor: widget.status.color,
                child: SvgPicture.asset(widget.status.icon,
                    width: 24.sp, height: 24.sp),
              ),
              SizedBox(height: 30.sp),
              Text(
                  widget.status == EvidenceSubmissionStatus.rejected
                      ? 'رفض المستند'
                      : 'الموافقة على المستند',
                  style: StyleText.fontSize14Weight500),
              SizedBox(height: 15.sp),
              Text(
                  widget.status == EvidenceSubmissionStatus.rejected
                      ? 'هل أنت متأكد من أنك تريد رفض هذا المستند؟'
                      : 'هل أنت متأكد من أنك تريد الموافقة على هذا المستند؟',
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.secondaryBlack)),
              SizedBox(height: 15.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  customButton(
                      width: 130,
                      color: AppColors.secondaryButton,
                      textStyle: StyleText.fontSize16Weight500,
                      title: 'لا',
                      function: () {
                        Navigator.of(context).pop();
                      }),
                  customButton(
                      width: 130,
                      title: 'نعم',
                      function: () async {
                        Navigator.of(context).pop();
                        if (widget.status ==
                            EvidenceSubmissionStatus.rejected) {
                          QiyasLogService.log('qiyas owner reject document');
                          RejectionDialog().show(context, widget.submissionId,
                              onConfirmed: widget
                                  .onConfirmed); // ← passed to RejectionDialog so notification fires after rejection reason is saved
                        } else {
                          QiyasLogService.log('qiyas owner approve document');
                          QiyasOwnerTasksCubit controller = sl();
                          await controller.updateTaskStatus(
                              submissionId: widget.submissionId,
                              status: widget.status);
                          widget.onConfirmed?.call(); // ← fire after approve
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
