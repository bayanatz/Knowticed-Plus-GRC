/// Module: messaging / connections / presentation/ui/widgets/connectionless_tile.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connectionless_tile.dart
/// Purpose: Connectionless tile — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 1/9/2024
// By: Nada Mohammed
// Last update: 1/9/2024
// Objectives: This file is responsible for providing the community new chats tile used in the community feature.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import 'package:grc_module/core/helper/main_helper/date_time_helper.dart';
import 'package:grc_module/core/helper/message_module/main_helper/localized_text_helper.dart';
import 'package:grc_module/core/helper/main_helper/spacing_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import '../../../domain/entities/single_connection_entity.dart';
import '../../controller/connections_controller.dart';
import 'package:grc_module/core/custom/46_custom_image_picker.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class ConnectionlessTile extends StatelessWidget {
  final SingleConnectionEntity chatModel;

  const ConnectionlessTile({
    super.key,
    required this.chatModel,
  });

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablett;

    return GestureDetector(
      onTap: () async {
        // DI via Bloc (team decision) — read the cubit from the widget tree
        // instead of GetX service-location (§3/§17).
        final connectionsCubit = context.read<ConnectionsCubit>();
        await connectionsCubit.createNewConnection(
            currentUser: connectionsCubit.currentUser,
            newConnectionUser: chatModel.toBaseMessagingInterface());
        connectionsCubit.selectConnection(chatModel, context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsetsDirectional.all(8.sp),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateTimeHelper.formatTime(
                      chatModel.lastMessageTime!.toDate()),
                  style: AppTextStyles.font12InputColorCairo
                      .copyWith(fontSize: 10.sp, height: 1.3),
                ),
              ],
            ),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.secondaryBlack,
                  radius: 20.r,
                  backgroundImage: chatModel.imageUri.contains('http')
                      ? NetworkImage(chatModel.imageUri)
                      : appImageProvider(chatModel.imageUri),
                ),
                horizontalSpace(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LocalizedTextHelper.formatString(
                          secondaryLanguageText:
                              chatModel.secondaryLanguageName,
                          primaryLanguageText: chatModel.primaryLanguageName,
                        ),
                        style: AppTextStyles.font14BlackCairoMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        S.of(context).leader,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.font12SecondaryBlackCairoRegular,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
