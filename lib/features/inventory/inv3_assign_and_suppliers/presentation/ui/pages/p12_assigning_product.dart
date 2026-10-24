import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/product_details_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p13_select_assigning_product_toogel.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_toolbar_action_button.dart';

class AssignProductDesktopScreen extends StatefulWidget {
  const AssignProductDesktopScreen({super.key});

  @override
  State<AssignProductDesktopScreen> createState() =>
      _AssignProductDesktopScreenState();
}

class _AssignProductDesktopScreenState
    extends State<AssignProductDesktopScreen> {
  ///////////////////////////////// Controller ////////////////////////////////////////////
  final TextEditingController _searchController = TextEditingController();

  ///////////////////////////////// Controller ////////////////////////////////////////////
  ///////////////////////////////// Variable //////////////////////////////////////////////

  final List<Map<String, String>> departments = [
    {"key": "dep1", "value": "Dep1"},
    {"key": "dep2", "value": "Dep2"},
    {"key": "dep3", "value": "Dep3"},
    {"key": "dep4", "value": "Dep4"},
  ];
  String? selectedDepartment;

  ///////////////////////////////// Variable //////////////////////////////////////////////

  /////////////////////////////// Approval Cycle /////////////////////////////////////

  List<ApprovalSection> approvalSections = [ApprovalSection()];
  bool requireApproval = false;
  List<EmployeeEntity> filteredEmployees = [];
  List<EmployeeEntity> selectedEmployees = [];
  List<EmployeeEntity> allEmployees = []; // 🔥 This fixes your undefined error
  void toggleSelection(EmployeeEntity employee) {
    setState(() {
      if (selectedEmployees.contains(employee)) {
        selectedEmployees.remove(employee);
      } else {
        selectedEmployees.add(employee);
      }
    });
  }

  bool isSelected(EmployeeEntity employee) {
    return selectedEmployees.any((e) => e.id == employee.id);
  }

  String getDepartmentName(String departmentId, bool isEnglish) {
    final departmentsEn = {'dept1': 'HR', 'dept2': 'Engineering'};
    final departmentsAr = {'dept1': 'الموارد البشرية', 'dept2': 'الهندسة'};
    return isEnglish
        ? departmentsEn[departmentId] ?? ''
        : departmentsAr[departmentId] ?? '';
  }

  void _onSearchChanged() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      final selected = allEmployees
          .where((e) => selectedEmployees.any((s) => s.id == e.id))
          .toList();

      if (query.isEmpty) {
        filteredEmployees = selected;
      } else {
        final matches = allEmployees
            .where((employee) {
              final firstName = isArabic
                  ? (employee.firstNameInArabic ?? '')
                  : (employee.firstName ?? '');
              final lastName = isArabic
                  ? (employee.lastNameInArabic ?? '')
                  : (employee.lastName ?? '');
              final fullName = '$firstName $lastName';
              return fullName.toLowerCase().contains(query);
            })
            .where((e) => !selected.contains(e))
            .toList();

        filteredEmployees = [...selected, ...matches];
      }
    });
  }

  /////////////////////////////// Approval Cycle /////////////////////////////////////

  @override
  void initState() {
    super.initState();
    // Simulated Firestore data
    allEmployees = [
      EmployeeEntity(
        id: '1',
        firstName: 'Ali',
        lastName: 'Hassan',
        firstNameInArabic: 'علي',
        lastNameInArabic: 'حسن',
        title: 'Manager',
        titleInArabic: 'مدير',
        departmentId: 'dept1',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '2',
        firstName: 'Sara',
        lastName: 'Kamal',
        firstNameInArabic: 'سارة',
        lastNameInArabic: 'كمال',
        title: 'Engineer',
        titleInArabic: 'مهندسة',
        departmentId: 'dept2',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '3',
        firstName: 'Mohamed',
        lastName: 'Saleh',
        firstNameInArabic: 'محمد',
        lastNameInArabic: 'صالح',
        title: 'Technician',
        titleInArabic: 'فني',
        departmentId: 'dept2',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '4',
        firstName: 'Fatma',
        lastName: 'Mostafa',
        firstNameInArabic: 'فاطمة',
        lastNameInArabic: 'مصطفى',
        title: 'HR Specialist',
        titleInArabic: 'أخصائي موارد بشرية',
        departmentId: 'dept1',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '5',
        firstName: 'Youssef',
        lastName: 'Gamal',
        firstNameInArabic: 'يوسف',
        lastNameInArabic: 'جمال',
        title: 'Designer',
        titleInArabic: 'مصمم',
        departmentId: 'dept3',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '6',
        firstName: 'Nour',
        lastName: 'Adel',
        firstNameInArabic: 'نور',
        lastNameInArabic: 'عادل',
        title: 'Developer',
        titleInArabic: 'مطور',
        departmentId: 'dept2',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '7',
        firstName: 'Ahmed',
        lastName: 'Ezz',
        firstNameInArabic: 'أحمد',
        lastNameInArabic: 'عز',
        title: 'Support',
        titleInArabic: 'دعم فني',
        departmentId: 'dept1',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '8',
        firstName: 'Laila',
        lastName: 'Samir',
        firstNameInArabic: 'ليلى',
        lastNameInArabic: 'سمير',
        title: 'Data Analyst',
        titleInArabic: 'محلل بيانات',
        departmentId: 'dept3',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '9',
        firstName: 'Omar',
        lastName: 'Nasser',
        firstNameInArabic: 'عمر',
        lastNameInArabic: 'ناصر',
        title: 'Coordinator',
        titleInArabic: 'منسق',
        departmentId: 'dept1',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '10',
        firstName: 'Heba',
        lastName: 'Saeed',
        firstNameInArabic: 'هبة',
        lastNameInArabic: 'سعيد',
        title: 'Tester',
        titleInArabic: 'مختبرة',
        departmentId: 'dept2',
        gender: 'female',
      ),
    ];

    // 🔁 Attach the search listener
    _searchController.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context).languageCode == 'ar';
    Localizations.localeOf(context).languageCode == 'en';
    final isMobile = ContextExtension(context).isPhone;
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).productName,
          onSecondTap: () {
            navigateTo(context, ViewProductDetails());
          },
          thirdTitle: S.of(context).assigningProduct,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Employee Information
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).employeeInformation,
                      style: StyleText.fontSize18Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                // space
                SizedBox(height: 8.sp),

                // Search and DropDown Department
                Row(
                  children: [
                    // Search
                    Expanded(
                      child: SizedBox(
                        height: 38.sp,
                        child: AppSearchTextField(
                          controller: _searchController,
                          expanded: false,
                        ),
                      ),
                    ),
                    // space
                    SizedBox(width: ButtonSizing.toolbarGap(context)),
                    // Department
                    isMobile
                        ? customButtonWithSvg(
                            title: "",
                            function: () {},
                            width: 38.sp,
                            height: 38.sp,
                            color: AppColors.card,
                            textStyle: isMobile
                                ? StyleText.fontSize14Weight500.copyWith(
                                    color: AppColors.textButton,
                                  )
                                : StyleText.fontSize16Weight500.copyWith(
                                    color: AppColors.textButton,
                                  ),
                            radius: 8.r,
                            // 22/10/2026 — Owner: filter and sort icons are one size and colour in every module (ToolbarStyle).
                            heightImage: ToolbarStyle.iconSize,
                            widthImage: ToolbarStyle.iconSize,
                            svgColor: ToolbarStyle.contentColor,
                            image:
                                "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
                            space: 8.sp,
                            colorBorder: Colors.transparent,
                          )
                        : SizedBox(
                            width: 135.sp,
                            child: CustomDropdown<String>(
                              items: (departments)
                                  .map((e) => DropdownItem<String>(
                                      value: e['key'] ?? '',
                                      label: e['value'] ?? ''))
                                  .toList(),
                              value: selectedDepartment,
                              onChanged: (value) {
                                setState(() {
                                  selectedDepartment = value;
                                });
                              },
                              hint: S.of(context).department,
                              height: 38.sp,
                              fillColor: AppColors.card,
                            ),
                          ),
                  ],
                ),

                // space
                SizedBox(height: 15.sp),

                // Grid View
                SizedBox(
                  height: isMobile ? 350.sp : null,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: allEmployees.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: CrossAxisCountHelper
                          .getCrossAxisCountForDefaultTablet2(
                        context,
                      ),
                      crossAxisSpacing: 12.sp,
                      mainAxisSpacing: 12.sp,
                      mainAxisExtent: 70.sp,
                    ),
                    itemBuilder: (context, index) {
                      final employee = allEmployees[index];
                      final isSelected = selectedEmployees.contains(employee);

                      return employeeCard(employee, () {
                        setState(() {
                          isSelected
                              ? selectedEmployees.remove(employee)
                              : selectedEmployees.add(employee);
                        });
                      }, isSelected);
                    },
                  ),
                ),

                // space
                SizedBox(height: 15.sp),

                // Discard & Add Assets
                Row(
                  textDirection: TextDirection
                      .ltr, // X-73: Cancel left, action right in both languages

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ Discard
                    customButton(
                      title: S.of(context).discard,
                      function: () {
                        Navigator.pop(context);
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.grey,
                    ),

                    // ✅ preview
                    customButton(
                      title: S.of(context).preview,
                      function: () {
                        navigateTo(context, SelectAssignProduct());
                      },
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget employeeCard(
    EmployeeEntity employee,
    VoidCallback onTap,
    bool isSelected,
  ) {
    final isEnglish = !context.isArabic;

    final fullName = isEnglish
        ? "${employee.firstName ?? ''} ${employee.lastName ?? ''}"
        : "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}";

    final title =
        isEnglish ? employee.title ?? '' : employee.titleInArabic ?? '';

    return Container(
      width: 310.sp,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      child: Row(
        children: [
          // image
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: CustomSvgImage.natural(
                assetPath: employee.gender == "male"
                    ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                    : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
                semanticsLabel: 'Gender Icon',
                fit: BoxFit.cover,
                width: 40.w,
                height: 40.h,
              ),
            ),
          ),
          SizedBox(width: 10.sp),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                FormatHelper.capitalize(fullName),
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                FormatHelper.capitalize(title),
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                FormatHelper.capitalize(title),
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
