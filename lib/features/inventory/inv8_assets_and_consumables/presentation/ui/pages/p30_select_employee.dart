import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval.dart';
import 'package:knowticed_plus/features/inventory/inv8_assets_and_consumables/presentation/ui/pages/p31_select_employee_details_toogel.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class SelectEmployeeDesktopScreen extends StatefulWidget {
  const SelectEmployeeDesktopScreen({super.key});

  @override
  State<SelectEmployeeDesktopScreen> createState() =>
      _SelectEmployeeDesktopScreenState();
}

class _SelectEmployeeDesktopScreenState
    extends State<SelectEmployeeDesktopScreen> {
  /////////////////////////// Search and Department //////////////////////////////////////
  final TextEditingController _searchController = TextEditingController();
  String? selectedDepartment;
  final List<Map<String, String>> departments = [
    {"key": "dep1", "value": "Dep1"},
    {"key": "dep2", "value": "Dep2"},
    {"key": "dep3", "value": "Dep3"},
    {"key": "dep4", "value": "Dep4"},
  ];
  String selectedLabel = "allocated"; // Default selected chip
  /////////////////////////// Controller //////////////////////////////////////

  /////////////////////////// Var Of ALl Employee /////////////////////////////
  List<EmployeeEntity> allEmployees = [];
  List<EmployeeEntity> filteredEmployees = [];
  List<EmployeeEntity> selectedEmployees = [];
  void _onSearchChanged() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      filteredEmployees = allEmployees.where((employee) {
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

  /////////////////////////// ALl Employee /////////////////////////////
  // Have Data Should Appear when Open Page
  @override
  void initState() {
    super.initState();
    allEmployees.addAll([
      EmployeeEntity(
        id: '11',
        firstName: 'Karim',
        lastName: 'Tarek',
        firstNameInArabic: 'كريم',
        lastNameInArabic: 'طارق',
        title: 'QA Engineer',
        titleInArabic: 'مهندس ضمان الجودة',
        departmentId: 'dept3',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '12',
        firstName: 'Dina',
        lastName: 'Maher',
        firstNameInArabic: 'دينا',
        lastNameInArabic: 'ماهر',
        title: 'Project Manager',
        titleInArabic: 'مديرة مشروع',
        departmentId: 'dept1',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '13',
        firstName: 'Hassan',
        lastName: 'Fahmy',
        firstNameInArabic: 'حسن',
        lastNameInArabic: 'فهمي',
        title: 'UI/UX Designer',
        titleInArabic: 'مصمم واجهة وتجربة المستخدم',
        departmentId: 'dept3',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '14',
        firstName: 'Marwa',
        lastName: 'Sami',
        firstNameInArabic: 'مروة',
        lastNameInArabic: 'سامي',
        title: 'Business Analyst',
        titleInArabic: 'محللة أعمال',
        departmentId: 'dept2',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '15',
        firstName: 'Tamer',
        lastName: 'Elsharkawy',
        firstNameInArabic: 'تامر',
        lastNameInArabic: 'الشرقاوي',
        title: 'Network Engineer',
        titleInArabic: 'مهندس شبكات',
        departmentId: 'dept1',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '16',
        firstName: 'Nadine',
        lastName: 'Ramy',
        firstNameInArabic: 'نادين',
        lastNameInArabic: 'رامي',
        title: 'Marketing Specialist',
        titleInArabic: 'أخصائية تسويق',
        departmentId: 'dept3',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '17',
        firstName: 'Walid',
        lastName: 'Zaki',
        firstNameInArabic: 'وليد',
        lastNameInArabic: 'زكي',
        title: 'System Admin',
        titleInArabic: 'مسؤول نظام',
        departmentId: 'dept2',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '18',
        firstName: 'Reem',
        lastName: 'Nabil',
        firstNameInArabic: 'ريم',
        lastNameInArabic: 'نبيل',
        title: 'Content Writer',
        titleInArabic: 'كاتبة محتوى',
        departmentId: 'dept1',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '19',
        firstName: 'Mostafa',
        lastName: 'Khaled',
        firstNameInArabic: 'مصطفى',
        lastNameInArabic: 'خالد',
        title: 'DevOps Engineer',
        titleInArabic: 'مهندس DevOps',
        departmentId: 'dept3',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '20',
        firstName: 'Salma',
        lastName: 'Ibrahim',
        firstNameInArabic: 'سلمى',
        lastNameInArabic: 'إبراهيم',
        title: 'Operations Manager',
        titleInArabic: 'مديرة العمليات',
        departmentId: 'dept1',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '11',
        firstName: 'Karim',
        lastName: 'Tarek',
        firstNameInArabic: 'كريم',
        lastNameInArabic: 'طارق',
        title: 'QA Engineer',
        titleInArabic: 'مهندس ضمان الجودة',
        departmentId: 'dept3',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '12',
        firstName: 'Dina',
        lastName: 'Maher',
        firstNameInArabic: 'دينا',
        lastNameInArabic: 'ماهر',
        title: 'Project Manager',
        titleInArabic: 'مديرة مشروع',
        departmentId: 'dept1',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '13',
        firstName: 'Hassan',
        lastName: 'Fahmy',
        firstNameInArabic: 'حسن',
        lastNameInArabic: 'فهمي',
        title: 'UI/UX Designer',
        titleInArabic: 'مصمم واجهة وتجربة المستخدم',
        departmentId: 'dept3',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '14',
        firstName: 'Marwa',
        lastName: 'Sami',
        firstNameInArabic: 'مروة',
        lastNameInArabic: 'سامي',
        title: 'Business Analyst',
        titleInArabic: 'محللة أعمال',
        departmentId: 'dept2',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '15',
        firstName: 'Tamer',
        lastName: 'Elsharkawy',
        firstNameInArabic: 'تامر',
        lastNameInArabic: 'الشرقاوي',
        title: 'Network Engineer',
        titleInArabic: 'مهندس شبكات',
        departmentId: 'dept1',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '16',
        firstName: 'Nadine',
        lastName: 'Ramy',
        firstNameInArabic: 'نادين',
        lastNameInArabic: 'رامي',
        title: 'Marketing Specialist',
        titleInArabic: 'أخصائية تسويق',
        departmentId: 'dept3',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '17',
        firstName: 'Walid',
        lastName: 'Zaki',
        firstNameInArabic: 'وليد',
        lastNameInArabic: 'زكي',
        title: 'System Admin',
        titleInArabic: 'مسؤول نظام',
        departmentId: 'dept2',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '18',
        firstName: 'Reem',
        lastName: 'Nabil',
        firstNameInArabic: 'ريم',
        lastNameInArabic: 'نبيل',
        title: 'Content Writer',
        titleInArabic: 'كاتبة محتوى',
        departmentId: 'dept1',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '19',
        firstName: 'Mostafa',
        lastName: 'Khaled',
        firstNameInArabic: 'مصطفى',
        lastNameInArabic: 'خالد',
        title: 'DevOps Engineer',
        titleInArabic: 'مهندس DevOps',
        departmentId: 'dept3',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '20',
        firstName: 'Salma',
        lastName: 'Ibrahim',
        firstNameInArabic: 'سلمى',
        lastNameInArabic: 'إبراهيم',
        title: 'Operations Manager',
        titleInArabic: 'مديرة العمليات',
        departmentId: 'dept1',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '11',
        firstName: 'Karim',
        lastName: 'Tarek',
        firstNameInArabic: 'كريم',
        lastNameInArabic: 'طارق',
        title: 'QA Engineer',
        titleInArabic: 'مهندس ضمان الجودة',
        departmentId: 'dept3',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '12',
        firstName: 'Dina',
        lastName: 'Maher',
        firstNameInArabic: 'دينا',
        lastNameInArabic: 'ماهر',
        title: 'Project Manager',
        titleInArabic: 'مديرة مشروع',
        departmentId: 'dept1',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '13',
        firstName: 'Hassan',
        lastName: 'Fahmy',
        firstNameInArabic: 'حسن',
        lastNameInArabic: 'فهمي',
        title: 'UI/UX Designer',
        titleInArabic: 'مصمم واجهة وتجربة المستخدم',
        departmentId: 'dept3',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '14',
        firstName: 'Marwa',
        lastName: 'Sami',
        firstNameInArabic: 'مروة',
        lastNameInArabic: 'سامي',
        title: 'Business Analyst',
        titleInArabic: 'محللة أعمال',
        departmentId: 'dept2',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '15',
        firstName: 'Tamer',
        lastName: 'Elsharkawy',
        firstNameInArabic: 'تامر',
        lastNameInArabic: 'الشرقاوي',
        title: 'Network Engineer',
        titleInArabic: 'مهندس شبكات',
        departmentId: 'dept1',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '16',
        firstName: 'Nadine',
        lastName: 'Ramy',
        firstNameInArabic: 'نادين',
        lastNameInArabic: 'رامي',
        title: 'Marketing Specialist',
        titleInArabic: 'أخصائية تسويق',
        departmentId: 'dept3',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '17',
        firstName: 'Walid',
        lastName: 'Zaki',
        firstNameInArabic: 'وليد',
        lastNameInArabic: 'زكي',
        title: 'System Admin',
        titleInArabic: 'مسؤول نظام',
        departmentId: 'dept2',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '18',
        firstName: 'Reem',
        lastName: 'Nabil',
        firstNameInArabic: 'ريم',
        lastNameInArabic: 'نبيل',
        title: 'Content Writer',
        titleInArabic: 'كاتبة محتوى',
        departmentId: 'dept1',
        gender: 'female',
      ),
      EmployeeEntity(
        id: '19',
        firstName: 'Mostafa',
        lastName: 'Khaled',
        firstNameInArabic: 'مصطفى',
        lastNameInArabic: 'خالد',
        title: 'DevOps Engineer',
        titleInArabic: 'مهندس DevOps',
        departmentId: 'dept3',
        gender: 'male',
      ),
      EmployeeEntity(
        id: '20',
        firstName: 'Salma',
        lastName: 'Ibrahim',
        firstNameInArabic: 'سلمى',
        lastNameInArabic: 'إبراهيم',
        title: 'Operations Manager',
        titleInArabic: 'مديرة العمليات',
        departmentId: 'dept1',
        gender: 'female',
      ),
    ]);
    // 🔁 Attach the search listener
    _searchController.addListener(_onSearchChanged);
    filteredEmployees = List.from(allEmployees);
  }

  bool isFormValid() {
    return selectedEmployees.isNotEmpty;
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context).languageCode == 'ar';
    Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            {
              navigateTo(context, InventoryManagement());
            }
          },
          secondTitle: S.of(context).assetsNameDetails,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
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
                    SizedBox(
                      width: 135.sp,
                      child: CustomDropdown<String>(
                        items: (departments)
                            .map((e) => DropdownItem<String>(
                                value: e['key'] ?? '', label: e['value'] ?? ''))
                            .toList(),
                        value: selectedDepartment,
                        onChanged: (value) {
                          setState(() {
                            selectedDepartment = value;
                          });
                        },
                        hint: selectedLabel == "allocated"
                            ? S.of(context).department
                            : S.of(context).branch,
                        height: 38.sp,
                        fillColor: AppColors.card,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                // Grid View Employee
                SizedBox(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: filteredEmployees.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: CrossAxisCountHelper
                          .getCrossAxisCountForDefaultTablet2(
                        context,
                      ),
                      crossAxisSpacing: 12.sp,
                      mainAxisSpacing: 12.sp,
                      mainAxisExtent: 65.sp,
                    ),
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      final isSelected = selectedEmployees.contains(employee);

                      return employeeCard(employee, () {
                        setState(() {
                          // ✅ Only keep one selected employee at a time
                          selectedEmployees = [employee];
                        });
                      }, isSelected);
                    },
                  ),
                ),

                // space
                SizedBox(height: 15.sp),

                // Discard & Preview
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
                        if (isFormValid()) {
                          navigateTo(
                            context,
                            SelectEmployeeDetailsSection(),
                          ); // replace with your target screen
                        }
                      },
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color:
                            isFormValid() ? AppColors.textButton : Colors.black,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: isFormValid() ? AppColors.primary : AppColors.grey,
                    ),
                  ],
                ),

                // space
                SizedBox(height: 15.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////////// Employee Card //////////////////////////
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

    return GestureDetector(
      onTap: withHaptic(onTap, HapticLevel.low),
      child: Container(
        width: 310.sp,
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
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
      ),
    );
  }

  ////////////////////////////////// Employee Card //////////////////////////
}
