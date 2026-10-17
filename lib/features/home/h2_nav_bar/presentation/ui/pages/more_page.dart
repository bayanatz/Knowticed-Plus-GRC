/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: more_page.dart
/// Purpose: Declares `MorePage`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - DEBUG-ONLY "🧪 Switch to test employee" row above
///          Sign Out (compile-time `kDebugTestEmployeeSwitchBuild`).
library;

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:grc_module/core/custom/helpers/preview.dart';
import 'package:grc_module/features/onboarding/o3_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/custom/navigation/custom_appbar_mobile.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/mobile_view/mobile_sign_in.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:grc_module/features/home/h2_nav_bar/persistent_nav_bar.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/helper/access/modules_enum.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/core/custom/helpers/custom_haptic.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
// ADDED 9/10/2026 — DEBUG-ONLY "Switch to test employee" row.
import 'package:grc_module/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart';
import 'package:grc_module/features/onboarding/o3_authentication/presentation/ui/widgets/debug_test_employee_widgets.dart';
import 'package:grc_module/core/theme/app_animations.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context).brightness == Brightness.light;
    NavBarCubit navBarController = Get.find();
    return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
            child: Column(
          children: [
            const CustomAppBarMobile(
                showIcon: false,
                isHome: true,
                showMoreIcon: true,
                showNotification: true),
            SizedBox(height: 16.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (Modules module in navBarController.moreListModules)
                      if (module !=
                          Modules.settings) // Adjust the enum name if different
                        moduleWidget(module, context),
                    // ADDED 9/10/2026 — DEBUG-ONLY "🧪 Switch to test employee"
                    // (signs out, then opens the test-employee picker).
                    // Compile-time constant: absent from release/profile builds.
                    if (kDebugTestEmployeeSwitchBuild)
                      const DebugSwitchToTestEmployeeTile(),
                    // DEBUG-ONLY 17/10/2026: opens the page that draws every
                    // shared custom widget, so the owner can review them.
                    if (kDebugTestEmployeeSwitchBuild)
                      ListTile(
                        leading: const Icon(Icons.widgets_outlined),
                        title: const Text('🧪 Customs preview'),
                        onTap: withHaptic(
                            () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const PreviewAllCustomPage(),
                                  ),
                                ),
                            HapticLevel.low),
                      ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                      margin:
                          EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.card),
                      child: InkWell(
                        splashColor: AppColors.transparent,
                        // MIGRATED 22/8/2026: was `CustomLogOutDialogBox`, the
                        // one-off dialog widget in core/custom. It duplicated
                        // CustomDialogManager, ignored the title/subtitle it was
                        // given in favour of its own hardcoded English pair, and
                        // took a non-localized `buttonText` — which is why the
                        // confirm button read "Yes" in the middle of an Arabic
                        // screen. The widget's file is deleted; this and the
                        // desktop drawer share the manager now.
                        onTap: () => CustomDialogManager.showDialogFlow(
                          context: context,
                          confirmLottie:
                              'assets/lottie_assets/main_lottie_assets/lot_action_logout.json',
                          confirmTitle: S.of(context).logout,
                          confirmSubtitle: S.of(context).confirmLogout,
                          confirmYesText: S.of(context).yes,
                          confirmNoText: S.of(context).Cancel,
                          onConfirm: () async {
                            hapticController.triggerHapticFeedback(
                                vibration: VibrateType.heavyImpact,
                                hapticFeedback: HapticFeedback.heavyImpact);
                            return true;
                          },
                          // Matches the drawer: no success dialog after logout.
                          showSuccessDialog: false,
                          successLottie:
                              'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
                          successTitle: S.of(context).logout,
                          successSubtitle: S.of(context).signedOutSuccessfully,
                          // After the success dialog closes, not underneath it.
                          onSuccessComplete: () {
                            if (!context.mounted) return;
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              withNavBar: false,
                              screen: const SignInScreen(),
                            );
                          },
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.lightPrimary
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8.r)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 10.h),
                              child: CustomSvgImage.natural(
                                  assetPath:
                                      "assets/icons_assets/home_assets/ic_action_logout.svg",
                                  color: AppColors.primary),
                            ),
                            SizedBox(width: 16.h),
                            Text(
                              S.of(context).signOut,
                              style: StyleText.fontSize16Weight400.copyWith(
                                fontSize: 16.sp,
                                color: AppColors.text,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        )));
  }

  Widget moduleWidget(Modules module, BuildContext context) {
    Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
      margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: AppColors.card),
      child: InkWell(
        splashColor: AppColors.transparent,
        onTapDown: (_) => HapticController.low(),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => module.widget));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: CustomSvgImage.natural(
                  assetPath: module.iconPath,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.primary),
            ),
            SizedBox(width: 16.h),
            Text(
              module.getModuleName,
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 16.sp,
                color: AppColors.text,
                fontWeight: FontWeight.w400,
              ),
            ),
            Spacer(),
            Transform.rotate(
              angle: context.isEnglish ? 3.13 : 0,
              child: Transform.scale(
                scale: 1,
                child: CustomSvgImage.natural(
                  // One arrow for both themes: rotated it points right (›) in
                  // English and left in Arabic (light mode used to point left).
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg',
                  color: AppColors.text,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
