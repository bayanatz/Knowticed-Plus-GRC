import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';

import 'package:grc_module/core/helper/main_helper/spacing_helper.dart';
import '../../../../../m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import '../../../../../m1_chat/presentation/ui/widgets/contact_info_widget.dart';
import '../../../../../m1_chat/presentation/ui/widgets/media_links_widget.dart';
import '../../../controller/connections_controller.dart';
import '../../../../../m3_groups/presentation/controller/groups_controller.dart';
import './widgets/tablet_chat_side.dart';
import './widgets/tablet_chats_list.dart';

class TabletLayoutBody extends StatelessWidget {
  const TabletLayoutBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionsCubit, ConnectionsState>(
      builder: (context, connectionsState) {
        final hasSelectedConnection = connectionsState is ConnectionsLoaded &&
            connectionsState.selectedConnection != null;

        if (hasSelectedConnection) {
          return BlocBuilder<SingleChatCubit, MasterChatState>(
            builder: (context, chatState) {
              return _buildLayout(
                context: context,
                isShowMedia: chatState.isShowMedia,
                isShowContactInfo: chatState.isShowContactInfo,  // ✅ NEW
                isExpansionTabletChat: chatState.isExpansionTabletChat,
                activeCubit: context.read<SingleChatCubit>(),
              );
            },
          );
        }

        return BlocBuilder<GroupsCubit, GroupsState>(
          builder: (context, groupsState) {
            final hasSelectedGroup = groupsState is GroupsLoaded &&
                groupsState.selectedGroup != null;

            if (hasSelectedGroup) {
              return BlocBuilder<GroupChatCubit, MasterChatState>(
                builder: (context, chatState) {
                  return _buildLayout(
                    context: context,
                    isShowMedia: chatState.isShowMedia,
                    isShowContactInfo: chatState.isShowContactInfo,  // ✅ NEW
                    isExpansionTabletChat: chatState.isExpansionTabletChat,
                    activeCubit: context.read<GroupChatCubit>(),
                  );
                },
              );
            }

            return _buildLayout(
              context: context,
              isShowMedia: false,
              isShowContactInfo: false,  // ✅ NEW
              isExpansionTabletChat: false,
            );
          },
        );
      },
    );
  }

  Widget _buildLayout({
    required BuildContext context,
    required bool isShowMedia,
    required bool isShowContactInfo,  // ✅ NEW
    required bool isExpansionTabletChat,
    MasterChatCubit? activeCubit,
  }) {
    // ✅ Hide chat list when media OR contact info OR expansion is active
    final bool hideChatList =
        isShowMedia || isShowContactInfo || isExpansionTabletChat;

    return Padding(
      padding: EdgeInsets.only(bottom: 25.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // ── Chat list (hidden when contact info or media is showing) ──
          if (!hideChatList)
            SizedBox(
              height: MediaQuery.of(context).size.height - 25.h,
              child: const TabletChatList(),
            ),

          if (!hideChatList || isShowContactInfo)
            horizontalSpace(Directionality.of(context) == TextDirection.ltr ? 10.w : 0),

          // ── Chat area (always visible) ──
          const Expanded(child: TabletChatSide()),

          // ── Contact Info panel (replaces chat list on left) ──
          if (isShowContactInfo && activeCubit != null)
            SizedBox(
              width: 300.w,
              height: MediaQuery.of(context).size.height - 25.h,
              child: BlocProvider<MasterChatCubit>.value(
                value: activeCubit,
                child: const ContactInfoWidget(),
              ),
            ),

          // ── Media panel (right side) ──
          if (isShowMedia && activeCubit != null)
            SizedBox(
              width: 300.w,
              child: BlocProvider<MasterChatCubit>.value(
                value: activeCubit,
                child: const MediaLinksWidget(),
              ),
            ),
        ],
      ),
    );
  }
}