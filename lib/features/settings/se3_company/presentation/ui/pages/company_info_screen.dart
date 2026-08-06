// ignore_for_file: must_be_immutable, prefer_const_declarations, unused_local_variable, deprecated_member_use, duplicate_ignore, no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks, use_build_context_synchronously
///*************************** FILE INFO **********************************///
/// Purpose: Responsive company information / branding screen (phone + tablet in
/// one page).
/// Author: Amr Mesbah
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/theme_controller.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_state.dart';
import 'package:grc_module/features/settings/se3_company/presentation/ui/widgets/sections/company_branding_screen.dart';
import 'package:grc_module/features/settings/se3_company/presentation/ui/widgets/fields/company_information_fields.dart';
import 'package:grc_module/core/custom/10-custom_tabs.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/generated/l10n.dart';
final HapticController hapticController = Get.put(HapticController());

class CompanyInfoScreen extends StatefulWidget {
  final bool? isBranding;

  CompanyInfoScreen({super.key, this.isBranding = false});

  @override
  // ignore: library_private_types_in_public_api
  _CompanyInfoScreenState createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  bool isEnglish = Get.locale.toString().contains('en');
  CompanyCubit get companyController => context.read<CompanyCubit>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContextExtension(context).isPhone
        ? _buildPhone(context)
        : _buildTablet(context);
  }

  /// Phone design (formerly company_info_screen.dart)
  Widget _buildPhone(BuildContext context) {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) => SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 0.02.w, vertical: 0.01.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTabs(
                    tabs: const [
                      'Company Information',
                      'Branding',
                    ],
                    selectedValue: state.brandingSelectedIndex,
                    onChanged: (value) {
                      companyController.setBrandingSelectedIndex(value);
                    },
                  ),
                  if (state.brandingSelectedIndex == 0)
                    Column(
                      children: [CompanyInformationFields()],
                    ),
                  if (state.brandingSelectedIndex == 1)
                    CompanyBrandingScreen(
                      onChangedImageUrl: (value) {},
                      onChangedPrimaryColor: (Color value) {
                        print(
                            'primary color is ${value.value.toRadixString(16)}');
                      },
                      onChangedSecondaryColor: (Color value) {},
                      onChangedFontArabic: (String value) {
                        print('arabic font isss $value');
                      },
                      onChangedFontEnglish: (String value) {},
                    ),
                ],
              ),
            ),
          ),
          // Only the Branding tab (index 1) has a working action. The company
          // info tab's "Update" opened UpdateCompanyInfoDialog, whose form
          // widgets (widgets/updates/...) no longer exist, so that entry point
          // is removed rather than left showing a broken dialog.
          if (state.brandingSelectedIndex != 0)
            customButton(
              title: S.of(context).Apply,
              function: () async {
                // This used to inline the whole logo/colour/font merge before
                // calling addCompany + getCompany. That is exactly what
                // CompanyCubit.updateCompanyModel() does (loading indicator,
                // theme refresh and all), so it's one call now.
                await companyController.updateCompanyModel();
              },
              width: 340.w,
              height: 38.sp,
              color: AppColors.primary,
              textStyle: StyleText.fontSize22Weight700
                  .copyWith(color: AppColors.textButton))
        ],
      ),
      ),
    );
  }

  /// Tablet design (formerly tablet_company_info_screen.dart)
  Widget _buildTablet(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color:
                    lightMode ? AppColors.background : AppColors.chatBackground,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: SingleChildScrollView(
                child: CompanyBrandingScreen(
                  onChangedImageUrl: (value) {},
                  onChangedPrimaryColor: (Color value) {},
                  onChangedSecondaryColor: (Color value) {},
                  onChangedFontArabic: (String value) {},
                  onChangedFontEnglish: (String value) {},
                ),
              ),
            ),
            SizedBox(height: 10.h),
            customButton(
              title: S.of(context).Apply,
              width: 300.w,
              height: 36.h,
              radius: 4.r,
              color: AppColors.primary,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.textButton),
              function: () async {
                hapticController.triggerHapticFeedback(
                    vibration: VibrateType.mediumImpact,
                    hapticFeedback: HapticFeedback.mediumImpact);
                await companyController.updateCompanyModel();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
