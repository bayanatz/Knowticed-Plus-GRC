/// ************************* FILE INFO *************************** ///
/// File Name: grc_details_page.dart
/// Purpose: This file contains the implementation of the Governance, Risk, and Compliance (GRC) details page. It provides a user interface for viewing, creating, editing, and restoring GRC modules. The page includes form fields for module details, owner selection, status toggling, and action buttons for user interactions.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 2026-06-28
library;

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_bottom_buttons.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_status_switch.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

enum GrcPageMode { view, edit, create, restore }

class GovernanceRiskAndComplianceDetails extends StatefulWidget {
  final GrcPageMode mode;

  const GovernanceRiskAndComplianceDetails({
    super.key,
    this.mode = GrcPageMode.create,
  });

  @override
  State<GovernanceRiskAndComplianceDetails> createState() =>
      _GovernanceRiskAndComplianceDetailsState();
}

class _GovernanceRiskAndComplianceDetailsState
    extends State<GovernanceRiskAndComplianceDetails> {
  final _nameEnController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descEnController = TextEditingController();
  final _descArController = TextEditingController();

  String? _selectedDepartment;
  DateTime? _activationDate;
  bool _statusValue = true;
  late GrcPageMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _descEnController.dispose();
    _descArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  if (_currentMode == GrcPageMode.create)
                    'Create New GRC Module'.tr
                  else if (_currentMode == GrcPageMode.edit)
                    'Edit GRC Module'.tr
                  else
                    'GRC Module'.tr,
                ],
              ),
              if (_currentMode == GrcPageMode.view &&
                  _currentMode != GrcPageMode.restore)
                GrcActionButtons(
                  onEditTap: () =>
                      setState(() => _currentMode = GrcPageMode.edit),
                ),
              if (_currentMode == GrcPageMode.edit)
                GrcStatusSwitch(
                  value: _statusValue,
                  onToggle: (v) => setState(() => _statusValue = v),
                ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15.sp),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GrcFormFields(
                          nameEnController: _nameEnController,
                          nameArController: _nameArController,
                          descEnController: _descEnController,
                          descArController: _descArController,
                          selectedDepartment: _selectedDepartment,
                          activationDate: _activationDate,
                          onDepartmentChanged: (v) =>
                              setState(() => _selectedDepartment = v),
                          onDateChanged: (v) =>
                              setState(() => _activationDate = v),
                        ),
                        SizedBox(height: 20.h),
                        GrcOwnerSection(
                          isViewMode: (_currentMode == GrcPageMode.view ||
                              _currentMode == GrcPageMode.restore),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              GrcBottomButtons(
                mode: _currentMode,
                onDiscard: _currentMode == GrcPageMode.create
                    ? () => Navigator.pop(context)
                    : () => setState(() => _currentMode = GrcPageMode.view),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
