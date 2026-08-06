// PORTED into services_app under features/settings.
// Source: services_app features/employees/employee_branding/presentation/ui/employee_branding_screen.dart
// Imports rewired to the equivalents that already exist in services_app.

/// ************************ FILE INFO ********************************///
/// File Name: employee_branding_screen.dart
/// Author: Amr Mesbah
/// Created: 2026-01-25
/// Purpose: Screen for employees to customize personal branding

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/custom/55_custom_responsive_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/helper/main_helper/biometric_controller.dart';


import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/settings/settings_screen/views/owner_screens/company_information/color_display_section.dart';
import 'package:grc_module/core/custom/1-custom_dropdwon.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_cubit.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/inventory_module/core/custom_button_widget.dart';

// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:grc_module/core/custom/61-custom_color_picker.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:grc_module/features/settings/se3_company/presentation/ui/widgets/shared/company_image.dart';
import 'package:grc_module/generated/l10n.dart';

import '../../../../../../core/custom/33-custom_haptic.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class EmployeeBrandingScreen extends StatefulWidget {
  const EmployeeBrandingScreen({super.key});

  @override
  State<EmployeeBrandingScreen> createState() => _EmployeeBrandingScreenState();
}

class _EmployeeBrandingScreenState extends State<EmployeeBrandingScreen> {
  // The single CompanyCubit is provided at the app root, so there's no
  // register-on-first-use dance here any more.
  CompanyCubit get companyController => context.read<CompanyCubit>();

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

    if (companyController.state.employeeBranding != null) {
      var branding = companyController.state.employeeBranding!;

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
      if (companyController.state.company != null) {
        selectedLogoUrl = companyController.state.company!.companyLogo?.companyLogo?.lastOrNull;

        String? primaryColorStr = companyController.state.company!.primaryColor?.primaryColor?.lastOrNull;
        if (primaryColorStr != null && primaryColorStr.isNotEmpty) {
          try {
            selectedPrimaryColor = Color(int.parse(primaryColorStr));
          } catch (e) {
            print('⚠️ Error parsing company primary color: $e');
          }
        }

        String? secondaryColorStr = companyController.state.company!.secondaryColor?.secondaryColor?.lastOrNull;
        if (secondaryColorStr != null && secondaryColorStr.isNotEmpty) {
          try {
            selectedSecondaryColor = Color(int.parse(secondaryColorStr));
          } catch (e) {
            print('⚠️ Error parsing company secondary color: $e');
          }
        }

        selectedEnglishFont = companyController.state.company!.englishFont?.englishFont?.lastOrNull;
        selectedArabicFont = companyController.state.company!.arabicFont?.arabicFont?.lastOrNull;
      }
    }
  }

  List<DropdownItem<String>> _convertToDropdownItems(List<String> items) {
    return items
        .map((item) => DropdownItem<String>(
              value: item.toLowerCase(),
              label: item,
            ))
        .toList();
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

    // Was DeleteDialog(isDeleteDialog: false) + a follow-up ResponseDialog.
    // CustomDialogManager.showDialogFlow covers both: it closes the confirm
    // dialog itself, runs onConfirm, and only shows the success dialog when
    // onConfirm returns true.
    CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: "assets/lottie_assets/main_lottie_assets/reset_brand.json",
      confirmTitle: S.of(context).resetPersonalBranding,
      confirmSubtitle:
          S.of(context).areYouSureYouWantToResetYourPersonalBrandingToCo,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        print('✅ User confirmed reset');

        hapticController.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact,
        );

        // Original skipped the success dialog when there was no employee id;
        // returning false reproduces that.
        if (employee?.id == null) return false;

        await companyController.resetEmployeeBrandingToCompany(employee!.id!);
        return true;
      },
      successLottie: "assets/lottie_assets/main_lottie_assets/correct.json",
      successTitle: "Successful",
      successSubtitle: "Personal Branding Has Been Reset To Company Defaults",
    );
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    // ✅ MOBILE: Return full Scaffold with AppBar
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).personalBranding),
          actions: [
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: _resetToCompanyDefaults,
              tooltip: S.of(context).resetToCompanyDefaults,
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
                    S.of(context).customizeYourPersonalBrandingTheseSettingsWillOv,
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
                    S.of(context).personalLogo,
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
                    S.of(context).colors,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CustomColorPickerSection(
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
                    S.of(context).fonts,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  buildResponsiveFields(
                    context: context,
                    mobileSpacing: 0,
                    left: CustomDropdown<String>(
                      value: selectedEnglishFont?.toLowerCase(),
                      items: _convertToDropdownItems(CompanyConstants.englishList),
                      hint: S.of(context).selectEnglishFont,
                      hintStyle: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedEnglishFont = value;
                          print('🎨 English font selected: $value');
                        });
                      },
                    ),
                    right: CustomDropdown<String>(
                      value: selectedArabicFont?.toLowerCase(),
                      items: _convertToDropdownItems(CompanyConstants.arabicList),
                      hint: S.of(context).selectArabicFont,
                      hintStyle: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.secondaryText,
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
                      title: S.of(context).savePersonalBranding,
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

// Moved here from core/helper/settings/utils/company_constants.dart, which was
// removed. This file is one of two independent consumers, so it keeps a local
// copy rather than sharing a dependency.
abstract class CompanyConstants {
  static const List<String> englishList = [
    'Cairo',
    'Tajawal',
    'Open Sans',
    'Muli',
    'Montserrat',
    'M Plus',
    'Lato',
    'Exo',
    'Calibri',
    'Arial',
  ];

  static List<String> arabicList = [
    'Tajawal',
    'Vazirmatn',
    'Rubik',
    'Noto Sans',
    'Harmattan',
    'Changa',
    'Amiri',
    'Almarai',
    'Alexandria',
    'Ibm Plex',
  ];
}
