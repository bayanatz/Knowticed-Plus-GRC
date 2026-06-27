import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';

import 'package:flutter/material.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/main_core_department_controller.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/core/custom/loading.dart';

import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/network/get_base_url.dart';

class AddDepartmentDialogNew extends StatefulWidget {
  const AddDepartmentDialogNew({super.key});

  @override
  State<AddDepartmentDialogNew> createState() => _AddDepartmentDialogNewState();
}

class _AddDepartmentDialogNewState extends State<AddDepartmentDialogNew> {
  final TextEditingController departmentNameController = TextEditingController();
  final TextEditingController departmentNameArabicController = TextEditingController();
  final AddDepartmentController departmentController = Get.find<AddDepartmentController>();
  final storage = GetStorage();

  bool submitted = false;

  // ✅ Track validation errors for each field
  Map<String, String> validationErrors = {};

  @override
  void dispose() {
    departmentNameController.dispose();
    departmentNameArabicController.dispose();
    super.dispose();
  }

  /// ✅ Validate fields and update error map
  void _validateFields() {
    setState(() {
      validationErrors.clear();

      if (departmentNameController.text.trim().isEmpty) {
        validationErrors['department_name'] = 'Department name is required';
      }

      if (departmentNameArabicController.text.trim().isEmpty) {
        validationErrors['department_name_arabic'] = 'اسم القسم مطلوب';
      }
    });
  }

  /// ✅ Show success dialog with Lottie animation
  void _showSuccessDialog() {
    bool lightMode = Theme.of(context).brightness == Brightness.light;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          width: 411.w,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(24.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie Animation
              Lottie.asset(
                'assets/lottie/approved.json',
                width: 100.w,
                height: 100.h,
                repeat: false,
              ),

              SizedBox(height: 16.h),

              // Success Text
              Text(
                'Success Upload',
                style: StyleText.fontSize18Weight500.copyWith(
                  color: AppColors.text
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Get.isDialogOpen == true) {
        Get.back(); // Close success dialog
      }
    });
  }

  Future<void> _createDepartment() async {
    setState(() {
      submitted = true;
    });

    // Validate inputs
    _validateFields();

    if (validationErrors.isNotEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      showLoadingIndicator();

      // ✅ Get dynamic company ID from storage
      String companyId = storage.read('company_id') ??
          storage.read('Company_Id') ??
          storage.read('companyId') ??
          '84763782';

      // ✅ Get current user email
      String currentUserEmail = storage.read('email') ?? '';

      if (currentUserEmail.isEmpty) {
        throw Exception('User email not found');
      }

      print('🏢 Creating department...');
      print('   Company ID: $companyId');
      print('   User Email: $currentUserEmail');

      // ✅ Generate unique department ID
      String departmentId = DateTime.now().millisecondsSinceEpoch.toString();

      // ✅ Create department data
      Map<String, dynamic> departmentData = {
        'Department_ID': departmentId,
        'Department_Name': departmentNameController.text.trim(),
        'Department_Name_In_Arabic': departmentNameArabicController.text.trim(),
        'Added_By': currentUserEmail,
        'Creation_Date': Timestamp.now(),
      };

      print('   Department ID: $departmentId');
      print('   Department Name: ${departmentData['Department_Name']}');

      // ✅ Save to Firebase
      await FirebaseFirestore.instance
          .collection(getBaseUrl('Departments'))
          .doc(departmentId)
          .set(departmentData);

      print('✅ Department created successfully');

      // ✅ Refresh departments list
      await departmentController.getAllDepartments();

      hideLoadingIndicator();
      Get.back(); // Close add department dialog

      // ✅ Show success dialog with Lottie
      _showSuccessDialog();

    } catch (e, stack) {
      print('❌ Error creating department: $e');
      print('Stack: $stack');

      hideLoadingIndicator();

      Get.snackbar(
        'Error',
        'Failed to create department: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// ✅ Responsive field builder for mobile/desktop layouts
  Widget buildResponsiveFields({
    required BuildContext context,
    required Widget left,
    required Widget right,
    String? leftFieldKey,
    String? rightFieldKey,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Check if any field in this row has an error
    bool hasRowError = false;
    if (leftFieldKey != null && validationErrors.containsKey(leftFieldKey)) {
      hasRowError = true;
    }
    if (rightFieldKey != null && validationErrors.containsKey(rightFieldKey)) {
      hasRowError = true;
    }

    // Wrap each field with consistent height container when there's a row error
    // Wrap each field with consistent height container when there's a row error
    Widget wrappedLeft = hasRowError
        ? Container(
      height: 76.h, // TextField height + error text height + spacing
      child: left,
    )
        : left;

    Widget wrappedRight = hasRowError && right is! SizedBox
        ? Container(
      height: 76.h, // TextField height + error text height + spacing
      child: right,
    )
        : right;

    if (isMobile) {
      return Column(
        children: [
          wrappedLeft,
          SizedBox(height: 10.sp),
          wrappedRight,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: wrappedLeft),
          SizedBox(width: 15.sp),
          Expanded(child: wrappedRight),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 500.w,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 30.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      child: CustomSvg(
                        assetPath: "assets/employee_assets/new_department.svg",
                        width: 16.w,
                        height: 16.h,
                        color: AppColors.textButton,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    S.of(context).add_department,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15.h),

              // ✅ Department Name Fields with Responsive Layout
              buildResponsiveFields(
                context: context,
                leftFieldKey: 'department_name',
                rightFieldKey: 'department_name_arabic',
                left: Directionality(
                  textDirection: TextDirection.ltr,

                child: CustomTextField(
                  label: 'Department Name',
                  hint: 'Text here',
                  controller: departmentNameController,
                  fillColor: AppColors.background,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  maxLength: 100,
                  onChanged: (value) {
                      if (submitted) {
                        _validateFields();
                      }
                    },
                ),
                ),
                right: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomTextField(
                    label: 'اسم القسم',
                    hint: 'نص هنا',
                    controller: departmentNameArabicController,
                    fillColor: AppColors.background,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    maxLength: 100,
                    onChanged: (value) {
                      if (submitted) {
                        _validateFields();
                      }
                    },
                  ),
                ),
              ),

              SizedBox(height: 15.h),

              // Action Buttons
              Row(
                children: [
                  // Discard Button
                  CustomButton(
                    buttonText: S.of(context).discard,
                    onTap: () => Get.back(),
                    width: isMobile ? 100.w : 150,
                    height: 38,
                    buttonColor: lightMode ? Colors.grey[400] : Colors.grey[700],
                    textStyle: StyleText.fontSize18Weight500.copyWith(
                      color: lightMode ? Colors.black : Colors.white,
                    ),
                  ),

                  Spacer(),

                  // Create Button (Yellow - AppColors.primary)
                  CustomButton(
                    buttonText: S.of(context).create,
                    onTap: _createDepartment,
                    width: isMobile ? 100.w : 150,
                    height: 38,
                    buttonColor: AppColors.primary,
                    textStyle: StyleText.fontSize18Weight500.copyWith(
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
}