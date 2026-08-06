/// Module: messaging / groups / presentation/ui/widgets/groups_tile.dart
/// ************************* FILE INFO *************************** ///
/// File Name: groups_tile.dart
/// Purpose: Groups tile — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 16/9/2024
// By: Youssef Ashraf , Nada Mohammed
// Last update: 01/5/2026
// Objectives: This file is responsible for providing the community group chats tile used in the community feature.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/pages/chat_mobile_view.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import 'package:grc_module/features/messaging/m3_groups/presentation/controller/groups_controller.dart';


import 'package:grc_module/core/network/message_module/routes/app_routes.dart';
import 'package:grc_module/core/constants/message_module/app_assets.dart';
import 'package:grc_module/core/enums/message_module/message_types.dart';
import 'package:grc_module/core/helper/main_helper/date_time_helper.dart';
import 'package:grc_module/core/helper/message_module/main_helper/localized_text_helper.dart';
import 'package:grc_module/core/helper/main_helper/spacing_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import '../../../../../../core/helper/message_module/interface/controller/messaging_init_controller.dart';
import '../../../../m1_chat/data/repository/group_chat_repository.dart';
import '../../../../m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import '../../../../../../core/helper/message_module/main_helper/update_ui_ids.dart';
import '../../../../m2_connections/presentation/controller/connections_controller.dart';
import '../../../domain/entities/group_entity.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class GroupsTile extends StatelessWidget {
  final GroupEntity groupEntity;

  const GroupsTile({
    super.key,
    required this.groupEntity,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return GestureDetector(
      onTap: () async {
        final groupsCubit = context.read<GroupsCubit>();

        // Select the group in GroupsCubit state
        groupsCubit.selectGroup(groupEntity);

        // ✅ Use registered GroupChatCubit from BlocProvider tree
        final groupChatCubit = context.read<GroupChatCubit>();

        await groupChatCubit.startChat(
          otherSideData: groupsCubit.selectedGroup!,
          currentUserData: groupsCubit.currentUser,
        );

        groupChatCubit.messageFocusNode.unfocus();
        groupChatCubit.getFirstUnreadIndex();

        if (!ContextExtension(context).isTablett) {
          // ── Pure Bloc: pass the active cubits into ChatMobileView (§3) ──
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatMobileView(
                masterChatCubit: groupChatCubit,
                connectionsCubit: context.read<ConnectionsCubit>(),
                groupsCubit: groupsCubit,
              ),
            ),
          );
        }
        // On tablet: GroupsCubit state change triggers TabletChatSide rebuild
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsetsDirectional.all(8.sp),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.background,
                  radius: 20.r,
                  backgroundImage: (groupEntity.groupImage != null)
                      ? NetworkImage(groupEntity.groupImage!)
                      : null,
                  child: groupEntity.groupImage == null
                      ? SvgPicture.asset(
                    AppAssets.message,
                    color: AppColors.text,
                    width: 20.sp,
                    height: 20.sp,
                  )
                      : null,
                ),
                horizontalSpace(5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 5.sp,
                    children: [
                      Text(
                        FormatHelper.capitalize(
                          LocalizedTextHelper.formatString(
                            primaryLanguageText:
                            groupEntity.primaryLanguageName,
                            secondaryLanguageText:
                            groupEntity.groupNameAr,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.font14BlackCairoMedium
                            .copyWith(height: 1.3),
                      ),
                      Text(
                        _getMessageText(isAr),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppTextStyles.font12InputColorCairo,
                      ),
                    ],
                  ),
                ),
                if (groupEntity.myNumUnreadMessage > 0)
                  Container(
                    padding: EdgeInsets.all(6.sp),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      groupEntity.myNumUnreadMessage.toString(),
                      style: AppTextStyles.font10BlackCairoRegular,
                    ),
                  ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateLabel(isAr),
                      style: AppTextStyles.font12InputColorCairo
                          .copyWith(fontSize: 10.sp, height: 1),
                    ),
                    SizedBox(height: 15.sp),
                    // ── Pin icon next to date ──
                    if (groupEntity.hasPinnedMessage)
                      Padding(
                        padding: EdgeInsetsDirectional.only(end: 4.w),
                        child: SvgPicture.asset(
                          'assets/icons_assets/messaging_assets/pin_svg.svg',
                          width: 14.sp,
                          height: 14.sp,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Format date to show "Today"/"اليوم", "Yesterday"/"أمس", or the actual date
  String _formatDateLabel(bool isAr) {
    if (groupEntity.lastMessageTime == null) {
      return DateTimeHelper.formatDate(groupEntity.createdAt.toDate());
    }

    final messageDate = groupEntity.lastMessageTime!.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay =
    DateTime(messageDate.year, messageDate.month, messageDate.day);

    if (messageDay == today) {
      return isAr ? 'اليوم' : 'Today';
    } else if (messageDay == yesterday) {
      return isAr ? 'أمس' : 'Yesterday';
    } else {
      return DateTimeHelper.formatDate(messageDate);
    }
  }

  /// Message preview text with AR/EN support
  String _getMessageText(bool isAr) {
    if (groupEntity.messageType == MessageTypes.deleted) {
      return isAr ? 'رسالة محذوفة' : 'Deleted Message';
    }
    if (groupEntity.messageType == MessageTypes.cameraImage) {
      return isAr ? 'صورة' : 'Image';
    }
    if (groupEntity.messageType == MessageTypes.video) {
      return isAr ? 'فيديو' : 'Video';
    }
    if (groupEntity.messageType == MessageTypes.audio) {
      return isAr ? 'صوت' : 'Audio';
    }
    if (groupEntity.messageType == MessageTypes.location) {
      return isAr ? 'موقع' : 'Location';
    }
    if (groupEntity.messageType == MessageTypes.poll) {
      return isAr ? 'استطلاع' : 'Poll';
    }
    if (groupEntity.messageType == MessageTypes.doc) {
      return isAr ? 'مستند' : 'Document';
    }
    if (groupEntity.messageType == MessageTypes.text) {
      return groupEntity.messageContent!;
    }
    return '';
  }
}