import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'dart:io';
import 'package:flutter/src/services/haptic_feedback.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:demo_app/features/settings/mode_changer.dart';
import 'package:demo_app/core/helper/main_helper/biometric_controller.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/core/services/notifications/firebase_notification_handler.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_appbar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/restart_widget.dart';
import 'package:demo_app/features/settings/presentation/controller/settings_controller.dart';
import 'package:demo_app/generated/l10n.dart';

import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/features/settings/widgets/custom_cards.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/language_screen.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/settings_appbar.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/terms_and_conditions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../employee/data/models/emplyees_model/new_employee_model.dart';
import '../../../../employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/helper/employees/employee_branding/presentation/ui/employee_branding_screen.dart';
import '../../../../home/presentation/ui/pages/edit_home_page.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/settings/settings_permissions.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/settings/settings_permissions_sections.dart';
import '../widgets/company/comapny_info.dart';
import '../widgets/company/company_information_fields.dart';
import 'about_this_app_screen.dart';
import 'comments_and_feedback_screen.dart';
import 'privacy_Statement.dart';
import 'request_page.dart';
import 'social_screen.dart';
import 'company_info_screen.dart';
import 'personal_info_screen.dart';
import 'settings_health_insurance.dart';


class SettingsLayout extends StatefulWidget {
  SettingsLayout({super.key});

  @override
  State<SettingsLayout> createState() => _SettingsLayoutState();
}

class _SettingsLayoutState extends State<SettingsLayout> {
  final SettingsController settingsController = Get.find();

  final storage = GetStorage();

  final ThemeController themeController = Get.find();

