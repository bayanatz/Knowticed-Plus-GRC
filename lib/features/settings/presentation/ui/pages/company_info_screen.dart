// ignore_for_file: must_be_immutable, prefer_const_declarations, unused_local_variable, deprecated_member_use, duplicate_ignore, no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks, use_build_context_synchronously
///*************************** FILE INFO **********************************///
/// Purpose: Responsive company information / branding screen (phone + tablet in
/// one page).
/// Author: Mohamed Elrashidy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/network/api_constants.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/settings/presentation/controller/add_company_controller.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/update_company_info_dialog.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/company/company_branding_screen.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/company/company_information_fields.dart';
import 'package:demo_app/features/settings/widgets/custom_upper_filter.dart';

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
  late String filterChoice;
  CompanyController companyController = Get.find();

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
    final ThemeController themeController = Get.find();
    return SingleChildScrollView(
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
                  UpperFilters(
                    isSettingsPage: true,
                    filterTitles: [
                      'Company Information',
                      'Branding',
                    ],
                    selectedIndex: companyController.brandingSelectedIndex,
                    selectedIndexState: (value) {
                      setState(() {
                        companyController.brandingSelectedIndex = value;
                      });
                    },
                    selectedDepartmentState: (value) {
                      setState(
                        () {
                          filterChoice = value;
                        },
                      );
                    },
                  ),
                  if (companyController.brandingSelectedIndex == 0)
                    Column(
                      children: [CompanyInformationFields()],
                    ),
                  if (companyController.brandingSelectedIndex == 1)
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
          customButton(
              title: companyController.brandingSelectedIndex == 0
                  ? 'Update'.tr
                  : "Apply".tr,
              function: () async {
                if (companyController.brandingSelectedIndex == 0) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const UpdateCompanyInfoDialog();
                    },
                  );
                } else {
                  showLoadingIndicator();
                  if (companyController.imageUrl != null) {
                    companyController.company!.companyLogo!.companyLogo!
                        .add(companyController.imageUrl);
                    companyController.company!.companyLogo!.timestamps!
                        .add(Timestamp.now());
                  }

                  companyController.company!.status = 'active';
                  if (companyController.primaryColor != null) {
                    companyController.company!.primaryColor!.primaryColor!.add(
                        '0x${companyController.primaryColor!.value.toRadixString(16)}');
                    companyController.company!.primaryColor!.timestamps!
                        .add(Timestamp.now());
                  }

                  if (companyController.secondaryColor != null) {
                    companyController.company!.secondaryColor!.secondaryColor!
                        .add(
                            '0x${companyController.secondaryColor!.value.toRadixString(16)}');
                    companyController.company!.secondaryColor!.timestamps!
                        .add(Timestamp.now());
                  }

                  if (companyController.selectedEnglishFont != null) {
                    companyController.company!.englishFont!.englishFont!
                        .add(companyController.selectedEnglishFont!
                            .toLowerCase());

                    companyController.company!.englishFont!.timestamps!
                        .add(Timestamp.now());
                  }

                  if (companyController.selectedArabicFont != null) {
                    companyController.company!.arabicFont!.arabicFont!.add(
                        companyController.selectedArabicFont!.toLowerCase());

                    companyController.company!.arabicFont!.timestamps!
                        .add(Timestamp.now());
                  }

                  await companyController.addCompany(
                    companyController.company!,
                    ApiConstants.baseUri.split('/').last,
                  );

                  await companyController.getCompany();
                  themeController.updatePrimaryColor();
                  themeController.updateSecondaryColor();
                  themeController.updateFonts();
                  setState(() {});
                  hideLoadingIndicator();
                }
              },
              width: 340.w,
              height: 38.sp,
              color: AppColors.primary,
              textStyle: StyleText.fontSize22Weight700
                  .copyWith(color: AppColors.textButton))
        ],
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
              title: 'Apply'.tr,
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
