import 'dart:io';
import 'dart:ui';

import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:demo_app/features/onboarding/authentication/presentation/ui/pages/custom_textfield.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';
import 'package:demo_app/features/onboarding/helper/functions.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/onboarding/widgets/dialogs/forgot_pass_dialog.dart';
import 'package:demo_app/features/onboarding/core_widgets/dialogs/response_dialog.dart';
import 'package:demo_app/core/helper/employees/biometrics_contoller.dart';
import 'package:demo_app/features/onboarding/authentication/welcome_screen/views/start_sign_up.dart';
import 'package:demo_app/features/onboarding/authentication/presentation/controller/login_controller.dart';
import 'package:demo_app/features/roles/role_management/controller/role_controller.dart';
import 'package:demo_app/main.dart';

// REMOVED_MODULE: import '../../../features/external/services_mangment_module/core/new_theme.dart';

final GlobalKey<FormState> _formKeyEmail = GlobalKey<FormState>();
final GlobalKey<FormState> _formKeyPassword = GlobalKey<FormState>();

/// Date Created :12/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :22/November/2023
/// Updated: 25/1/2025 - Added case-insensitive email handling
/// Objectives: this screen is the login page located at the beginning of the application

class StartSignIn extends StatefulWidget {
  StartSignIn({this.isLogout = false, super.key});
  bool isLogout;
  @override
  State<StartSignIn> createState() => _StartSignInState();
}

class _StartSignInState extends State<StartSignIn> {
  bool isHrChecked = false;
  bool isOwnerChecked = false;
  bool isSignIn = true;
  double companyInformation = 0;
  double companyService = 0;
  double contactInformation = 0;
  double confirmations = 0;
  bool canBiometrics = false;
  String appVersion = '';

  Future<bool> checkCanBiometrics() async {
    print('check biometrics callled');
    canBiometrics = await checkBiometrics();
    setState(() {});
    return canBiometrics;
  }

