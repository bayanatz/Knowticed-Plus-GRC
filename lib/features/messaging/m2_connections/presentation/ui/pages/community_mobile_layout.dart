/// Module: messaging / connections / presentation/ui/pages/community_mobile_layout.dart
/// ************************* FILE INFO *************************** ///
/// File Name: community_mobile_layout.dart
/// Purpose: Community mobile layout — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

// Date: 16/9/2024
// By: Youssef Ashraf
// Objectives: This file is responsible for providing the community mobile layout used in the community feature.

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/domain/enums/sort_enum.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/ui/widgets/layouts/widgets/tablet_chats_list.dart';
import 'package:knowticed_plus/features/messaging/helpers/constants/messaging_assets.dart';
import 'package:knowticed_plus/features/messaging/helpers/spacing_helper.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_sort_button.dart';

class CommunityMobileLayout extends StatelessWidget {
  const CommunityMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: BlocBuilder<MessagingHomeCubit, MessagingHomeState>(
          builder: (context, state) {
            final controller = context.read<MessagingHomeCubit>();

            return Column(
              children: [
                Row(
                  spacing: ButtonSizing.toolbarGap(context),
                  children: [
                    // search
                    AppSearchTextField(
                      controller: controller.searchController,
                      onChanged: (text) {
                        controller.filterAllChats();
                      },
                    ),
                    // CHANGED 17/10/2026 (Moataz: "the sort … has to be a
                    // perfect square … aligned by the search bar … the
                    // selection is far away"): the To-Do sort as is — the
                    // custom's own 38 x 38 square and menu right under it.
                    // The 36.h x 36 box and the 94 drop are gone.
                    CustomSortButton<SortEnum>(
                      value: controller.sort,
                      items: SortEnum.values,
                      labelBuilder: (sort) => sort.label(context),
                      title: S.of(context).sort,
                      showTitle: false,
                      svgPath: AppAssets.sort,
                      onChanged: controller.sortChats,
                    ),
                  ],
                ),
                const TabletChatList(),
                verticalSpace(80),
              ],
            );
          },
        ),
      ),
    );
  }
}
