// ****************** FILE INFO ******************
// File Name: crm_add_deal_step1_details.dart
// Purpose: Step 1 (Deal Details & Assigned Dates) of the Add Deal wizard
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/widgets/crm_employee_selection_card.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/enums/crm_currency_enum.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class CrmAddDealStep1Details extends StatefulWidget {
  final TextEditingController dealNameEnController;
  final TextEditingController dealNameArController;
  final TextEditingController noteEnController;
  final TextEditingController noteArController;
  final TextEditingController expectedValueController;
  final List<CrmDealCategoryModel>? categories;
  final List<CrmTeamMemberModel>? employees;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final String? selectedCurrency;
  final ValueChanged<String?> onCurrencyChanged;
  final String? selectedLikelihood;
  final ValueChanged<String?> onLikelihoodChanged;
  final DateTime? startDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final DateTime? closeDate;
  final ValueChanged<DateTime?> onCloseDateChanged;
  final CrmTeamMemberModel? selectedEmployee;
  final ValueChanged<CrmTeamMemberModel?> onEmployeeSelected;
  final bool isSubmitted;

  const CrmAddDealStep1Details({
    super.key,
    required this.dealNameEnController,
    required this.dealNameArController,
    required this.noteEnController,
    required this.noteArController,
    required this.expectedValueController,
    this.categories,
    this.employees,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.selectedLikelihood,
    required this.onLikelihoodChanged,
    required this.startDate,
    required this.onStartDateChanged,
    required this.closeDate,
    required this.onCloseDateChanged,
    required this.selectedEmployee,
    required this.onEmployeeSelected,
    required this.isSubmitted,
  });

  @override
  State<CrmAddDealStep1Details> createState() => _CrmAddDealStep1DetailsState();
}

class _CrmAddDealStep1DetailsState extends State<CrmAddDealStep1Details> {
  final TextEditingController _employeeSearchController =
      TextEditingController();

  static const List<String> _defaultCategories = <String>[
    'ERP System',
    'CRM Solution',
    'POS Software',
    'Cloud Hosting',
    'Consulting',
    'Maintenance',
  ];