  Future<void> _loadAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = packageInfo.version;
      });
    } catch (e) {
      setState(() {
        appVersion = 'Unknown';
      });
    }
  }

  @override
  void initState() {
    print('🎨 StartSignIn: init state called, isLogout: ${widget.isLogout}');

    // Don't reload theme on logout - it's already loaded!
    if (!widget.isLogout) {
      checkCanBiometrics();
    }

    _loadAppVersion();

    // Remove any duplicate drawer controller
    if (Get.isRegistered<DrawerController>()) {
      Get.delete<DrawerController>();
    }

    // Ensure theme UI is updated for this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<ThemeController>()) {
        Get.find<ThemeController>().updateSystemUIOverlayStyle();
      }
    });

    super.initState();
  }

  RoleController addRoleController = Get.put(RoleController());
  LoginController loginController = Get.put(LoginController());

  bool firstLogin = false;

  @override
  Widget build(BuildContext context) {
    print('🏗️ BUILD METHOD CALLED');
    print('🏗️ isSignIn: $isSignIn');
    print('🏗️ isPortrait: ${MediaQuery.of(context).orientation == Orientation.portrait}');

    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    print('🏗️ lightMode: $lightMode');
    print('🏗️ isKeyboardVisible: $isKeyboardVisible');

    print('storage ${storage.read('Biometric')}');
    final HapticController hapticController = Get.put(HapticController());

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    Widget content = Column(
      children: [
        GetBuilder<LoginController>(
          builder: (LoginController loginController) =>
              Column(
                children: [
                  SizedBox(height: 0.046.h),
                  Container(
                    height: isPortrait ? null : null,
                    decoration: BoxDecoration(),
                    child: CustomField(
                      imagePath: "assets/icons/sms.svg",
                      controller: loginController.emailcontroller,
                      validator: (value) {
                        return Validator.email(value);
                      },
                      showSuffix: false,
                      onTap: () {
                        // Add onTap function
                      },
                      hintText: 'Enter Your Email',
                      fillColor: AppColors.card,
                    ),
                  ),
                  SizedBox(height: 0.018.h),
                  Container(
                    height: isPortrait ? 0.068.h : null,
                    decoration: BoxDecoration(),
                    child: CustomField(
                      imagePath: "assets/icons/lock1.svg",
                      controller: loginController.passcontroller,
                      showSuffix: true,
                      onTap: () {
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.lightImpact,
                            hapticFeedback: HapticFeedback.lightImpact);
                      },
                      hintText: 'Enter Your Password',
                      fillColor: AppColors.card,
                    ),
                  ),
                ],
              ),
        ),
        SizedBox(height: 0.015.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                hapticController.triggerHapticFeedback(
                    vibration: VibrateType.mediumImpact,
                    hapticFeedback: HapticFeedback.mediumImpact);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ForgotPassDialog();
                  },
                );
              },
              child: Text(
                'Forgot Password?'.tr,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize018.h,
                  color: AppColors.text,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 0.021.h),
        ElevatedButton(
          onPressed: () async {
            hapticController.triggerHapticFeedback(
                vibration: VibrateType.mediumImpact,
                hapticFeedback: HapticFeedback.mediumImpact);

            // ✅ Trim and normalize email to lowercase for case-insensitive comparison
            String email = loginController.emailcontroller.text.trim().toLowerCase();
            String password = loginController.passcontroller.text;

            print("🔐 User entered email: ${loginController.emailcontroller.text}");
            print("🔐 Normalized email: $email");

            if (email.isEmpty || password.isEmpty) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ResponseDialog(
                      title: "Missing Information".tr,
                      subtitle: "Please enter both email and password to sign in".tr,
                      lottieAsset: "assets/images/error.json",
                    );
                  });
              return;
            }

            if (await checkInternet()) {
              loginController.login(context, email, password);
            } else {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ResponseDialog(
                      title: "Error".tr,
                      subtitle: "Please Check Your Internet Connection".tr,
                      lottieAsset: "assets/images/internet.json",
                    );
                  });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            fixedSize: Size(0.8.w, 0.070.h),
          ),
          child: Text(
            'Sign In'.tr,
            style: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: FontConstants.fontSize026.h,
              color: AppColors.textButton,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      body: isPortrait
          ? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(children: [
              Image.asset(
                'assets/images/sign_in_hori.png',
                width: double.infinity,
                fit: BoxFit.cover,
                height: 0.3.h,
              ),
              Positioned(
                top: 0.04.h,
                left: Get.locale.toString().contains('ar')
                    ? 0.89.w
                    : 0.030.w,
                child: SizedBox(
                  width: .06.h,
                  height: storage.read('logo') == null ? .05.h : .06.h,
                  child: storage.read('logo') == null
                      ? SvgPicture.asset(
                    'assets/images/demo_app_logo.svg',
                  )
                      : SvgPicture.network(
                    storage.read('logo'),
                    fit: BoxFit.fill,
                  ),
                ),
              )
            ]),
            isSignIn
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.04.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'demo_app Plus'.tr,
                    style: StyleText.fontSize24Weight600?.copyWith(
                      fontSize: 36.sp,
                        color: AppColors.text
                    ) ?? TextStyle(fontSize: 24, color: AppColors.text),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Navigate the Digital Frontier with Ease'.tr,
                    style: StyleText.fontSize24Weight600?.copyWith(
                        color: AppColors.text
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(),
            isSignIn
                ? Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 0.06.w, vertical: 0.0.h),
              child: content,
            )
                : SignUpView(
              isSignIn: isSignIn,
              compServiceState: (value) {
                setState(() {
                  companyService = value;
                });
              },
              compInfoState: (value) {
                setState(() {
                  companyInformation = value;
                });
              },
              isSignInState: (value) {
                setState(() {
                  isSignIn = value;
                });
              },
              companyInformation: companyInformation,
              companyService: companyService,
              confirmations: confirmations,
              confState: (value) {
                setState(() {
                  confirmations = value;
                });
              },
              contactInformation: contactInformation,
              conactInfoState: (value) {
                setState(() {
                  contactInformation = value;
                });
              },
            ),
            isSignIn
                ? Padding(
              padding: EdgeInsets.only(top: 0.17.h),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${'Copyright'.tr}© ${DateTime.now().year} demo_app. ${"ALL RIGHTS RESERVED".tr}',
                      style:
                      AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize018.h,
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 0.02.h,
                    ),
                    Text(
                      '${"Version:".tr} ${localizeNumber(appVersion.isNotEmpty ? appVersion : "Unknown")}',
                      style:
                      AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize018.h,
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : const SizedBox.shrink(),
          ],
        ),
      )
          : isSignIn
      // login desktop & tablet
          ? Stack(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 2.6,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image:
                    AssetImage('assets/images/loginPhoto.jpeg'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: [
                    BackdropFilter(
                      filter:
                      ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                    Container(
                      color: Colors.white.withOpacity(
                          0.19),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                    color: AppColors.background,
                    width: MediaQuery.of(context).size.width / 1.7,
                    height: double.infinity,
                    child: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0.07.h),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'demo_app Plus'.tr,
                                            style: StyleText.fontSize24Weight600.copyWith(
                                              fontSize: 36.sp,
                                                color: AppColors.text
                                            )
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                            'Navigate the Digital Frontier with Ease'
                                                .tr,
                                            style: StyleText.fontSize22Weight700.copyWith(
                                                color: AppColors.text
                                            )
                                        ),
                                        content
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                        ))),
              ),
            ],
          ),
          isSignIn
              ? Positioned(
            top: 0.070.h,
            left: Get.locale.toString().contains('ar')
                ? 0.9.w
                : 0.030.w,
            child: SizedBox(
              width: .095.h,
              height:
              storage.read('logo') == null ? .07.h : .095.h,
              child: storage.read('logo') == null
                  ? SvgPicture.asset(
                'assets/images/demo_app_logo.svg',
              )
                  : SvgPicture.network(
                storage.read('logo'),
                fit: BoxFit.fill,
              ),
            ),
          )
              : const SizedBox.shrink(),
          isSignIn && !isKeyboardVisible
              ? Positioned(
            bottom: 0.070.h,
            right: (Platform.isAndroid || Platform.isIOS)
                ? Get.locale.toString().contains('ar')
                ? 0.55.w
                : 0.19.w
                : Get.locale.toString().contains('ar')
                ? 0.55.w
                : 0.185.w,
            child: Text(
              '${'Copyright'.tr}© ${DateTime.now().year} demo_app. ${"ALL RIGHTS RESERVED".tr}',
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize018.h,
                color: AppColors.text,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
              : const SizedBox.shrink(),
          isSignIn && !isKeyboardVisible
              ? Positioned(
            bottom: 0.030.h,
            right: Get.locale.toString().contains('ar')
                ? 0.65.w
                : 0.28.w,
            child: Text(
              '${"Version:".tr} ${localizeNumber(appVersion.isNotEmpty ? appVersion : "Unknown")}',
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize018.h,
                color: AppColors.text,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
              : const SizedBox.shrink(),
          isSignIn
              ? Positioned(
            top: 0.070.h,
            right: Get.locale.toString().contains('ar')
                ? null
                : 0.020.w,
            left: Get.locale.toString().contains('en')
                ? null
                : 0.020.w,
            child: GestureDetector(
              onTap: () {
                final box = GetStorage();
                String? localeData;
                localeData = box.read<String>('LocaleData');

                if (localeData.toString().contains('ar')) {
                  var locale = const Locale('en', 'US');
                  print(locale);
                  Get.updateLocale(locale);
                  box.write('LocaleData', locale.toString());
                } else {
                  var locale = const Locale('ar', 'EG');
                  Get.updateLocale(locale);
                  box.write('LocaleData', locale.toString());
                }
                hapticController.triggerHapticFeedback(
                    vibration: VibrateType.heavyImpact,
                    hapticFeedback: HapticFeedback.heavyImpact);
              },
              child: Text(
                Get.locale.toString().contains('en')
                    ? 'العربية'
                    : 'English',
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize020.h,
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
              : const SizedBox.shrink(),
        ],
      )
          : SignUpView(
        isSignIn: isSignIn,
        compServiceState: (value) {
          setState(() {
            companyService = value;
          });
        },
        compInfoState: (value) {
          setState(() {
            companyInformation = value;
          });
        },
        isSignInState: (value) {
          setState(() {
            isSignIn = value;
          });
        },
        companyInformation: companyInformation,
        companyService: companyService,
        confirmations: confirmations,
        confState: (value) {
          setState(() {
            confirmations = value;
          });
        },
        contactInformation: contactInformation,
        conactInfoState: (value) {
          setState(() {
            contactInformation = value;
          });
        },
      ),
    );
  }
}