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
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/custom_appbar_mobile.dart';
import 'package:grc_module/core/custom/37-custom_navigate.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/features/settings/se6_requests/presentation/controller/request_controller.dart';
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBarMobile(
            showIcon: true,
            showMoreIcon: false,
            title: "Health Insurance",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 0.04.w, vertical: 0.0.w),
                child: Column(
                  children: [
                    HealthInsuranceFields(),
                    // The "Request to Change" button that sat here opened
                    // RequestToChangeDialogMobile, whose form widgets
                    // (widgets/updates/...) no longer exist. Removed with the
                    // dialog rather than left opening a broken screen.
                    SizedBox(height: 0.02.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tablet design (formerly tablet_settings_health_insurance.dart)
  Widget _buildTablet(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return GetBuilder<RequestController>(
        init: Get.find<RequestController>(),
        builder: (requestController) {
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
                      colorBorder: Colors.transparent),
                ],
              ),
              SizedBox(height: 15.sp),
            ],
          );
        });
  }
}
