/// Module: GRC Policy Management
/// Description: Widget for adding and managing policy controls in a new policy.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyControlItemWidget, PolicyControlModel
/// Revision History: 2026-07-01 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: add_policy_controls.dart
/// Purpose: Contains AddPolicyControlsPage, the controls list widget
///          embedded inside CreateNewPolicyPage as step 2.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart';
import 'package:grc_module/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:grc_module/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/52_custom_upload_document.dart';
import 'package:grc_module/generated/l10n.dart';

/// class name: [AddPolicyControlsPage]
///
/// purpose: renders the list of policy control cards for step 2 of the
///          Create New Policy flow. Manages adding, removing, and updating
///          individual PolicyControlModel entries.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class AddPolicyControlsPage extends StatefulWidget {
  final bool isArabicEnabled;
  final List<PolicyControlModel> controls;
  final DateTime? policyStartDate;
  final DateTime? policyEndDate;
  final bool controlsSubmitted;
  final VoidCallback? onChanged;

  const AddPolicyControlsPage({
    super.key,
    required this.isArabicEnabled,
    required this.controls,
    required this.policyStartDate,
    required this.policyEndDate,
    required this.controlsSubmitted,
    this.onChanged,
  });

  @override
  State<AddPolicyControlsPage> createState() => _AddPolicyControlsPageState();
}

class _AddPolicyControlsPageState extends State<AddPolicyControlsPage> {
  List<PolicyControlModel> get _controls => widget.controls;

  void _addControl() {
    setState(() => _controls.add(PolicyControlModel()));
  }

  void _removeControl(int index) {
    setState(() {
      _controls[index].dispose();
      _controls.removeAt(index);
    });
  }

  void _onControlStartDateChanged(int index, DateTime? date) {
    setState(() {
      _controls[index].startDate = date;
      final end = _controls[index].endDate;
      if (end != null && date != null && end.isBefore(date)) {
        _controls[index].endDate = null;
      }
    });
  }

  void _onControlEndDateChanged(int index, DateTime? date) {
    setState(() => _controls[index].endDate = date);
  }

  void _onUploadDocumentEn(int index) {
    showUploadDialog(
      context: context,
      dialogTitle: S.of(context).uploadControlDocumentEnglish,
      titleFieldLabel: S.of(context).documentTitle,
      titleFieldHint: S.of(context).Texthere,
      browseLabel: S.of(context).browseFiles,
      submitLabel: S.of(context).submit,
      discardLabel: S.of(context).discard,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onSubmit: (file, title) {
        setState(() => _controls[index].documentEn =
            PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  void _onUploadDocumentAr(int index) {
    showUploadDialog(
      context: context,
      dialogTitle: 'رفع مستند الضابط (عربي)',
      titleFieldLabel: 'عنوان المستند',
      titleFieldHint: 'اكتب هنا',
      browseLabel: 'تصفح الملفات',
      submitLabel: 'إرسال',
      discardLabel: 'إلغاء',
      textDirection: TextDirection.rtl,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onSubmit: (file, title) {
        setState(() => _controls[index].documentAr =
            PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).addPolicyControls,
          style: AppTextStyles.font16BlackRegularCairo.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < _controls.length; i++)
                    PolicyControlItemWidget(
                      key: ValueKey(_controls[i]),
                      control: _controls[i],
                      isArabicEnabled: widget.isArabicEnabled,
                      controlsSubmitted: widget.controlsSubmitted,
                      showRemoveButton: _controls.length > 1,
                      onRemove: () => _removeControl(i),
                      onUploadDocumentEn: () => _onUploadDocumentEn(i),
                      onUploadDocumentAr: () => _onUploadDocumentAr(i),
                      onRemoveDocumentEn: () =>
                          setState(() => _controls[i].documentEn = null),
                      onRemoveDocumentAr: () =>
                          setState(() => _controls[i].documentAr = null),
                      onFrequencyChanged: (value) =>
                          setState(() => _controls[i].frequency = value),
                      policyStartDate: widget.policyStartDate,
                      policyEndDate: widget.policyEndDate,
                      onStartDateChanged: (date) =>
                          _onControlStartDateChanged(i, date),
                      onEndDateChanged: (date) =>
                          _onControlEndDateChanged(i, date),
                      onChanged: widget.onChanged,
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: customButtonWithSvg(
                      colorBorder: AppColors.textButton,
                      widthImage: 16.w,
                      heightImage: 16.h,
                      function: _addControl,
                      title: 'Control',
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.white),
                      image:
                          'assets/icons_assets/database_builder_assets/plus_head.svg',
                      color: AppColors.black,
                      svgColor: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
