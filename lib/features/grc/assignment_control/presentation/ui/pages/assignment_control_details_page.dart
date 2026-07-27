import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_item.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';

class AssignmentControlDetailsPage extends StatefulWidget {
  final AssignmentControlItem item;
  final GRCModuleEntity module;

  const AssignmentControlDetailsPage({
    super.key,
    required this.item,
    required this.module,
  });

  @override
  State<AssignmentControlDetailsPage> createState() =>
      _AssignmentControlDetailsPageState();
}

class _AssignmentControlDetailsPageState
    extends State<AssignmentControlDetailsPage> {
  bool get _isRejected => widget.item.tab == AssignmentControlTab.rejected;

  bool get _canAct =>
      widget.item.tab == AssignmentControlTab.pending ||
      widget.item.tab == AssignmentControlTab.overdue ||
      _isRejected;

  void _onActionPressed(BuildContext context) {
    showUploadDialog(
      context: context,
      dialogTitle: (_isRejected ? 'Edit Evidence' : 'Upload Evidence').tr,
      titleFieldLabel: 'Note'.tr,
      titleFieldHint: 'Add a note (optional)'.tr,
      submitLabel: 'Submit'.tr,
      onSubmit: (file, note) => _confirmSubmit(context, file, note),
    );
  }

  void _confirmSubmit(BuildContext context, PlatformFile file, String note) {
    final cubit = context.read<AssignmentControlCubit>();
    showConfirmDialog(
      context: context,
      title: 'Submit Evidence'.tr,
      subtitle: 'Are you sure you want to submit this evidence?'.tr,
      confirmLabel: 'Submit'.tr,
      cancelLabel: 'Cancel'.tr,
      onConfirm: () => cubit.submitEvidence(
        moduleId: widget.module.moduleId,
        policyId: widget.item.control.policyId,
        controlId: widget.item.control.id,
        championEmail: currentGrcUserEmail(),
        documentFile: File(file.path!),
        note: note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.item.control;
    final assignment = widget.item.assignment;
    final isArabic = context.isArabic;
    final rejectionReason = (assignment?.departmentManagerRejectionReason
                ?.isNotEmpty ==
            true)
        ? assignment!.departmentManagerRejectionReason
        : assignment?.controlOwnerRejectionReason;

    return BlocConsumer<AssignmentControlCubit, AssignmentControlState>(
      listener: (context, state) {
        if (state is AssignmentControlActionSuccess) {
          showSuccessDialog(
            context: context,
            title: 'Evidence Submitted'.tr,
            subtitle: 'Your evidence was submitted successfully'.tr,
          );
          Navigator.pop(context);
        } else if (state is AssignmentControlFailure) {
          showErrorDialog(context: context, subtitle: state.message);
        }
      },
      builder: (context, state) {
        final isSaving = state is AssignmentControlLoading;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(
                    screensTitles: [
                      'GRC'.tr,
                      widget.module.localizedName(isArabic: isArabic),
                      'Assignment Controls'.tr,
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    isArabic ? control.controlsNameAr : control.controlsNameEn,
                    style: StyleText.fontSize16Weight600,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isArabic
                        ? control.controlsDescriptionAr
                        : control.controlsDescriptionEn,
                    style: StyleText.fontSize12Weight400,
                  ),
                  SizedBox(height: 15.h),
                  if (rejectionReason != null && rejectionReason.isNotEmpty) ...[
                    Text('Rejection Reason'.tr, style: CardStyles.label(12)),
                    SizedBox(height: 4.h),
                    Text(rejectionReason, style: CardStyles.value(12)),
                    SizedBox(height: 15.h),
                  ],
                  if (assignment != null && assignment.submissionNote.isNotEmpty) ...[
                    Text('Submission Note'.tr, style: CardStyles.label(12)),
                    SizedBox(height: 4.h),
                    Text(assignment.submissionNote, style: CardStyles.value(12)),
                    SizedBox(height: 15.h),
                  ],
                  if (assignment != null && assignment.submissionDocument.isNotEmpty)
                    ProductWarrantyCard(
                      title: 'Evidence'.tr,
                      fileName: assignment.submissionDocument
                          .split('/')
                          .last
                          .split('?')
                          .first,
                      onTapFile: () {},
                    ),
                  const Spacer(),
                  if (_canAct)
                    customButton(
                      title: (_isRejected ? 'Edit' : 'Upload Evidence').tr,
                      function: isSaving ? () {} : () => _onActionPressed(context),
                      width: double.infinity,
                      height: 44.h,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.textButton),
                    ),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
