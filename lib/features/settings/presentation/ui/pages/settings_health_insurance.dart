// ignore_for_file: must_be_immutable, prefer_const_declarations, unused_local_variable, deprecated_member_use, duplicate_ignore, no_leading_underscores_for_local_identifiers, use_build_context_synchronously
///********************************** FILE INFO *************************
/// Purpose: Responsive health insurance settings page (phone + tablet in one
/// page).
/// Author: Mohamed Elrashidy
/// Refactored At: 11/11/2024
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_appbar_mobile.dart';
import 'package:demo_app/core/custom/37-custom_navigate.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/shared_action_widgets.dart';
import 'package:demo_app/features/settings/presentation/controller/request_controller.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/edit_page_request_health.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/health_insurance_fields.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/request_to_change_dialog_mobile.dart';

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
    final orientation = MediaQuery.of(context).orientation;

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.02.h),
                          child: SizedBox(
                            width: 0.95.w,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.signOut,
                                padding: EdgeInsets.symmetric(
                                  vertical: 0.007.h,
                                  horizontal:
                                      orientation == Orientation.portrait
                                          ? 0.22.w
                                          : 0.155.w,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                hapticController.triggerHapticFeedback(
                                    vibration: VibrateType.heavyImpact,
                                    hapticFeedback: HapticFeedback.heavyImpact);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return RequestToChangeDialogMobile(
                                      isSetting: true,
                                      title: "Request to Change",
                                      imageUrl: "assets/icons/reqToChange.svg",
                                      isExclate: false,
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Request to Change'.tr,
                                style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: FontConstants.fontSize022.h,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textButton,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  customButtonWithImage(
                      title: 'Request to Change'.tr,
                      function: () {
                        navigateTo(context, EditPageRequestHealth());
                      },
                      color: AppColors.primary,
                      width: 300.w,
                      height: 36.h,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.textButton),
                      radius: 4.r,
                      image: 'assets/request_chnage.svg',
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
