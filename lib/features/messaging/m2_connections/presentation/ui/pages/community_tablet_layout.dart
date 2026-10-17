/// Module: messaging / connections / presentation/ui/pages/community_tablet_layout.dart
/// ************************* FILE INFO *************************** ///
/// File Name: community_tablet_layout.dart
/// Purpose: Community tablet layout — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

// By: Youssef Ashraf
// Date: 16/9/2024
// Objectives: This file is responsible for providing the home tablet layout used in the messaging feature.

import 'package:flutter/material.dart';
import 'package:grc_module/features/messaging/helpers/main/messages_permissions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:grc_module/features/messaging/m3_groups/presentation/ui/pages/tablet/create_group_page_tablet.dart';
import 'package:grc_module/features/messaging/m4_messaging_home/domain/enums/sort_enum.dart';
import 'package:grc_module/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';
import 'package:grc_module/features/messaging/m2_connections/presentation/ui/widgets/layouts/tablet_body.dart';

import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/messaging/helpers/spacing_helper.dart';
import 'package:grc_module/features/messaging/helpers/constants/messaging_assets.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:grc_module/core/custom/buttons/custom_sort_button.dart';
import 'package:grc_module/core/custom/buttons/custom_button_with_svg.dart';
import 'package:grc_module/core/theme/app_theme.dart';

class HomeTabletLayout extends StatelessWidget {
  const HomeTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    ContextExtension(context).isPhone;
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
                  // expanded: false — AppSearchTextField's own root is an
                  // Expanded, and nesting it inside this one throws
                  // "Incorrect use of ParentDataWidget".
                  child: AppSearchTextField(
                    expanded: false,
                    controller: controller.searchController,
                    onChanged: (text) => controller.filterAllChats(),
                  ),
                ),
                // CHANGED 17/10/2026: the To-Do sort — the custom's own
                // sizes (38 x 38 on phone, 100 x 38 with label on iPad).
                CustomSortButton<SortEnum>(
                  value: controller.sort,
                  items: SortEnum.values,
                  labelBuilder: (sort) => sort.label(context),
                  title: S.of(context).sort,
                  showTitle: !isPortrait,
                  svgPath: AppAssets.sort,
                  onChanged: controller.sortChats,
                ),
                // CHANGED 21/9/2026 — the same check GroupsCubit.createGroup
                // enforces (master toggle AND switch). Checking only the
                // switch showed the button to roles whose Create then did
                // nothing ("createGroup denied" in the log, no dialog).
                if (MessagesAccess.canCreateGroup)
                  customButtonWithSvg(
                    height: 38.sp,
                    title: S.of(context).createGroup,
                    image: AppAssets.message,
                    textStyle: StyleText.fontSize14Weight500
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
