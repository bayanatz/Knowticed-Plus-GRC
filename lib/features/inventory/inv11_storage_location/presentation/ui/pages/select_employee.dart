import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/pages/select_employee_with_data_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/storage_location_form_kit.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class SelectEmployee extends StatefulWidget {
  final Map<String, dynamic> storageLocationData;

  const SelectEmployee({super.key, this.storageLocationData = const {}});

  @override
  State<SelectEmployee> createState() => _SelectEmployeeState();
}

class _SelectEmployeeState extends State<SelectEmployee> {
  /////////////////////////// Department Translations //////////////////////////////////////
  static const Map<String, String> departmentTranslationsCamel = {
    "marketing": "التسويق",
    "sales": "المبيعات",
    "hr": "شؤون الموظفين",
    "executive": "الإدارة التنفيذية",
    "customerSupport": "دعم العملاء",
    "operations": "العمليات",
    "finance": "المالية",
    "informationTechnology": "تقنية المعلومات",
    "humanResources": "الموارد البشرية",
    "dataManagement": "إدارة البيانات",
    "complianceAndLegal": "الامتثال والقانون",
    "software": "البرمجيات",
  };

  /////////////////////////// Search and Department //////////////////////////////////////
  final TextEditingController _searchController = TextEditingController();
  final MainCoreEmployeeController controller = Get.put(
    MainCoreEmployeeController(),
  );
  final MainCoreDepartmentCubit departmentController =
      Get.find<MainCoreDepartmentCubit>();

  String? selectedDepartment;
  String selectedLabel = "allocated"; // Default selected chip

  /////////////////////////// Var Of All Employee /////////////////////////////
  List<EmployeeEntityPro> allEmployees = [];
  List<EmployeeEntityPro> filteredEmployees = [];
  List<EmployeeEntityPro> selectedEmployees = [];
  bool _isLoading = true;
  String? _errorMessage;

  ///////////////////////////////////// validation /////////////////////////////////
  Map<String, String?> validationErrors = {};
  bool isFormValid = false;

  bool _validateRequiredFields() {
    validationErrors.clear();

    // Validate that at least one employee is selected
    if (selectedEmployees.isEmpty) {
      validationErrors['employeeSelection'] =
          S.of(context).atLeastOneEmployeeRequired;
    }

    return validationErrors.isEmpty;
  }

  void _showValidationErrors() {
    // Format errors with bullet points for better readability
    String errorMessage =
        validationErrors.values.map((error) => '$error').join('\n');

    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  0.6, // Max 60% of screen height
              maxWidth: 411.w,
              minHeight: 120.h, // Minimum height to maintain layout
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json',
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(height: 20.h),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        errorMessage,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePreviewButton() {
    if (_validateRequiredFields()) {
      debugPrint('Navigating to SelectEmployeeWithDataToggle with:');
      debugPrint('Storage Location Data: ${widget.storageLocationData}');
      debugPrint('Selected Employees: ${selectedEmployees.length}');

      // Pass both storage location data and selected employees to the next screen
      navigateTo(
        context,
        SelectEmployeeWithDataToggle(
          storageLocationData: <String, dynamic>{
            ...widget.storageLocationData,
            // Role picked on each card (employee / manager), keyed by id.
            'employeeRoles': {
              for (final e in selectedEmployees)
                _employeeKey(e): _employeeRoles[_employeeKey(e)] ?? 'employee',
            },
          },
          selectedEmployees: selectedEmployees,
        ),
      );
    } else {
      _showValidationErrors();
    }
  }

  ///////////////////////////////////// validation /////////////////////////////////

  // Generate departments list from the translation map
  List<Map<String, String>> get departments {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return departmentTranslationsCamel.entries.map((entry) {
      return {
        "key": entry.key,
        "value":
            isArabic ? entry.value : _formatEnglishDepartmentName(entry.key),
      };
    }).toList();
  }

  // Helper method to format English department names
  String _formatEnglishDepartmentName(String camelCase) {
    // Convert camelCase to readable format
    return camelCase
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : word,
        )
        .join(' ')
        .trim();
  }

  bool _isManager(EmployeeEntityPro employee) {
    // Check various role/title fields for manager keywords
    final roleLower = (employee.role ?? '').toLowerCase().trim();
    final titleLower = (employee.title ?? '').toLowerCase().trim();
    final titleArLower = (employee.titleInArabic ?? '').toLowerCase().trim();

    // English manager keywords
    final englishManagerKeywords = [
      'manager',
      'director',
      'head',
      'supervisor',
      'chief',
      'executive',
      'admin',
      'administrator',
      'lead',
      'senior manager',
      'department head',
      'team lead',
      'project manager',
      'general manager',
      'assistant manager',
    ];

    // Arabic manager keywords
    final arabicManagerKeywords = [
      'مدير',
      'مديرة',
      'رئيس',
      'رئيسة',
      'مسؤول',
      'مسؤولة',
      'قائد',
      'قائدة',
      'مشرف',
      'مشرفة',
      'إداري',
      'إدارية',
      'تنفيذي',
      'تنفيذية',
      'عام',
      'عامة',
      'مساعد مدير',
      'مساعدة مدير',
      'رئيس قسم',
      'رئيسة قسم',
    ];

    // Check if any role/title contains manager keywords
    bool hasEnglishManagerKeyword = englishManagerKeywords.any(
      (keyword) => roleLower.contains(keyword) || titleLower.contains(keyword),
    );

    bool hasArabicManagerKeyword = arabicManagerKeywords.any(
      (keyword) =>
          roleLower.contains(keyword) ||
          titleLower.contains(keyword) ||
          titleArLower.contains(keyword),
    );

    return hasEnglishManagerKeyword || hasArabicManagerKeyword;
  }

