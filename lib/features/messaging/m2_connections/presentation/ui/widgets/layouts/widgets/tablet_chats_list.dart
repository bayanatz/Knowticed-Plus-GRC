import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/messaging/helpers/constants/messaging_list_fit.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_tab_with_container.dart';
import 'package:knowticed_plus/features/messaging/helpers/main/messages_permissions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/messaging/helpers/constants/messaging_assets.dart';
import 'package:knowticed_plus/features/messaging/helpers/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/ui/widgets/connections_list.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/pages/tablet/create_group_page_tablet.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/widgets/groups_list.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/domain/enums/chat_type_selector_enum.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class TabletChatList extends StatefulWidget {
  const TabletChatList({super.key});

  @override
  State<TabletChatList> createState() => _TabletChatListState();
}

class _TabletChatListState extends State<TabletChatList> {
  bool seeAllGroups = false;
  bool seeAllConnections = false;
  ChatTypeSelectorEnum chatTypeSelectorEnum = ChatTypeSelectorEnum.all;

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);

    // ✅ When on Groups/DirectMessages tab → always show all (no limit)
    // When on All tab → respect seeAll toggles (limit to 3 unless expanded)
    // CHANGED 17/10/2026 (Moataz: the All / Direct / Groups switch "only
    // shows in the mobile" — a large screen shows groups and direct messages
    // together): on tablet / desktop there is no switch and the list is
    // always "All".
    if (isTablet) chatTypeSelectorEnum = ChatTypeSelectorEnum.all;
    final bool isAllTab = chatTypeSelectorEnum == ChatTypeSelectorEnum.all;

    // 20/10/2026 (Moataz: See More "doesn't make sense"): the two lists
    // share the panel's real height (kpMessagingSplit) instead of each one
    // taking what the whole screen holds.
    final GroupsState groupsState = context.watch<GroupsCubit>().state;
    final ConnectionsState connectionsState =
        context.watch<ConnectionsCubit>().state;
    final int groupsCount =
        groupsState is GroupsLoaded ? groupsState.groups.length : 0;
    final int connectionsCount = connectionsState is ConnectionsLoaded
        ? connectionsState.filteredConnections.length
        : 0;

    return LayoutBuilder(builder: (context, constraints) {
      final ({int groups, int dms}) fit = kpMessagingSplit(
        height: constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height - 380.sp,
        groups: groupsCount,
        dms: connectionsCount,
        // top padding · the two headers · the gaps (+ tabs and button on phone)
        overhead: 110.sp + (isTablet ? 0 : 110.sp),
      );
      return Padding(
        padding: EdgeInsets.only(top: 20.sp),
        child: SizedBox(
          width: isTablet ? 258.w : double.infinity,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Type selector tabs ────────────────────────────────────
                // CHANGED 17/10/2026 (Moataz: "custom is not working" — the
                // hand-built row of three customButtons overflowed on the
                // phone): the shared CustomSegmentedTabs (the Time Tracker
                // toggle), equal widths so it always fits its row.
                if (!isTablet)
                  CustomSegmentedTabs(
                    tabs: <String>[
                      for (final ChatTypeSelectorEnum type
                          in ChatTypeSelectorEnum.values)
                        type.label(context),
                    ],
                    selectedIndex: ChatTypeSelectorEnum.values
                        .indexOf(chatTypeSelectorEnum),
                    equalWidth: true,
                    containerColor: AppColors.card,
                    onTabSelected: (int index) {
                      setState(() {
                        chatTypeSelectorEnum =
                            ChatTypeSelectorEnum.values[index];
                        // Reset see more when switching tabs
                        seeAllGroups = false;
                        seeAllConnections = false;
                      });
                    },
                  ),

                verticalSpace(16.26),

                // ── Create Group button (phone portrait only) ─────────────
                // if (chatTypeSelectorEnum != ChatTypeSelectorEnum.directMessages)
                //   if (Get.find<MessagingInitController>()
                //       .messagingConfigurations
                //       .createGroup)
                // 21/9/2026 — gated like the tablet button (MessagesAccess).
                ContextExtension(context).isPhone &&
                        MessagesAccess.canCreateGroup
                    ? customButtonWithSvg(
                        image: AppAssets.message,
                        title: S.of(context).createGroup,
                        textStyle: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.textButton),
                        color: AppColors.primary,
                        colorBorder: AppColors.primary,
                        svgColor: AppColors.textButton,
                        widthImage: 20.sp,
                        heightImage: 20.sp,
                        space: 10.sp,
                        function: () => CreateGroupPageTablet.open(context),
                      )
                    : Container(),
                if (context.isPortrait &&
                    ContextExtension(context).isPhone &&
                    chatTypeSelectorEnum != ChatTypeSelectorEnum.directMessages)
                  verticalSpace(10),

                // ── Groups header (only in All tab) ──────────────────────
                if (chatTypeSelectorEnum == ChatTypeSelectorEnum.all)
                  BlocBuilder<GroupsCubit, GroupsState>(
                    builder: (context, state) {
                      final groupsLength =
                          state is GroupsLoaded ? state.groups.length : 0;
                      return Row(
                        children: [
                          Text(
                            S.of(context).groups,
                            style: StyleText.fontSize16Weight500,
                          ),
                          const Spacer(),
                          // ✅ Only show See More if there are MORE than 3
                          if (groupsLength > fit.groups)
                            GestureDetector(
                              onTap: () {
                                HapticController
                                    .low(); // list row: on the tap (X-117)
                                setState(() {
                                  seeAllGroups = !seeAllGroups;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: _buildSeeMoreText(seeAllGroups
                                  ? S.of(context).seeLess
                                  : S.of(context).seeMore),
                            ),
                        ],
                      );
                    },
                  ),

                if (chatTypeSelectorEnum != ChatTypeSelectorEnum.all)
                  verticalSpace(10),

                // ── Groups List ───────────────────────────────────────────
                if (chatTypeSelectorEnum != ChatTypeSelectorEnum.directMessages)
                  GroupsList(
                    seeAll: !isAllTab || seeAllGroups,
                    limit: fit.groups,
                  ),

                if (chatTypeSelectorEnum != ChatTypeSelectorEnum.directMessages)
                  verticalSpace(16.26),

                // ── Direct Messages header (only in All tab) ──────────────
                if (chatTypeSelectorEnum == ChatTypeSelectorEnum.all)
                  BlocBuilder<ConnectionsCubit, ConnectionsState>(
                    builder: (context, state) {
                      final connectionsLength = state is ConnectionsLoaded
                          ? state.filteredConnections.length
                          : 0;
                      return Row(
                        children: [
                          Text(
                            S.of(context).directMessage,
                            style: StyleText.fontSize16Weight500,
                          ),
                          const Spacer(),
                          // ✅ Only show See More if there are MORE than 3
                          if (connectionsLength > fit.dms)
                            GestureDetector(
                              onTap: () {
                                HapticController
                                    .low(); // list row: on the tap (X-117)
                                setState(() {
                                  seeAllConnections = !seeAllConnections;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: _buildSeeMoreText(seeAllConnections
                                  ? S.of(context).seeLess
                                  : S.of(context).seeMore),
                            ),
                        ],
                      );
                    },
                  ),

                if (chatTypeSelectorEnum == ChatTypeSelectorEnum.all)
                  verticalSpace(12.73),

                // ── Connections List ──────────────────────────────────────
                if (chatTypeSelectorEnum != ChatTypeSelectorEnum.groups)
                  ConnectionsList(
                    seeAll: !isAllTab || seeAllConnections,
                    limit: fit.dms,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSeeMoreText(String text) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: StyleText.fontSize12Weight500.copyWith(
              color: AppColors.blue,
            ),
          ),
          // 20/10/2026 (owner): the line sits close under the word (was 5).
          SizedBox(height: 1.sp),
          Container(
            height: 0.8,
            color: AppColors.blue,
          ),
        ],
      ),
    );
  }
}
