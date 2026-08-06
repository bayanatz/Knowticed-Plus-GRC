/// Module: messaging / chat / presentation/ui/widgets/menus/message_menu_popup_button.dart
// Date: 6/8/2024
// By: Nada Mohammed , Youssef Ashraf
// Last update: 28/4/2026
// Objectives: This file is responsible for providing a widget that represents the message menu popup button in the messaging screen.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/constants/message_module/app_assets.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/widgets/menus/state_drop_down.dart';
import '../../../../../m3_groups/presentation/ui/pages/tablet/tablet_group_chat_profile_view.dart';
import '../../../../domain/enum/chat_actions.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import '../../../controller/main_controllers/group_chat_cubit.dart';
import '../../../controller/main_controllers/single_chat_cubit.dart';

class MessageMenuPopupButton extends StatelessWidget {
  const MessageMenuPopupButton({
    this.isGroup = true,
    super.key,
  });

  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: AppColors.transparent,
      ),
      child: SizedBox(
        width: 36.sp,
        child: StateDropDown(
            menuWidth: 200.sp,
            yOffset: 180.sp,
            xOffset: 10.sp,
            items: isGroup
                ? ChatActionsEnum.groupActions
                : ChatActionsEnum.singleActions,
            currentValue: null,
            customButton: SvgPicture.asset(
              AppAssets.more,
              color: AppColors.text,
            ),
            textButton: "",
            onChanged: (Enum value) {
              final cubit = context.read<MasterChatCubit>();

              switch (value as ChatActionsEnum) {
              // ── View Contact (single chat) — opens side panel ──
                case ChatActionsEnum.viewContact:
                  cubit.toggleContactInfoState();

              // ── View Group (group chat) ──
                case ChatActionsEnum.viewGroup:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TabletGroupChatProfileView(),
                    ),
                  );

              // ── Pin last pinned message to appbar ──
                case ChatActionsEnum.pin:
                  cubit.toggleChatPin();

              // ── Media, Links & Docs ──
                case ChatActionsEnum.mediaLinksAndDocs:
                  cubit.toggleMediaState();

              // ── TODO: Mute Notifications ──
                case ChatActionsEnum.muteNotifications:
                  break;

              // ── TODO: Disappearing Messages ──
                case ChatActionsEnum.disappearingMessages:
                  break;

              // ── TODO: Schedule Messages ──
                case ChatActionsEnum.scheduleMessages:
                  break;
              }
            }),
      ),
    );
  }
}