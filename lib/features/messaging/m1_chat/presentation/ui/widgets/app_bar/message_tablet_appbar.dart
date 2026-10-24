/// Module: messaging / chat / presentation/ui/widgets/app_bar/message_tablet_appbar.dart
library;

import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/widgets/group_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/messaging/helpers/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/domain/entities/single_connection_entity.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/entities/group_entity.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/menus/message_menu_popup_button.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/app_bar/scheduled_message_banner.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/cards/stacked_avatars.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class MessageTabletAppBar extends StatelessWidget {
  final double height;
  const MessageTabletAppBar({super.key, this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    bool isTablet = ContextExtension(context).isTablett;

    // ✅ Use context.read — MasterChatCubit is provided via BlocProvider.value in ChatTabletView
    final masterChatCubit = context.read<MasterChatCubit>();

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Main AppBar ──
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.sp),
                  topRight: Radius.circular(8.sp),
                ),
                boxShadow: [
                  // 18/10/2026 (Moataz): a soft shadow under the header,
                  // not a hard 1 px line.
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: masterChatCubit is SingleChatCubit
                  ? _buildSingleChatAppBar(context, isTablet, state)
                  : masterChatCubit is GroupChatCubit
                      ? _buildGroupAppBar(context, isTablet, state)
                      : const SizedBox(),
            ),

            // ── Pinned Message Preview Strip ──
            if (state.chatPinnedMessage != null)
              _buildPinnedMessageStrip(context, state),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pinned Message Strip (below appbar)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPinnedMessageStrip(BuildContext context, MasterChatState state) {
    final pinnedMsg = state.chatPinnedMessage!;
    final cubit = context.read<MasterChatCubit>();

    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        // Scroll to the pinned message
        final index = state.messages.indexWhere(
          (m) => m.messageId == pinnedMsg.messageId,
        );
        if (index != -1) {
          cubit.chatScrollCubit.scrollAndHighlight(index);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        color: AppColors.background,
        child: Row(
          children: [
            Icon(
              Icons.push_pin_rounded,
              color: AppColors.primary,
              size: 16.sp,
            ),
            horizontalSpace(8),
            Expanded(
              child: Text(
                pinnedMsg.messageContent ?? '',
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryBlack),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            horizontalSpace(8),
            GestureDetector(
              onTapDown: (_) => HapticController.low(),
              onTap: () {
                cubit.toggleChatPin();
              },
              child: Icon(
                Icons.close,
                color: AppColors.secondaryBlack,
                size: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Single Chat AppBar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSingleChatAppBar(
      BuildContext context, bool isTablet, MasterChatState state) {
    if (state.otherConnectionSide == null) return const SizedBox();

    final singleConnection =
        state.otherConnectionSide as SingleConnectionEntity;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.sp),
          topRight: Radius.circular(8.sp),
        ),
        color: AppColors.card,
      ),
      // 20/10/2026 (owner): the ⋮ dots are as far from the end edge as from
      // the top and bottom edges ([_kMenuEdgeWidth]); no end padding.
      padding:
          EdgeInsetsDirectional.only(start: 10.sp, top: 10.sp, bottom: 10.sp),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'profileChat',
                    child: Container(
                      height: 45.sp,
                      width: 45.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mediumGrey,
                        image: state.otherConnectionSide!.imageUri.isNotEmpty
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: state.otherConnectionSide!.imageUri
                                        .contains("http")
                                    ? NetworkImage(
                                        state.otherConnectionSide!.imageUri)
                                    : appImageProvider(
                                        state.otherConnectionSide!.imageUri),
                              )
                            : null,
                      ),
                      child: state.otherConnectionSide!.imageUri.isEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30.r),
                              child: CustomSvgImage(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                                width: 30.w,
                                height: 30.h,
                                fit: BoxFit.fill,
                              ),
                            )
                          : null,
                    ),
                  ),
                  horizontalSpace(5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 2.sp,
                      children: [
                        Text(
                          singleConnection.name,
                          style: StyleText.fontSize14Weight500,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          singleConnection.subInfo,
                          style: StyleText.fontSize12Weight400
                              .copyWith(color: AppColors.secondaryBlack),
                        ),
                      ],
                    ),
                  ),
                  // Figma 6799:8931 — next scheduled message, left of ⋮.
                  const ScheduledMessageBanner(),
                  MessageMenuPopupButton(
                      isGroup: false, width: _kMenuEdgeWidth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Group Chat AppBar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildGroupAppBar(
      BuildContext context, bool isTablet, MasterChatState state) {
    if (state.otherConnectionSide == null) return const SizedBox();

    final groupEntity = state.otherConnectionSide as GroupEntity;

    return Container(
      // 20/10/2026 (owner): the ⋮ dots are as far from the end edge as from
      // the top and bottom edges ([_kMenuEdgeWidth]); no end padding.
      padding:
          EdgeInsetsDirectional.only(start: 10.sp, top: 10.sp, bottom: 10.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.sp),
          topRight: Radius.circular(8.sp),
        ),
        color: AppColors.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 20/10/2026 (owner): the group's photo, or the people
                  // icon when it has none (it showed the chat icon).
                  Hero(
                    tag: 'profileChat',
                    child: GroupAvatar(
                      imageUrl: groupEntity.groupImage ?? groupEntity.imageUri,
                      size: 45.sp,
                      radius: 8.r,
                    ),
                  ),
                  horizontalSpace(16),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  FormatHelper.capitalize(
                                    groupEntity.primaryLanguageName,
                                  ),
                                  style: StyleText.fontSize14Weight500
                                      .copyWith(height: 1.3),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              verticalSpace(ContextExtension(context).isTablett
                                  ? 4.sp
                                  : 8.sp),
                              // 20/10/2026 (owner): the members' own photos
                              // (the app's avatar, as in the Direct Message list,
                              // without one), at most four,
                              // then "+N"; a ring in the card colour keeps
                              // the overlapping faces apart.
                              StackedAvatars(
                                height: 24.sp,
                                avatarColor: AppColors.background,
                                avatarTextColor: AppColors.text,
                                ringColor: AppColors.card,
                                width: 24.sp * 0.6 * 4 + 24.sp,
                                fontSize: 10.sp,
                                images: groupEntity.members
                                    .map((e) => e.memberImage.startsWith('http')
                                        ? e.memberImage
                                        : "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png")
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        const ScheduledMessageBanner(),
                        MessageMenuPopupButton(width: _kMenuEdgeWidth),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Width of the ⋮ trigger at the header's end edge (20/10/2026, owner: "above
/// and below, right equal padding"). The header is 10 + 45 + 10 high and the
/// dots sit centred in the 24-px icon (4 wide, 18 high), so their gap to the
/// top / bottom is 32.5 − 9 and to the end edge (trigger/2) − 2: equal when
/// the trigger is 65 − 14 wide.
double get _kMenuEdgeWidth => 65.sp - 14;
