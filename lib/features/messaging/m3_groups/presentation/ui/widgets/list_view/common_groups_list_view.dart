// Date: 5/9/2024
// By: Nada Mohammed
// Last update: 5/9/2024
// Objectives: This file is responsible for providing common groups list view used in the group chat profile screen.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/messaging/m1_chat/data/models/chat/chat_model.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/widgets/tiles/common_group_tile.dart';

class CommonGroupsListView extends StatelessWidget {
  const CommonGroupsListView({
    super.key,
    required this.chatModel,
  });

  final ChatModel chatModel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chatModel.otherUser!.groupsInCommon.length,
      itemBuilder: (context, index) {
        return CommonGroupTile(
          group: chatModel.otherUser!.groupsInCommon[index],
        );
      },
    );
  }
}
