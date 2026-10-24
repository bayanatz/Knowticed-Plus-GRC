/// Module: messaging / chat / presentation/ui/widgets/menus/menu_attachment_message.dart
library;
// Date: 18/8/2024
// By: Youssef Ashraf,  Nada Mohammed
// Last update: 18/2/2026
// Objectives: This file is responsible for providing a widget that represents the attachment message menu in the messaging screen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/messages/more_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/messages/messages_sections_enum.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/messaging/helpers/constants/messaging_assets.dart';
import 'package:knowticed_plus/features/messaging/helpers/enums/message_types.dart';
import 'package:knowticed_plus/features/messaging/helpers/haptic_feedback_helper.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/main_helper/message_action_types.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/buttons/menu_icon_button.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/menus/share_location_contact.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/dialogs/poll_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MenuAttachmentMessage extends StatelessWidget {
  final MasterChatCubit masterChatCubit;

  const MenuAttachmentMessage({
    super.key,
    required this.masterChatCubit,
  });

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MainCoreEmployeeController>();

    final bool showContact = mainController.isHasPermission(
      module: Modules.messages,
      permission: MoreMessagesPermissions.contact,
      section: MessagesPermissionsSections.morePermissions,
    );

    final bool showLocation = mainController.isHasPermission(
      module: Modules.messages,
      permission: MoreMessagesPermissions.location,
      section: MessagesPermissionsSections.morePermissions,
    );

    final bool showPhoto = mainController.isHasPermission(
      module: Modules.messages,
      permission: MoreMessagesPermissions.photo,
      section: MessagesPermissionsSections.morePermissions,
    );

    final bool showDocuments = mainController.isHasPermission(
      module: Modules.messages,
      permission: MoreMessagesPermissions.documents,
      section: MessagesPermissionsSections.morePermissions,
    );

    // Figma 6799:5666 — Poll.
    final bool showPoll = mainController.isHasPermission(
      module: Modules.messages,
      permission: MoreMessagesPermissions.poll,
      section: MessagesPermissionsSections.morePermissions,
    );

    // If no permissions at all, show nothing
    if (!showContact &&
        !showLocation &&
        !showPhoto &&
        !showDocuments &&
        !showPoll) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      width: 330.w,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      // CHANGED 2/9/2026: every Column here defaulted to MainAxisSize.max, so
      // inside the Dialog the menu stretched to the full available height and
      // rendered as a tall empty card with four icons at the top. min makes the
      // card wrap its two rows of buttons.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showContact)
                      MenuIconButton(
                        // Bug report #23: was `() {}`.
                        onTap: () {
                          // This menu's own context dies with the dialog, so
                          // the follow-up dialog hangs off the root navigator.
                          final hostContext =
                              Navigator.of(context, rootNavigator: true)
                                  .context;
                          Get.back();
                          shareContact(hostContext, masterChatCubit);
                        },
                        icon: AppAssets.contactImage,
                        text: S.of(context).contact,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showLocation)
                      MenuIconButton(
                        // Bug report #23: was `() {}` — now sends the current
                        // location like WhatsApp.
                        onTap: () {
                          // This menu's own context dies with the dialog, so
                          // the follow-up dialog hangs off the root navigator.
                          final hostContext =
                              Navigator.of(context, rootNavigator: true)
                                  .context;
                          Get.back();
                          shareCurrentLocation(hostContext, masterChatCubit);
                        },
                        icon:
                            "assets/icons_assets/messaging_assets/ic_place_map.svg",
                        text: S.of(context).location,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showPhoto)
                      MenuIconButton(
                        onTap: () {
                          HapticFeedbackHelper.triggerHapticFeedback(
                            vibration: VibrateType.mediumImpact,
                            hapticFeedback: HapticFeedback.mediumImpact,
                          );
                          Get.back();
                          masterChatCubit.selectMessageToMakeAction(
                            message: null,
                            context: context,
                            actionType: MessageActionTypes.newMessage,
                            newMessageType: MessageTypes.galleryImage,
                          );
                        },
                        icon: AppAssets.galleryImage,
                        // Bug report #15: "Gallery" → "Photos" (images
                        // only — see ImageMessageCubit.getImageGallery).
                        text:
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? 'الصور'
                                : 'Photos',
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showDocuments)
                      MenuIconButton(
                        onTap: () {
                          HapticFeedbackHelper.triggerHapticFeedback(
                            vibration: VibrateType.mediumImpact,
                            hapticFeedback: HapticFeedback.mediumImpact,
                          );
                          Get.back();
                          masterChatCubit.selectMessageToMakeAction(
                            message: null,
                            context: context,
                            actionType: MessageActionTypes.newMessage,
                            newMessageType: MessageTypes.doc,
                          );
                        },
                        icon: AppAssets.document,
                        text: S.of(context).document,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showPoll)
                      MenuIconButton(
                        onTap: () {
                          final hostContext =
                              Navigator.of(context, rootNavigator: true)
                                  .context;
                          Get.back();
                          showPollDialog(hostContext, masterChatCubit);
                        },
                        icon: AppAssets.poll,
                        text: S.of(context).poll,
                      ),
                  ],
                ),
              ),
              // CHANGED 2/9/2026: this was an empty Column, which takes the
              // full height it is offered and forced the row (and card) tall.
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }
}
