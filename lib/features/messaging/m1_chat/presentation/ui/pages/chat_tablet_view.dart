/// Module: messaging / chat / presentation/ui/pages/chat_tablet_view.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/messaging/helpers/spacing_helper.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/entities/group_entity.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/app_bar/message_tablet_appbar.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/send_new_message/tablet_new_message.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/pages/chat_mobile_view.dart';

class ChatTabletView extends StatelessWidget {
  const ChatTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Read MasterChatCubit — works for both SingleChatCubit and GroupChatCubit
    // since both are provided as MasterChatCubit via BlocProvider.value in TabletChatSide
    final masterChatCubit = context.read<MasterChatCubit>();

    // Clear unread messages only for single chat
    if (masterChatCubit is SingleChatCubit &&
        masterChatCubit.state.otherConnectionSide != null) {
      masterChatCubit.clearNumOfUnReadMessages(
        currentUserId: context.read<ConnectionsCubit>().currentUser.userId,
        otherUserId: masterChatCubit.state.otherConnectionSide!.otherSideId,
      );
    }

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      builder: (context, state) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {},
          child: Row(
            children: [
              // ── Chat Column (always visible) ──────────────────
              Expanded(
                child: Column(
                  children: [
                    MessageTabletAppBar(),
                    // PinnedMessage(),
                    verticalSpace(16),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.sp),
                        child: MessageListView(
                          isGroup: state.otherConnectionSide is GroupEntity,
                        ),
                      ),
                    ),
                    // 18/10/2026 (D-146 / D-184): + and Send sit the SAME
                    // distance from the panel's sides and its bottom (was 25
                    // at the sides, 10 below).
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 25.sp,
                        end: 25.sp,
                        bottom: 25.sp,
                      ),
                      child: NewMessageTablet(),
                    ),
                  ],
                ),
              ),

              // // ── Media Panel (slides in from right) ────────────
              // AnimatedSize(
              //   duration: const Duration(milliseconds: 250),
              //   curve: Curves.easeInOut,
              //   child: state.isShowMedia
              //       ? SizedBox(
              //     width: 280.sp,
              //     child: MediaLinksWidget(),
              //   )
              //       : const SizedBox.shrink(),
              // ),
            ],
          ),
        );
      },
    );
  }
}
