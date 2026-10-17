/// Module: messaging / chat / presentation/ui/widgets/pinned_message.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Keep for context extensions only

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/functions_on_messages_controllers/pin_message_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

class PinnedMessage extends StatelessWidget {
  const PinnedMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MasterChatCubit, MasterChatState>(
      builder: (context, state) {
        final cubit = context.read<MasterChatCubit>();

        return BlocBuilder<PinMessageCubit, PinMessageState>(
          bloc: cubit.pinnedMessageCubit,
          builder: (context, pinState) {
            if (pinState.pinnedMessagesInRow.isEmpty) {
              return const SizedBox.shrink();
            }

            // Get the current pinned message to display

            return GestureDetector(
              onTapDown: (_) => HapticController.low(),
              onTap: () {
                cubit.chatScrollCubit.scrollAndHighlight(
                  pinState.pinnedMessagesInRow.first,
                );
              },
              child: Column(
                children: [
                  // Container(
                  //   height: 60.h,
                  //   padding: EdgeInsetsDirectional.only(start: 24, end: 16.w),
                  //   color: AppColors.card,
                  //   child: Row(
                  //     spacing: 10.w,
                  //     children: [
                  //       Container(
                  //         height: 40.h,
                  //         width: 40.h,
                  //         padding: EdgeInsets.all(10.h),
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(8.r),
                  //           color: ContextExtension(context).isPhone
                  //               ? AppColors.darkGrey.withOpacity(0.1)
                  //               : AppColors.whiteShadow,
                  //         ),
                  //         child: SvgPicture.asset(AppAssets.pin),
                  //       ),
                  //       Expanded(
                  //         child: _buildMessageTypeIcon(state, currentMessage),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  _buildAppBarDivider(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppBarDivider() {
    return Divider(
      color: AppColors.lightGrey,
      thickness: 0.5,
      height: 1,
    );
  }
}
