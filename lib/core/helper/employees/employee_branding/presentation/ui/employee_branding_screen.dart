/// ************************ FILE INFO ********************************///
/// File Name: employee_branding_screen.dart
/// Author: Amr Mesbah
/// Created: 2026-01-25
/// Purpose: Screen for employees to customize personal branding

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/helper/employees/core_widgets/services_management/custom_reasponsive_filed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/biometric_controller.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/employees/core_widgets/dialogs/delete_dialog.dart';
import 'package:demo_app/core/helper/employees/core_widgets/dialogs/response_dialog.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/settings/settings_screen/views/owner_screens/company_information/color_display_section.dart';
import 'package:demo_app/core/helper/knowledge_hub_module/core/custom_drop_down.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/employees/core_widgets/grc/custom_button_with_image.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/settings/presentation/controller/add_company_controller.dart';
import 'package:demo_app/features/settings/utils/company_constants.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/inventory_module/core/custom_button_widget.dart';

// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/color_display_section.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/timeline_widget.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/company/company_image.dart';
import 'package:demo_app/core/helper/employees/employee_branding/presentation/controller/add_company_controller.dart';

class EmployeeBrandingScreen extends StatefulWidget {
  const EmployeeBrandingScreen({super.key});

  @override
  State<EmployeeBrandingScreen> createState() => _EmployeeBrandingScreenState();
}

class _EmployeeBrandingScreenState extends State<EmployeeBrandingScreen> {
  final CompanyControllerPersonal companyController = Get.find();

  Color? selectedPrimaryColor;
  Color? selectedSecondaryColor;
  String? selectedEnglishFont;
  String? selectedArabicFont;
  String? selectedLogoUrl;

  @override
  void initState() {
    super.initState();
    print('📱 ===== EMPLOYEE BRANDING SCREEN INIT START =====');
    _loadCurrentBranding();
    print('📱 ===== EMPLOYEE BRANDING SCREEN INIT END =====');
  }

  void _loadCurrentBranding() {
    print('🔄 Loading current employee branding...');

    if (companyController.employeeBranding != null) {
      var branding = companyController.employeeBranding!;

      selectedLogoUrl = branding.logo;

      if (branding.primaryColor != null && branding.primaryColor!.isNotEmpty) {
        try {
          selectedPrimaryColor = Color(int.parse(branding.primaryColor!));
        } catch (e) {
          print('⚠️ Error parsing primary color: $e');
        }
      }

      if (branding.secondaryColor != null && branding.secondaryColor!.isNotEmpty) {
        try {
          selectedSecondaryColor = Color(int.parse(branding.secondaryColor!));
        } catch (e) {
          print('⚠️ Error parsing secondary color: $e');
        }
      }

      selectedEnglishFont = branding.fontEnglish;
      selectedArabicFont = branding.fontArabic;

      print('✅ Current branding loaded');
      print('   Logo: $selectedLogoUrl');
      print('   Primary Color: $selectedPrimaryColor');
      print('   Secondary Color: $selectedSecondaryColor');
      print('   English Font: $selectedEnglishFont');
      print('   Arabic Font: $selectedArabicFont');
    } else {
      print('ℹ️ No employee branding found, using company defaults');

      // Load company defaults for display
      if (companyController.company != null) {
        selectedLogoUrl = companyController.company!.companyLogo?.companyLogo?.lastOrNull;

        String? primaryColorStr = companyController.company!.primaryColor?.primaryColor?.lastOrNull;
        if (primaryColorStr != null && primaryColorStr.isNotEmpty) {
          try {
            selectedPrimaryColor = Color(int.parse(primaryColorStr));
          } catch (e) {
            print('⚠️ Error parsing company primary color: $e');
          }
        }

        String? secondaryColorStr = companyController.company!.secondaryColor?.secondaryColor?.lastOrNull;
        if (secondaryColorStr != null && secondaryColorStr.isNotEmpty) {
          try {
            selectedSecondaryColor = Color(int.parse(secondaryColorStr));
          } catch (e) {
            print('⚠️ Error parsing company secondary color: $e');
          }
        }

        selectedEnglishFont = companyController.company!.englishFont?.englishFont?.lastOrNull;
        selectedArabicFont = companyController.company!.arabicFont?.arabicFont?.lastOrNull;
      }
    }
  }

  List<Map<String, String>> _convertToDropdownItems(List<String> items) {
    return items.map((item) => {
      "key": item.toLowerCase(),
      "value": item,
    }).toList();
  }

