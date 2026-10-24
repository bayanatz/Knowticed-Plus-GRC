/// Module: messaging / chat / presentation/ui/widgets/bubbles/default_bubble.dart
part of '../../pages/chat_mobile_view.dart';

//Youssef Ashraf

class DefaultBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final bool? hideSeen;
  final Widget content;
  final BoxConstraints? constraints;
  final int index;
  final bool? noMargin;
  final bool? isOverlay;

  const DefaultBubble({
    super.key,
    required this.index,
    this.hideSeen,
    this.constraints,
    this.isOverlay,
    this.noMargin,
    required this.content,
    required this.messageModel,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context) {
    var isMe = messageModel.isMe;

    // ── DEBUG ──
    if (isMe) {}

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final cubit = context.read<MasterChatCubit>();
        cubit.resetResources();

        if (cubit.overlayCubit.isVisible) {
          cubit.overlayCubit.removeOverlay();
          return;
        }

        if (cubit.state.selectMessages == true) {
          cubit.toggleSelectMessages(false);
          return;
        }

        // ✅ Use Get.back() since we navigated in with Get.toNamed()
        // Navigator.of(context).pop() pops from the wrong (nested tab) navigator
        Get.back();
      },
      child: BlocBuilder<MasterChatCubit, MasterChatState>(
        builder: (context, state) {
          final cubit = context.read<MasterChatCubit>();

          final bool selecting = state.selectMessages && isOverlay == null;
          final bool showSender = !isMe && isOverlay == null;
          final ({String name, String image}) sender = _sender(state);

          return GestureDetector(
            onTap: selecting && MasterChatCubit.isForwardable(messageModel)
                ? () {
                    HapticController.low();
                    cubit.toggleMessageSelected(messageModel);
                  }
                : null,
            onLongPress: () {
              if (isOverlay ?? false) return;
              if (selecting) return;

              cubit.overlayCubit.showMessageOverlay(
                content: content,
                context: context,
                index: index,
                isGroup: messageModel.isGroup,
                messageModel: messageModel,
              );
            },
            child: Column(
              children: [
                // ── WhatsApp-style date separator ──
                if (isOverlay == null) _buildDateSeparatorIfNeeded(cubit),

                // REBUILT 18/10/2026 (D-184 + Figma "2 Selected"):
                // [tick] [sender avatar] bubble   …   bubble [tick]
                // Mine on the right, theirs on the left; a bubble plus what
                // sits beside it never crosses the middle of the panel
                // (bubble_width.dart). Incoming bubbles show who sent them.
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    bottom: noMargin ?? false
                        ? 0
                        : ContextExtension(context).isPhone
                            ? 24.h
                            : 16.h,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (selecting && !isMe) _tick(cubit),
                      if (showSender) ...[
                        _SenderAvatar(image: sender.image, name: sender.name),
                        SizedBox(width: 8.w),
                      ],
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: AlignmentDirectional.bottomStart,
                        children: [
                          Container(
                            constraints: constraints ??
                                kpBubbleConstraints(
                                  context,
                                  reserve: (showSender ? 28.r + 8.w : 0) +
                                      (selecting ? _kTick + 8.w : 0),
                                ),
                            padding: EdgeInsets.all(8.sp),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                              color: isMe
                                  ? AppColors.primary
                                  : AppColors.background,
                            ),
                            // 18/10/2026: a TEXT bubble is as wide as its
                            // text (up to the responsive max).
                            child: _hugIfText(Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Who sent it (incoming only) ──
                                if (showSender && sender.name.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4.h),
                                    child: Text(
                                      sender.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: StyleText.fontSize12Weight500
                                          .copyWith(color: AppColors.blue),
                                    ),
                                  ),

                                // ── Replied message ──
                                if (messageModel.repliedMessage != null)
                                  GestureDetector(
                                    onTapDown: (_) => HapticController.low(),
                                    onTap: () {
                                      cubit.chatScrollCubit.scrollAndHighlight(
                                        messageModel.repliedMessage!.index,
                                      );
                                    },
                                    child: ReplyContent(
                                      model: messageModel.repliedMessage!,
                                    ),
                                  ),

                                // ── Main content ──
                                content,

                                // ── Time + seen row ──
                                if (!(hideSeen ?? false))
                                  _buildTimeAndSeenRow(context, isMe),
                              ],
                            )),
                          ),

                          // ── Reacts ──
                          if (messageModel.reacts.isNotEmpty &&
                              isOverlay == null)
                            PositionedDirectional(
                              bottom: -8.h,
                              child: CustomStackedAvatars(
                                avatars: messageModel.reacts
                                    .map((e) => e.getReact)
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                      if (selecting && isMe) _tick(cubit),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static double get _kTick => 22.sp;

  /// Selection tick (Figma "2 Selected"). A message that cannot be forwarded
  /// keeps the slot empty so the column of ticks stays straight.
  Widget _tick(MasterChatCubit cubit) {
    final bool can = MasterChatCubit.isForwardable(messageModel);
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 4.w),
      child: SizedBox.square(
        dimension: _kTick,
        child: can
            ? CustomCheckBox(
                isSelected:
                    cubit.selectedMessageIds.contains(messageModel.messageId),
                size: _kTick,
              )
            : null,
      ),
    );
  }

  /// The sender of an incoming message: the other person in a direct chat,
  /// the matching member in a group (name read from the email as a last
  /// resort).
  ({String name, String image}) _sender(MasterChatState state) {
    final ChatTypeEntity? side = state.otherConnectionSide;
    if (side is SingleConnectionEntity) {
      return (name: side.name, image: side.imageUri);
    }
    if (side is GroupEntity) {
      final String id = (messageModel.senderId ?? '').toLowerCase();
      for (final MemberEntity m in side.members) {
        if (m.memberId.toLowerCase() == id) {
          return (
            name: LocalizedTextHelper.formatString(
              secondaryLanguageText: m.secondaryLanguageName,
              primaryLanguageText: m.primaryLanguageName,
            ),
            image: m.memberImage,
          );
        }
      }
      return (
        name: FormatHelper.formatEmailToName(messageModel.senderId),
        image: messageModel is GroupMessageEntity
            ? (messageModel as GroupMessageEntity).senderImage
            : '',
      );
    }
    return (name: '', image: '');
  }

  // ── WhatsApp-style date separator logic ──
  Widget _buildDateSeparatorIfNeeded(MasterChatCubit cubit) {
    final messages = cubit.state.messages;
    final currentDate = messageModel.time.toDate();

    // First message → always show date
    if (index == 0) {
      return MessageDate(date: currentDate);
    }

    // Compare with previous message date
    final previousDate = messages[index - 1].time.toDate();
    final bool isDifferentDay = !_isSameDay(currentDate, previousDate);

    if (isDifferentDay) {
      return MessageDate(date: currentDate);
    }

    return const SizedBox.shrink();
  }

  /// The bubble's time: "1:07 PM" today, otherwise the day and the time —
  /// "Yesterday 10:58 PM", "14/10/2026 9:15 AM" (20/10/2026, owner: the day
  /// alone did not say when it was sent).
  String _bubbleTime(BuildContext context, DateTime t) {
    final String day = DateTimeHelper.formatTime(t);
    final String time =
        DateFormat('h:mm a', Localizations.localeOf(context).toString())
            .format(t);
    return day == time ? time : '$day $time';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _hugIfText(Widget child) =>
      messageModel.messageType == MessageTypes.text
          ? IntrinsicWidth(child: child)
          : child;

  Widget _buildTimeAndSeenRow(BuildContext context, bool isMe) {
    final seenAndUnseenEnabled = Get.find<MessagingInitController>()
        .messagingConfigurations
        .seenAndUnseen;

    // ── DEBUG ──
    if (isMe) {}

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Edited label
        if (messageModel.isEdited)
          Text(
            S.of(context).edited,
            style: StyleText.fontSize10Weight400.copyWith(
              color: isMe ? AppColors.textButton : AppColors.text,
            ),
            softWrap: true,
          ),

        const Spacer(),

        // Time
        Text(
          _bubbleTime(context, messageModel.time.toDate()),
          style: StyleText.fontSize8Weight500
              .copyWith(color: AppColors.secondaryBlack)
              .copyWith(
                color: !isMe ? AppColors.secondaryBlack : AppColors.textButton,
              ),
        ),

        SizedBox(width: 4.w),

        // ── Seen / Sent icon ──

        if (isMe &&
            Get.find<MainCoreEmployeeController>().isHasPermission(
              module: Modules.messages,
              section: MessagesPermissionsSections.messagesPermissions,
              permission: MessagesPermissions.seenAndUnseen,
            ))
          Icon(
            (seenAndUnseenEnabled && messageModel.isSeen)
                ? Icons.done_all
                : Icons.done,
            color: (seenAndUnseenEnabled && messageModel.isSeen)
                ? AppColors.blue
                : AppColors.textButton,
            size: ContextExtension(context).isTablet ? 18.sp : 16.sp,
          ),
      ],
    );
  }
}

/// 28 avatar beside an incoming bubble (D-184): the photo, or the initials.
class _SenderAvatar extends StatelessWidget {
  const _SenderAvatar({required this.image, required this.name});

  final String image;
  final String name;

  @override
  Widget build(BuildContext context) {
    final String initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .take(2)
        .map((String w) => w[0].toUpperCase())
        .join();
    return CircleAvatar(
      radius: 14.r,
      backgroundColor: AppColors.mediumGrey,
      foregroundImage: image.isEmpty ? null : appImageProvider(image),
      child: Text(
        initials,
        style: StyleText.fontSize10Weight500.copyWith(color: AppColors.text),
      ),
    );
  }
}
