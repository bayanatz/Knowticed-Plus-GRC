/// Module: GRC Policy Management
/// Description: Multi-step page for creating a new GRC policy.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, AddPolicyControlsPage, PolicyInfoFormWidget
/// Revision History: 2026-07-01 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: create_new_policy.dart
/// Purpose: Contains CreateNewPolicyPage, the two-step form for policy
///          creation — step 0: policy info, step 1: policy controls.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/add_policy_controls.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_header_widget.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [CreateNewPolicyPage]
///
/// purpose: two-step page that first collects policy info (step 0) then
///          shows the controls widget (step 1) without navigating to a new
///          route — the body switches in-place via _step.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class CreateNewPolicyPage extends StatefulWidget {
  const CreateNewPolicyPage({super.key});

  @override
  State<CreateNewPolicyPage> createState() => _CreateNewPolicyPageState();
}

class _CreateNewPolicyPageState extends State<CreateNewPolicyPage> {
  int _step = 0;
  bool _isArabicEnabled = true;

  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _numberController = TextEditingController();
  final _numberArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  PolicyDocumentInfo? _document;

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _numberController.dispose();
    _numberArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onUploadDocument() {
    setState(() {
      _document = const PolicyDocumentInfo(
        name: 'Submission 1.pdf',
        sizeLabel: '62 KB',
        dateLabel: '28 Dec 2023',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaginationAppBar(
              screensTitles: ['GRC'.tr, 'Create New Policy'.tr],
            ),
            Expanded(
              child: _step == 0 ? _buildStep0() : _buildStep1(),
            ),
            SizedBox(height: 16.h),
            _buildButtons(),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PolicyHeaderWidget(
                isArabicEnabled: _isArabicEnabled,
                onArabicToggle: (value) =>
                    setState(() => _isArabicEnabled = value),
              ),
              SizedBox(height: 15.h),
              PolicyInfoFormWidget(
                isArabicEnabled: _isArabicEnabled,
                nameController: _nameController,
                nameArController: _nameArController,
                numberController: _numberController,
                numberArController: _numberArController,
                descriptionController: _descriptionController,
                descriptionArController: _descriptionArController,
                weightController: _weightController,
                startDate: _startDate,
                endDate: _endDate,
                onStartDateChanged: (d) => setState(() => _startDate = d),
                onEndDateChanged: (d) => setState(() => _endDate = d),
                document: _document,
                onUploadDocument: _onUploadDocument,
                onRemoveDocument: () => setState(() => _document = null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return AddPolicyControlsPage(isArabicEnabled: _isArabicEnabled);
  }

  Widget _buildButtons() {
    if (_step == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          customButton(
            title: 'Discard'.tr,
            function: () {},
            height: 38.h,
            width: 150.w,
            color: AppColors.grey,
            textStyle:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
          customButton(
            title: 'Next'.tr,
            function: () => setState(() => _step = 1),
            height: 38.h,
            width: 150.w,
            color: AppColors.primary,
            textStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.textButton),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: 'Save For Later'.tr,
          function: () {},
          height: 38.h,
          width: 150.w,
          color: AppColors.grey,
          textStyle:
              StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        customButton(
          title: 'Preview'.tr,
          function: () {},
          height: 38.h,
          width: 150.w,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }
}
