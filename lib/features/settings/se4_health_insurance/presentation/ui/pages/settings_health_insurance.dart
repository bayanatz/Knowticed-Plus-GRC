/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: settings_health_insurance.dart
/// Purpose: The health-insurance section of the settings screen.
/// Author: Amr Mesbah
/// Created at: 12/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N17: the GetBuilder<RequestController> wrapper removed; the
///          last raw Colors.transparent routed through AppColors.

// ignore_for_file: must_be_immutable, prefer_const_declarations, unused_local_variable, deprecated_member_use, duplicate_ignore, no_leading_underscores_for_local_identifiers, use_build_context_synchronously
///********************************** FILE INFO *************************
/// Purpose: Responsive health insurance settings page (phone + tablet in one
/// page).
/// Author: Amr Mesbah
/// Refactored At: 11/11/2024
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/custom/50-custom_side_frame_master.dart';
import 'package:grc_module/core/custom/37-custom_navigate.dart';
import 'package:grc_module/core/custom/6-custom_button_with_svg.dart';
import 'package:grc_module/features/settings/se4_health_insurance/presentation/ui/pages/edit_page_request_health.dart';
import 'package:grc_module/features/settings/se4_health_insurance/presentation/ui/widgets/fields/health_insurance_fields.dart';
import 'package:grc_module/generated/l10n.dart';

String? section;
String? whatChanged;
String? insuranceName2;

final HapticController hapticController = Get.put(HapticController());

class SettingsHealthInsurance extends StatefulWidget {
  const SettingsHealthInsurance({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsHealthInsuranceState createState() => _SettingsHealthInsuranceState();
}

class _SettingsHealthInsuranceState extends State<SettingsHealthInsurance> {
  int selectedContainerIndex = 0;
  bool isEnglish = Get.locale.toString().contains('en');

  @override
  void initState() {
    section = null;
    whatChanged = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContextExtension(context).isPhone
        ? _buildPhone(context)
        : _buildTablet(context);
  }

  /// Phone design (formerly mobile_settings_health_insurance.dart)
  Widget _buildPhone(BuildContext context) {
    // SideFrameMasterServices supplies the mobile Scaffold, the breadcrumb
    // header (back chevron + page title) and the scroll view, so this method
    // only provides the page body.
    return SideFrameMasterServices(
      titleText: S.of(context).settings,
      onFirstTap: () => Navigator.of(context).maybePop(),
      secondTitle: "Health Insurance",
      child: Column(
        children: [
          HealthInsuranceFields(),
          SizedBox(height: 15.sp),
          // RESTORED: this button used to open RequestToChangeDialogMobile and
          // was deleted when that dialog's form widgets were removed, leaving
          // the phone with no way to raise an insurance change request while
          // the tablet kept one. It now goes to EditPageRequestHealth — the
          // same destination _buildTablet uses — so both breakpoints match.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customButtonWithSvg(
                // `fixedWidth`, not `width`: `width:` is accepted and ignored
                // by customButtonWithSvg so the app-wide ButtonSizing rule
                // wins. 200.sp matches the phone button on the personal
                // information screen.
                fixedWidth: 200.sp,
                title: S.of(context).requestToChange,
                function: () {
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.mediumImpact,
                      hapticFeedback: HapticFeedback.mediumImpact);
                  navigateTo(context, EditPageRequestHealth());
                },
                color: AppColors.primary,
                colorBorder: AppColors.transparent,
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.textButton),
                image:
                    'assets/icons_assets/settings_assets/request_change_document.svg',
                svgColor: AppColors.textButton,
                space: 8.w,
                widthImage: 16.w,
                heightImage: 23.h,
              ),
            ],
          ),
          SizedBox(height: 15.sp),
        ],
      ),
    );
  }

  /// Tablet design (formerly tablet_settings_health_insurance.dart)
  Widget _buildTablet(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // Was wrapped in GetBuilder<RequestController>, whose only purpose was to
    // rebuild on RequestController.update(). Those calls came from the four
    // write methods, which were unreachable and are now deleted
    // (CR-SKEL-SE6-N09), so the wrapper rebuilt on nothing.
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          height: 470.h,
          clipBehavior: Clip.antiAlias,
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HealthInsuranceFields(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButtonWithSvg(
                // `fixedWidth`, not `width`: `width:` is accepted and ignored
                // by customButtonWithSvg so the app-wide ButtonSizing rule wins
                // over the stale `width:` arguments left at dozens of call
                // sites. `fixedWidth` is the opt-in override, and 200.sp here
                // matches the same button on the personal information screen.
                fixedWidth: 250.w,
                title: S.of(context).requestToChange,
                function: () {
                  navigateTo(context, EditPageRequestHealth());
                },
                color: AppColors.primary,
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.textButton),
                image: 'assets/icons_assets/settings_assets/request_change_document.svg',
                svgColor: AppColors.textButton,
                space: 8.w,
                widthImage: 16.w,
                heightImage: 23.h,
                colorBorder: AppColors.transparent),
          ],
        ),
        SizedBox(height: 15.sp),
      ],
    );
  }
}
