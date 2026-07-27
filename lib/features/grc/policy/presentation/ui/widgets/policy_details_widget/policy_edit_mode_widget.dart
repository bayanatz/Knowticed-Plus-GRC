/// Module: GRC Policy Management
/// Description: Editable "edit mode" body of the Policy Details page — the
///              "Create Arabic Version" toggle plus the shared
///              [PolicyInfoFormWidget] fields. The Active/Inactive status
///              toggle lives on [PolicyEditPage] itself, outside this form.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-18
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyInfoFormWidget,
///               flutter_switch
/// Revision History: 2026-07-18 - Initial creation
///                   2026-07-22 - Replaced the hardcoded isArabicEnabled:
///                                true with a real toggle, and moved the
///                                status toggle out to PolicyEditPage
library;

import 'dart:io';

import 'package:demo_app/core/custom/46_custom_image_picker.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [PolicyEditModeWidget]
///
/// purpose: renders the editable form for a Policy — the "Create Arabic
///          Version" toggle followed by [PolicyInfoFormWidget]. Kept as a
///          thin, stateless composition: all field state lives in the
///          parent page, this widget only lays it out.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 18/7/2026
class PolicyEditModeWidget extends StatelessWidget {
  final bool isArabicEnabled;
  final ValueChanged<bool> onArabicToggle;
  final File? imageFile;
  final String? imageUrl;
  final ValueChanged<File> onImagePicked;

  final bool submitted;
  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController numberController;
  final TextEditingController numberArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final TextEditingController weightController;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final PolicyDocumentInfo? documentEn;
  final PolicyDocumentInfo? documentAr;
  final VoidCallback onUploadDocumentEn;
  final VoidCallback onUploadDocumentAr;
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;

  const PolicyEditModeWidget({
    super.key,
    required this.isArabicEnabled,
    required this.onArabicToggle,
    required this.onImagePicked,
    this.imageFile,
    this.imageUrl,
    required this.submitted,
    required this.nameController,
    required this.nameArController,
    required this.numberController,
    required this.numberArController,
    required this.descriptionController,
    required this.descriptionArController,
    required this.weightController,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    this.documentEn,
    this.documentAr,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImagePicker(
              radius: 30.r,
              badgeRadius: 11.r,
              imageFile: imageFile,
              imageUrl: imageUrl,
              onImagePicked: onImagePicked,
            ),
            Row(
              children: [
                Text(
                  'Create Arabic Version'.tr,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                ),
                SizedBox(width: 10.w),
                FlutterSwitch(
                  width: 38.sp,
                  height: 22.sp,
                  padding: 3.sp,
                  borderRadius: 20.sp,
                  toggleSize: 16.sp,
                  activeColor: AppColors.secondaryPrimary,
                  inactiveColor: Colors.grey.withOpacity(.16),
                  value: isArabicEnabled,
                  onToggle: onArabicToggle,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        PolicyInfoFormWidget(
          isArabicEnabled: isArabicEnabled,
          submitted: submitted,
          nameController: nameController,
          nameArController: nameArController,
          numberController: numberController,
          numberArController: numberArController,
          descriptionController: descriptionController,
          descriptionArController: descriptionArController,
          weightController: weightController,
          startDate: startDate,
          endDate: endDate,
          onStartDateChanged: onStartDateChanged,
          onEndDateChanged: onEndDateChanged,
          documentEn: documentEn,
          documentAr: documentAr,
          onUploadDocumentEn: onUploadDocumentEn,
          onUploadDocumentAr: onUploadDocumentAr,
          onRemoveDocumentEn: onRemoveDocumentEn,
          onRemoveDocumentAr: onRemoveDocumentAr,
        ),
      ],
    );
  }
}
