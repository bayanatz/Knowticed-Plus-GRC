///***************************** FILE INFO ****************************/
/// Purpose: Responsive personal information screen (phone + tablet in one page).
/// Author: Mohamed Elrashidy
/// refactored at: 11/11/2024
import 'package:demo_app/features/settings/core_widgets/main_widget/shared_action_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_appbar_mobile.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/custom/37-custom_navigate.dart';
import 'package:demo_app/features/settings/presentation/controller/request_controller.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/personal_information_fields.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/edit_page_request.dart';

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
                        customButtonWithImage(
                          title: 'Request to Change'.tr,
                          function: () {
                            hapticController.triggerHapticFeedback(
                                vibration: VibrateType.mediumImpact,
                                hapticFeedback: HapticFeedback.mediumImpact);
                            navigateTo(context, EditPageRequest());
                          },
                          color: AppColors.primary,
                          width: 300.w,
                          height: 36.h,
                          textStyle: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.textButton),
                          image: 'assets/request_chnage.svg',
                          radius: 4.r,
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
                  customButtonWithImage(
                    title: 'Request to Change'.tr,
                    function: () {
                      hapticController.triggerHapticFeedback(
                          vibration: VibrateType.heavyImpact,
                          hapticFeedback: HapticFeedback.heavyImpact);
                      navigateTo(context, EditPageRequest());
                    },
                    color: AppColors.primary,
                    width: 300.w,
                    height: 36.h,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton),
                    image: 'assets/request_chnage.svg',
                    radius: 4.r,
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
