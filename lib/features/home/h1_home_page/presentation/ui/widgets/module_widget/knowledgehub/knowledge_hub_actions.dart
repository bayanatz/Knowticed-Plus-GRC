import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';
import 'package:grc_module/features/home/main_controller/core_widgets/removed_module_placeholder.dart';

import 'package:grc_module/core/custom/37-custom_navigate.dart';
import 'package:grc_module/generated/l10n.dart';
// REMOVED_MODULE: import 'package:grc_module/features/knowledge_hub_module/knowledge_hub/presentation/ui/s1_create_new_knowledge/master_page/creating_knowledge_hub.dart';
// REMOVED_MODULE: import 'package:grc_module/features/knowledge_hub_module/knowledge_hub/presentation/ui/s8_dashboard/dashboard_screen.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
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
                S.of(context).knowledge_hub,
                style: AppTextStyles.font14BlackCairoMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SvgPicture.asset(
                'assets/icons_assets/roles_assets/knowledge_book_idea.svg',
                width: 20,
                height: 20,
                color: AppColors.primary,
              )
            ],
          ),
          SizedBox(height: 7.h),
          customButton(
              textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                  fontWeight: FontWeight.w500, color: AppColors.textButton),
              title: S.of(context).createHub,
              function: () {

                navigateTo(context, RemovedModulePage(moduleName: S.of(context).knowledge_hub));

              }),
          customButton(
              textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
                  fontWeight: FontWeight.w500, color: AppColors.textButton),
              title: S.of(context).viewDashboard,
              function: () {
                navigateTo(context, RemovedModulePage(moduleName: S.of(context).knowledge_hub));
              }),
          // customButton(
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