  // Helper method to navigate to screen on mobile
  void _navigateToScreen(BuildContext context, Widget screen, String title) {
    var isMobile = context.isPhone;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: isMobile ? null : AppBar(
            title: Text(title),
          ),
          body: screen
        ),
      ),
    );
  }

  String _getEmployeeName() {
    final mainCoreEmployeeController = Get.find<MainCoreEmployeeController>();

    if (mainCoreEmployeeController.employeeEntity == null) return '';

    final isEnglish = Get.locale.toString().contains('en');

    final firstName = isEnglish
        ? (mainCoreEmployeeController.employeeEntity?.firstName ?? '').capitalize
        : mainCoreEmployeeController.employeeEntity?.firstNameInArabic ?? '';

    final lastName = isEnglish
        ? (mainCoreEmployeeController.employeeEntity?.lastName ?? '').capitalize
        : mainCoreEmployeeController.employeeEntity?.lastNameInArabic ?? '';

    return "$firstName $lastName".trim();
  }



    @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    SettingsController settingsController = Get.find();
    final HapticController hapticController = Get.put(HapticController());
    final BiometricController biometricController = Get.put(BiometricController());
    final MainCoreEmployeeController mainCoreEmployeeController = Get.find();

    bool orientation = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    double desktopImageSize = 0.03.h;

    // Check permissions for each item
    bool hasPersonalInfo = true; // Usually always visible
    bool hasHealthInsurance = true; // Usually always visible
    bool hasSocialInfo = true; // Usually always visible
    bool hasRequests = true; // Usually always visible

    // Permission-based visibility checks
    bool hasBrandingTheme = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.branding,
    );

    bool hasHomeLayout = true; // Usually always visible

    bool hasCompanyInfo = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.companyInformation,
    );

    bool hasLanguage = true; // Usually always visible
    bool hasCommentsAndFeedbacks = true; // Usually always visible
    bool hasAboutApp = true; // Usually always visible
    bool hasTermsConditions = true; // Usually always visible
    bool hasPrivacyStatement = true; // Usually always visible

    bool hasAnimation = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.animation,
    );

    bool hasBiometrics = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.biometricsForLogin,
    );
    NewEmployeeModel? employee = NewEmployeeModel();

    final lightMode = themeController.currentTheme.value.brightness == Brightness.light;
    var isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // **FIXED: Use theme controller instead of context for theme**
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          isMobile ?  SizedBox(height: 50.sp):  SizedBox(height: 20.h),
          SettingsAppBar(
            startDate: settingsController.employee?.firstLogin,
            superVisor: settingsController.employee?.supervisor?.lastOrNull,
            image: settingsController.employee?.photo?.lastOrNull,
            name: _getEmployeeName(),
            role: settingsController.employee?.role?.lastOrNull?.capitalize?.tr ?? '',
          ),
          isMobile ? SizedBox(height: 10.sp)  : SizedBox(height: orientation ? 0.05.h : 0.02.h),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Container(

                        child: Padding(
                          padding: EdgeInsets.only(
                            left:isArabic ? isMobile ? 10.sp : 0.sp : 10.w,
                            right: isArabic ?  10.w :isMobile ? 10.sp : 0.w,
                          ),
                          child: Column(
                            children: [
                              // First Section: User Information (Personal Information, Health Insurance, Social Information, Requests)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.h),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    color: AppColors.background,
                                    child: Column(
                                      children: [
                                        if (hasPersonalInfo)
                                          Container(

                                            color: settingsController.selectedContainerIndex == 0
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              name: 'Personal Information'.tr,
                                              icon: SvgPicture.asset(
                                                  width: 15.w,
                                                  height: 15.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_settings_new/Personal Information.svg',
                                                  color: settingsController.selectedContainerIndex == 0
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              index: 0,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              isSelected: settingsController.selectedContainerIndex == 0,
                                              onTap: isMobile
                                                  ? () {
                                                print("11111111111111111111 Tapped Personal Information");
                                                _navigateToScreen(context, PersonalInfoScreen(), 'Personal Information'.tr);
                                              }
                                                  : null, // Null for tablet - will use default selection behavior
                                            ),
                                          ),
                                        if (hasHealthInsurance)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 10
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              name: 'Health Insurance'.tr,
                                              icon: SvgPicture.asset(
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_settings_new/Health Insurance.svg',
                                                  color: settingsController.selectedContainerIndex == 10
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              index: 10,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _navigateToScreen(context, SettingsHealthInsurance(), 'Health Insurance'.tr)
                                                  : null,
                                            ),
                                          ),
                                        if (hasSocialInfo)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 12
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              name: S.of(context).generalInformation,
                                              icon: SvgPicture.asset(
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_settings_new/Social Information.svg',
                                                  color: settingsController.selectedContainerIndex == 12
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              index: 12,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _navigateToScreen(context, SocialScreen(), S.of(context).generalInformation)
                                                  : null,
                                            ),
                                          ),
                                        if (hasRequests)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 13
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              name: 'Requests'.tr,
                                              icon: SvgPicture.asset(
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_settings_new/Requests.svg',
                                                  color: settingsController.selectedContainerIndex == 13
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              index: 13,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _navigateToScreen(context,  MyRequestPage(), 'Requests'.tr)
                                                  : null,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Second Section: App Customization (Branding and Theme, Home Layout, Company Information)
                              // Only show this section if at least one item has permission
                              if (hasBrandingTheme || hasHomeLayout || hasCompanyInfo)
                                SizedBox(height: orientation && Get.locale.toString().contains('en') ? 0.01.h : 0),
                              if (hasBrandingTheme || hasHomeLayout || hasCompanyInfo)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 7.h),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          if (hasBrandingTheme)
                                            Container(
                                              color: settingsController.selectedContainerIndex == 14
                                                  ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                  : AppColors.card,
                                              child: CustomCard(
                                                name: S.of(context).brandingAndTheme,
                                                icon: SvgPicture.asset(
                                                    width: 20.w,
                                                    height:  18.h,
                                                    fit: BoxFit.fill,
                                                    'assets/icons_settings_new/Branding and Theme.svg',
                                                    color: settingsController.selectedContainerIndex == 14
                                                        ? AppColors.secondaryPrimary
                                                        : AppColors.secondaryPrimary
                                                ),
                                                index: 14,
                                                selectIndex: settingsController.selectedContainerIndex,
                                                onTap: isMobile
                                                    ? () => _navigateToScreen(context, CompanyInfoScreen(), S.of(context).brandingAndTheme)
                                                    : null,
                                              ),
                                            ),

                                          // // ✅ ADD THIS NEW EMPLOYEE BRANDING ITEM
                                          // Container(
                                          //   color: settingsController.selectedContainerIndex == 17
                                          //       ? lightMode ? AppColors.primary.withOpacity(.1) : AppColors.primary.withOpacity(.08)
                                          //       : AppColors.card,
                                          //   child: CustomCard(
                                          //     name: 'Personal Branding'.tr,
                                          //     icon: SvgPicture.asset(
                                          //         width: 20.w,
                                          //         height: 18.h,
                                          //         fit: BoxFit.fill,
                                          //         'assets/icons_settings_new/Branding and Theme.svg', // Reusing same icon, or create a new one
                                          //         color: settingsController.selectedContainerIndex == 17
                                          //             ? AppColors.secondaryPrimary
                                          //             : AppColors.secondaryPrimary
                                          //     ),
                                          //     index: 17,
                                          //     selectIndex: settingsController.selectedContainerIndex,
                                          //     onTap: isMobile
                                          //         ? () => _navigateToScreen(context, const EmployeeBrandingScreen(), 'Personal Branding'.tr)
                                          //         : null,
                                          //   ),
                                          // ),

                                          if (hasHomeLayout)
                                            Container(
                                              color: settingsController.selectedContainerIndex == 15
                                                  ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                  : AppColors.card,
                                              child: CustomCard(
                                                onTap: () {
                                                  Navigator.of(context).push(MaterialPageRoute(
                                                      builder: (context) => EditHomePage()));
                                                },
                                                name:  S.of(context).homeLayout,
                                                icon: SvgPicture.asset(
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_settings_new/Home Layout.svg',
                                                  color: AppColors.secondaryPrimary,
                                                ),
                                                index: 15,
                                                selectIndex: settingsController.selectedContainerIndex,
                                              ),
                                            ),
                                          if (hasCompanyInfo)
                                            Container(
                                              color: settingsController.selectedContainerIndex == 8
                                                  ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                  : AppColors.card,
                                              child: CustomCard(
                                                name: 'Company Information'.tr,
                                                icon: SvgPicture.asset(
                                                    width: 20.w,
                                                    height:  18.h,
                                                    fit: BoxFit.fill,
                                                    'assets/icons_settings_new/Company Information.svg',
                                                    color: settingsController.selectedContainerIndex == 8
                                                        ? AppColors.secondaryPrimary
                                                        : AppColors.secondaryPrimary
                                                ),
                                                index: 8,
                                                selectIndex: settingsController.selectedContainerIndex,
                                                onTap: isMobile
                                                    ? () => _navigateToScreen(context, CompanyScreenInfo(), 'Company Information'.tr)
                                                    : null,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              // Third Section: Support & Legal (Language, Comments and Feedbacks, About This App, Terms and Conditions, Privacy Statement)
                              SizedBox(height: 0.h),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.h),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    color: AppColors.card,
                                    child: Column(
                                      children: [
                                        if (hasLanguage)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 2
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.background
                                                : AppColors.card,
                                            child: CustomCard(
                                              icon: SvgPicture.asset(
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_settings_new/Language.svg',
                                                  color: settingsController.selectedContainerIndex == 2
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              name: 'Language'.tr,
                                              index: 2,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _navigateToScreen(context, const LanguageScreen(), 'Language'.tr)
                                                  : null,
                                            ),
                                          ),
                                        if (hasCommentsAndFeedbacks)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 4
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) : AppColors.background
                                                : AppColors.card,
                                            child: CustomCard(
                                              icon: SvgPicture.asset(
                                                  'assets/icons_settings_new/Comments and Feedbacks.svg',
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  color: settingsController.selectedContainerIndex == 4
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              name: 'Comments And Feedbacks'.tr,
                                              index: 4,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _navigateToScreen(context, const CommentsAndFeedbackScreen(), 'Comments And Feedbacks'.tr)
                                                  : null,
                                            ),
                                          ),
                                        if (hasAboutApp)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 5
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) : AppColors.background
                                                : AppColors.card,
                                            child: CustomCard(
                                              icon: SvgPicture.asset(
                                                  'assets/icons_settings_new/About This App.svg',
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  color: settingsController.selectedContainerIndex == 5
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              name: FormatHelper.capitalize(S.of(context).aboutThisPlatform),
                                              index: 5,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _navigateToScreen(context, const AboutThisAppScreen(), 'About This App'.tr)
                                                  : null,
                                            ),
                                          ),
                                        if (hasTermsConditions)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 6
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.background
                                                : AppColors.card,
                                            child: CustomCard(
                                              icon: SvgPicture.asset(
                                                  'assets/icons_settings_new/termsAndCondtion.svg',
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  color: settingsController.selectedContainerIndex == 6
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              name: 'Terms And Conditions'.tr,
                                              index: 6,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _navigateToScreen(context, const TermsConditions(), 'Terms And Conditions'.tr)
                                                  : null,
                                            ),
                                          ),
                                        if (hasPrivacyStatement)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 16
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) : AppColors.background
                                                : AppColors.card,
                                            child: CustomCard(
                                              icon: SvgPicture.asset(
                                                  'assets/icons_settings_new/Privacy Statement.svg',
                                                  width: 22.w,
                                                  height:  22.h,
                                                  fit: BoxFit.fill,
                                                  color: settingsController.selectedContainerIndex == 16
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              name: S.of(context).privacyStatement,
                                              index: 16,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _navigateToScreen(context, const PrivacyStatementPage(), S.of(context).privacyStatement)
                                                  : null,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Fourth Section: System Preferences (Haptic Feedback, Biometrics, Dark Mode, Animation, Notification)
                              SizedBox(height: 0),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 7.h),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(

                                   color:  AppColors.card,
                                    child: Column(
                                      children: [
                                        CustomCard(
                                          icon: Center(
                                            child: SvgPicture.asset(
                                              'assets/icons_settings_new/Haptic Feedback.svg',
                                              width: 20.w,
                                              height:  18.h,
                                              fit: BoxFit.fill,
                                              color: AppColors.secondaryPrimary,
                                            ),
                                          ),
                                          name: 'Haptic Feedback'.tr,
                                          isSwitchTile: true,
                                          currentValue: hapticController.isHapticEnabled.value == true,
                                          onSwitchChanged: (Value) {
                                            hapticController.toggleHapticFeedback(Value);
                                            print("Haptic Feedback is enabled: ${hapticController.isHapticEnabled.value}");
                                            RestartWidget.restartApp(context);
                                          },
                                        ),
                                        if (hasBiometrics)
                                          CustomCard(
                                            icon: Center(
                                              child: SvgPicture.asset(
                                                'assets/icons_settings_new/Biometrics.svg',
                                                width: 20.w,
                                                height:  18.h,
                                                fit: BoxFit.fill,
                                                color: AppColors.secondaryPrimary,
                                              ),
                                            ),
                                            name: 'Biometrics'.tr,
                                            isSwitchTile: true,
                                            currentValue: biometricController.isBiometricEnabled.value == true,
                                            onSwitchChanged: (Value) {
                                              hapticController.triggerHapticFeedback(
                                                  vibration: VibrateType.mediumImpact,
                                                  hapticFeedback: HapticFeedback.mediumImpact
                                              );
                                              biometricController.toggleBiometricFeedback(Value);
                                              print("biometric enabled: ${biometricController.isBiometricEnabled.value}");
                                              RestartWidget.restartApp(context);
                                            },
                                          ),
                                        CustomCard(
                                          icon: Center(
                                            child: SvgPicture.asset(
                                              'assets/icons_settings_new/Dark Mode.svg',
                                              width: 20.w,
                                              height:  18.h,
                                              fit: BoxFit.fill,
                                              color: AppColors.secondaryPrimary,
                                            ),
                                          ),
                                          name: 'Dark Mode'.tr,
                                          isSwitchTile: true,
                                          currentValue: themeController.currentTheme.value == AppColors.darkTheme,
                                          onSwitchChanged: (Value) {
                                            if (!mounted) return; // ✅ Add mounted check

                                            hapticController.triggerHapticFeedback(
                                                vibration: VibrateType.mediumImpact,
                                                hapticFeedback: HapticFeedback.mediumImpact
                                            );
                                            // Only toggle if the value actually changed
                                            bool isDarkMode = themeController.currentTheme.value == AppColors.darkTheme;
                                            if (Value != isDarkMode) {
                                              themeController.toggleTheme();
                                              // Consider removing RestartWidget if not necessary
                                              // RestartWidget.restartApp(context);
                                            }
                                          },
                                        ),
                                        if (hasAnimation)
                                          CustomCard(
                                            icon: Center(
                                              child: SvgPicture.asset(
                                                'assets/icons_settings_new/Animation.svg',
                                                width: 20.w,
                                                height:  18.h,
                                                fit: BoxFit.fill,
                                                color: AppColors.secondaryPrimary,
                                              ),
                                            ),
                                            name: 'Animation'.tr,
                                            isSwitchTile: true,
                                            currentValue: false,
                                            onSwitchChanged: (Value) {
                                              hapticController.triggerHapticFeedback(
                                                  vibration: VibrateType.mediumImpact,
                                                  hapticFeedback: HapticFeedback.mediumImpact
                                              );
                                            },
                                          ),
                                        CustomCard(
                                          icon: Center(
                                            child: SvgPicture.asset(
                                              'assets/icons_settings_new/Notification.svg',
                                              width: 20.w,
                                              height:  18.h,
                                              fit: BoxFit.fill,
                                              color: AppColors.secondaryPrimary,
                                            ),
                                          ),
                                          name: 'Notification'.tr,
                                          isSwitchTile: true,
                                          currentValue: settingsController.notificationEnabled,
                                          onSwitchChanged: (Value) {
                                            settingsController.notificationEnabled = Value;
                                            if (Value) {
                                              appNotificationController.subscribeToTopic(
                                                  settingsController.employee!.email!.last!);
                                              storage.write('notificationEnabled', true);
                                            } else {
                                              FirebaseNotificationHandler.unsubscribeFromTopic(
                                                  settingsController.employee!.email!.last!);
                                              storage.write('notificationEnabled', false);
                                            }
                                            Get.find<SettingsController>().update();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                isMobile ?  SizedBox() :  Container(

                  width: orientation ? 0.5.w : 0.58.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r)
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: Get.locale.toString().contains('en') ? 0.01.h : 10.w,
                        left: 10.w,
                        top: orientation
                            ? Get.locale.toString().contains('en') ? 6 : 18
                            : 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (settingsController.selectedContainerIndex == 0 && hasPersonalInfo)
                          const PersonalInfoScreen(),
                        if (settingsController.selectedContainerIndex == 2 && hasLanguage)
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r)
                            ),
                            width: double.infinity,
                            height: orientation
                                ? Mode.owner ? 0.75.h : 0.69.h
                                : 0.65.h,
                            child: const LanguageScreen(),
                          ),
                        if (settingsController.selectedContainerIndex == 4 && hasCommentsAndFeedbacks)
                          const CommentsAndFeedbackScreen(),
                        if (settingsController.selectedContainerIndex == 5 && hasAboutApp)
                          const AboutThisAppScreen(),
                        if (settingsController.selectedContainerIndex == 6 && hasTermsConditions)
                          const TermsConditions(),
                        if (settingsController.selectedContainerIndex == 8 && hasCompanyInfo)
                          CompanyScreenInfo(),
                        if (settingsController.selectedContainerIndex == 9)
                          Container(),
                        if (settingsController.selectedContainerIndex == 10 && hasHealthInsurance)
                          SettingsHealthInsurance(),
                        if (settingsController.selectedContainerIndex == 12 && hasSocialInfo)
                          SocialScreen(),
                        if (settingsController.selectedContainerIndex == 13 && hasRequests)
                          MyRequestPage(),
                        if (settingsController.selectedContainerIndex == 14 && hasBrandingTheme)
                          CompanyInfoScreen(),
                        if (settingsController.selectedContainerIndex == 16 && hasPrivacyStatement)
                          const PrivacyStatementPage(),

                        // ✅ FIXED: Wrapped with Expanded and SingleChildScrollView
                        if (settingsController.selectedContainerIndex == 17)
                          Expanded(
                            child: SingleChildScrollView(
                              child: const EmployeeBrandingScreen(),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}