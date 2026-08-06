///***************************** FILE INFO ****************************/
/// Purpose: Responsive personal information screen (phone + tablet in one page).
/// Author: Amr Mesbah
/// refactored at: 11/11/2024
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/custom_appbar_mobile.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/37-custom_navigate.dart';
import 'package:grc_module/features/settings/se6_requests/presentation/controller/request_controller.dart';
import 'package:grc_module/features/settings/se1_profile/presentation/ui/widgets/fields/personal_information_fields.dart';
import 'package:grc_module/features/settings/se6_requests/presentation/ui/pages/edit_page_request.dart';
import 'package:grc_module/generated/l10n.dart';

String? section;
String? whatChanged;

final HapticController hapticController = Get.put(HapticController());

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  int selectedContainerIndex = 0;
  bool isEnglish = Get.locale.toString().contains('en');

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

  /// Phone design (formerly mobile_personal_info_screen.dart)
  Widget _buildPhone(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBarMobile(
              showIcon: true,
              showMoreIcon: false,
              title: "Personal Information"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 0.04.w, vertical: 0.0.w),
                child: Column(
                  children: [
                    Container(
                        child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0.0.w, vertical: 0.0.h),
                      child: PersonalInformationFields(),
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        customButtonWithSvg(
                          title: S.of(context).requestToChange,
                          function: () {
                            hapticController.triggerHapticFeedback(
                                vibration: VibrateType.mediumImpact,
                                hapticFeedback: HapticFeedback.mediumImpact);
                            navigateTo(context, EditPageRequest());
                          },
                          color: AppColors.primary,
                          colorBorder: AppColors.transparent,
                          textStyle: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.textButton),
                          image: 'assets/icons_assets/settings_assets/request_change_document.svg',
                          svgColor: AppColors.textButton,
                          widthImage: 16.w,
                          heightImage: 23.h,
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

  /// Tablet design (formerly tablet_personal_info_screen.dart)
  Widget _buildTablet(BuildContext context) {
    return GetBuilder<RequestController>(
        init: Get.find<RequestController>(),
        builder: (requestController) {
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
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
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [PersonalInformationFields()],
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
                      hapticController.triggerHapticFeedback(
                          vibration: VibrateType.heavyImpact,
                          hapticFeedback: HapticFeedback.heavyImpact);
                      navigateTo(context, EditPageRequest());
                    },
                    color: AppColors.primary,
                    colorBorder: AppColors.transparent,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton),
                    image: 'assets/icons_assets/settings_assets/request_change_document.svg',
                    svgColor: AppColors.textButton,
                    widthImage: 16,
                    heightImage: 23,
                  ),
                ],
              ),
            ],
          );
        });
  }
}
