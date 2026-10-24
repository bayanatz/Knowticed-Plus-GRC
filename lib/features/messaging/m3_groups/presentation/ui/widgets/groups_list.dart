/// Module: messaging / groups / presentation/ui/widgets/groups_list.dart
/// ************************* FILE INFO *************************** ///
/// File Name: groups_list.dart
/// Purpose: Groups list — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

// By: Youssef Ashraf, Nada Mohammed
// Last update: 18/9/2024
// Objectives: This file is responsible for providing the community group chats list used in the community feature.

import 'package:knowticed_plus/features/messaging/helpers/constants/messaging_list_fit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';

import 'package:knowticed_plus/features/messaging/helpers/enums/message_types.dart';
import 'package:knowticed_plus/features/messaging/helpers/main/chat_settings_service.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/widgets/groups_tile.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/widgets/new_group_tile.dart';

class GroupsList extends StatelessWidget {
  final bool seeAll;

  /// Rows shown while [seeAll] is false; null = what the screen holds.
  /// ADDED 20/10/2026 (the All list shares the panel between both lists).
  final int? limit;

  const GroupsList({this.seeAll = false, this.limit, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        final controller = context.read<GroupsCubit>();
        final filteredList = List.of(controller.groups);

        // 🔽 Sort by last message time (most recent first)
        filteredList.sort((a, b) {
          final aTime = a.lastMessageTime;
          final bTime = b.lastMessageTime;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        // Pinned groups first (bug report #21), keeping the time order
        // inside each half. Rebuilds when a pin changes.
        return ValueListenableBuilder<Set<String>>(
          valueListenable: ChatSettingsService.pinnedChats,
          builder: (context, pinned, _) {
            bool isPinned(dynamic g) =>
                pinned.contains(ChatSettingsService.groupKey(g.groupId));
            final ordered = [
              ...filteredList.where(isPinned),
              ...filteredList.where((g) => !isPinned(g)),
            ];
            filteredList
              ..clear()
              ..addAll(ordered);

            final itemCount = seeAll
                ? filteredList.length
                : filteredList.length
                    .clamp(0, limit ?? kpMessagingFitCount(context));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 8.w),
                ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: 8.h),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final group = filteredList[index];
                    return group.messageType != MessageTypes.none
                        ? GroupsTile(groupEntity: group)
                        : NewGroupTile(groupEntity: group);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
