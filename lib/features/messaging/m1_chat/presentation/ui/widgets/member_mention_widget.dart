/// Module: messaging / chat / presentation/ui/widgets/member_mention_widget.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Keep for context extensions only

import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/main_helper/localized_text_helper.dart';
import 'package:knowticed_plus/features/messaging/helpers/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/entities/member_entity.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/user_image.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class MemberMentionWidget extends StatelessWidget {
  final MemberEntity member;

  const MemberMentionWidget({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        final groupChatCubit =
            context.read<MasterChatCubit>() as GroupChatCubit;
        groupChatCubit.addMention(member);
      },
      child: ContextExtension(context).isTablet
          ? Container(
              // 20/10/2026: at least 88, wider for a long word so a name is
              // never cut ("Transformation").
              constraints: BoxConstraints(minWidth: 88.w, maxWidth: 140.w),
              padding: EdgeInsets.all(4.sp),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  verticalSpace(10),
                  _MentionAvatar(member: member, size: 35),
                  verticalSpace(5),
                  // 20/10/2026 (owner): one font size for every name (the
                  // FittedBox shrank long names); a long name wraps.
                  Text(
                    LocalizedTextHelper.formatString(
                      secondaryLanguageText: member.secondaryLanguageName,
                      primaryLanguageText: member.primaryLanguageName,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize12Weight500,
                  ),
                  verticalSpace(10),
                ],
              ),
            )
          : Row(
              spacing: 4.w,
              children: [
                _MentionAvatar(member: member, size: 30),
                Text(
                  LocalizedTextHelper.formatString(
                    secondaryLanguageText: member.secondaryLanguageName,
                    primaryLanguageText: member.primaryLanguageName,
                  ),
                  style: StyleText.fontSize12Weight500,
                ),
              ],
            ),
    );
  }
}

/// The member's photo in a circle, or a person icon when there is none
/// (20/10/2026 — the empty picture showed nothing).
class _MentionAvatar extends StatelessWidget {
  const _MentionAvatar({required this.member, required this.size});

  final MemberEntity member;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (member.memberImage.startsWith('http')) {
      return UserImage(member: member, radius: size);
    }
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
      ),
      child: Icon(Icons.person, size: size.r * 0.6, color: AppColors.text),
    );
  }
}