  List<String> get _effectiveCategories {
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      final List<String> names = widget.categories!
          .where((CrmDealCategoryModel c) => c.isActive && !c.isDeleted)
          .map((CrmDealCategoryModel c) => FormatHelper.localizedString(
                englishName: c.nameEn,
                arabicName: c.nameAr,
              ))
          .where((String name) => name.isNotEmpty)
          .toList();
      if (names.isNotEmpty) return names;
    }
    return _defaultCategories;
  }

  List<CrmTeamMemberModel> get _effectiveEmployees {
    if (widget.employees != null && widget.employees!.isNotEmpty) {
      return widget.employees!;
    }
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

  @override
  void dispose() {
    _employeeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Section 1: Deal Details ──────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Deal Details',
            arabicName: 'تفاصيل الصفقة',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Category (half row)
              buildResponsiveFields(
                context: context,
                left: CustomDropdown<String>(
                  label: 'Category',
                  hint: 'Choose',
                  value: widget.selectedCategory,
                  items: _effectiveCategories
                      .map((String c) =>
                          DropdownItem<String>(value: c, label: c))
                      .toList(),
                  fillColor: AppColors.background,
                  errorText:
                      (widget.isSubmitted && widget.selectedCategory == null)
                          ? 'Field Required'
                          : null,
                  onChanged: widget.onCategoryChanged,
                ),
                right: const SizedBox.shrink(),
              ),

              SizedBox(height: 16.sp),

              // Deal Name (Bilingual Pair: Left English, Right Arabic)
              buildResponsiveFields(
                context: context,
                left: CustomTextField(
                  label: 'Deal Name',
                  hint: 'Text Here',
                  controller: widget.dealNameEnController,
                  fillColor: AppColors.background,
                  errorText: (widget.isSubmitted &&
                          widget.dealNameEnController.text.trim().isEmpty)
                      ? 'Field Required'
                      : null,
                ),
                right: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomTextField(
                    label: 'اسم الصفقة',
                    hint: 'اكتب هنا',
                    textAlign: TextAlign.right,
                    controller: widget.dealNameArController,
                    fillColor: AppColors.background,
                    errorText: (widget.isSubmitted &&
                            widget.dealNameArController.text.trim().isEmpty)
                        ? 'الحقل مطلوب'
                        : null,
                  ),
                ),
              ),

              SizedBox(height: 16.sp),

              // Note (Bilingual Multiline)
              _buildNotesRow(context),

              SizedBox(height: 16.sp),

              // Expected Value & Currency
              buildResponsiveFields(
                context: context,
                left: CustomTextField(
                  label: 'Expected Value',
                  hint: 'Text Here',
                  controller: widget.expectedValueController,
                  keyboardType: TextInputType.number,
                  fillColor: AppColors.background,
                  errorText: (widget.isSubmitted &&
                          widget.expectedValueController.text.trim().isEmpty)
                      ? 'Field Required'
                      : null,
                ),
                right: CustomDropdown<String>(
                  label: 'Currency',
                  hint: 'Choose',
                  value: widget.selectedCurrency,
                  items: CrmCurrencyEnum.values
                      .map((CrmCurrencyEnum c) =>
                          DropdownItem<String>(value: c.code, label: c.code))
                      .toList(),
                  fillColor: AppColors.background,
                  errorText:
                      (widget.isSubmitted && widget.selectedCurrency == null)
                          ? 'Field Required'
                          : null,
                  onChanged: widget.onCurrencyChanged,
                ),
              ),

              SizedBox(height: 16.sp),

              // Likelihood (half row)
              buildResponsiveFields(
                context: context,
                left: CustomDropdown<String>(
                  label: 'Likelihood',
                  hint: 'Choose',
                  value: widget.selectedLikelihood,
                  items: _likelihoods
                      .map((String l) =>
                          DropdownItem<String>(value: l, label: l))
                      .toList(),
                  fillColor: AppColors.background,
                  errorText:
                      (widget.isSubmitted && widget.selectedLikelihood == null)
                          ? 'Field Required'
                          : null,
                  onChanged: widget.onLikelihoodChanged,
                ),
                right: const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.sp),

        // ── Section 2: Assigned & Date Details ─────────────────────────────
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
                  value: widget.startDate,
                  fillColor: AppColors.background,
                  errorText: (widget.isSubmitted && widget.startDate == null)
                      ? 'Field Required'
                      : null,
                  onChanged: widget.onStartDateChanged,
                ),
                right: CustomDateField(
                  label: 'Expected Close Date',
                  hint: 'Select Date',
                  value: widget.closeDate,
                  fillColor: AppColors.background,
                  errorText: (widget.isSubmitted && widget.closeDate == null)
                      ? 'Field Required'
                      : null,
                  onChanged: widget.onCloseDateChanged,
                ),
              ),

              SizedBox(height: 20.sp),

              // Assigned To Header
              Text(
                'Assigned To',
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.sp),

              // Employee Search & Filters Toolbar
              _buildEmployeeSearchToolbar(context),

              SizedBox(height: 12.sp),

              // Employee Selectable Cards Grid
              _buildEmployeeGrid(context),

              if (widget.isSubmitted &&
                  widget.selectedEmployee == null) ...<Widget>[
                SizedBox(height: 6.sp),
                Text(
                  'Field Required',
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.red,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesRow(BuildContext context) {
    return Column(
      children: <Widget>[
        // English Note
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomTextField(
              label: 'Note',
              hint: 'Description',
              controller: widget.noteEnController,
              fillColor: AppColors.background,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 4.sp),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${widget.noteEnController.text.length}/500',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.darkGrey,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.sp),
        // Arabic Note
        Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomTextField(
                label: 'ملاحظة',
                hint: 'اكتب هنا',
                textAlign: TextAlign.right,
                controller: widget.noteArController,
                fillColor: AppColors.background,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 4.sp),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.noteArController.text.length}/500',
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.darkGrey,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeSearchToolbar(BuildContext context) {
    final bool hasError = widget.isSubmitted && widget.selectedEmployee == null;

    return CustomSearchFilterSortBar<String, String>(
      searchController: _employeeSearchController,
      onSearchChanged: (_) => setState(() {}),
      searchHint: 'Search',
      showFilter: true,
      onFilterTap: () {},
      showSort: true,
      sortItems: const <String>['Name: A-Z', 'Name: Z-A', 'Role'],
      selectedSort: 'Name: A-Z',
      sortLabelBuilder: (String item) => item,
      onSortChanged: (String? sort) {},
      fillColor: AppColors.background,
      isError: hasError,
    );
  }

  Widget _buildEmployeeGrid(BuildContext context) {
    final String query = _employeeSearchController.text.trim().toLowerCase();
    final List<CrmTeamMemberModel> list =
        _effectiveEmployees.where((CrmTeamMemberModel e) {
      return query.isEmpty ||
          e.name.toLowerCase().contains(query) ||
          e.role.toLowerCase().contains(query);
    }).toList();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount = constraints.maxWidth > 900
            ? 4
            : (constraints.maxWidth > 600 ? 3 : 2);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 64.sp,
            crossAxisSpacing: 10.sp,
            mainAxisSpacing: 10.sp,
          ),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            final CrmTeamMemberModel employee = list[index];
            final bool isSelected = widget.selectedEmployee?.id == employee.id;

            return CrmEmployeeSelectionCard(
              employee: employee,
              isSelected: isSelected,
              onTap: () {
                if (isSelected) {
                  widget.onEmployeeSelected(null);
                } else {
                  widget.onEmployeeSelected(employee);
                }
              },
            );
          },
        );
      },
    );
  }
}
