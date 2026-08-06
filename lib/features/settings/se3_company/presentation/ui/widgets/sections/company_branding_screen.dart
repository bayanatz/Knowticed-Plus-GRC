/// ************************ FILe INFO ********************************///
/// File Name: company_branding_screen.dart
/// Author: Amr Mesbah
/// refactored at: 11/04/2025
/// Updated by: Amr Mesbah - Fixed cross-device branding sync
/// Updated by: Amr Mesbah - Reset now applies immediately without needing Apply click
/// Updated by: Amr Mesbah - Colors update instantly in UI after reset (no navigation needed)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/custom/55_custom_responsive_fields.dart';
import 'package:grc_module/core/custom/61-custom_color_picker.dart';
import 'package:grc_module/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/haptic_controller.dart' hide storage;
import 'package:grc_module/core/helper/main_helper/biometric_controller.dart';


import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/settings/settings_screen/views/owner_screens/company_information/color_display_section.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/knowledge_hub_module/core/custom_drop_down.dart';
import 'package:grc_module/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_state.dart';
import 'package:grc_module/core/custom/33-custom_haptic.dart';
import 'package:grc_module/core/network/api_constants.dart';
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/core/custom_reasponsive_filed.dart';
import 'package:grc_module/features/settings/se3_company/presentation/ui/widgets/shared/company_image.dart';
import 'package:grc_module/core/custom/1-custom_dropdwon.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
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
  CompanyCubit get _cubit => context.read<CompanyCubit>();

  final TextEditingController _companyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('📱 ============ BRANDING SCREEN INIT START ============');
    // Clear any unsaved branding selections from a previous visit. Deferred a
    // frame because context.read isn't available during initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cubit.clearBrandingSelections();
    });
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

  List<DropdownItem<String>> _convertToDropdownItems(List<String> items) {
    return items
        .map((item) => DropdownItem<String>(
              value: item.toLowerCase(),
              label: item,
            ))
        .toList();
  }

  String? _getInitialEnglishFont() {
    final state = _cubit.state;
    if (state.selectedEnglishFont != null) {
      return state.selectedEnglishFont!.toLowerCase();
    }
    if (state.isCompanyActive &&
        state.company!.englishFont?.englishFont?.lastOrNull != null) {
      return state.company!.englishFont!.englishFont!.last!.toLowerCase();
    }
    return null;
  }

  String? _getInitialArabicFont() {
    final state = _cubit.state;
    if (state.selectedArabicFont != null) {
      return state.selectedArabicFont!.toLowerCase();
    }
    if (state.isCompanyActive &&
        state.company!.arabicFont?.arabicFont?.lastOrNull != null) {
      return state.company!.arabicFont!.arabicFont!.last!.toLowerCase();
    }
    return null;
  }

  void _resetBranding() {
    print('🔄 ===== RESET BRANDING TRIGGERED =====');
    // Was DeleteDialog(isDeleteDialog: false). CustomDialogManager.showDialogFlow
    // closes the confirm dialog itself (so the manual Navigator.pop below is
    // gone) and requires a success step, which this flow previously had none of
    // - the app-restart now runs from onSuccessComplete, after the success
    // dialog is dismissed.
    CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: "assets/lottie_assets/main_lottie_assets/reset_brand.json",
      confirmTitle: S.of(context).resetBranding,
      confirmSubtitle: S.of(context).areYouSureYouWantToResetTheCompanyBranding,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
            print('✅ User confirmed reset');

            hapticController.triggerHapticFeedback(
              vibration: VibrateType.mediumImpact,
              hapticFeedback: HapticFeedback.mediumImpact,
            );

            // ── 1. Null out all branding fields in the company model ──────
            if (_cubit.state.company!.companyLogo?.companyLogo?.lastOrNull != null) {
              _cubit.state.company!.companyLogo?.companyLogo?.add(null);
              _cubit.state.company!.companyLogo?.timestamps?.add(Timestamp.now());
              print('🗑️ Logo reset');
            }

            if (_cubit.state.company!.primaryColor?.primaryColor?.lastOrNull != null) {
              _cubit.state.company!.primaryColor?.primaryColor?.add(null);
              _cubit.state.company!.primaryColor?.timestamps?.add(Timestamp.now());
              print('🗑️ Primary color reset');
            }

            if (_cubit.state.company!.secondaryColor?.secondaryColor?.lastOrNull != null) {
              _cubit.state.company!.secondaryColor?.secondaryColor?.add(null);
              _cubit.state.company!.secondaryColor?.timestamps?.add(Timestamp.now());
              print('🗑️ Secondary color reset');
            }

            if (_cubit.state.company!.englishFont?.englishFont?.lastOrNull != null) {
              _cubit.state.company!.englishFont?.englishFont?.add(null);
              _cubit.state.company!.englishFont?.timestamps?.add(Timestamp.now());
              print('🗑️ English font reset');
            }

            if (_cubit.state.company!.arabicFont?.arabicFont?.lastOrNull != null) {
              _cubit.state.company!.arabicFont?.arabicFont?.add(null);
              _cubit.state.company!.arabicFont?.timestamps?.add(Timestamp.now());
              print('🗑️ Arabic font reset');
            }

            // ── 2. Mark company as inactive ───────────────────────────────
            print('🗑️ Setting company status to inactive');
            _cubit.state.company!.status = 'inactive';

            // ── 3. Clear in-memory controller fields ──────────────────────
            _cubit.clearBrandingSelections();
            print('🗑️ Cleared all in-memory controller branding fields');

            // ── 4. Save to Firebase ───────────────────────────────────────
            print('💾 Saving reset company data to Firebase...');
            await _cubit.addCompany(
              _cubit.state.company!,
              ApiConstants.baseUri.split("/").last,
            );
            print('💾 Firebase save complete');

            // ── 5. Rebuild THIS screen's widget tree immediately so
            // CustomColorPickerSection shows default colors right away without the
            // user needing to navigate away and back.
            if (mounted) {
              setState(() {
                print('🔄 setState called — CustomColorPickerSection will rebuild with default colors');
              });
            }

            print('🗑️ Reset complete!');
            return true;
      },
      successLottie: "assets/lottie_assets/main_lottie_assets/correct.json",
      successTitle: "Successful",
      successSubtitle: "Company Branding Has Been Reset",
      // Refresh Firebase + restart the app to apply the theme-wide reset, once
      // the success dialog has been dismissed.
      onSuccessComplete: () async {
        print('🔄 Refreshing company data and restarting app...');
        await _cubit.getCompany(shouldRestart: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 ===== BRANDING SCREEN BUILD START =====');
    var isMobile = ContextExtension(context).isPhone;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) => Column(
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
                      title: S.of(context).Reset,
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
                CustomColorPickerSection(
                  primaryColor: state.primaryColor ?? Colors.blue,
                  secondaryColor: state.secondaryColor ?? Colors.red,
                  onPrimaryColorSelected: (Color color) {
                    print('🎨 PRIMARY COLOR SELECTED: $color');
                    _cubit.setPrimaryColor(color);
                    widget.onChangedPrimaryColor(color);
                  },
                  onSecondaryColorSelected: (Color color) {
                    print('🖌️ SECONDARY COLOR SELECTED: $color');
                    _cubit.setSecondaryColor(color);
                    widget.onChangedSecondaryColor(color);
                  },
                ),

                SizedBox(height: 24.h),

                // ── Fonts Section ─────────────────────────────────────────
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
                    value: _getInitialEnglishFont(),
                    items: _convertToDropdownItems(CompanyConstants.englishList),
                    itemHeight: 36.h,
                    borderRadius: BorderRadius.circular(4.r),
                    hint: S.of(context).selectEnglishFont,
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.text,
                    ),
                    onChanged: (value) {
                      _cubit.setSelectedEnglishFont(value);
                      widget.onChangedFontEnglish(value);
                      print('📝 English font changed: $value');
                    },
                  ),
                  right: CustomDropdown<String>(
                    value: _getInitialArabicFont(),
                    items: _convertToDropdownItems(CompanyConstants.arabicList),
                    itemHeight: 36.h,
                    borderRadius: BorderRadius.circular(4.r),
                    hint: S.of(context).selectArabicFont,
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.text,
                    ),
                    onChanged: (value) {
                      _cubit.setSelectedArabicFont(value);
                      widget.onChangedFontArabic(value);
                      print('📝 Arabic font changed: $value');
                    },
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
