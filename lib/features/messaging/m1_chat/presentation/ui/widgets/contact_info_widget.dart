/// Module: messaging / chat / presentation/ui/widgets/contact_info_widget.dart
  // Date: 28/4/2026
  // By: Amr Mesbah
  // Objectives: Contact Info side panel for single chat — shows starred messages count,
  //             disappearing messages toggle, mute notification toggle, and common groups.
  //             Tapping "Starred Messages" expands to show the actual starred messages.

  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:flutter_svg/svg.dart';
  import 'package:get/get.dart';
  import 'package:grc_module/core/enums/message_module/message_types.dart';
import 'package:grc_module/core/theme/app_colors.dart';
  import 'package:grc_module/features/messaging/m1_chat/domain/entity/message_entity.dart';
  import 'package:grc_module/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
  import 'package:grc_module/features/messaging/m2_connections/domain/entities/single_connection_entity.dart';
  import 'package:grc_module/features/messaging/m3_groups/presentation/controller/groups_controller.dart';

  import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/generated/l10n.dart';
  import 'package:grc_module/core/helper/main_helper/date_time_helper.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
  import 'package:grc_module/core/constants/message_module/app_assets.dart';
  import 'package:grc_module/core/helper/main_helper/spacing_helper.dart';
  import '../../../../m3_groups/domain/entities/group_entity.dart';


  class ContactInfoWidget extends StatefulWidget {
    const ContactInfoWidget({super.key});

    @override
    State<ContactInfoWidget> createState() => _ContactInfoWidgetState();
  }

  class _ContactInfoWidgetState extends State<ContactInfoWidget> {
    bool _showStarredMessages = false;

    @override
    Widget build(BuildContext context) {
      bool isTablet = MediaQuery.of(context).size.width >= 600;

      return BlocBuilder<MasterChatCubit, MasterChatState>(
        builder: (context, state) {
          if (state.otherConnectionSide == null) return const SizedBox();

          final cubit = context.read<MasterChatCubit>();
          final connection =
          state.otherConnectionSide as SingleConnectionEntity;
          final List<GroupEntity> commonGroups = _getCommonGroups(context);
          final starredMessages =
          state.messages.where((m) => m.isStarred).toList();

          return Container(
            margin: EdgeInsetsDirectional.only(
              start: 10.sp,
              top: 32.h,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isTablet ? AppColors.field : AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            width: isTablet ? 269.sp : double.infinity,
            child: _showStarredMessages
                ? _buildStarredMessagesView(
                cubit, starredMessages, connection)
                : _buildContactInfoView(
                cubit, state, starredMessages, commonGroups),
          );
        },
      );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Main Contact Info View
    // ─────────────────────────────────────────────────────────────────────────

    Widget _buildContactInfoView(
        MasterChatCubit cubit,
        MasterChatState state,
        List<MessageEntity> starredMessages,
        List<GroupEntity> commonGroups,
        ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Text(
                S.current.contactInfo,
                style: AppTextStyles.font16BlackMediumCairo,
              ),

              const Spacer(),
              InkWell(
                onTap: () => cubit.toggleContactInfoState(),
                child: SvgPicture.asset(
                  AppAssets.close,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.secondaryBlack,
                ),
              ),
            ],
          ),

          verticalSpace(24),

          // ── Starred Messages (tappable) ──
          InkWell(
            onTap: () {
              if (starredMessages.isNotEmpty) {
                setState(() => _showStarredMessages = true);
              }
            },
            child: Row(
              children: [
                Text(
                  starredMessages.length.toString(),
                  style: AppTextStyles.font14BlackCairoMedium,
                ),
                horizontalSpace(8),
                Expanded(
                  child: Text(
                    S.of(context).startedMessages,
                    style: AppTextStyles.font14BlackCairoMedium,
                  ),
                ),
                Icon(
                  Icons.star_outline_rounded,
                  color: AppColors.secondaryBlack,
                  size: 20.sp,
                ),
              ],
            ),
          ),

          verticalSpace(16),

          // ── Disappearing Messages ──
          _InfoRow(
            icon: Icons.timer_outlined,
            label: S.current.disappearingMessages,
          ),

          verticalSpace(16),

          // ── Mute Notification ──
          _InfoRow(
            icon: Icons.notifications_off_outlined,
            label: S.of(context).muteNotifications,
          ),

          verticalSpace(24),

          // ── Common Groups ──
          if (commonGroups.isNotEmpty) ...[
            Text(
              '${S.of(context).groupsCommon} ${commonGroups.length}',
              style: AppTextStyles.font14BlackCairoMedium.copyWith(
                color: AppColors.secondaryBlack,
              ),
            ),
            verticalSpace(12),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: commonGroups.length,
                separatorBuilder: (_, __) => verticalSpace(8),
                itemBuilder: (context, index) {
                  final group = commonGroups[index];
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundColor: AppColors.primary,
                        backgroundImage: group.groupImage != null
                            ? NetworkImage(group.groupImage!)
                            : null,
                        child: group.groupImage == null
                            ? SvgPicture.asset(
                          AppAssets.message,
                          color: AppColors.textButton,
                          width: 16.sp,
                          height: 16.sp,
                        )
                            : null,
                      ),
                      horizontalSpace(8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.primaryLanguageName,
                              style: AppTextStyles.font14BlackCairoMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                             FormatHelper.capitalize( group.members
                                 .take(3)
                                 .map((m) => m.primaryLanguageName)
                                 .join(' , ') +
                                 (group.members.length > 3
                                     ? ' , ........'
                                     : ''),),
                              style: AppTextStyles
                                  .font12SecondaryBlackCairoRegular,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],

          if (commonGroups.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  S.current.noCommonGroups,
                  style: AppTextStyles.font14SecondaryBlackCairo,
                ),
              ),
            ),
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Starred Messages View
    // ─────────────────────────────────────────────────────────────────────────

    Widget _buildStarredMessagesView(
        MasterChatCubit cubit,
        List<MessageEntity> starredMessages,
        SingleConnectionEntity connection,
        ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with back button ──
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _showStarredMessages = false),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 18.sp,
                  color: AppColors.secondaryBlack,
                ),
              ),
              const Spacer(),
              Text(
                S.current.startedMessages,
                style: AppTextStyles.font16BlackMediumCairo,
              ),
            ],
          ),

          verticalSpace(16),

          // ── Starred messages list ──
          if (starredMessages.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  S.current.noStarredMessages,
                  style: AppTextStyles.font14SecondaryBlackCairo,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: starredMessages.length,
                separatorBuilder: (_, __) => Divider(
                  color: AppColors.background,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final msg = starredMessages[index];
                  return _StarredMessageTile(
                    message: msg,
                    connectionName: connection.name,
                    onTap: () {
                      // Scroll to this message in chat
                      final msgIndex = cubit.state.messages.indexWhere(
                            (m) => m.messageId == msg.messageId,
                      );
                      if (msgIndex != -1) {
                        cubit.chatScrollCubit.scrollAndHighlight(msgIndex);
                        // Close contact info after navigating
                        cubit.toggleContactInfoState();
                      }
                    },
                  );
                },
              ),
            ),
        ],
      );
    }

    int _getStarredCount(MasterChatState state) {
      return state.messages.where((m) => m.isStarred).length;
    }

    List<GroupEntity> _getCommonGroups(BuildContext context) {
      // Computation + error handling live in GroupsCubit; UI never catches (§11.2).
      final masterCubit = context.read<MasterChatCubit>();
      final otherUserId =
          masterCubit.state.otherConnectionSide?.otherSideId ?? '';
      final currentUserId = masterCubit.state.currentUser?.userId ?? '';
      return context
          .read<GroupsCubit>()
          .commonGroupsWith(otherUserId, currentUserId);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // _StarredMessageTile — single starred message row
  // ─────────────────────────────────────────────────────────────────────────────

  class _StarredMessageTile extends StatelessWidget {
    final MessageEntity message;
    final String connectionName;
    final VoidCallback onTap;

    const _StarredMessageTile({
      required this.message,
      required this.connectionName,
      required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.star_rounded,
                color: AppColors.primary,
                size: 18.sp,
              ),
              horizontalSpace(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Sender + time ──
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.isMe ? S.of(context).you : connectionName,
                            style: AppTextStyles.font12SecondaryBlackCairoRegular
                                .copyWith(
                              color: AppColors.secondaryBlack,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateTimeHelper.formatTime(message.time.toDate()),
                          style: AppTextStyles.font10BlackCairoRegular.copyWith(
                            color: AppColors.secondaryBlack,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(4),
                    // ── Message content ──
                    Text(
                      _getMessagePreview(message),
                      style: AppTextStyles.font14BlackCairoMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    String _getMessagePreview(MessageEntity msg) {
      switch (msg.messageType) {
        case MessageTypes.text:
          return msg.messageContent ?? '';
        case MessageTypes.cameraImage:
        case MessageTypes.galleryImage:
          return '📷 ${S.current.image}';
        case MessageTypes.video:
          return '🎥 ${S.current.video}';
        case MessageTypes.audio:
          return '🎵 ${S.current.audio}';
        case MessageTypes.doc:
          return '📄 ${msg.docMessageModel?.fileName ?? S.current.document}';
        case MessageTypes.location:
          return '📍 ${S.current.location}';
        default:
          return msg.messageContent ?? '';
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // _InfoRow
  // ─────────────────────────────────────────────────────────────────────────────

  class _InfoRow extends StatelessWidget {
    final IconData icon;
    final String label;
    final Widget? trailing;

    const _InfoRow({
      required this.icon,
      required this.label,
      this.trailing,
    });

    @override
    Widget build(BuildContext context) {
      return Row(
        children: [
          if (trailing != null) trailing!,
          if (trailing != null) horizontalSpace(8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.font14BlackCairoMedium,
            ),
          ),
          Icon(
            icon,
            color: AppColors.secondaryBlack,
            size: 20.sp,
          ),
        ],
      );
    }
  }