/// Module: messaging / chat / presentation/ui/widgets/menus/message_overlay/menu_items.dart
// message menu items

part of '../../../pages/chat_mobile_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MessageMenuItems
// ─────────────────────────────────────────────────────────────────────────────

class MessageMenuItems extends StatelessWidget {
  const MessageMenuItems({
    super.key,
    required this.overlayEntry,
    required this.messageModel,
    required this.index,
  });

  final OverlayEntry? overlayEntry;
  final MessageEntity messageModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MasterChatCubit>();
    final isMe = messageModel.isMe;

    final mainController = Get.find<MainCoreEmployeeController>();

    final bool hasEditPermission = mainController.isHasPermission(
      module: Modules.messages,
      permission: MessagesPermissions.editMessage,
      section: MessagesPermissionsSections.messagesPermissions,
    );

    final bool hasDeletePermission = mainController.isHasPermission(
      module: Modules.messages,
      permission: MessagesPermissions.deleteMessage,
      section: MessagesPermissionsSections.messagesPermissions,
    );

    final bool hasReactionsPermission = mainController.isHasPermission(
      module: Modules.messages,
      permission: MessagesPermissions.reactions,
      section: MessagesPermissionsSections.messagesPermissions,
    );

    return Container(
      width: 154.w,
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Edit (own text messages only + permission) ────────────
            if (isMe &&
                messageModel.messageType == MessageTypes.text &&
                hasEditPermission)
              _MenuItem(
                svgPath: "assets/icons_assets/main_icons_assets/assets_edit.svg",
                label: S.of(context).Edit,
                onTap: () {
                  overlayEntry?.remove();
                  overlayEntry?.dispose();
                  cubit.selectMessageToMakeAction(
                    message: messageModel,
                    actionType: MessageActionTypes.editMessage,
                    newMessageType: null,
                    context: context,
                  );
                },
              ),

            // ── Reply (everyone can reply) ────────────────────────────
            _MenuItem(
              svgPath: AppAssets.reply,
              label: S.of(context).reply,
              onTap: () {
                overlayEntry?.remove();
                overlayEntry?.dispose();
                cubit.selectMessageToMakeAction(
                  message: messageModel,
                  actionType: MessageActionTypes.replyMessage,
                  newMessageType: null,
                  context: context,
                );
              },
            ),

            // ── Copy (text messages only) ─────────────────────────────
            if (messageModel.messageType == MessageTypes.text)
              _MenuItem(
                svgPath: AppAssets.copy,
                label: S.of(context).copy,
                onTap: () {
                  overlayEntry?.remove();
                  overlayEntry?.dispose();
                  Clipboard.setData(
                    ClipboardData(text: messageModel.messageContent ?? ''),
                  );
                },
              ),

            // ── Star / Unstar (everyone) ──────────────────────────────
            _MenuItem(
              svgPath: "assets/icons_assets/messaging_assets/star.svg",
              label: messageModel.isStarred
                  ? S.of(context).unStar
                  : S.of(context).star,
              onTap: () {
                overlayEntry?.remove();
                overlayEntry?.dispose();
                cubit.toggleStarMessage(messageIndex: index);
              },
            ),

            // ── Pin / Unpin (everyone) ────────────────────────────────
            _MenuItem(
              svgPath: AppAssets.pin,
              label: messageModel.isPinned ? S.of(context).unpin : S.of(context).pin,
              onTap: () {
                cubit.pinnedMessageCubit.updatePinMessage(messageModel);
                overlayEntry?.remove();
                overlayEntry?.dispose();

              },
            ),

            // ── Delete (own messages only + permission) ───────────────
            if (isMe && hasDeletePermission)
              _MenuItem(
                svgPath: AppAssets.trash,
                label: S.of(context).Delete,
                labelColor: const Color(0xffDF1C1C),
                onTap: () {
                  overlayEntry?.remove();
                  overlayEntry?.dispose();
                  cubit.selectMessageToMakeAction(
                    message: messageModel,
                    actionType: MessageActionTypes.deleteMessage,
                    newMessageType: null,
                    context: context,
                  );
                  CustomDialogManager.showDialogFlow(
                    context: context,
                    confirmLottie: AppAssets.trashGif,
                    confirmTitle: S.of(context).DeleteMessage,
                    confirmSubtitle:
                        S.of(context).AreYousureYouWanttoDeleteThisMessage,
                    confirmYesText: S.of(context).Delete,
                    confirmNoText: S.of(context).Cancel,
                    // showDialogFlow pops the confirm dialog itself, so the
                    // manual Get.back() calls the old DeleteDialog needed are gone.
                    onNoPressed: () {
                      cubit.selectMessageToMakeAction(
                        message: messageModel,
                        actionType: MessageActionTypes.newMessage,
                        newMessageType: null,
                        context: context,
                      );
                    },
                    onConfirm: () async {
                      cubit.applySelectedMessageAction(context);
                      return true;
                    },
                    successLottie: AppAssets.trashGif,
                    successTitle: S.of(context).DeleteMessage,
                    successSubtitle: S.of(context).DeleteMessage,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MenuItem  (private reusable row)
// ─────────────────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? svgPath;
  final Color? labelColor;

  const _MenuItem({
    required this.label,
    required this.onTap,
    this.icon,
    this.svgPath,
    this.labelColor,
  }) : assert(
  icon != null || svgPath != null,
  '_MenuItem needs either icon or svgPath',
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        overlayColor: WidgetStatePropertyAll(
          AppColors.primary.withOpacity(0.15),
        ),
        onTap: onTap,
        child: SizedBox(
          height: 40.h,
          child: Row(
            children: [
              horizontalSpace(16),
              if (icon != null)
                Icon(icon, color: AppColors.secondaryBlack, size: 18.sp)
              else
                SvgPicture.asset(
                  svgPath!,
                  width: 18.w,
                  height: 18.h,
                ),
              horizontalSpace(9),
              Text(
                label,
                style: AppTextStyles.font14BlackCairoMedium.copyWith(
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}