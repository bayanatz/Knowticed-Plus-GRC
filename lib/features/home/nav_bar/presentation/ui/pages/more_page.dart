import 'package:demo_app/features/onboarding/authentication/presentation/ui/pages/mobile_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/constants/image_paths.dart';
import 'package:demo_app/features/settings/mode_changer.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_appbar_mobile.dart';
import 'package:demo_app/features/home/core_widgets/dialogs/custom_logout_dialog.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/mobile_sign_in.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/home/nav_bar/presentation/controller/nav_bar_controller.dart';
import 'package:demo_app/core/nav_bar_package.dart/functions.dart';

import 'package:demo_app/features/home/core_widgets/main_widget/timeline_widget.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    NavBarController navBarController = Get.find();
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
                            imagePath: "assets/images/newLogOut.json",
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
                              Mode.hr = false;
                              Mode.owner = false;
                              Navigator.of(context).pop();
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                withNavBar: false,
                                screen: const StartSignInMobile(),
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
                          child: SvgPicture.asset("assets/logout_new.svg",
                              color: AppColors.primary),
                        ),
                        SizedBox(width: 16.h),
                        Text(
                          'Sign Out'.tr,
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

                  ImagePaths.getImagePath(
                    context,
                    'back_icon',
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
