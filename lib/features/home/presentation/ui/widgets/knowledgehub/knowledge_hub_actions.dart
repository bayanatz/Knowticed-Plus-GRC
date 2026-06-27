import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/widgets/standard_container.dart';
import 'package:demo_app/features/home/data/models/home_component_model.dart';
import 'package:demo_app/features/home/core_widgets/removed_module_placeholder.dart';

import '../../../../../../core/custom/37-custom_navigate.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';
import '../../../../../../generated/l10n.dart';
// REMOVED_MODULE: import '../../../../../knowledge_hub_module/knowledge_hub/presentation/ui/s1_create_new_knowledge/master_page/creating_knowledge_hub.dart';
// REMOVED_MODULE: import '../../../../../knowledge_hub_module/knowledge_hub/presentation/ui/s8_dashboard/dashboard_screen.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

class KnowledgeHubActions extends StatelessWidget {
  KnowledgeHubActions({super.key, required this.model});
  HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    return StandardContainer(
        child: SizedBox(
      width: 140.sp,
      child: Column(
        spacing: 5.sp,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Knowledge Hub'.tr,
                style: AppTextStyles.font14BlackCairoMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SvgPicture.asset(
                'assets/skeleton/home/icons/knowledge_hub.svg',
                width: 20,
                height: 20,
                color: AppColors.primary,
              )
            ],
          ),
          SizedBox(height: 7.h),
          CustomButton(
              textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                  fontWeight: FontWeight.w500, color: AppColors.textButton),
              buttonText: S.of(context).createHub,
              onTap: () {

                navigateTo(context, RemovedModulePage(moduleName: 'Knowledge Hub'.tr));

              }),
          CustomButton(
              textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                  fontWeight: FontWeight.w500, color: AppColors.textButton),
              buttonText: 'View Dashboard'.tr,
              onTap: () {
                navigateTo(context, RemovedModulePage(moduleName: 'Knowledge Hub'.tr));
              }),
          // CustomButton(
          //     textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
          //         fontWeight: FontWeight.w500, color: AppColors.textButton),
          //     buttonText: 'View Approval'.tr,
          //     onTap: () {
          //
          //       navigateTo(context, ApprovalsScreen());
          //     }),
        ],
      ),
    ));
  }
}
