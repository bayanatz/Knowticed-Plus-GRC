/// Module: messaging / groups / presentation/ui/widgets/new_group_tile.dart
/// ************************* FILE INFO *************************** ///
/// File Name: new_group_tile.dart
/// Purpose: New group tile — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

// Date: 1/9/2024
// By: Nada Mohammed
// Last update: 3/9/2024
// Objectives: This file is responsible for providing the community new group tile used in the community feature.

import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/helper/localized_number.dart';
import 'package:grc_module/features/messaging/helpers/messaging_bridge/main_helper/localized_text_helper.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/features/messaging/helpers/constants/messaging_assets.dart';
import 'package:grc_module/core/helper/date_time_helper.dart';
import 'package:grc_module/features/messaging/helpers/spacing_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/pages/chat_mobile_view.dart';
import 'package:grc_module/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:grc_module/features/messaging/m3_groups/domain/entities/group_entity.dart';
import 'package:grc_module/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:grc_module/features/messaging/helpers/main/chat_settings_service.dart';
import 'package:grc_module/features/messaging/helpers/main/chat_state_icons.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

class NewGroupTile extends StatelessWidget {
  final GroupEntity groupEntity;
  final VoidCallback? onTap;

  const NewGroupTile({
    super.key,
    required this.groupEntity,
    this.onTap,
  });

  void _handleTap(BuildContext context) {
    final groupsCubit = context.read<GroupsCubit>();

    // Clear the open direct message so the panel switches to the group.
    context.read<ConnectionsCubit>().clearSelectedConnection();

    // Select the group
    groupsCubit.selectGroup(groupEntity);

    // ✅ FIX: read GroupChatCubit from context (must be provided above in widget tree)
    // instead of creating a new local instance which is never provided to BLoC
    final groupChatCubit = context.read<GroupChatCubit>();

    groupChatCubit.startChat(
      otherSideData: groupsCubit.selectedGroup!,
      currentUserData: groupsCubit.currentUser,
    );

    groupChatCubit.getFirstUnreadIndex();
    groupChatCubit.messageFocusNode.unfocus();

    if (ContextExtension(context).isTablett) {
      // Tablet: panel updates in place via BLoC state — no navigation needed
    } else {
      // Pure Bloc: push ChatMobileView with the active cubits (§3).
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => ChatMobileView(
            masterChatCubit: groupChatCubit,
            connectionsCubit: context.read<ConnectionsCubit>(),
            groupsCubit: groupsCubit,
          ),
        ),
      );
    }

    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablett;

    return GestureDetector(
      onTapDown: (_) => HapticController.medium(),
      onTap: () => _handleTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius:
              BorderRadius.circular(4.r), // bug report #3: cards use 4.r
        ),
        padding: EdgeInsetsDirectional.all(8.sp),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  // DateFormat still emits Latin digits for `ar` (see
                  // LocalizedNumber.digits) — map them, so the date matches
                  // the Arabic-Indic counts elsewhere on this screen.
                  LocalizedNumber.digits(
                    context,
                    DateTimeHelper.formatDate(groupEntity.createdAt.toDate()),
                  ),
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.greyDark)
                      .copyWith(fontSize: 10.sp, height: 1),
                ),
              ],
            ),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.background,
                  radius: 20.r,
                  backgroundImage: (groupEntity.groupImage != null)
                      ? NetworkImage(groupEntity.groupImage!)
                      : null,
                  child: groupEntity.groupImage == null
                      ? CustomSvgImage.natural(
                          assetPath: AppAssets.message,
                          color: AppColors.text,
                          width: 20.sp,
                          height: 20.sp,
                        )
                      : null,
                ),
                horizontalSpace(5),
                Expanded(
                  child: BlocBuilder<GroupsCubit, GroupsState>(
                    builder: (context, state) {
                      final groupsCubit = context.read<GroupsCubit>();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 10.sp,
                        children: [
                          Text(
                            // Was `primaryLanguageName` alone, so a group with
                            // an Arabic name still showed its English one in
                            // Arabic mode. Same call groups_tile.dart makes;
                            // formatString capitalizes, so the separate
                            // FormatHelper.capitalize is gone with it.
                            LocalizedTextHelper.formatString(
                              primaryLanguageText:
                                  groupEntity.primaryLanguageName,
                              secondaryLanguageText: groupEntity.groupNameAr,
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: StyleText.fontSize14Weight500
                                .copyWith(height: 1.3),
                          ),
                          if (groupEntity.createdBy ==
                              groupsCubit.currentUser.userId)
                            Text(
                              S.of(context).youCreatedThisGroup,
                              style: isTablet
                                  ? StyleText.fontSize12Weight500.copyWith(
                                      color: AppColors.secondaryPrimary)
                                  : StyleText.fontSize12Weight500.copyWith(
                                      color: AppColors.secondaryPrimary),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                // Bug report p.17: a group with no messages yet is drawn by
                // THIS tile, which had no pin / mute icons — so pinning
                // "Testers" moved it to the top but showed no pin. Same
                // widget GroupsTile uses.
                ChatStateIcons(
                  chatKey: ChatSettingsService.groupKey(groupEntity.groupId),
                  hasPinnedMessage: groupEntity.hasPinnedMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
