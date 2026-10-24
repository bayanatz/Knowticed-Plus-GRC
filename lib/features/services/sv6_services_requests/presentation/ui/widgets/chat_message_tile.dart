/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: chat_message_tile.dart
/// Purpose: One message of a service-request comment thread: the sender's
///          avatar, name and job title, the message bubble and its time.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/repository/chat_repository_impl.dart';

/// A single comment in the thread.
class ServicesChatMessageTile extends StatelessWidget {
  const ServicesChatMessageTile({
    required this.message,
    required this.content,
    required this.timeText,
    this.onLongPressStart,
    super.key,
  });

  final ChatMessageData message;

  /// The bubble's content: the text, or the attachment preview.
  final Widget content;

  /// The message time, already formatted for the reader.
  final String timeText;

  /// Opens the edit / delete menu; null when the reader may not change it.
  final GestureLongPressStartCallback? onLongPressStart;

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final secondary = lightMode ? AppColors.secondaryText : AppColors.grey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: CustomSvgImage.natural(
                assetPath:
                    'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png',
                width: 35.sp,
                height: 35.sp,
                fit: BoxFit.scaleDown,
              ),
            ),
            SizedBox(width: 10.sp),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: lightMode ? AppColors.blackButton : AppColors.white,
                  ),
                ),
                Text(
                  message.senderTitle,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onLongPressStart: onLongPressStart,
          child: Padding(
            padding: EdgeInsets.only(top: 10.sp),
            child: Container(
              padding: message.text != null
                  ? EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp)
                  : EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: content,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.sp),
          child: Text(
            timeText,
            style: StyleText.fontSize10Weight400.copyWith(color: secondary),
          ),
        ),
      ],
    );
  }
}
