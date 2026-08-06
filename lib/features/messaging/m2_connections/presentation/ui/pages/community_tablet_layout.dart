/// Module: messaging / connections / presentation/ui/pages/community_tablet_layout.dart
/// ************************* FILE INFO *************************** ///
/// File Name: community_tablet_layout.dart
/// Purpose: Community tablet layout — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// By: Youssef Ashraf
// Date: 16/9/2024
// Objectives: This file is responsible for providing the home tablet layout used in the messaging feature.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:grc_module/core/custom/35-custom_search_widget_custom.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:grc_module/features/messaging/m3_groups/presentation/ui/pages/tablet/create_group_page_tablet.dart';
import 'package:grc_module/features/messaging/m4_messaging_home/domain/enums/sort_enum.dart';
import 'package:grc_module/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';
import 'package:grc_module/features/messaging/m2_connections/presentation/ui/widgets/layouts/tablet_body.dart';
import 'package:grc_module/core/enums/message_module/permissions/messages_permissions.dart';
import 'package:grc_module/core/enums/message_module/permissions/messages_permissions_sections.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';

import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/helper/main_helper/spacing_helper.dart';
import 'package:grc_module/core/constants/message_module/app_assets.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/custom/47_custom_sort_button.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';



class HomeTabletLayout extends StatelessWidget {
  const HomeTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {

    var isMobile = ContextExtension(context).isPhone;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return BlocBuilder<MessagingHomeCubit, MessagingHomeState>(
      builder: (context, state) {
        final controller = context.read<MessagingHomeCubit>();

        return Column(
          children: [
            verticalSpace(16),
            Row(
              spacing: 16.sp,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child:   AppSearchTextField(
                    controller: controller.searchController,
                    onChanged: (text) => controller.filterAllChats(),
                  ),
                ),
                SizedBox(
                  width: isMobile ? 38.sp : 100.sp,
                  height: 38.h,
                  child: CustomSortButton<SortEnum>(
                      value: controller.sort,
                      items: SortEnum.values,
                      labelBuilder: (sort) => sort.label(context),
                      title: S.of(context).sort,
                      showTitle: !isPortrait,
                      svgPath: AppAssets.sort,
                      width: double.infinity,
                      height: 38.h,
                      yOffset: isPortrait ? 50 : 16,
                      onChanged: controller.sortChats,
                    ),
                ),
                if( Get.find<MainCoreEmployeeController>().isHasPermission(
                  module: Modules.messages,
                  section: MessagesPermissionsSections.messagesPermissions,
                  permission: MessagesPermissions.createGroup,
                ))
                  customButtonWithSvg(
                    title: S.of(context).createGroup,
                    image: AppAssets.message,
                    textStyle: AppTextStyles.font14BlackCairoMedium
                        .copyWith(color: AppColors.textButton),
                    color: AppColors.primary,
                    colorBorder: AppColors.primary,
                    svgColor: AppColors.textButton,
                    widthImage: 20.sp,
                    heightImage: 20.sp,
                    space: 10.sp,
                    function: () {
                      context.read<GroupsCubit>().resetCreateGroupControllers();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateGroupPageTablet(),
                        ),
                      );
                    },
                  ),
              ],
            ),
             Expanded(child: TabletLayoutBody()),
          ],
        );
      },
    );
  }
}