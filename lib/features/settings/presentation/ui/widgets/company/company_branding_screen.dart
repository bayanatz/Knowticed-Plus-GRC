/// ************************ FILe INFO ********************************///
/// File Name: company_branding_screen.dart
/// Author: Mohamed Elrashidy
/// refactored at: 11/04/2025
/// Updated by: Amr Mesbah - Fixed cross-device branding sync
/// Updated by: Amr Mesbah - Reset now applies immediately without needing Apply click
/// Updated by: Amr Mesbah - Colors update instantly in UI after reset (no navigation needed)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/features/settings/core_widgets/services_management/custom_reasponsive_filed.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/color_display_section.dart';
import 'package:demo_app/core/helper/knowledge_hub_module/core/custom_drop_down.dart';
import 'package:demo_app/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/biometric_controller.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/settings/core_widgets/dialogs/delete_dialog.dart';
import 'package:demo_app/features/settings/core_widgets/dialogs/response_dialog.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/settings/settings_screen/views/owner_screens/company_information/color_display_section.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/knowledge_hub_module/core/custom_drop_down.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/settings/presentation/controller/add_company_controller.dart';
import 'package:demo_app/features/settings/utils/company_constants.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/timeline_widget.dart';
import '../../../../../../core/network/api_constants.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_drop_down.dart';
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/core/custom_reasponsive_filed.dart';
import 'company_image.dart';

class CompanyBrandingScreen extends StatefulWidget {
  const CompanyBrandingScreen({
    super.key,
    required this.onChangedImageUrl,
    required this.onChangedPrimaryColor,
    required this.onChangedSecondaryColor,
    required this.onChangedFontEnglish,
    required this.onChangedFontArabic,
  });

  final ValueChanged<String> onChangedImageUrl;
  final ValueChanged<Color> onChangedPrimaryColor;
  final ValueChanged<Color> onChangedSecondaryColor;
  final ValueChanged<String> onChangedFontEnglish;
  final ValueChanged<String> onChangedFontArabic;

  @override
  State<CompanyBrandingScreen> createState() => _CompanyBrandingScreenState();
}

class _CompanyBrandingScreenState extends State<CompanyBrandingScreen> {
  CompanyController companyController = Get.find();
  CompanyController addCompanyController = Get.find();