  void _saveBranding() {
    print('💾 ===== SAVE EMPLOYEE BRANDING TRIGGERED =====');

    if (employee?.id == null) {
      Get.snackbar(
        'Error',
        'Employee ID not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    String? primaryColorHex = selectedPrimaryColor != null
        ? '0x${selectedPrimaryColor!.value.toRadixString(16)}'
        : null;

    String? secondaryColorHex = selectedSecondaryColor != null
        ? '0x${selectedSecondaryColor!.value.toRadixString(16)}'
        : null;

    print('💾 Saving employee branding:');
    print('   Employee ID: ${employee!.id}');
    print('   Logo: $selectedLogoUrl');
    print('   Primary Color: $primaryColorHex');
    print('   Secondary Color: $secondaryColorHex');
    print('   English Font: $selectedEnglishFont');
    print('   Arabic Font: $selectedArabicFont');

    companyController.saveEmployeeBranding(
      employeeId: employee!.id!,
      logo: selectedLogoUrl,
      primaryColor: primaryColorHex,
      secondaryColor: secondaryColorHex,
      fontEnglish: selectedEnglishFont?.toLowerCase(),
      fontArabic: selectedArabicFont?.toLowerCase(),
    );
  }

  void _resetToCompanyDefaults() {
    print('🔄 ===== RESET TO COMPANY DEFAULTS TRIGGERED =====');

    showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog(
          isDeleteDialog: false,
          deleteTitleText: "Reset Personal Branding".tr,
          lottiePhoto: "assets/images/reset_brand.json",
          deleteText: "Are You Sure You Want To Reset Your Personal Branding To Company Defaults?".tr,
          yesOnPressed: () async {
            print('✅ User confirmed reset');

            hapticController.triggerHapticFeedback(
              vibration: VibrateType.mediumImpact,
              hapticFeedback: HapticFeedback.mediumImpact,
            );

            Navigator.pop(context);

            if (employee?.id != null) {
              await companyController.resetEmployeeBrandingToCompany(employee!.id!);

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const ResponseDialog(
                    title: "Successful",
                    subtitle: "Personal Branding Has Been Reset To Company Defaults",
                    lottieAsset: "assets/images/correct.json",
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    // ✅ MOBILE: Return full Scaffold with AppBar
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Personal Branding'.tr),
          actions: [
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: _resetToCompanyDefaults,
              tooltip: 'Reset to Company Defaults'.tr,
            ),
          ],
        ),
        body: _buildBrandingContent(isMobile, lightMode),
      );
    }

    // ✅ TABLET: Return content only (no Scaffold, no AppBar)
    return _buildBrandingContent(isMobile, lightMode);
  }

  // ✅ Extracted content builder
  Widget _buildBrandingContent(bool isMobile, bool lightMode) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Customize your personal branding. These settings will override company branding for your account only.'.tr,
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: lightMode ? Colors.black87 : Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Main branding container
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
            ),
            child: Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo section
                  Text(
                    "Personal Logo".tr,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CompanyImage(
                    onChangedImageUrl: (url) {
                      setState(() {
                        selectedLogoUrl = url;
                        print('🎨 Logo selected: $url');
                      });
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Colors section
                  Text(
                    "Colors".tr,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ColorDisplaySection(
                    primaryColor: selectedPrimaryColor ?? Colors.blue,
                    secondaryColor: selectedSecondaryColor ?? Colors.red,
                    onPrimaryColorSelected: (Color color) {
                      setState(() {
                        selectedPrimaryColor = color;
                        print('🎨 Primary color selected: 0x${color.value.toRadixString(16)}');
                      });
                    },
                    onSecondaryColorSelected: (Color color) {
                      setState(() {
                        selectedSecondaryColor = color;
                        print('🎨 Secondary color selected: 0x${color.value.toRadixString(16)}');
                      });
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Fonts section
                  Text(
                    "Fonts".tr,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  buildResponsiveFields(
                    context: context,
                    mobileSpacing: 0,
                    left: CustomDropdownFormFieldInvMaster(
                      selectedValue: selectedEnglishFont?.toLowerCase(),
                      items: _convertToDropdownItems(CompanyConstants.englishList),
                      widthIcon: 14,
                      heightIcon: 7,
                      height: 36,
                      spaceHeight: 8.h,
                      hint: Text(
                        'Select English Font'.tr,
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.secondaryText
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedEnglishFont = value;
                          print('🎨 English font selected: $value');
                        });
                      },
                    ),
                    right: CustomDropdownFormFieldInvMaster(
                      selectedValue: selectedArabicFont?.toLowerCase(),
                      items: _convertToDropdownItems(CompanyConstants.arabicList),
                      widthIcon: 14,
                      heightIcon: 7,
                      height: 36,
                      spaceHeight: 8.h,
                      hint: Text(
                        'Select Arabic Font'.tr,
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.secondaryText
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedArabicFont = value;
                          print('🎨 Arabic font selected: $value');
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: customButton(
                      title: "Save Personal Branding".tr,
                      function: _saveBranding,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      height: 48.h,
                      radius: 8.r,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}