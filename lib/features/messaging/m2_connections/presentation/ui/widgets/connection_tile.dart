/// Module: messaging / connections / presentation/ui/widgets/connection_tile.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connection_tile.dart
/// Purpose: Connection tile — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

// Date: 1/9/2024
// By: Youssef Ashraf , Nada Mohammed
// Last update: 2/5/2026
// Objectives: This file is responsible for providing the community chats tile used in the community feature.

import 'package:knowticed_plus/core/helper/localized_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/messaging/helpers/enums/message_types.dart';
import 'package:knowticed_plus/core/helper/date_time_helper.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/main_helper/localized_text_helper.dart';
import 'package:knowticed_plus/features/messaging/helpers/spacing_helper.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/main_helper/incrption.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_weights.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/controller/messaging_init_controller.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/domain/entities/single_connection_entity.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/helpers/main/chat_settings_service.dart';
import 'package:knowticed_plus/features/messaging/helpers/main/chat_state_icons.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ConnectionTile extends StatelessWidget {
  final SingleConnectionEntity connection;

  const ConnectionTile({
    super.key,
    required this.connection,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticController.low(); // list row: on the tap (X-117)
        context.read<ConnectionsCubit>().selectConnection(connection, context);
      },
      child: Container(
        padding: EdgeInsetsDirectional.all(8.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius:
              BorderRadius.circular(4.r), // bug report #3: cards use 4.r
        ),
        child: Column(
          spacing: 4.sp,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Moataz 22/10/2026: a true circle the size of the group card's
                // (was 30.w x 30.h, which turns oval when the window's shape changes).
                SizedBox(
                  width: 40.r,
                  height: 40.r,
                  child: ClipOval(
                    child: connection.imageUri.isNotEmpty &&
                            connection.imageUri.contains('http')
                        ? Image.network(
                            connection.imageUri,
                            fit: BoxFit.cover,
                            width: 40.r,
                            height: 40.r,
                          )
                        : CustomSvgImage(
                            assetPath:
                                "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                            width: 40.r,
                            height: 40.r,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                horizontalSpace(5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.sp,
                    children: [
                      Text(
                        LocalizedTextHelper.formatString(
                          secondaryLanguageText:
                              connection.secondaryLanguageName,
                          primaryLanguageText: connection.primaryLanguageName,
                        ),
                        style:
                            StyleText.fontSize14Weight500.copyWith(height: 1.3),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (connection.primaryLanguageSubInfo != null)
                        Text(
                          LocalizedTextHelper.formatString(
                            secondaryLanguageText:
                                connection.secondaryLanguageSubInfo,
                            primaryLanguageText:
                                connection.primaryLanguageSubInfo!,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: StyleText.fontSize12Weight400
                              .copyWith(color: AppColors.secondaryBlack),
                        ),
                      Text(
                        getMessageText(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: connection.isrUserTyping
                            ? StyleText.fontSize12Weight500
                                .copyWith(color: AppColors.secondaryPrimary)
                                .copyWith(
                                    height: 1.3,
                                    fontWeight: AppFontWeights.regular)
                            : StyleText.fontSize12Weight400
                                .copyWith(color: AppColors.secondaryBlack)
                                .copyWith(height: 1.3),
                      ),
                    ],
                  ),
                ),
                horizontalSpace(8.w),
                // Owner 21/10/2026: trailing column sits right under the time (end-aligned); unread badge beside the pin, not squeezed next to the text.
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Moataz 22/10/2026: the time sits in the corner column like the
                    // group card (it was a separate row above the avatar).
                    Text(
                      DateTimeHelper.formatTime(
                        connection.lastMessageTime != null
                            ? connection.lastMessageTime!.toDate()
                            : DateTime.now(),
                      ),
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.greyDark)
                          .copyWith(fontSize: 10.sp, height: 1),
                    ),
                    SizedBox(height: 6.sp),
                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 24.sp),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4.sp,
                        children: [
                          // ── Pin / mute icons (bug report #20–#22) ──
                          // Pinned chat (⋮ → Pin) or a pinned message;
                          // muted chat (⋮ → Mute Notifications).
                          ChatStateIcons(
                            chatKey: ChatSettingsService.directKey(
                              ChatSettingsService.currentUserId ?? '',
                              connection.userId,
                            ),
                            hasPinnedMessage: connection.hasPinnedMessage,
                            padding: EdgeInsets.zero,
                          ),
                          if ((connection.myNumUnreadMessage) > 0)
                            // Owner 21/10/2026: same badge as the group tiles —
                            // the branding primary, dark text.
                            CircleAvatar(
                              radius: 8.r,
                              backgroundColor: AppColors.primary,
                              child: Center(
                                child: Text(
                                  LocalizedNumber.of(
                                      context, connection.myNumUnreadMessage),
                                  style: StyleText.fontSize10Weight600
                                      .copyWith(color: AppColors.textButton),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (connection.isSeen)
                      if (Get.find<MessagingInitController>()
                          .messagingConfigurations
                          .seenAndUnseen)
                        Padding(
                          padding: EdgeInsets.only(top: 4.0.h),
                          child: Icon(
                            Icons.done_all,
                            color: AppColors.secondaryPrimary,
                            size: 16.sp,
                          ),
                        ),
                    if (connection.isLastMessageSenderIsCurrentUser &&
                        !connection.isSeen)
                      if (Get.find<MessagingInitController>()
                          .messagingConfigurations
                          .seenAndUnseen)
                        Padding(
                          padding: EdgeInsets.only(top: 4.0.h),
                          child: Icon(
                            Icons.done,
                            color: AppColors.secondaryPrimary,
                            size: 16.sp,
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

  String getMessageText() {
    if (connection.isrUserTyping) return S.current.typing;
    switch (connection.messageType) {
      case MessageTypes.deleted:
        return S.current.deletedMessage;
      case MessageTypes.cameraImage:
        return '${S.current.send} ${S.current.image}';
      case MessageTypes.video:
        return '${S.current.send} ${S.current.video}';
      case MessageTypes.audio:
        return '${S.current.send} ${S.current.audio}';
      case MessageTypes.location:
        return '${S.current.send} ${S.current.location}';
      case MessageTypes.contact:
        return '${S.current.send} ${S.current.contact}';
      case MessageTypes.poll:
        return S.current.poll;
      case MessageTypes.doc:
        return '${S.current.send} ${S.current.document}';
      case MessageTypes.text:
        final raw = connection.messageContent ?? '';
        if (raw.isEmpty) return raw;
        return MessageEncryptionService().decrypt(
          raw,
          chatId: connection.connectionId,
        );
      default:
        return '';
    }
  }
}
