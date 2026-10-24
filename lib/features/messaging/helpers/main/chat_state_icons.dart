/// Module: messaging / main_controller / helper / chat_state_icons.dart
/// Purpose: The small pin / mute icons shown under the date on a chat card
///          (direct message or group). Bug report #20–#22.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/messaging/helpers/main/chat_settings_service.dart';

class ChatStateIcons extends StatelessWidget {
  const ChatStateIcons({
    super.key,
    required this.chatKey,
    this.hasPinnedMessage = false,
    this.padding,
  });

  /// ChatSettingsService key of the chat this card opens.
  final String chatKey;

  /// A message inside the chat is pinned — also shows the pin.
  final bool hasPinnedMessage;

  // Owner 21/10/2026: optional padding so the chat tiles can line the pin up with the time's end edge (null = old padding).
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: ChatSettingsService.pinnedChats,
      builder: (context, pinned, _) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: ChatSettingsService.mutedChats,
          builder: (context, muted, _) {
            final bool showPin = hasPinnedMessage || pinned.contains(chatKey);
            final bool showMute = muted.contains(chatKey);
            if (!showPin && !showMute) return const SizedBox.shrink();
            return Padding(
              padding:
                  padding ?? EdgeInsetsDirectional.only(top: 4.h, end: 4.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4.sp,
                children: [
                  if (showMute)
                    Icon(
                      Icons.volume_off_rounded,
                      size: 14.sp,
                      color: AppColors.secondaryBlack,
                    ),
                  if (showPin)
                    CustomSvgImage.natural(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_action_pin.svg',
                      width: 14.sp,
                      height: 14.sp,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