  final TextEditingController _companyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('📱 ============ BRANDING SCREEN INIT START ============');
    companyController.imageUrl = null;
    companyController.selectedEnglishFont = null;
    companyController.selectedArabicFont = null;
    companyController.primaryColor = null;
    companyController.secondaryColor = null;
    print('📱 Current storage font: ${storage.read('font')}');
    print('📱 Current storage font_arabic: ${storage.read('font_arabic')}');
    print('📱 ============ BRANDING SCREEN INIT END ============');
  }

  @override
  void dispose() {
    print('📱 BRANDING SCREEN DISPOSED');
    _companyNameController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _convertToDropdownItems(List<String> items) {
    return items.map((item) => {
      "key": item.toLowerCase(),
      "value": item,
    }).toList();
  }

  String? _getInitialEnglishFont() {
    if (companyController.selectedEnglishFont != null) {
      return companyController.selectedEnglishFont!.toLowerCase();
    }
    if (addCompanyController.company?.status == 'active' &&
        addCompanyController.company!.englishFont?.englishFont?.lastOrNull != null) {
      return addCompanyController.company!.englishFont!.englishFont!.last!.toLowerCase();
    }
    return null;
  }

  String? _getInitialArabicFont() {
    if (companyController.selectedArabicFont != null) {
      return companyController.selectedArabicFont!.toLowerCase();
    }
    if (addCompanyController.company?.status == 'active' &&
        addCompanyController.company!.arabicFont?.arabicFont?.lastOrNull != null) {
      return addCompanyController.company!.arabicFont!.arabicFont!.last!.toLowerCase();
    }
    return null;
  }

  void _resetBranding() {
    print('🔄 ===== RESET BRANDING TRIGGERED =====');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return DeleteDialog(
          isDeleteDialog: false,
          deleteTitleText: "Reset Branding".tr,
          lottiePhoto: "assets/images/reset_brand.json",
          deleteText: "Are You Sure You Want To Reset The Company Branding?".tr,
          yesOnPressed: () async {
            print('✅ User confirmed reset');

            hapticController.triggerHapticFeedback(
              vibration: VibrateType.mediumImpact,
              hapticFeedback: HapticFeedback.mediumImpact,
            );

            // ── 1. Null out all branding fields in the company model ──────
            if (addCompanyController.company!.companyLogo?.companyLogo?.lastOrNull != null) {
              addCompanyController.company!.companyLogo?.companyLogo?.add(null);
              addCompanyController.company!.companyLogo?.timestamps?.add(Timestamp.now());
              print('🗑️ Logo reset');
            }

            if (addCompanyController.company!.primaryColor?.primaryColor?.lastOrNull != null) {
              addCompanyController.company!.primaryColor?.primaryColor?.add(null);
              addCompanyController.company!.primaryColor?.timestamps?.add(Timestamp.now());
              print('🗑️ Primary color reset');
            }

            if (addCompanyController.company!.secondaryColor?.secondaryColor?.lastOrNull != null) {
              addCompanyController.company!.secondaryColor?.secondaryColor?.add(null);
              addCompanyController.company!.secondaryColor?.timestamps?.add(Timestamp.now());
              print('🗑️ Secondary color reset');
            }

            if (addCompanyController.company!.englishFont?.englishFont?.lastOrNull != null) {
              addCompanyController.company!.englishFont?.englishFont?.add(null);
              addCompanyController.company!.englishFont?.timestamps?.add(Timestamp.now());
              print('🗑️ English font reset');
            }

            if (addCompanyController.company!.arabicFont?.arabicFont?.lastOrNull != null) {
              addCompanyController.company!.arabicFont?.arabicFont?.add(null);
              addCompanyController.company!.arabicFont?.timestamps?.add(Timestamp.now());
              print('🗑️ Arabic font reset');
            }

            // ── 2. Mark company as inactive ───────────────────────────────
            print('🗑️ Setting company status to inactive');
            addCompanyController.company!.status = 'inactive';

            // ── 3. Clear in-memory controller fields ──────────────────────
            companyController.imageUrl = null;
            companyController.primaryColor = null;
            companyController.secondaryColor = null;
            companyController.selectedEnglishFont = null;
            companyController.selectedArabicFont = null;
            print('🗑️ Cleared all in-memory controller branding fields');

            // ── 4. Save to Firebase ───────────────────────────────────────
            print('💾 Saving reset company data to Firebase...');
            await addCompanyController.addCompany(
              addCompanyController.company!,
              ApiConstants.baseUri.split("/").last,
            );
            print('💾 Firebase save complete');

            // ── 5. Pop dialog using dialogContext (safe — not the page context)
            Navigator.pop(dialogContext);

            // ── 6. ✅ KEY FIX: Rebuild THIS screen's widget tree immediately
            // so ColorDisplaySection shows default colors right away
            // without the user needing to navigate away and back
            if (mounted) {
              setState(() {
                print('🔄 setState called — ColorDisplaySection will rebuild with default colors');
              });
            }

            // ── 7. Refresh Firebase + restart app to apply theme-wide reset
            print('🔄 Refreshing company data and restarting app...');
            await addCompanyController.getCompany(shouldRestart: true);

            // Note: lines below won't execute after restart — kept as safety fallback
            print('🗑️ Reset complete!');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 ===== BRANDING SCREEN BUILD START =====');
    var isMobile = context.isPhone;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                // ── Company Image + Reset Button ──────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CompanyImage(onChangedImageUrl: widget.onChangedImageUrl),
                    customButton(
                      title: "Reset".tr,
                      function: _resetBranding,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.text,
                      ),
                      width: 150.w,
                      height: 38.h,
                      radius: 8.r,
                      color: const Color(0xffCCCCCCCC),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // ── Color Display Section ─────────────────────────────────
                // companyController.primaryColor and secondaryColor are null
                // after reset → setState above forces this to rebuild with
                // the fallback Colors.blue / Colors.red immediately
                ColorDisplaySection(
                  primaryColor: companyController.primaryColor ?? Colors.blue,
                  secondaryColor: companyController.secondaryColor ?? Colors.red,
                  onPrimaryColorSelected: (Color color) {
                    print('🎨 PRIMARY COLOR SELECTED: $color');
                    setState(() {
                      companyController.primaryColor = color;
                    });
                    widget.onChangedPrimaryColor(color);
                  },
                  onSecondaryColorSelected: (Color color) {
                    print('🖌️ SECONDARY COLOR SELECTED: $color');
                    setState(() {
                      companyController.secondaryColor = color;
                    });
                    widget.onChangedSecondaryColor(color);
                  },
                ),

                SizedBox(height: 24.h),

                // ── Fonts Section ─────────────────────────────────────────
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
                    selectedValue: _getInitialEnglishFont(),
                    items: _convertToDropdownItems(CompanyConstants.englishList),
                    widthIcon: 14,
                    heightIcon: 7,
                    height: 36,
                    spaceHeight: 8.h,
                    borderRadius: 4.r,
                    hint: Text(
                      'Select English Font'.tr,
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.text
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          companyController.selectedEnglishFont = value;
                        });
                        widget.onChangedFontEnglish(value);
                        print('📝 English font changed: $value');
                      }
                    },
                  ),
                  right: CustomDropdownFormFieldInvMaster(
                    selectedValue: _getInitialArabicFont(),
                    items: _convertToDropdownItems(CompanyConstants.arabicList),
                    widthIcon: 14,
                    heightIcon: 7,
                    height: 36,
                    spaceHeight: 8.h,
                    borderRadius: 4.r,
                    hint: Text(
                      'Select Arabic Font'.tr,
                      style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.text

                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          companyController.selectedArabicFont = value;
                        });
                        widget.onChangedFontArabic(value);
                        print('📝 Arabic font changed: $value');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}