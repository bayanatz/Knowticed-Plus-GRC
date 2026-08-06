/// Module: messaging / chat / presentation/ui/widgets/menus/menu_attachment_message.dart
// Date: 18/8/2024
// By: Youssef Ashraf,  Nada Mohammed
// Last update: 18/2/2026
// Objectives: This file is responsible for providing a widget that represents the attachment message menu in the messaging screen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/core/enums/message_module/permissions/messages_more_permissions.dart';
import 'package:grc_module/core/enums/message_module/permissions/messages_permissions_sections.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/constants/message_module/app_assets.dart';
import 'package:grc_module/core/enums/message_module/message_types.dart';
import 'package:grc_module/core/helper/main_helper/haptic_feedback_helper.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import '../../../../../../../core/helper/message_module/main_helper/message_action_types.dart';
import '../../../../../../../core/helper/message_module/interface/controller/messaging_init_controller.dart';
import '../buttons/menu_icon_button.dart';
import 'package:grc_module/generated/l10n.dart';

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
      permission: MessagesMorePermissions.contact,
      section: MessagesPermissionsSections.morePermissions,
    );

    final bool showLocation = mainController.isHasPermission(
      module: Modules.messages,
      permission: MessagesMorePermissions.location,
      section: MessagesPermissionsSections.morePermissions,
    );

    final bool showPhoto = mainController.isHasPermission(
      module: Modules.messages,
      permission: MessagesMorePermissions.photo,
      section: MessagesPermissionsSections.morePermissions,
    );

    final bool showDocuments = mainController.isHasPermission(
      module: Modules.messages,
      permission: MessagesMorePermissions.documents,
      section: MessagesPermissionsSections.morePermissions,
    );


    // If no permissions at all, show nothing
    if (!showContact && !showLocation && !showPhoto && !showDocuments) {
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showContact)
                      MenuIconButton(
                        onTap: () {},
                        icon: AppAssets.contactImage,
                        text: S.of(context).contact,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showLocation)
                      MenuIconButton(
                        onTap: () {},
                        icon: "assets/icons_assets/messaging_assets/location_svg.svg",
                        text: S.of(context).location,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
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
                        text: S.of(context).gallery,
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
              Expanded(child: Column()),
              Expanded(child: Column()),
            ],
          ),
        ],
      ),
    );
  }
}