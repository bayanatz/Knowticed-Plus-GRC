import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'dart:io'; // ✅ Keep this for mobile/desktop

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart'
    as employee_entity_main;
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/inventory/presentation/controller/product_cubit.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/order_info_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

class RequireApprovalProductDetailsAssetsDesktopScreen extends StatefulWidget {
  final ProductModel productModel; // still useful for pre-filling fields
  final List<ProductModel> productModels;
  final int currentProductIndex;
  final bool isMultiProduct;
  final Map<String, dynamic> orderData; // ✅ Add this line
  final bool isConsumable; // ✅ ADD THIS LINE
  final bool isEditMode; // Add this parameter

  const RequireApprovalProductDetailsAssetsDesktopScreen({
    super.key,
    required this.productModel,
    required this.productModels,
    required this.currentProductIndex,
    required this.isConsumable, // ✅ ADD THIS PARAMETER

    required this.isMultiProduct,
    required this.orderData,
    required this.isEditMode, // ✅ Also pass in constructor
  });

  @override
  State<RequireApprovalProductDetailsAssetsDesktopScreen> createState() =>
      _RequireApprovalProductDetailsAssetsDesktopScreenState();
}

class _RequireApprovalProductDetailsAssetsDesktopScreenState
    extends State<RequireApprovalProductDetailsAssetsDesktopScreen> {
  ProductModel getFinalProductModel() {
    final now = DateTime.now();

    final String allLabel =
        (S.of(context).all).isNotEmpty ? S.of(context).all : 'All Requests';

    return widget.productModel.copyWith(
      // ✅ PRESERVE ALL DATA FROM PREVIOUS PAGES
      orderType: widget.productModel.orderType,
      productName: widget.productModel.productName, // From page 2
      orderNote: widget.productModel.orderNote, // From page 2
      expectedLifetime:
          widget.productModel.expectedLifetime, // From page 3 (lifetime + unit)
      expectedDelivery:
          widget.productModel.expectedDelivery, // From page 3 (lifetime + unit)
      reorderLevel: widget.productModel.reorderLevel, // From page 3
      reorderQuantity: widget.productModel.reorderQuantity, // From page 3
      additionalNote: widget.productModel.additionalNote, // From page 3
      productQuantity: widget.productModel.productQuantity, // From page 3
      storageRequirement:
          widget.productModel.storageRequirement, // From page 3 (multi-select)
      storageLocation: widget
          .productModel.storageLocation, // From page 3 (multiple locations)
      productSpecificationImage:
          widget.productModel.productSpecificationImage, // From page 3
      productWarrantyImage:
          widget.productModel.productWarrantyImage, // From page 3
      attachmentsImage: widget.productModel.attachmentsImage, // From page 3
      // ✅ ADD NEW PAGE 4 DATA - APPROVAL CYCLE
      approvalCycle: requireApproval
          ? approvalSections
              .expand(
                (section) => section.selectedApprovers.map(
                  (e) => EmployeeEntityModel(
                    id: e.id,
                    firstName: e.firstName,
                    lastName: e.lastName,
                    firstNameInArabic: e.firstNameInArabic,
                    lastNameInArabic: e.lastNameInArabic,
                    title: e.title,
                    titleInArabic: e.titleInArabic,
                    gender: e.gender,
                    email: e.email,
                  ),
                ),
              )
              .toList()
          : [],

      // ✅ ADD REQUEST TYPES
      requestType: FieldWithTimestamp(
        value: approvalSections
            .expand(
              (e) => e.selectedRequestTypes.where((t) => t != allLabel),
            )
            .toList(),
        timestamp: now,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final product = widget.productModels[widget.currentProductIndex];
    debugPrint("🔵 [FinalStep] Index: ${widget.currentProductIndex}");
    debugPrint("productId: ${product.productId.value}");
    debugPrint("orderId: ${product.orderId.value}");
    debugPrint("requestType: ${product.requestType.value}");

    // If in edit mode, load existing approval data
    if (widget.isEditMode) {
      _loadApprovalDataFromModel(widget.productModel);
    }

    // ✅ LOAD REAL EMPLOYEES instead of hardcoded data
    _loadEmployees();

    // 🔁 Attach the search listener
    _searchController.addListener(_onSearchChanged);
  }

  final MainCoreEmployeeController employeeController = Get.put(
    MainCoreEmployeeController(),
  );
  final MainCoreDepartmentCubit departmentController =
      Get.find<MainCoreDepartmentCubit>();

  // ✅ ADD MANAGER DETECTION METHOD (same as SelectEmployee)
  bool _isManager(employee_entity_main.EmployeeEntityPro employee) {
    final roleLower = (employee.role ?? '').toLowerCase().trim();
    final titleLower = (employee.title ?? '').toLowerCase().trim();
    final titleArLower = (employee.titleInArabic ?? '').toLowerCase().trim();

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

  // ✅ ADD EMPLOYEE LOADING METHOD (adapted from SelectEmployee)
  Future<void> _loadEmployees() async {
    try {
      // Use the controller to get employees
      final employees = await employeeController.getAllNewEmployees();

      // Filter out managers and convert to the EmployeeEntity used in approval screen
      final nonManagerEmployees =
          (employees ?? employeeController.allEmployeesEntities ?? [])
              .where((emp) => !_isManager(emp))
              .map(
                (emp) => EmployeeEntity(
                  id: emp.id ?? '',
                  firstName: emp.firstName,
                  lastName: emp.lastName,
                  firstNameInArabic: emp.firstNameInArabic,
                  lastNameInArabic: emp.lastNameInArabic,
                  title: emp.title,
                  titleInArabic: emp.titleInArabic,
                  departmentId: emp.departmentId,
                  gender: emp.gender ?? 'male',
                  email: emp.email,
                ),
              )
              .toList();

      setState(() {
        allEmployees = nonManagerEmployees;
        _onSearchChanged(); // Apply initial filtering
      });
    } catch (error) {
      debugPrint('Error loading employees: $error');
    }
  }

  void _loadApprovalDataFromModel(ProductModel model) {
    // Ensure at least one approval section exists
    if (approvalSections.isEmpty) {
      approvalSections = [ApprovalSection()];
    }
    final s = approvalSections[0];

    // ========= 1) Approval cycle =========
    if (model.approvalCycle.isNotEmpty) {
      requireApproval = true;

      // Convert EmployeeEntityModel -> EmployeeEntity
      final approvers = model.approvalCycle
          .map(
            (emp) => EmployeeEntity(
              id: emp.id ?? '', // guard
              firstName: emp.firstName,
              lastName: emp.lastName,
              firstNameInArabic: emp.firstNameInArabic,
              lastNameInArabic: emp.lastNameInArabic,
              title: emp.title,
              titleInArabic: emp.titleInArabic,
              gender: emp.gender ?? 'male', // simple fallback
              email: emp.email,
            ),
          )
          .toList();

      s.selectedApprovers = approvers;
    }

    // ========= 2) Request types (from model) =========
    if (model.requestType.value.isNotEmpty) {
      // do NOT include "All" from storage; only concrete types
      s.selectedRequestTypes = List<String>.from(model.requestType.value);
    } else {
      s.selectedRequestTypes = [];
    }

    // ========= 3) Sync "All" chip =========
    const List<String> baseRequestTypes = [
      'New Asset',
      'Return Asset',
      'Repair Asset',
      'Routine Maintenance',
      'Missing Asset',
      'Stolen Asset',
    ];

    // Use your localization key; fallback to 'All Requests'
    final String allLabel =
        (S.of(context).all.isNotEmpty) ? S.of(context).all : 'All Requests';

    // Remove any stray "All" that might have been persisted (shouldn't be, but safe)
    s.selectedRequestTypes.remove(allLabel);

    // If all individuals are present, show the All chip at index 0
    final sel = s.selectedRequestTypes.toSet(); // unique
    final bool allSelected = sel.length == baseRequestTypes.length &&
        sel.containsAll(baseRequestTypes);

    if (allSelected) {
      if (!s.selectedRequestTypes.contains(allLabel)) {
        s.selectedRequestTypes.insert(0, allLabel);
      }
    } else {
      s.selectedRequestTypes.remove(allLabel);
    }

    // (Optional) Deduplicate to be extra safe
    s.selectedRequestTypes = [
      ...{...s.selectedRequestTypes},
    ];

    // Trigger rebuild so UI reflects loaded state
    setState(() {});
  }

  ////////////////////////////// Controller ///////////////////////////////////////
  TextEditingController lifeTimeController = TextEditingController();
  TextEditingController reorderLevelController = TextEditingController();
  TextEditingController reorderQuantityController = TextEditingController();
  TextEditingController additionalNoteController = TextEditingController();
  TextEditingController defaultStorageQuantityController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  TextEditingController expectedLifetimeController = TextEditingController();
  TextEditingController productQuantityController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController orderDateController = TextEditingController();
  TextEditingController receivingDateController = TextEditingController();

  ////////////////////////////// Controller /////////////////////////////////////

  ////////////////////////////// DropDown Var /////////////////////////////////////
  String selectedDurationUnit = "hours";
  String? defaultStorageLocation;

  ////////////////////////////// DropDown Var /////////////////////////////////////

  ////////////////////////////// Storage Content /////////////////////////////////////
  final List<Map<String, String>> storageLocations = [
    {"key": "roomA", "value": "Room A"},
    {"key": "roomB", "value": "Room B"},
    {"key": "roomC", "value": "Room C"},
  ];
  ////////////////////////////// Storage Content /////////////////////////////////////

  ///////////////////////////// For PicImage /////////////////////////////////////////
  PlatformFile? productSpecificationFile;
  PlatformFile? productWarrantyFile;
  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // so you can use bytes for Web preview
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (type == 'spec') {
          productSpecificationFile = result.files.first;
        } else {
          productWarrantyFile = result.files.first;
        }
      });
    }
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    return '${(bytes / 1024).ceil()} KB';
  }

  ///////////////////////////// For PicImage /////////////////////////////////////////

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

  ////////////////////////////// Info Icon ///////////////////////////////////////////

  ////////////////////////////// Info Icon ///////////////////////////////////////////

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;
    Localizations.localeOf(context).languageCode == 'ar';
    final isMobile = context.isPhone;

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: widget.isEditMode
              ? widget.productModel.productName.value
              : S.of(context).addingNewProduct,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // product Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 1.sp),
                    Text(
                      S.of(context).productDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                // space
                SizedBox(height: 8.sp),

                // All Content Page
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Always show the first container (with the switch)
                      Container(
                        margin: EdgeInsets.only(bottom: 20.sp),
                        height: requireApproval
                            ? null
                            : 700.sp, // 👈 Add fixed height when switch is off
                        padding: EdgeInsets.only(
                          top: 15,
                          right: 15.sp,
                          left: 15.sp,
                          bottom: 7.sp,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : AppColors.chatBackground,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Requires Approvals row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).requiresApprovals,
                                  style: StyleText.fontSize14Weight400.copyWith(
                                    color: AppColors.blackButton,
                                  ),
                                ),
                                isMobile
                                    ? Spacer()
                                    : isTablet && !isLandscape
                                        ? SizedBox(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                .21,
                                          )
                                        : SizedBox(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                .24,
                                          ),
                                FlutterSwitch(
                                  height: 22.sp,
                                  width: 38.sp,
                                  toggleSize: 18.sp,
                                  value: requireApproval,
                                  borderRadius: 20.sp,
                                  padding: 1.0,
                                  activeColor: AppColors.secondaryPrimary,
                                  onToggle: (val) {
                                    setState(() {
                                      requireApproval = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 15.sp),

                            if (requireApproval) ...[
                              buildRequestTypeAndSearchSections(
                                approvalSections[0],
                                0,
                              ),
                              SizedBox(height: 10.sp),
                              buildEmployeeSearchList(approvalSections[0], 0),
                              buildApprovalCycleRow(approvalSections[0]),
                              SizedBox(height: 0.sp),
                            ],
                          ],
                        ),
                      ),

                      // Additional approval sections if more than one exists
                      if (requireApproval && approvalSections.length > 1)
                        ...List.generate(approvalSections.length - 1, (index) {
                          final section = approvalSections[index + 1];
                          return Container(
                            margin: EdgeInsets.only(bottom: 20.sp),
                            padding: EdgeInsets.only(
                              top: 15,
                              right: 15.sp,
                              left: 15.sp,
                              bottom: 7.sp,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : AppColors.chatBackground,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildRequestTypeAndSearchSections(
                                  section,
                                  index + 1,
                                ),
                                SizedBox(height: 10.sp),
                                buildEmployeeSearchList(section, index + 1),
                                buildApprovalCycleRow(section),
                              ],
                            ),
                          );
                        }),

                      // ✅ Always show Add Button at the end if approvals are required
                      if (requireApproval)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            customButtonWithSvg(
                              title: S
                                  .of(context)
                                  .differentApprovalCycleForTheOtherRequestTypes,
                              function: () {
                                setState(() {
                                  approvalSections.add(ApprovalSection());
                                });
                              },
                              textStyle: StyleText.fontSize12Weight500.copyWith(
                                color:
                                    AppTheme.readableOn(AppColors.blackButton),
                              ),
                              width: 320.sp,
                              height: 30.sp,
                              space: 8.sp,
                              radius: 4.r,
                              color: AppColors.blackButton,
                              svgColor:
                                  AppTheme.readableOn(AppColors.blackButton),
                              image:
                                  "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                              widthImage: 12.sp,
                              heightImage: 12.sp,
                              colorBorder: Colors.transparent,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // space
                SizedBox(height: 20.sp),

                // Discard & Add Assets
                Row(
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

                    customButton(
                      title: widget.currentProductIndex ==
                              (widget.orderData["products"].length - 1)
                          ? widget.isEditMode
                              ? S.of(context).save
                              : S.of(context).addingNewProduct
                          : "proceed",
                      function: () {
                        debugPrint("🔎 Approval Sections Selected:");
                        for (int i = 0; i < approvalSections.length; i++) {
                          final section = approvalSections[i];
                          final approvers = section.selectedApprovers
                              .map(
                                (e) =>
                                    '${e.firstName ?? ''} ${e.lastName ?? ''} (${e.email ?? e.id})',
                              )
                              .toList();
                          debugPrint('    Approvers:');
                          for (final approver in approvers) {
                            debugPrint('    - $approver');
                          }
                        }

                        if (!_validateAllData()) {
                          showAppDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (_) => AlertDialog(
                              content: SizedBox(
                                height: 180.sp,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json',
                                      width: 70.sp,
                                      height: 70.sp,
                                      repeat: true,
                                      fit: BoxFit.scaleDown,
                                    ),
                                    SizedBox(height: 10.sp),
                                    Text(
                                      S.of(context).validationError,
                                      style: StyleText.fontSize16Weight500
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                    SizedBox(height: 10.sp),
                                    Text(
                                      S
                                          .of(context)
                                          .completeRequiredFieldsBeforeSubmitting,
                                      style: StyleText.fontSize14Weight400
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                          return;
                        }

                        final finalProductModel = getFinalProductModel();

                        final updatedProductModels = [...widget.productModels];

                        // ✅ REPLACE WITH FINAL MODEL
                        if (updatedProductModels.length >
                            widget.currentProductIndex) {
                          updatedProductModels[widget.currentProductIndex] =
                              finalProductModel;
                        } else {
                          updatedProductModels.add(finalProductModel);
                        }

                        final totalProducts =
                            widget.orderData["products"].length;
                        final isLastProduct =
                            widget.currentProductIndex == totalProducts - 1;

                        debugPrint("📦 Final Product Before Submit:");
                        debugPrint('${finalProductModel.toJson()}');

                        if (!isLastProduct) {
                          // ✅ SHOW PROCEED DIALOG
                          showAppDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8.r,
                                ), // Border radius 8
                              ),
                              contentPadding: EdgeInsets.all(
                                20.sp,
                              ), // <-- Added uniform padding
                              content: SizedBox(
                                height: 183.sp, // Fixed height
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json',
                                      width: 70.sp,
                                      height: 70.sp,
                                      repeat: true,
                                      fit: BoxFit.scaleDown,
                                    ),
                                    SizedBox(height: 10.sp),
                                    Text(
                                      S.of(context).continueToNextProduct,
                                      style: StyleText.fontSize16Weight500
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                    SizedBox(height: 10.sp),
                                    Text(
                                      S
                                          .of(context)
                                          .doYouWantToProceedToNextProduct,
                                      style: StyleText.fontSize14Weight400
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 10.sp),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        customButton(
                                          title: S.of(context).no,
                                          function: () {
                                            Navigator.pop(context);
                                          },
                                          width: 135.sp,
                                          height: 38.sp,
                                          color: AppColors.primary,
                                          textStyle: StyleText
                                              .fontSize14Weight500
                                              .copyWith(
                                            color: AppColors.textButton,
                                          ),
                                        ),
                                        SizedBox(width: 20.sp),
                                        customButton(
                                          title: S.of(context).yes,
                                          function: () {
                                            Navigator.pop(
                                              context,
                                            ); // Close dialog
                                            // Go to next product
                                            navigateTo(
                                              context,
                                              AddingProductAssets(
                                                orderData: widget.orderData,
                                                isConsumable:
                                                    widget.isConsumable,
                                                isMultiProduct:
                                                    widget.isMultiProduct,
                                                currentProductIndex:
                                                    widget.currentProductIndex +
                                                        1,
                                                productModels:
                                                    updatedProductModels,
                                              ),
                                            );
                                          },
                                          width: 135.sp,
                                          height: 38.sp,
                                          color: AppColors.primary,
                                          textStyle: StyleText
                                              .fontSize14Weight500
                                              .copyWith(
                                            color: AppColors.textButton,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          // ✅ SHOW FINAL SUBMIT DIALOG
                          showAppDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8.r,
                                ), // Border radius 8
                              ),
                              contentPadding: EdgeInsets.all(20.sp),
                              content: SizedBox(
                                height: 188.sp,
                                width: 420.sp,
                                child: Column(
                                  children: [
                                    Lottie.asset(
                                      widget.isEditMode
                                          ? "assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json"
                                          : 'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json',
                                      width: 70.sp,
                                      height: 70.sp,
                                      repeat: true,
                                      fit: BoxFit.scaleDown,
                                    ),
                                    SizedBox(height: 10.sp),
                                    Text(
                                      widget.isEditMode
                                          ? S.of(context).editingProductDetails
                                          : S.of(context).addingNewProduct,
                                      style: StyleText.fontSize20Weight500
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                    SizedBox(height: 10.sp),
                                    Text(
                                      widget.isEditMode
                                          ? S.of(context).areYouSureEditProduct
                                          : S
                                              .of(context)
                                              .areYouSureYouWantToAddThisProduct,
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    SizedBox(height: 10.sp),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        customButton(
                                          title: S.of(context).no,
                                          function: () {
                                            Navigator.pop(context);
                                          },
                                          width: 135.sp,
                                          radius: 4.sp,
                                          height: 38.sp,
                                          color: AppColors.primary,
                                          textStyle: StyleText
                                              .fontSize14Weight500
                                              .copyWith(
                                            color: AppColors.textButton,
                                          ),
                                        ),
                                        SizedBox(width: 20.sp),
                                        customButton(
                                          title: S.of(context).yes,
                                          radius: 4.sp,
                                          function: () {
                                            Navigator.pop(
                                              context,
                                            ); // Close dialog
                                            // In your submit button function, replace the submitProductsToFirebase call with:
                                            if (widget.isEditMode) {
                                              // ✅ UPDATE EXISTING PRODUCT
                                              context
                                                  .read<ProductCubit>()
                                                  .updateProduct(
                                                    finalProductModel,
                                                  );
                                            } else {
                                              // ✅ CREATE NEW PRODUCT
                                              submitProductsToFirebase(
                                                updatedProductModels,
                                              );
                                            }
                                          },
                                          width: 135.sp,
                                          height: 38.sp,
                                          color: AppColors.primary,
                                          textStyle: StyleText
                                              .fontSize14Weight500
                                              .copyWith(
                                            color: AppColors.textButton,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.primary,
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textButton,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////// Dialog Verify  //////////////////////////////

  var employeeEntity = Get.find<MainCoreEmployeeController>().employeeEntity!;

  ProductModel updatedProductModel() {
    final now = DateTime.now();

    // tiny helpers
    FieldWithTimestamp<String> text(String v) =>
        FieldWithTimestamp<String>(value: v, timestamp: now);
    DropdownFieldWithTimestamp dd(DropdownFieldWithTimestamp d) =>
        DropdownFieldWithTimestamp(
          value: d.value,
          options: d.options,
          timestamp: now,
        );

    // firstNameCreator
    // lastNameCreator
    // firstNameArCreator
    // lastNameArCreator
    // departmentCreator
    // departmentArCreator
    // jobTitleCreator
    // jobTitleArCreator
    // emailCreator
    // phoneCreator

    return ProductModel(
      // ---- Text fields (existing) ----
      firstNameCreator: text(widget.productModel.firstNameCreator.value),
      lastNameCreator: text(widget.productModel.lastNameCreator.value),
      firstNameArCreator: text(widget.productModel.firstNameArCreator.value),
      lastNameArCreator: text(widget.productModel.lastNameArCreator.value),
      departmentCreator: text(widget.productModel.departmentCreator.value),
      departmentArCreator: text(widget.productModel.departmentArCreator.value),
      jobTitleCreator: text(widget.productModel.jobTitleCreator.value),
      jobTitleArCreator: text(widget.productModel.jobTitleArCreator.value),
      emailCreator: text(widget.productModel.emailCreator.value),
      phoneCreator: text(widget.productModel.phoneCreator.value),

      orderId: text(widget.productModel.orderId.value),
      orderNote: text(widget.productModel.orderNote.value),
      orderType: text(widget.productModel.orderId.value),
      productId: text(widget.productModel.productId.value),
      productName: text(widget.productModel.productName.value),
      quantity: text(widget.productModel.quantity.value),
      category: text(widget.productModel.category.value),
      subCategory: text(widget.productModel.subCategory.value),
      brand: text(widget.productModel.brand.value),
      model: text(widget.productModel.model.value),
      unitCost: text(widget.productModel.unitCost.value),
      currency: text(widget.productModel.currency.value),
      supplierName: text(widget.productModel.supplierName.value),
      storageAllocations: text(widget.productModel.storageAllocations.value),
      orderDate: text(widget.productModel.orderDate.value),
      receivingDate: text(widget.productModel.receivingDate.value),
      usageFrequency: text(widget.productModel.usageFrequency.value),
      unitOfMeasurement: text(widget.productModel.unitOfMeasurement.value),
      expectedLifetime: text(widget.productModel.expectedLifetime.value),
      expectedDelivery: text(widget.productModel.expectedDelivery.value),
      deliverySelectedData: text(
        widget.productModel.deliverySelectedData.value,
      ),
      reorderLevel: text(widget.productModel.reorderLevel.value),
      reorderQuantity: text(widget.productModel.reorderQuantity.value),
      additionalNote: text(widget.productModel.additionalNote.value),
      productQuantity: text(widget.productModel.productQuantity.value),

      // ---- Images (keep as-is; they already have timestamps) ----
      productSpecificationImage: widget.productModel.productSpecificationImage,
      productWarrantyImage: widget.productModel.productWarrantyImage,
      attachmentsImage: widget.productModel.attachmentsImage,

      // ---- Dropdowns (clone value/options; refresh timestamp) ----
      storageRequirement: dd(widget.productModel.storageRequirement),
      deliveryMethod: dd(widget.productModel.deliveryMethod),
      year: dd(widget.productModel.year),
      maintenanceFrequency: dd(widget.productModel.maintenanceFrequency),
      storageLocation: dd(widget.productModel.storageLocation),
      status: dd(widget.productModel.status),

      // ---- Request / approvals (keep) ----
      approvalCycle: widget.productModel.approvalCycle,
      requestType: FieldWithTimestamp<List<String>>(
        value: widget.productModel.requestType.value,
        timestamp: now,
      ),

      // ========= NEW FIELDS (invoice details) =========
      paymentMethod: dd(widget.productModel.paymentMethod),
      vat: text(widget.productModel.vat.value),
      discountPercentage: text(widget.productModel.discountPercentage.value),
      shipping: text(widget.productModel.shipping.value),
      orderValue: text(widget.productModel.orderValue.value),

      // ========= NEW FIELDS (supplier bank transfer) =========
      supplierId: text(widget.productModel.supplierId.value),
      advancedPayment: dd(widget.productModel.advancedPayment),
      methodOfPayment: dd(widget.productModel.methodOfPayment),
      beneficiaryName: text(widget.productModel.beneficiaryName.value),
      beneficiaryBankName: text(widget.productModel.beneficiaryBankName.value),
      beneficiaryAccountIban: text(
        widget.productModel.beneficiaryAccountIban.value,
      ),
      bankSwiftBicCode: text(widget.productModel.bankSwiftBicCode.value),
      bankAddress: text(widget.productModel.bankAddress.value),

      // ========= NEW FIELD (attachments meta) =========
      transactionId: text(widget.productModel.transactionId.value),
    );
  }

  Future<void> submitProductsToFirebase(List<ProductModel> products) async {
    debugPrint("=== SUBMITTING ${products.length} PRODUCTS TO FIREBASE ===");

    final String userId = InventoryPaths.userEmail;
    final String basePath = "Demo/${InventoryPaths.companyId}/CreateOrder/user";

    for (int i = 0; i < products.length; i++) {
      final product = products[i];

      // Generate unique document ID
      final docId = "${product.orderId.value}_${product.productId.value}";

      debugPrint("\n--- Product $i ---");
      debugPrint("Edit Mode: ${widget.isEditMode}");
      debugPrint("Uploading to: $basePath/$userId/$docId");
      debugPrint("Order ID: ${product.orderId.value}");
      debugPrint("Product ID: ${product.productId.value}");

      try {
        final docRef = FirebaseFirestore.instance.doc(
          '$basePath/$userId/$docId',
        );

        if (widget.isEditMode) {
          // ✅ UPDATE EXISTING DOCUMENT
          await docRef.update({
            ...product.toJson(),
            'updatedAt': FieldValue.serverTimestamp(),
            'status': 'updated',
          });
          debugPrint("✅ Product $i UPDATED successfully");
        } else {
          // ✅ CREATE NEW DOCUMENT
          await docRef.set({
            ...product.toJson(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'status': 'submitted',
          });
          debugPrint("✅ Product $i CREATED successfully");
        }
      } catch (e) {
        debugPrint(
          "❌ Error ${widget.isEditMode ? 'updating' : 'creating'} Product $i: $e",
        );
      }
    }

    if (!mounted) return;
    ProductCubit.get(context).loadProducts();

    if (!mounted) return;
    showAppDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: SizedBox(
          height: 180.h,
          width: 411.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                width: 70.sp,
                height: 70.sp,
                repeat: true,
                fit: BoxFit.scaleDown,
              ),
              SizedBox(height: 10.sp),
              Text(
                S.of(context).productAdded,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 10.sp),
              Text(
                S.of(context).youSuccessfullyAddedThisProduct,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      navigateTo(context, InventoryManagement());
    });
  } ////////////////////////////// Dialog Verify  //////////////////////////////

  bool _validateAllData() {
    // Check if approval data is properly set when required
    if (requireApproval) {
      if (approvalSections.isEmpty) {
        debugPrint("❌ No approval sections found");
        return false;
      }

      for (final section in approvalSections) {
        if (section.selectedRequestTypes.isEmpty) {
          debugPrint("❌ No request types selected in section");
          return false;
        }
        if (section.selectedApprovers.isEmpty) {
          debugPrint("❌ No approvers selected in section");
          return false;
        }
      }
    }

    return true;
  }

  Widget employeeCard(
    EmployeeEntity employee,
    VoidCallback onTap,
    bool isSelected,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Name handling (same as SelectEmployee)
    final nameEn = [
      employee.firstName,
      employee.lastName,
    ].where((x) => (x ?? '').trim().isNotEmpty).join(' ').trim();
    final nameAr = [
      employee.firstNameInArabic,
      employee.lastNameInArabic,
    ].where((x) => (x ?? '').trim().isNotEmpty).join(' ').trim();
    final displayName = isArabic
        ? (nameAr.isNotEmpty ? nameAr : nameEn)
        : (nameEn.isNotEmpty ? FormatHelper.capitalize(nameEn) : nameAr);

    // Department handling (same as SelectEmployee)
    String departmentName = '';
    if (employee.departmentId != null && employee.departmentId!.isNotEmpty) {
      try {
        departmentName = departmentController.getDepartmentName(
          employee.departmentId!,
          !isArabic,
        );
      } catch (error) {
        debugPrint('Error getting department name: $error');
        departmentName =
            isArabic ? 'القسم غير محدد' : 'Department not specified';
      }
    } else {
      departmentName = isArabic ? 'القسم غير محدد' : 'Department not specified';
    }

    // Title handling
    final titleEn = (employee.title ?? '').trim();
    final titleAr = (employee.titleInArabic ?? '').trim();
    final displayTitle = isArabic
        ? (titleAr.isNotEmpty ? titleAr : titleEn)
        : FormatHelper.capitalize(titleEn);

    return Container(
      width: 310.sp,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: StyleText.fontSize15Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  departmentName,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  displayTitle,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 35.sp),
            child: GestureDetector(
              onTapDown: hapticDown(onTap, HapticLevel.low),
              onTap: onTap,
              child: CustomSvgImage.natural(
                assetPath: isSelected
                    ? 'assets/icons_assets/main_icons_assets/ic_form_checkbox_checked.svg'
                    : 'assets/icons_assets/main_icons_assets/ic_form_checkbox_empty.svg',
                width: 22.w,
                height: 22.h,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRequestTypeAndSearchSections(ApprovalSection section, int index) {
    // All request types (same list you had)
    const List<String> baseRequestTypes = [
      'New Asset',
      'Return Asset',
      'Repair Asset',
      'Routine Maintenance',
      'Missing Asset',
      'Stolen Asset',
    ];

    // Localized "All" label (fallback just in case)
    final String allLabel =
        (S.of(context).all).isNotEmpty ? S.of(context).all : 'All Requests';

    // Helper: are all individual items selected?
    bool allIndividualsSelected() {
      final sel =
          section.selectedRequestTypes.where((t) => t != allLabel).toSet();
      return sel.length == baseRequestTypes.length &&
          sel.containsAll(baseRequestTypes);
    }

    // Ensure "All" chip is in sync (call after any change)
    void syncAllChip() {
      if (allIndividualsSelected()) {
        if (!section.selectedRequestTypes.contains(allLabel)) {
          section.selectedRequestTypes.insert(0, allLabel);
        }
      } else {
        section.selectedRequestTypes.remove(allLabel);
      }
    }

    // Search filter (includes the All chip too)
    final String q = section.searchController.text.trim().toLowerCase();
    final List<String> withAll = [allLabel, ...baseRequestTypes];
    final List<String> filteredRequestTypes = q.isEmpty
        ? withAll
        : withAll.where((t) => t.toLowerCase().contains(q)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          S.of(context).toWhichTypesOfRequestsDoesThisApply,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 8.h),

        // ✅ SelectChip with "All" behavior
        SizedBox(
          width: 480.w,
          child: CustomMultiSelectFilter<String>(
            items: (filteredRequestTypes)
                .map((e) => MultiSelectDropdownItem<String>(value: e, label: e))
                .toList(),
            values: section.selectedRequestTypes,
            onChanged: (values) {
              final previous = List<String>.of(section.selectedRequestTypes);
              for (final item in values.where((v) => !previous.contains(v))) {
                ((v) {
                  setState(() {
                    if (v == allLabel) {
                      section.selectedRequestTypes
                        ..clear()
                        ..add(allLabel)
                        ..addAll(baseRequestTypes);
                    } else {
                      if (!section.selectedRequestTypes.contains(v)) {
                        section.selectedRequestTypes.add(v);
                      }
                      syncAllChip();
                    }
                  });
                })(item);
              }
              for (final item in previous.where((v) => !values.contains(v))) {
                ((v) {
                  setState(() {
                    if (v == allLabel) {
                      section.selectedRequestTypes.clear();
                    } else {
                      section.selectedRequestTypes.remove(v);
                      syncAllChip();
                    }
                  });
                })(item);
              }
            },
            label: S.of(context).selectRequestTypes,
            fillColor: AppColors.background,
            height: 38.h,
          ),
        ),

        SizedBox(height: 10.h),

        // Add approvals label
        Text(
          S.of(context).addApprovals,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 8.h),

        // Search field
        SizedBox(
          width: 400.w,
          child: AppSearchTextField(
            controller: section.searchController,
            fillColor: AppColors.background,
            onChanged: (_) => setState(() {}), // triggers filter + rebuild
          ),
        ),
      ],
    );
  }

  Widget buildEmployeeSearchList(ApprovalSection section, int index) {
    final query = section.searchController.text.trim().toLowerCase();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final matches = query.isEmpty
        ? []
        : allEmployees.where((e) {
            final fullName = isArabic
                ? '${e.firstNameInArabic ?? ''} ${e.lastNameInArabic ?? ''}'
                : '${e.firstName ?? ''} ${e.lastName ?? ''}';
            return fullName.toLowerCase().contains(query);
          }).toList();

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(), // avoid nested scroll conflict
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: matches.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
          context,
        ),
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
        mainAxisExtent: 77.sp,
      ),
      itemBuilder: (context, index) {
        final employee = matches[index];
        final isSelected = section.selectedApprovers.contains(employee);

        return employeeCard(employee, () {
          setState(() {
            isSelected
                ? section.selectedApprovers.remove(employee)
                : section.selectedApprovers.add(employee);
          });
        }, isSelected);
      },
    );
  }

  Widget buildApprovalCycleRow(ApprovalSection section) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    Theme.of(context).brightness == Brightness.light;

    return Column(
      children: List.generate((section.selectedApprovers.length / 4).ceil(), (
        rowIndex,
      ) {
        final rowItems =
            section.selectedApprovers.skip(rowIndex * 4).take(4).toList();

        return Padding(
          padding: EdgeInsets.only(bottom: 8.sp),
          child: Row(
            children: List.generate(rowItems.length * 2 - 1, (i) {
              if (i.isEven) {
                final index = i ~/ 2;
                final employee = rowItems[index];
                return Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
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
                              width: 40.sp,
                              height: 40.sp,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 28.sp,
                          right: -2.sp,
                          child: GestureDetector(
                            onTapDown: (_) => HapticController.high(),
                            onTap: () {
                              setState(() {
                                section.selectedApprovers.remove(employee);
                              });
                            },
                            child: CustomSvgImage.natural(
                              assetPath:
                                  "assets/icons_assets/main_icons_assets/ic_editor_decrease.svg",
                              width: 14.sp,
                              height: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.sp),
                    Padding(
                      padding: EdgeInsets.only(top: 8.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FormatHelper.capitalize(
                              isEnglish
                                  ? "${employee.firstName} ${employee.lastName}"
                                  : "${employee.firstNameInArabic} ${employee.lastNameInArabic}",
                            ),
                            style: StyleText.fontSize13Weight500.copyWith(
                              color: AppColors.blackButton,
                            ),
                          ),
                          Text(
                            FormatHelper.capitalize(
                              isEnglish
                                  ? employee.title ?? ''
                                  : employee.titleInArabic ?? '',
                            ),
                            style: StyleText.fontSize10Weight500.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.sp),
                  child: Transform.rotate(
                    angle: isEnglish ? 0 : 3.1416,
                    child: CustomSvgImage.natural(
                      assetPath:
                          "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                      width: 25.sp,
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.text
                          : AppColors.whiteShadow,
                    ),
                  ),
                );
              }
            }),
          ),
        );
      }),
    );
  }

  Widget buildFilePreview(
    PlatformFile file,
    DateTime uploadDate,
    VoidCallback onRemove,
  ) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    String size = formatBytes(file.size);
    String formattedDate = "${uploadDate.day.toString().padLeft(2, '0')}/"
        "${uploadDate.month.toString().padLeft(2, '0')}/"
        "${uploadDate.year}";

    return Container(
      width: 283.sp,
      height: 60.sp,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.secondaryText,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // image
          Padding(
            padding: EdgeInsets.all(6.sp),
            child: kIsWeb
                ? Image.memory(
                    file.bytes!,
                    width: 36.sp,
                    height: 36.sp,
                    fit: BoxFit.cover,
                  )
                : (file.path != null
                    ? Image.file(
                        File(file.path!),
                        width: 36.sp,
                        height: 36.sp,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox()),
          ),

          // space
          SizedBox(width: 10.sp),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // file name
                Text(
                  FormatHelper.capitalize(file.name),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // space
                SizedBox(height: 5.sp),
                Text(
                  size,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // Remove button & Date
          Padding(
            padding: EdgeInsets.all(10.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTapDown: hapticDown(onRemove, HapticLevel.high),
                  onTap: onRemove,
                  child: CustomSvgImage.natural(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_editor_decrease.svg",
                    width: 12.sp,
                    height: 12.sp,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                Spacer(),
                Text(
                  "Date: $formattedDate",
                  style: StyleText.fontSize10Weight400.copyWith(
                    color:
                        lightMode ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeEntity {
  final String id; // ✅ Required for selection logic
  final String? firstName;
  final String? lastName;
  final String? firstNameInArabic;
  final String? lastNameInArabic;
  final String? title;
  final String? email; // ✅ Add this
  final String? role;
  final String? titleInArabic;
  final String? departmentId;
  final String gender;

  EmployeeEntity({
    required this.id, // ✅ Make sure it's passed
    this.firstName,
    this.lastName,
    this.firstNameInArabic,
    this.lastNameInArabic,
    this.email,
    this.role,
    this.title,
    this.titleInArabic,
    this.departmentId,
    required this.gender,
  });
}

class ApprovalSection {
  final GlobalKey iconKey = GlobalKey(); // for tapping
  final LayerLink layerLink = LayerLink(); // for positioning
  OverlayEntry? overlayEntry; // for showing tooltip
  List<String> selectedRequestTypes =
      []; // ✅ Change from String? to List<String>
  List<EmployeeEntity> selectedApprovers = [];
  TextEditingController searchController = TextEditingController();
  GlobalKey tooltipIconKey = GlobalKey(); // ✅ NEW
}
