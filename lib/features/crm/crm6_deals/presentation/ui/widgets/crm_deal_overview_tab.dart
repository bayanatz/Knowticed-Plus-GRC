// ****************** FILE INFO ******************
// File Name: crm_deal_overview_tab.dart
// Purpose: Overview tab for Deal Details page with View Mode and Edit Mode matching Figma screenshots 1 and 2
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_client_deals_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_deals_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/enums/crm_currency_enum.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_overview_assigned_card.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_overview_employee_picker.dart';

class CrmDealOverviewTab extends StatefulWidget {
  final CrmClientDealModel deal;
  final VoidCallback? onSave;

  const CrmDealOverviewTab({
    super.key,
    required this.deal,
    this.onSave,
  });

  @override
  State<CrmDealOverviewTab> createState() => _CrmDealOverviewTabState();
}

class _CrmDealOverviewTabState extends State<CrmDealOverviewTab> {
  bool _isEditMode = false;
  StreamSubscription<dynamic>? _categoriesSub;
  List<String> _loadedCategories = <String>[];

  late final TextEditingController _dealNameEnController;
  late final TextEditingController _dealNameArController;
  late final TextEditingController _noteEnController;
  late final TextEditingController _noteArController;
  late final TextEditingController _expectedValueController;
  final TextEditingController _employeeSearchController =
      TextEditingController();

  String? _selectedCategory;
  String? _selectedAssignTo;
  String? _selectedCurrency = 'EGP';
  String? _selectedLikelihood;
  DateTime? _startDate;
  DateTime? _closeDate;
  CrmTeamMemberModel? _selectedEmployee;

  static const List<String> _defaultCategories = <String>[
    'ERP System',
    'CRM Solution',
    'POS Software',
    'Cloud Hosting',
    'Consulting',
    'Maintenance',
  ];

  List<String> get _categories =>
      _loadedCategories.isNotEmpty ? _loadedCategories : _defaultCategories;

