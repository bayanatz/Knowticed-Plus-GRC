// Date: 5/9/2024
// By: Nada Mohammed, Youssef Ashraf
// Last update: 5/9/2024
// Objectives: This file is responsible for providing a widget that contains the chat profile header used in the chat profile screen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';


import 'package:grc_module/core/constants/message_module/app_assets.dart';
import 'package:grc_module/core/helper/main_helper/haptic_feedback_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import '../../controller/message_controller.dart';
import 'package:grc_module/core/custom/46_custom_image_picker.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class ChatProfileHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const ChatProfileHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        if (state is! MessageLoaded || state.chatModel == null) {
          return const SizedBox();
        }

        final chatModel = state.chatModel!;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ContextExtension(context).isTablett ? 24.w : 16.w,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedbackHelper.triggerHapticFeedback(
                    vibration: VibrateType.mediumImpact,
                    hapticFeedback: HapticFeedback.mediumImpact,
                  );
                  Navigator.of(context).pop();
                },
                child: Get.locale.toString().contains('en')
                    ? SvgPicture.asset(
                  AppAssets.mobileArrowBack,
                  color: AppColors.text,
                  width: ContextExtension(context).isTablett ? 24.w : 16.w,
                  height: ContextExtension(context).isTablett ? 24.h : 16.h,
                )
                    : SvgPicture.asset(
                  AppAssets.arrowForward,
                  color: AppColors.text,
                  width: ContextExtension(context).isTablett ? 24.w : 16.w,
                  height: ContextExtension(context).isTablett ? 24.h : 16.h,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Hero(
                      tag: 'profileChat',
                      child: Container(
                        height: 100.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          image: _getChatProfileImage(chatModel) != null &&
                              chatModel.groupModel == null
                              ? DecorationImage(
                            fit: BoxFit.cover,
                            image: appImageProvider(
                              _getChatProfileImage(chatModel),
                            ),
                          )
                              : DecorationImage(
                            fit: BoxFit.cover,
                            image: chatModel.groupModel != null &&
                                _getChatProfileImage(chatModel) != null
                                ? FileImage(
                              _getChatProfileImage(chatModel),
                            ) as ImageProvider
                                : appImageProvider(AppAssets.profile),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      textAlign: TextAlign.center,
                      title,
                      style: ContextExtension(context).isTablett
                          ? AppTextStyles.font23MediumBlackCairo
                          : AppTextStyles.font18BlackSemiBoldCairo,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: ContextExtension(context).isTablett
                          ? AppTextStyles.font16LightGreyRegularCairo
                          : AppTextStyles.font12LightGreyRegularCairo,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  dynamic _getChatProfileImage(chatModel) {
    if (chatModel.otherUser != null) {
      return chatModel.otherUser!.avatarUrl;
    } else if (chatModel.groupModel != null) {
      if (chatModel.groupModel!.groupImage != null) {
        return chatModel.groupModel!.groupImage;
      } else {
        // should be refactored to make no image avatar
        return null;
      }
    } else {
      return AppAssets.management;
    }
  }
}