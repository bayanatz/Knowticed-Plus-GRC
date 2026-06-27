// ==================== FILE 1: services_actions.dart ====================
// REMOVED_MODULE: import 'package:demo_app/features/services_mangment_module/presentation/s4_bulk_upload_services/ui/pages/create_new_services_toggle.dart';
// REMOVED_MODULE: import 'package:demo_app/features/services_mangment_module/presentation/s6_services_requests/ui/pages/my_request_toggle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_icon_button.dart';
import 'package:demo_app/features/home/widgets/standard_container.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/custom/37-custom_navigate.dart';
import 'package:demo_app/features/home/data/models/home_component_model.dart';
import 'package:demo_app/features/home/core_widgets/removed_module_placeholder.dart';

import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

class ServicesActions extends StatelessWidget {
  ServicesActions({super.key, required this.model});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light ;
    var isMobile = context.isPhone;
    return Container(
      height: isMobile ? 115.h : 130.h,
      child: StandardContainer(
        child: SizedBox(
          width: 140.sp,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 7.sp,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Services'.tr,
                      style: isMobile ? StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.text
                      ) : AppTextStyles.font14BlackCairoMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SvgPicture.asset(
                      'assets/skeleton/home/icons/service.svg',
                      width: isMobile ? 12.w : 20.w ,
                      height: isMobile ? 12.h : 20.h ,
                      fit: BoxFit.scaleDown,
                      color: AppColors.primary,
                    )
                  ],
                ),


                SizedBox(height: 2.sp),
                CustomButton(
                  height: 25.h,
                  textStyle: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.textButton
                  ),
                  buttonText: 'Create Service'.tr,
                  onTap: () {
                    navigateTo(context, RemovedModulePage(moduleName: 'Services'.tr));
                  },
                ),

                Column(
                  children: [
                    CustomButton(
                      height: 25.h,
                      textStyle: StyleText.fontSize14Weight400.copyWith(
                          color: AppColors.textButton
                      ),
                      buttonText: 'My Requests'.tr,
                      onTap: () {
                        // Navigate to My Requests page (Admin view)
                        navigateTo(context, RemovedModulePage(moduleName: 'Services'.tr));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}