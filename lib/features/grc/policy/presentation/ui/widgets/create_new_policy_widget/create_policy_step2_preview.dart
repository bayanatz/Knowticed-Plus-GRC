/// Module: GRC Policy Management
/// Description: Step 2 (Preview) content of the Create Policy page —
///              read-only policy summary plus the controls table.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-16
/// Dependencies: Flutter SDK, AppColors, PolicyInfoFormWidget,
///               PolicyControlsTableWidget, AddControllerButton
/// Revision History: 2026-07-16 - Extracted from create_new_policy.dart
library;

/// ************************* FILE INFO *************************** ///
/// File Name: create_policy_step2_preview.dart
/// Purpose: Contains CreatePolicyStep2Preview, the full preview step of
///          CreateNewPolicyPage — policy summary + controls table.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 16/7/2026

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/add_controller_button.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_controls_table_widget.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// class name: [CreatePolicyStep2Preview]
///
/// purpose: step 2 of [CreateNewPolicyPage] — shows the policy info
///          read-only, then either the controls table (if any control was
///          touched) or an [AddControllerButton] that sends the user back
///          to step 1.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 16/7/2026
class CreatePolicyStep2Preview extends StatelessWidget {
  final bool isArabicEnabled;
  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController numberController;
  final TextEditingController numberArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final TextEditingController weightController;
  final DateTime? startDate;
  final DateTime? endDate;
  final PolicyDocumentInfo? documentEn;
  final PolicyDocumentInfo? documentAr;
  final List<PolicyControlModel> touchedControls;
  final VoidCallback onAddController;
  final VoidCallback onControlsChanged;

  const CreatePolicyStep2Preview({
    super.key,
    required this.isArabicEnabled,
    required this.nameController,
    required this.nameArController,
    required this.numberController,
    required this.numberArController,
    required this.descriptionController,
    required this.descriptionArController,
    required this.weightController,
    required this.startDate,
    required this.endDate,
    required this.documentEn,
    required this.documentAr,
    required this.touchedControls,
    required this.onAddController,
    required this.onControlsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Policy info summary (read-only) --
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15.sp),
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: PolicyInfoFormWidget(
                isArabicEnabled: isArabicEnabled,
                nameController: nameController,
                nameArController: nameArController,
                numberController: numberController,
                numberArController: numberArController,
                descriptionController: descriptionController,
                descriptionArController: descriptionArController,
                weightController: weightController,
                startDate: startDate,
                endDate: endDate,
                onStartDateChanged: (_) {},
                onEndDateChanged: (_) {},
                documentEn: documentEn,
                documentAr: documentAr,
                onUploadDocumentEn: () {},
                onUploadDocumentAr: () {},
                onRemoveDocumentEn: () {},
                onRemoveDocumentAr: () {},
              ),
            ),
            SizedBox(height: 16.h),
            // -- Controls table / Add Controller button --
            touchedControls.isEmpty
                ? AddControllerButton(onPressed: onAddController)
                : PolicyControlsTableWidget(
                    controls: touchedControls,
                    onSave: onControlsChanged,
                  ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
