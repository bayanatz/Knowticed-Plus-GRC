/// Date Created :12/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Objectives: the sign-in page for every form factor.
///
/// Layout matches Knowticed's start_sign_in.dart one-for-one:
///   • portrait  (phone AND tablet) → hero image 0.3.h, headings, form,
///     centred copyright / version block.
///   • landscape (tablet + desktop) → split panel: hero image on the left,
///     headings + form centred on the right, language toggle top-right.
///
/// There is deliberately no separate phone layout — Knowticed drives both
/// phones and tablets from the same portrait branch, so a single
/// [_portraitLayout] is used here too.
///
/// Fields use the shared core CustomTextField (2-custom_textfield.dart), tuned
/// with Knowticed's field styling (8px radius, tinted prefix icon, 0.01.h
/// content padding) so the two apps render identically.

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/custom/date_time_in_arabic.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/custom/64_custom_response_dialog.dart';
import 'package:grc_module/core/helper/main_helper/functions.dart';
import 'package:grc_module/features/onboarding/o3_authentication/presentation/controller/biometrics_contoller.dart';
import 'package:grc_module/features/onboarding/o3_authentication/presentation/controller/login_controller.dart';
import 'package:grc_module/features/onboarding/o3_authentication/presentation/ui/widgets/forgot_password_dialog.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/main.dart';

