/// Module: messaging/m1_chat
///
///*************************** FILE INFO ****************************///
/// File Name: starred_messages_view.dart
/// Description: `StarredMessagesView` page.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

// Date: 8/9/2024
// By: Nada Mohammed
// Last update: 8/9/2024
// Objectives: This file is responsible for providing starred messages view in the chat profile screen.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/messaging/helpers/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_app_bar.dart';

import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/message_controller.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/starred_message_card.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

class StarredMessagesView extends StatelessWidget {
  final String title;
  final String? imageUrl;

  const StarredMessagesView({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablett;

    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        if (state is! MessageLoaded || state.chatModel == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(title: S.of(context).starredMessages),
            body: const Center(child: CircleProgressMaster.inline()),
          );
        }

        final messageCubit = context.read<MessageCubit>();
        final starredMessagesCount = state.chatModel!.starredMessagesCount;
        final starredMessages = messageCubit.getStarredMessages();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(title: S.of(context).starredMessages),
          body: starredMessagesCount == 0
              ? SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24.w : 16.w,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.stars,
                          size: isTablet ? 220.w : 100.w,
                          color: AppColors.primary,
                        ),
                        verticalSpace(16),
                        Column(
                          children: [
                            Text(
                              S.of(context).noStarredMessages,
                              style: isTablet
                                  ? StyleText.fontSize28Weight500
                                  : StyleText.fontSize23Weight500,
                            ),
                            verticalSpace(isTablet ? 8 : 4),
                            Text(
                              textAlign: TextAlign.center,
                              S
                                  .of(context)
                                  .tapAndHoldOnAMessageToStarItAndItWillShowUpHere,
                              style: isTablet
                                  ? StyleText.fontSize23Weight400
                                  : StyleText.fontSize16Weight400,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: isTablet ? 24.w : 16.w,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        verticalSpace(20),
                        Container(
                          color: AppColors.background,
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: starredMessagesCount,
                            itemBuilder: (context, index) {
                              return StarredMessageCard(
                                index: index,
                                messageModel: starredMessages[index],
                                title: title,
                                imageUrl: imageUrl,
                                isGroup: state.chatModel!.groupModel != null,
                              );
                            },
                          ),
                        ),
                        verticalSpace(20),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
