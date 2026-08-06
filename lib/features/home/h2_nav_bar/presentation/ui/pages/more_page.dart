import 'package:grc_module/features/home/main_controller/core_widgets/dialogs/custom_logout_dialog.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'package:grc_module/features/onboarding/o3_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';


import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/home/main_controller/core_widgets/main_widget/custom_appbar_mobile.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/mobile_view/mobile_sign_in.dart';
import 'package:grc_module/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:grc_module/features/home/h2_nav_bar/utils/functions.dart';


import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';

import '../../../../../../core/custom/33-custom_haptic.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
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
                  if (module != Modules.settings) // Adjust the enum name if different
                    moduleWidget(module, context),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                  margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.card
                  ),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomLogOutDialogBox(
                            title: "Sign Out",
                            subtitle: "Are You Sure You Want To Sign Out?",
                            imagePath: "assets/lottie_assets/home_lottie_assets/newLogOut.json",
                            backgroundColor: AppColors.signOut,
                            showButtons: true,
                            buttonText: 'Yes',
                            buttoncolor: AppColors.text,
                            buttonFontColor: AppColors.textButton,
                            onConfirm: () {
                              hapticController.triggerHapticFeedback(
                                  vibration: VibrateType.heavyImpact,
                                  hapticFeedback: HapticFeedback.heavyImpact);
                              print("yes");
                              // AppDrawerCubit.isHr = false;
                              // AppDrawerCubit.isOwner = false;
                              Navigator.of(context).pop();
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                withNavBar: false,
                                screen: const SignInScreen(),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.lightPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 10.h),
                          child: SvgPicture.asset("assets/icons_assets/home_assets/logout_arrow.svg",
                              color: AppColors.primary),
                        ),
                        SizedBox(width: 16.h),
                        Text(
                          S.of(context).signOut,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize020.h,
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
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
      margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.card
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => module.widget));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.15),
                  borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: SvgPicture.asset(module.iconPath,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.primary),
            ),
            SizedBox(width: 16.h),
            Text(
              module.getModuleName,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize020.h,
                color: AppColors.text,
                fontWeight: FontWeight.w400,
              ),
            ),
            Spacer(),
            Transform.rotate(
              angle: Get.locale.toString().contains('en') ? 3.13 : 0,
              child: Transform.scale(
                scale: 1.3,
                child: SvgPicture.asset(
                  color: AppColors.text,

                  themeController.currentTheme == AppColors.darkTheme
                      ? 'assets/icons_assets/main_icons_assets/arrow_back_curved.svg'
                      : 'assets/icons_assets/main_icons_assets/arrow_back_curved.svg',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