/// Hero artwork shared by the portrait header and the landscape side panel —
/// the same file Knowticed uses.
const String kSignInHeroImage = 'assets/png_assets/loginPhoto.jpeg';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool canBiometrics = false;
  String appVersion = '';
  String buildNumber = '';

  late final LoginController loginController = Get.put(LoginController());
  final HapticController hapticController = Get.put(HapticController());

  @override
  void initState() {
    super.initState();
    _checkCanBiometrics();
    _getAppVersion();
  }

  Future<bool> _checkCanBiometrics() async {
    canBiometrics = await checkBiometrics();
    if (mounted) setState(() {});
    return canBiometrics;
  }

  Future<void> _getAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        appVersion = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        appVersion = '1.0.0';
        buildNumber = '1';
      });
    }
  }

  bool get _isArabic => Get.locale.toString().contains('ar');

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Knowticed branches on orientation only: phones and tablets held upright
    // get the identical stacked layout, everything else the split panel.
    return Scaffold(
      body: isPortrait ? _portraitLayout() : _landscapeLayout(),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Shared credential form
  // ───────────────────────────────────────────────────────────────────────

  /// Email + password + forgot-password + Sign In button.
  ///
  /// Mirrors Knowticed's `content` column: the children are centre-aligned so
  /// the 80%-width Sign In button sits in the middle of the form column.
  Widget _signInForm({required bool isPortrait}) {
    return GetBuilder<LoginController>(
      builder: (controller) => Column(
        children: [
          SizedBox(height: 0.046.h),
          // NOTE: both hints were hardcoded (not localised) in the two original
          // pages and are kept that way here. There is an `enterYourEmail` l10n
          // key but no `enterYourPassword`, so localising just one would be
          // inconsistent — add the missing key to the .arb files to do both.
          _field(
            controller: controller.emailcontroller,
            hint: 'Enter Your Email',
            asset: 'assets/icons_assets/main_icons_assets/mail-inbox-app.svg',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 0.018.h),
          SizedBox(
            height: isPortrait ? 0.068.h : null,
            child: _field(
              controller: controller.passcontroller,
              hint: 'Enter Your Password',
              asset:'assets/icons_assets/main_icons_assets/password-protection.svg',

              obscureText: true, // renders the built-in eye toggle
              onTap: () => hapticController.triggerHapticFeedback(
                  vibration: VibrateType.lightImpact,
                  hapticFeedback: HapticFeedback.lightImpact),
            ),
          ),
          SizedBox(height: 0.015.h),
          // "Forgot Password?" sits right-aligned under the password field.
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _onForgotPasswordPressed,
                child: Text(
                  S.of(context).forgotPassword,
                  style: StyleText.fontSize14Weight400.copyWith(
                    fontSize: FontConstants.fontSize018.h,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.021.h),
          ElevatedButton(
            onPressed: _onSignInPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              fixedSize: Size(0.8.w, 0.070.h),
            ),
            child: Text(
              S.of(context).signIn,
              style: StyleText.fontSize20Weight500.copyWith(
                fontSize: FontConstants.fontSize026.h,
                fontWeight: FontWeight.w600,
                color: AppColors.textButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Core CustomTextField tuned to Knowticed's CustomField appearance:
  /// 8px radius, 0.01.h vertical padding, prefix icon tinted with
  /// [AppColors.lightPrimary] at 0.025.h, card fill.
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required String asset,
    TextInputType? keyboardType,
    bool obscureText = false,
    VoidCallback? onTap,
  }) {
    return CustomTextField(
      height: 36,
      controller: controller,
      hint: hint,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onTap: onTap,
      fillColor: AppColors.card,
      borderRadius: BorderRadius.circular(8.0),

      valueStyle: StyleText.fontSize14Weight400
          .copyWith(color: AppColors.secondaryText),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText),
      prefixIcon: CustomSvgImage(
        assetPath: asset,
        width: 0.020.h,
        height: 0.020.h,
        fit: BoxFit.scaleDown,
        color: AppColors.primary,
      ),
    );
  }

  void _onForgotPasswordPressed() {
    hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact);
    showDialog(
      context: context,
      builder: (_) => const ForgotPasswordDialog(),
    );
  }

  Future<void> _onSignInPressed() async {
    hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact);

    // Email is normalised to lower case so sign-in is case-insensitive.
    final String email =
        loginController.emailcontroller.text.trim().toLowerCase();
    final String password = loginController.passcontroller.text;

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => ResponseDialog(
          title: S.of(context).missingInformation,
          subtitle: S.of(context).pleaseEnterBothEmailAndPasswordToSignIn,
          lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
        ),
      );
      return;
    }

    if (await checkInternet()) {
      loginController.login(context, email, password);
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => ResponseDialog(
          title: S.of(context).error,
          subtitle: S.of(context).pleaseCheckYourInternetConnection,
          lottieAsset: "assets/lottie_assets/main_lottie_assets/internet.json",
        ),
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // Shared chrome
  // ───────────────────────────────────────────────────────────────────────

  Widget _logo({required double width, required double height}) => SizedBox(
        width: width,
        height: height,
        child: storage.read('logo') == null
            ? SvgPicture.asset(
                'assets/icons_assets/main_icons_assets/knowticed_logo.svg',
                fit: BoxFit.fill,
              )
            : SvgPicture.network(storage.read('logo'), fit: BoxFit.fill),
      );

  /// Title + tagline. The tagline steps down from semi-bold 22 (landscape) to
  /// regular 23 (portrait), exactly as Knowticed does.
  Widget _headings({required bool isPortrait}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).demoAppPlus,
            style: StyleText.fontSize36Weight500
                .copyWith(color: AppColors.text),
          ),
          SizedBox(height: isPortrait ? 8 : 10.h),
          Text(
            S.of(context).navigateTheDigitalFrontierWithEase,
            style: (isPortrait
                    ? StyleText.fontSize24Weight600
                    : StyleText.fontSize22Weight700)
                .copyWith(color: AppColors.text),
          ),
        ],
      );

  Widget _copyright() => Text(
        '${S.of(context).copyright}© ${DateTime.now().year} Knowticed. ${S.of(context).allRIGHTSRESERVED}',
        style: StyleText.fontSize14Weight400.copyWith(
          fontSize: FontConstants.fontSize018.h,
          color: AppColors.text,
        ),
        textAlign: TextAlign.center,
      );

  Widget _versionLabel() => Text(
        appVersion.isEmpty
            ? '${S.of(context).version} ...'
            : '${S.of(context).version} ${localizeNumber(appVersion)}',
        style: StyleText.fontSize14Weight400.copyWith(
          fontSize: FontConstants.fontSize018.h,
          color: AppColors.text,
        ),
        textAlign: TextAlign.center,
      );

  /// Landscape-only locale toggle.
  Widget _languageToggle() => GestureDetector(
        onTap: () {
          final box = GetStorage();
          final String? localeData = box.read<String>('LocaleData');
          final Locale locale = localeData.toString().contains('ar')
              ? const Locale('en', 'US')
              : const Locale('ar', 'EG');
          Get.updateLocale(locale);
          box.write('LocaleData', locale.toString());
          hapticController.triggerHapticFeedback(
              vibration: VibrateType.heavyImpact,
              hapticFeedback: HapticFeedback.heavyImpact);
        },
        child: Text(
          Get.locale.toString().contains('en') ? 'العربية' : 'English',
          style: StyleText.fontSize20Weight500.copyWith(
            fontSize: FontConstants.fontSize020.h,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      );

  // ───────────────────────────────────────────────────────────────────────
  // Portrait — phone and tablet
  // ───────────────────────────────────────────────────────────────────────

  Widget _portraitLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                kSignInHeroImage,
                width: double.infinity,
                fit: BoxFit.cover,
                height: 0.3.h,
              ),
              Positioned(
                top: 0.04.h,
                left: _isArabic ? 0.89.w : 0.030.w,
                child: _logo(
                  width: .06.h,
                  height: storage.read('logo') == null ? .05.h : .06.h,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.04.w),
            child: _headings(isPortrait: true),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.06.w),
            child: _signInForm(isPortrait: true),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.17.h),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _copyright(),
                  SizedBox(height: 0.02.h),
                  _versionLabel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Landscape — tablet and desktop
  // ───────────────────────────────────────────────────────────────────────

  Widget _landscapeLayout() {
    final bool isKeyboardVisible =
        MediaQuery.of(context).viewInsets.bottom != 0;
    final bool isMobilePlatform = Platform.isAndroid || Platform.isIOS;

    return Stack(
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2.6,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(kSignInHeroImage),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                    child: Container(color: Colors.transparent),
                  ),
                  Container(color: Colors.white.withOpacity(0.19)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.background,
                height: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.07.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _headings(isPortrait: false),
                          _signInForm(isPortrait: false),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0.070.h,
          left: _isArabic ? 0.9.w : 0.030.w,
          child: _logo(
            width: .095.h,
            height: storage.read('logo') == null ? .07.h : .095.h,
          ),
        ),
        if (!isKeyboardVisible)
          Positioned(
            bottom: 0.070.h,
            right: isMobilePlatform
                ? (_isArabic ? 0.55.w : 0.19.w)
                : (_isArabic ? 0.55.w : 0.185.w),
            child: _copyright(),
          ),
        if (!isKeyboardVisible)
          Positioned(
            bottom: 0.030.h,
            right: _isArabic ? 0.65.w : 0.28.w,
            child: _versionLabel(),
          ),
        Positioned(
          top: 0.070.h,
          right: _isArabic ? null : 0.020.w,
          left: _isArabic ? 0.020.w : null,
          child: _languageToggle(),
        ),
      ],
    );
  }
}