  List<CrmTeamMemberModel> get _effectiveEmployees {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final MainCoreEmployeeController controller =
          Get.find<MainCoreEmployeeController>();
      final List<EmployeeEntityPro> entities =
          controller.allEmployeesEntities ?? <EmployeeEntityPro>[];
      final List<CrmTeamMemberModel> members = entities
          .where((EmployeeEntityPro e) =>
              e.id != null &&
              e.id!.isNotEmpty &&
              (e.status?.toLowerCase() == 'active' || e.status == null))
          .map(CrmTeamMemberModel.fromEmployeeEntity)
          .where((CrmTeamMemberModel m) => m.name.isNotEmpty)
          .toList();
      if (members.isNotEmpty) return members;
    }
    return const <CrmTeamMemberModel>[];
  }

  static const List<String> _likelihoods = <String>[
    '10%',
    '25%',
    '50%',
    '75%',
    '100%',
  ];

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    final List<String> parts = dateStr.split('/');
    if (parts.length == 3) {
      final int? day = int.tryParse(parts[0]);
      final int? month = int.tryParse(parts[1]);
      final int? year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.tryParse(dateStr);
  }

  @override
  void initState() {
    super.initState();
    _dealNameEnController = TextEditingController(text: widget.deal.dealNameEn);
    _dealNameArController = TextEditingController(text: widget.deal.dealNameAr);
    _noteEnController = TextEditingController(text: widget.deal.noteEn);
    _noteArController = TextEditingController(text: widget.deal.noteAr);
    _expectedValueController = TextEditingController(
      text: widget.deal.expectedValue.toInt().toString(),
    );
    _selectedCategory = widget.deal.category.isNotEmpty
        ? widget.deal.category
        : _defaultCategories.first;
    _selectedAssignTo = widget.deal.assignedEmployee;
    _selectedLikelihood =
        widget.deal.likelihood.isNotEmpty ? widget.deal.likelihood : '25%';

    _startDate = _parseDate(widget.deal.startDate) ?? widget.deal.createdAt;
    _closeDate = _parseDate(widget.deal.closeDate) ??
        widget.deal.createdAt.add(const Duration(days: 30));

    final List<CrmTeamMemberModel> emps = _effectiveEmployees;
    if (emps.isNotEmpty) {
      _selectedEmployee = emps.firstWhere(
        (CrmTeamMemberModel e) =>
            e.name.toLowerCase() == widget.deal.assignedEmployee.toLowerCase(),
        orElse: () => emps.first,
      );
      if (_selectedAssignTo == null || _selectedAssignTo!.isEmpty) {
        _selectedAssignTo = _selectedEmployee?.name;
      }
    }

    if (Get.isRegistered<CrmDealsBaseRepository>()) {
      _categoriesSub =
          Get.find<CrmDealsBaseRepository>().watchCategories().listen((result) {
        result.fold((_) {}, (List<CrmDealCategoryModel> list) {
          final List<String> names = list
              .where((CrmDealCategoryModel c) => c.isActive && !c.isDeleted)
              .map((CrmDealCategoryModel c) => FormatHelper.localizedString(
                    englishName: c.nameEn,
                    arabicName: c.nameAr,
                  ))
              .where((String n) => n.isNotEmpty)
              .toList();
          if (names.isNotEmpty && mounted) {
            setState(() => _loadedCategories = names);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _categoriesSub?.cancel();
    _dealNameEnController.dispose();
    _dealNameArController.dispose();
    _noteEnController.dispose();
    _noteArController.dispose();
    _expectedValueController.dispose();
    _employeeSearchController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    CrmControlDialogs.showSaveDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Save Deal',
        arabicName: 'حفظ الصفقة',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Are you sure you want to save changes to this deal?',
        arabicName: 'هل أنت متأكد من حفظ التعديلات على هذه الصفقة؟',
      ),
      onConfirm: () async {
        await _performSaveDeal();
      },
    );
  }

  Future<void> _performSaveDeal() async {
    showLoadingIndicator();
    try {
      final double expectedVal =
          double.tryParse(_expectedValueController.text.trim()) ??
              widget.deal.expectedValue;
      final double likelihoodVal = double.tryParse(
              (_selectedLikelihood ?? '25%').replaceAll('%', '').trim()) ??
          25.0;

      final String employeeName = _selectedEmployee?.name ??
          _selectedAssignTo ??
          widget.deal.assignedEmployee;
      final String employeeId =
          _selectedEmployee?.id ?? widget.deal.assignedEmployeeId;

      if (Get.isRegistered<CrmClientDealsBaseRepository>()) {
        final CrmClientDealsBaseRepository repo =
            Get.find<CrmClientDealsBaseRepository>();

        final CrmClientDealRecordModel updatedRecord = CrmClientDealRecordModel(
          id: widget.deal.id,
          clientId: widget.deal.clientId,
          categoryId: widget.deal.categoryId,
          categoryNameEn: _selectedCategory ?? widget.deal.category,
          categoryNameAr: _selectedCategory ?? widget.deal.category,
          currentStageId: widget.deal.currentStageId.isNotEmpty
              ? widget.deal.currentStageId
              : widget.deal.stage,
          stageNameEn: widget.deal.stageLabelEn,
          stageNameAr: widget.deal.stageLabelAr,
          assignedEmployeeId: employeeId,
          assignedEmployeeName: employeeName,
          nameEn: _dealNameEnController.text.trim(),
          nameAr: _dealNameArController.text.trim(),
          noteEn: _noteEnController.text.trim(),
          noteAr: _noteArController.text.trim(),
          currency: _selectedCurrency ?? widget.deal.currency,
          expectedValue: expectedVal,
          likelihood: likelihoodVal,
          startDate: _startDate ?? DateTime.now(),
          closeDate: _closeDate ?? DateTime.now().add(const Duration(days: 30)),
          status: widget.deal.stage,
          subtotal: expectedVal,
          discountTotal: 0,
          taxTotal: 0,
          grandTotal: widget.deal.amount > 0 ? widget.deal.amount : expectedVal,
          productLines: widget.deal.rawProductLines,
          serviceLines: widget.deal.rawServiceLines,
          checklist: widget.deal.checklist,
          createdAt: widget.deal.createdAt,
          createdBy: '',
        );

        await repo.updateClientDeal(deal: updatedRecord);
      }
    } finally {
      hideLoadingIndicator();
    }

    if (mounted) {
      setState(() {
        _isEditMode = false;
      });

      await CrmControlDialogs.showSuccessDialog(
        context: context,
        title: FormatHelper.localizedString(
          englishName: 'Saved Successfully',
          arabicName: 'تم الحفظ بنجاح',
        ),
        subtitle: FormatHelper.localizedString(
          englishName: 'Deal details have been updated.',
          arabicName: 'تم تحديث تفاصيل الصفقة بنجاح.',
        ),
      );

      widget.onSave?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Top Edit Button in View Mode
        if (!_isEditMode) ...<Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: CustomEditIcon(
              title: FormatHelper.localizedString(
                englishName: 'Edit',
                arabicName: 'تعديل',
              ),
              color: AppColors.primary,
              borderColor: Colors.transparent,
              svgColor: AppColors.black,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.bold,
              ),
              onTap: () => setState(() => _isEditMode = true),
            ),
          ),
          SizedBox(height: 16.sp),
        ],

        // Section 1: Deal Details
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Deal Details',
            arabicName: 'تفاصيل الصفقة',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Category & Assign to
              buildResponsiveFields(
                context: context,
                left: CustomDropdown<String>(
                  label: 'Category',
                  hint: 'Choose',
                  value: _selectedCategory,
                  enabled: _isEditMode,
                  items: _categories
                      .map((String c) =>
                          DropdownItem<String>(value: c, label: c))
                      .toList(),
                  fillColor: AppColors.background,
                  onChanged: (String? val) =>
                      setState(() => _selectedCategory = val),
                ),
                right: CustomDropdown<String>(
                  label: 'Assign to',
                  hint: 'Choose',
                  value: _selectedAssignTo,
                  enabled: _isEditMode,
                  items: _effectiveEmployees
                      .map((CrmTeamMemberModel e) =>
                          DropdownItem<String>(value: e.name, label: e.name))
                      .toList(),
                  fillColor: AppColors.background,
                  onChanged: (String? val) {
                    setState(() {
                      _selectedAssignTo = val;
                      if (val != null) {
                        for (final CrmTeamMemberModel e
                            in _effectiveEmployees) {
                          if (e.name == val) {
                            _selectedEmployee = e;
                            break;
                          }
                        }
                      }
                    });
                  },
                ),
              ),

              SizedBox(height: 16.sp),

              // Deal Name Bilingual
              buildResponsiveFields(
                context: context,
                left: CustomTextField(
                  label: 'Deal Name',
                  hint: 'Text Here',
                  controller: _dealNameEnController,
                  readOnly: !_isEditMode,
                  fillColor: AppColors.background,
                ),
                right: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomTextField(
                    label: 'اسم الصفقة',
                    hint: 'اكتب هنا',
                    textAlign: TextAlign.right,
                    controller: _dealNameArController,
                    readOnly: !_isEditMode,
                    fillColor: AppColors.background,
                  ),
                ),
              ),

              SizedBox(height: 16.sp),

              // Notes Bilingual
              _buildNotesRow(context),

              SizedBox(height: 16.sp),

              // Expected Value & Currency
              buildResponsiveFields(
                context: context,
                left: CustomTextField(
                  label: 'Expected Value',
                  hint: 'Text Here',
                  controller: _expectedValueController,
                  readOnly: !_isEditMode,
                  keyboardType: TextInputType.number,
                  fillColor: AppColors.background,
                ),
                right: CustomDropdown<String>(
                  label: 'Currency',
                  hint: 'Choose',
                  value: _selectedCurrency,
                  enabled: _isEditMode,
                  items: CrmCurrencyEnum.values
                      .map((CrmCurrencyEnum c) =>
                          DropdownItem<String>(value: c.code, label: c.code))
                      .toList(),
                  fillColor: AppColors.background,
                  onChanged: (String? val) =>
                      setState(() => _selectedCurrency = val),
                ),
              ),

              SizedBox(height: 16.sp),

              // Likelihood in half-row
              buildResponsiveFields(
                context: context,
                left: CustomDropdown<String>(
                  label: 'Likelihood',
                  hint: 'Choose',
                  value: _selectedLikelihood,
                  enabled: _isEditMode,
                  items: _likelihoods
                      .map((String l) =>
                          DropdownItem<String>(value: l, label: l))
                      .toList(),
                  fillColor: AppColors.background,
                  onChanged: (String? val) =>
                      setState(() => _selectedLikelihood = val),
                ),
                right: const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.sp),

        // Section 2: Assigned & Date Details
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Assigned & Date Details',
            arabicName: 'الموظف المعين وتفاصيل التاريخ',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Dates Row
              buildResponsiveFields(
                context: context,
                left: CustomDateField(
                  label: 'Start Date',
                  hint: 'Select Date',
                  value: _startDate,
                  enabled: _isEditMode,
                  fillColor: AppColors.background,
                  onChanged: (DateTime? val) =>
                      setState(() => _startDate = val),
                ),
                right: CustomDateField(
                  label: 'Expected Close Date',
                  hint: 'Select Date',
                  value: _closeDate,
                  enabled: _isEditMode,
                  fillColor: AppColors.background,
                  onChanged: (DateTime? val) =>
                      setState(() => _closeDate = val),
                ),
              ),

              SizedBox(height: 20.sp),

              Text(
                'Assigned To',
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.sp),

              // Assigned Employee Details Card in View Mode (Screenshot 1)
              if (!_isEditMode)
                CrmDealOverviewAssignedCard(
                  name: _selectedEmployee?.name ??
                      (widget.deal.assignedEmployee.isNotEmpty
                          ? widget.deal.assignedEmployee
                          : 'Amro Handousa'),
                  jobTitle: _selectedEmployee?.role ?? 'Employee',
                  phone: _selectedEmployee?.phone.isNotEmpty == true
                      ? _selectedEmployee!.phone
                      : '011587954555',
                  department: _selectedEmployee?.department.isNotEmpty == true
                      ? _selectedEmployee!.department
                      : (widget.deal.department.isNotEmpty
                          ? widget.deal.department
                          : 'IT'),
                  email: _selectedEmployee?.email.isNotEmpty == true
                      ? _selectedEmployee!.email
                      : 'amr@gmail.com',
                  avatarUrl: _selectedEmployee?.avatarUrl,
                )
              // Employee Picker Grid in Edit Mode (Screenshot 2)
              else
                CrmDealOverviewEmployeePicker(
                  searchController: _employeeSearchController,
                  employees: _effectiveEmployees,
                  selectedEmployee: _selectedEmployee,
                  onEmployeeSelected: (CrmTeamMemberModel? emp) {
                    setState(() {
                      _selectedEmployee = emp;
                      _selectedAssignTo = emp?.name;
                    });
                  },
                  onSearchChanged: () => setState(() {}),
                ),
            ],
          ),
        ),

        // Bottom Discard / Save buttons in Edit Mode (Screenshot 2)
        if (_isEditMode) ...<Widget>[
          SizedBox(height: 32.sp),
          Row(
            textDirection: TextDirection
                .ltr, // X-73: Cancel left, action right in both languages

            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              customButton(
                title: FormatHelper.localizedString(
                  englishName: 'Discard',
                  arabicName: 'إلغاء',
                ),
                color: const Color(0xFFE5E7EB),
                borderColor: Colors.transparent,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
                function: () => setState(() => _isEditMode = false),
              ),
              customButton(
                title: FormatHelper.localizedString(
                  englishName: 'Save',
                  arabicName: 'حفظ',
                ),
                color: AppColors.primary,
                borderColor: Colors.transparent,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
                function: _onSavePressed,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNotesRow(BuildContext context) {
    return Column(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomTextField(
              label: 'Note',
              hint: 'Description',
              controller: _noteEnController,
              readOnly: !_isEditMode,
              fillColor: AppColors.background,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            if (_isEditMode) ...<Widget>[
              SizedBox(height: 4.sp),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_noteEnController.text.length}/500',
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.darkGrey,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12.sp),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomTextField(
                label: 'ملاحظة',
                hint: 'اكتب هنا',
                textAlign: TextAlign.right,
                controller: _noteArController,
                readOnly: !_isEditMode,
                fillColor: AppColors.background,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
              ),
              if (_isEditMode) ...<Widget>[
                SizedBox(height: 4.sp),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_noteArController.text.length}/500',
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
