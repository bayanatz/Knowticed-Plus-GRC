///*************************** FILE INFO **********************************///
/// Purpose: Responsive screen that displays the additional info documents and
/// images (phone + tablet in one page).
/// Author: Mohamed Elrashidy
/// Refactored At: 13/11/2024
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/settings/mode_changer.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_appbar_mobile.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/request_escalate_dialog.dart';
import 'package:demo_app/features/settings/presentation/controller/request_controller.dart';
import 'package:demo_app/features/settings/presentation/controller/settings_controller.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/additional_info_content.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/request_to_change_dialog_mobile.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/settings_header.dart';

class SettingsAdditionalInfo extends StatefulWidget {
  const SettingsAdditionalInfo({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsAdditionalInfoState createState() => _SettingsAdditionalInfoState();
}

class _SettingsAdditionalInfoState extends State<SettingsAdditionalInfo> {
  int selectedContainerIndex = 0;
  bool isEnglish = Get.locale.toString().contains('en');
  SettingsController settingsController = Get.find();
  final HapticController hapticController = Get.put(HapticController());

  @override
  Widget build(BuildContext context) {
    return ContextExtension(context).isPhone
        ? _buildPhone(context)
        : _buildTablet(context);
  }

  /// Phone design (formerly mobile_settings_additional_info.dart)
  Widget _buildPhone(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBarMobile(
            showIcon: true,
            showMoreIcon: false,
            title: "Additional Information",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 0.04.w, vertical: 0.0.w),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0.0.w, vertical: 0.0.h),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 0.04.w, vertical: 0.01.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(bottom: 0.02.h, top: 0.01.h),
                              child: SettingsHeader(
                                imagePath: 'assets/icons_assets/main_icons_assets/newAddInfo.svg',
                                text: 'Additional Information'.tr,
                              ),
                            ),
                            AdditionalInfoContent()
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.02.h),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.signOut,
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.007.h,
                                    horizontal: isPortrait ? 0.22.w : 0.155.w),
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
                                      imageUrl: "assets/icons_assets/main_icons_assets/reqToChange.svg",
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
                                    color: AppColors.textButton),
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

  /// Tablet design (formerly tablet_settings_additional_info.dart)
  Widget _buildTablet(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return GetBuilder<RequestController>(
        init: Get.find<RequestController>(),
        builder: (requestController) {
          return Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: isPortrait
                        ? Mode.owner
                            ? 0.678.h
                            : 0.62.h
                        : 0.54.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.02.w, vertical: 0.01.w),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(bottom: 0.02.h, top: 0.01.h),
                              child: SettingsHeader(
                                imagePath: 'assets/icons_assets/main_icons_assets/newAddInfo.svg',
                                text: 'Additional Information'.tr,
                              ),
                            ),
                            AdditionalInfoContent()
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: Get.locale.toString().contains('ar')
                        ? (isPortrait
                            ? EdgeInsets.only(
                                top: 0.015.w,
                                bottom: 0.0.h,
                              )
                            : EdgeInsets.only(
                                top: 0.025.h,
                                bottom: 0.0.w,
                              ))
                        : EdgeInsets.only(
                            top: isPortrait ? 0.02.w : 0.025.h,
                            bottom: isPortrait ? 0.0 : 0.0.h,
                          ),
                    child: Container(
                      width: isPortrait ? double.infinity : null,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.signOut,
                          padding: EdgeInsets.symmetric(
                            vertical: isPortrait ? 0.01.h : 0.015.h,
                            horizontal: isPortrait ? 0 : 0.155.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return RequestExcalateDialog(
                                  isSetting: true,
                                  title: "Request to Change",
                                  imageUrl: "assets/icons_assets/main_icons_assets/reqToChange.svg",
                                  isExclate: false,
                                  onPressed: () {});
                            },
                          );
                        },
                        child: Text(
                          'Request to Change'.tr,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: isPortrait
                                ? FontConstants.fontSize020.h
                                : FontConstants.fontSize025.h,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
