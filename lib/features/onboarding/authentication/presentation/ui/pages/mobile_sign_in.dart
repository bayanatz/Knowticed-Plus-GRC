import 'dart:ui';

import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/onboarding/authentication/presentation/ui/pages/custom_textfield.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';
import 'package:demo_app/features/onboarding/helper/functions.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/onboarding/core_widgets/buttons/main_custom_button.dart';
import 'package:demo_app/features/onboarding/widgets/dialogs/forgot_pass_dialog.dart';
import 'package:demo_app/features/onboarding/core_widgets/dialogs/response_dialog.dart';
import 'package:demo_app/core/helper/employees/biometrics_contoller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/onboarding/authentication/presentation/controller/login_controller.dart';
import 'package:demo_app/features/roles/role_management/controller/role_controller.dart';
import 'package:demo_app/main.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Date Created :12/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :19/Feb/2024
/// Objectives: this screen is the login page located at the beginning of the application

class StartSignInMobile extends StatefulWidget {
  const StartSignInMobile({super.key});

  @override
  State<StartSignInMobile> createState() => _StartSignInMobileState();
}

class _StartSignInMobileState extends State<StartSignInMobile> {
  bool isHrChecked = false;
  bool isOwnerChecked = false;
  bool isSignIn = true;
  double companyInformation = 0;
  double companyService = 0;
  double contactInformation = 0;
  double confirmations = 0;
  bool canBiometrics = false;
  String appVersion = '';
  String buildNumber = '';

  Future<bool> checkCanBiometrics() async {
    canBiometrics = await checkBiometrics();
    setState(() {});
    return canBiometrics;
  }

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      print('Error getting app version: $e');
      setState(() {
        appVersion = '1.0.0';
        buildNumber = '1';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkCanBiometrics();
    _getAppVersion();
  }

  RoleController addRoleController = Get.put(RoleController());
  LoginController loginController = Get.put(LoginController());
  bool firstLogin = false;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    final HapticController hapticController = Get.put(HapticController());
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    print('storage ${storage.read('Biometric')}');

    return Scaffold(
        body: GetBuilder<LoginController>(
          builder: (controller) {
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Wrap the image container in a Visibility widget
                    Visibility(
                      visible: !isKeyboardVisible, // Show image when keyboard is not visible
                      child: Container(
                        width: double.infinity,
                        height: 0.35.h,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/mobileSignIn.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Stack(
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                              child: Container(color: Colors.transparent),
                            ),
                            Container(
                              color: Colors.white.withOpacity(0.19),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isKeyboardVisible)
                      SizedBox(
                        height: 0.12.h,
                      ),
                    Expanded(
                      child: Container(
                          color: AppColors.card,
                          height: double.infinity,
                          child: SingleChildScrollView(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 0.07.h : 0.04.w
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 0.01.h),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'demo_app Plus'.tr,
                                              style: StyleText.fontSize20Weight600.copyWith(
                                                  color: AppColors.text
                                              )
                                          ),
                                          SizedBox(height: 10.sp),
                                          Text(
                                              'Navigate the Digital Frontier with Ease'.tr,
                                              style: StyleText.fontSize18Weight500.copyWith(
                                                  color: AppColors.text
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          child: CustomField(
                                            imagePath: "assets/icons/sms.svg",
                                            controller: controller.emailcontroller,
                                            validator: (value) {
                                              return Validator.email(value);
                                            },
                                            showSuffix: false,
                                            onTap: () {
                                              // Add onTap function
                                            },
                                            hintText: 'Enter Your Email',
                                          ),
                                        ),
                                        SizedBox(height: 0.018.h),
                                        Container(
                                          height: 0.068.h,
                                          decoration: BoxDecoration(

                                          ),
                                          child: CustomField(
                                            imagePath: "assets/icons/lock1.svg",
                                            controller: controller.passcontroller,
                                            showSuffix: true,
                                            onTap: () {
                                              hapticController.triggerHapticFeedback(
                                                  vibration: VibrateType.lightImpact,
                                                  hapticFeedback: HapticFeedback.lightImpact
                                              );
                                            },
                                            hintText: 'Enter Your Password',
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 0.015.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            hapticController.triggerHapticFeedback(
                                                vibration: VibrateType.mediumImpact,
                                                hapticFeedback: HapticFeedback.mediumImpact
                                            );
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ForgotPassDialog();
                                              },
                                            );
                                          },
                                          child: Text(
                                            'Forgot Password?'.tr,
                                            style: StyleText.fontSize14Weight500.copyWith(
                                              color: AppColors.secondaryPrimary
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 0.021.h),
                                    MainCustomButton(
                                      buttonText: 'Sign In'.tr,
                                      textStyle: StyleText.fontSize20Weight500.copyWith(
                                          color: AppColors.textButton
                                      ),
                                      onPressed: () async {
                                        hapticController.triggerHapticFeedback(
                                          vibration: VibrateType.mediumImpact,
                                          hapticFeedback: HapticFeedback.mediumImpact,
                                        );
                                        if (await checkInternet()) {
                                          loginController.login(
                                              context,
                                              loginController.emailcontroller.text.trim(),
                                              loginController.passcontroller.text
                                          );
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return ResponseDialog(
                                                  title: "Error".tr,
                                                  subtitle: "Please Check Your Internet Connection".tr,
                                                  lottieAsset: "assets/images/internet.json",
                                                );
                                              }
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                )
                            ),
                          )
                      ),
                    ),
                  ],
                ),
                if (isSignIn)
                  Positioned(
                    top: 0.070.h,
                    left: Get.locale.toString().contains('ar') ? 0.8.w : 0.030.w,
                    child: SizedBox(
                      width: .08.h,
                      height: storage.read('logo') == null ? .06.h : 0.08.h,
                      child: storage.read('logo') == null
                          ? SvgPicture.asset(
                        'assets/images/demo_app_logo.svg',
                        fit: BoxFit.fill,
                      )
                          : SvgPicture.network(
                        storage.read('logo'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                if (isSignIn && !isKeyboardVisible)
                  Positioned(
                    bottom: 0.070.h,
                    left: Get.locale.toString().contains('ar') ? 0 : 0,
                    right: Get.locale.toString().contains('ar') ? 0 : 0,
                    child: Center(
                      child: Text(
                          '${'Copyright'.tr}© ${DateTime.now().year} demo_app. ${"ALL RIGHTS RESERVED".tr}',
                          style: StyleText.fontSize14Weight500.copyWith(
                              color: AppColors.text
                          )
                      ),
                    ),
                  ),
                if (isSignIn && !isKeyboardVisible)
                  Positioned(
                    bottom: 0.040.h,
                    left: Get.locale.toString().contains('ar') ? 0 : 0,
                    right: Get.locale.toString().contains('ar') ? 0 : 0,
                    child: Center(
                      child: Text(
                          appVersion.isEmpty
                              ? '${"Version:".tr} ...'
                              : '${"Version:".tr} ${localizeNumber(appVersion)}',
                          style: StyleText.fontSize12Weight500.copyWith(
                              color: AppColors.text
                          )
                      ),
                    ),
                  ),
              ],
            );
          },
        )
    );
  }
}