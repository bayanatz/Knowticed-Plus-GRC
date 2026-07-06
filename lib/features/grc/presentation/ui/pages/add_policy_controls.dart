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

import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

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

  const AddPolicyControlsPage({
    super.key,
    required this.isArabicEnabled,
    required this.controls,
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

  void _onUploadDocument(int index) {
    setState(() {
      _controls[index].document = const PolicyDocumentInfo(
        name: 'Control Doc.pdf',
        sizeLabel: '40 KB',
        dateLabel: '28 Dec 2023',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Policy Controls'.tr,
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
                      showRemoveButton: _controls.length > 1,
                      onRemove: () => _removeControl(i),
                      onUploadDocument: () => _onUploadDocument(i),
                      onRemoveDocument: () =>
                          setState(() => _controls[i].document = null),
                      onFrequencyChanged: (value) =>
                          setState(() => _controls[i].frequency = value),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: customButtonWithSvg(
                      colorBorder: AppColors.textButton,
                      space: 10.w,
                      radius: 8.r,
                      widthImage: 16.w,
                      heightImage: 16.h,
                      function: _addControl,
                      title: 'Control',
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.white),
                      image: 'assets/icons/add.svg',
                      color: AppColors.textButton,
                      width: 140.w,
                      height: 36.h,
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