  void _onSearchChanged() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final query = _searchController.text.trim().toLowerCase();

    // Filter out managers from all employees first
    var nonManagerEmployees =
        allEmployees.where((e) => !_isManager(e)).toList();

    // Apply department filter if selected
    if (selectedDepartment != null && selectedDepartment!.isNotEmpty) {
      nonManagerEmployees = nonManagerEmployees.where((employee) {
        if (employee.departmentId == null || employee.departmentId!.isEmpty) {
          return false;
        }

        // Get department name from the controller and compare with selected department key
        try {
          final employeeDepartmentName = departmentController.getDepartmentName(
              employee.departmentId!, !isArabic);

          // Check if the employee's department matches the selected department
          return employee.departmentId == selectedDepartment ||
              employeeDepartmentName.toLowerCase().contains(
                    selectedDepartment!.toLowerCase(),
                  );
        } catch (error) {
          debugPrint('Error filtering by department: $error');
          return false;
        }
      }).toList();
    }

    // Apply name filter
    setState(() {
      filteredEmployees = nonManagerEmployees.where((employee) {
        if (query.isEmpty) return true;

        final firstName = isArabic
            ? (employee.firstNameInArabic ?? '')
            : (employee.firstName ?? '');
        final lastName = isArabic
            ? (employee.lastNameInArabic ?? '')
            : (employee.lastName ?? '');
        final fullName = '$firstName $lastName'.toLowerCase();
        return fullName.contains(query);
      }).toList();
    });
  }

  Future<void> _loadEmployees() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use the controller to get employees
      final employees = await controller.getAllNewEmployees();

      setState(() {
        // Use the employees from the method return or the controller's property
        allEmployees = employees ?? controller.allEmployeesEntities ?? [];
        _isLoading = false;
        _onSearchChanged(); // Apply initial filtering
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading employees: $error';
      });
      debugPrint('Error loading employees: $error');
    }
  }

  // Updated validation method
  bool isValidForm() {
    return _validateRequiredFields();
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Debug: Print the received storage location data
    debugPrint(
      'SelectEmployee received storage location data: ${widget.storageLocationData}',
    );

    // Load employees on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventory,
          onFirstTap: () {
            navigateTo(context, InventoryManagement());
          },
          secondTitle: S.of(context).addingNewStorageLocation,
          child: _buildContent(lightMode),
        ),
      ),
    );
  }

  Widget _buildContent(bool lightMode) {
    if (_isLoading) {
      return Center(child: CircleProgressMaster());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading employees',
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),
            SizedBox(height: 10.sp),
            customButton(
              title: S.of(context).retry,
              function: _loadEmployees,
              wrapContent: true,
            ),
          ],
        ),
      );
    }

    if (allEmployees.isEmpty) {
      return Center(
        child: Text(
          'No employees found',
          style: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.blackButton,
          ),
        ),
      );
    }

    final bool ready = selectedEmployees.isNotEmpty;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Ticked employees first (in the order they were ticked), then the rest
    // in their normal order.
    final ordered = [
      ...selectedEmployees.where(filteredEmployees.contains),
      ...filteredEmployees.where((e) => !selectedEmployees.contains(e)),
    ];

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Assigning Employees" — 18 medium, as in Figma 4068:30775.
          Text(
            isArabic ? 'تعيين الموظفين' : 'Assigning Employees',
            style: StyleText.fontSize18Weight500.copyWith(
              color: AppColors.blackButton,
            ),
          ),
          SizedBox(height: 8.sp),

          // Search (fills) + Department (135), both 38 tall, 15 apart.
          Row(
            children: [
              AppSearchTextField(
                controller: _searchController,
                onChanged: (_) {},
                height: 38,
                fillColor: AppColors.card,
              ),
              SizedBox(width: ButtonSizing.toolbarGap(context)),
              SizedBox(
                width: 135.sp,
                child: CustomDropdown<String>(
                  items: departments
                      .map((e) => DropdownItem<String>(
                            value: e['key'] ?? '',
                            label: e['value'] ?? '',
                          ))
                      .toList(),
                  value: selectedDepartment,
                  onChanged: (value) {
                    setState(() {
                      selectedDepartment = value;
                      _onSearchChanged();
                    });
                  },
                  hint: S.of(context).department,
                  height: 38,
                  triggerPadding: StorageFieldSpec.contentPadding,
                  suffixIconPadding: StorageFieldSpec.suffixPadding,
                  borderRadius: BorderRadius.circular(8.r),
                  fillColor: AppColors.card,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.sp),

          // 3 columns of 66-tall cards, 15 apart both ways.
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: ordered.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
                context,
              ),
              crossAxisSpacing: 15.sp,
              mainAxisSpacing: 15.sp,
              mainAxisExtent: 66.sp,
            ),
            itemBuilder: (context, index) {
              final employee = ordered[index];
              final isSelected = selectedEmployees.contains(employee);
              return employeeCard(employee, () {
                setState(() {
                  if (isSelected) {
                    selectedEmployees.remove(employee);
                  } else {
                    selectedEmployees.add(employee);
                  }
                  validationErrors.remove('employeeSelection');
                });
              }, isSelected);
            },
          ),
          SizedBox(height: 20.sp),

          // Discard (start) / Preview (end). Preview is disabled — grey and
          // unresponsive — until at least one employee is ticked.
          Row(
            textDirection: TextDirection
                .ltr, // X-73: Cancel left, action right in both languages

            children: [
              customButton(
                title: S.of(context).discard,
                function: () => Navigator.pop(context),
                textStyle: storageDiscardTextStyle,
                width: 150.sp,
                color: storageDiscardColor,
              ),
              const Spacer(),
              IgnorePointer(
                ignoring: !ready,
                child: customButton(
                  title: S.of(context).preview,
                  function: _handlePreviewButton,
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                  width: 150.sp,
                  color: storageButtonColor(enabled: ready),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.sp),
        ],
      ),
    );
  }

  ////////////////////////////////// Employee Card //////////////////////////
  // Figma 4068:30472 — 66 tall, white, radius 8. Avatar 40 at 13, three text
  // lines, checkbox (22, radius 6) top-end, role chip (20 tall) bottom-end.

  /// Role each ticked employee gets in this storage location.
  final Map<String, String> _employeeRoles = {};

  String _employeeKey(EmployeeEntityPro e) =>
      (e.id?.isNotEmpty ?? false) ? e.id! : (e.email ?? '');

  Widget employeeCard(
    EmployeeEntityPro employee,
    VoidCallback onTap,
    bool isSelected,
  ) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final nameEn = [employee.firstName, employee.lastName]
        .where((x) => (x ?? '').trim().isNotEmpty)
        .join(' ')
        .trim();
    final nameAr = [employee.firstNameInArabic, employee.lastNameInArabic]
        .where((x) => (x ?? '').trim().isNotEmpty)
        .join(' ')
        .trim();
    final displayName = isArabic
        ? (nameAr.isNotEmpty ? nameAr : nameEn)
        : (nameEn.isNotEmpty ? FormatHelper.capitalize(nameEn) : nameAr);

    String departmentName;
    if ((employee.departmentId ?? '').isNotEmpty) {
      try {
        departmentName = departmentController.getDepartmentName(
          employee.departmentId!,
          !isArabic,
        );
      } catch (_) {
        departmentName =
            isArabic ? 'القسم غير محدد' : 'Department not specified';
      }
    } else {
      departmentName = isArabic ? 'القسم غير محدد' : 'Department not specified';
    }

    final roleEn = (employee.role ?? '').trim();
    final titleEn = (employee.title ?? '').trim();
    final titleAr = (employee.titleInArabic ?? '').trim();
    final displayTitle = isArabic
        ? (titleAr.isNotEmpty
            ? titleAr
            : (roleEn.isNotEmpty ? roleEn : titleEn))
        : FormatHelper.capitalize(roleEn.isNotEmpty ? roleEn : titleEn);

    final Color primaryText = light ? AppColors.blackButton : AppColors.white;
    final Color secondaryText =
        light ? AppColors.secondaryText : AppColors.grey;
    final String key = _employeeKey(employee);

    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: light ? AppColors.white : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
        // 6 top/bottom leaves 54 for the three text lines (17.5 + 16.8 +
        // 16.8 at the heights below); Cairo's default line box needs ~70.
        padding: EdgeInsetsDirectional.fromSTEB(13.sp, 6.sp, 8.sp, 6.sp),
        child: Row(
          children: [
            // Avatar — a 40×40 circle (`.r` both ways, never an oval).
            ClipOval(
              child: CustomSvgImage.natural(
                assetPath: employee.gender == "male"
                    ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                    : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
                width: 40.r,
                height: 40.r,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.sp),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: primaryText, height: 1.25),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    departmentName,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: secondaryText, height: 1.4),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    displayTitle,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: secondaryText, height: 1.4),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.sp),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomCheckBox(
                  isSelected: isSelected,
                  size: 22.r,
                  borderColor: const Color(0xCCCCCCCC),
                ),
                // Role chip (Employee / Manager) — only once ticked.
                StorageRoleChip(
                  value: _employeeRoles[key] ?? 'employee',
                  enabled: isSelected,
                  fillColor: kStorageInnerFill,
                  onChanged: (v) => setState(() => _employeeRoles[key] = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
