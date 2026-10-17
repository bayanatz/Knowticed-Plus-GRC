/// Module: messaging / chat / presentation/ui/widgets/app_bar/message_mobile_appbar.dart
library;
// Date: 6/8/2024
// By: Youssef Ashraf, Nada Mohammed
// Last update: 6/8/2024
// Objectives: This file is responsible for providing a widget that represents the app bar in the messaging screen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';

import 'package:grc_module/features/messaging/helpers/constants/messaging_assets.dart';
import 'package:grc_module/features/messaging/helpers/haptic_feedback_helper.dart';
import 'package:grc_module/features/messaging/helpers/messaging_bridge/main_helper/localized_text_helper.dart';
import 'package:grc_module/features/messaging/helpers/spacing_helper.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/messaging/m2_connections/domain/entities/single_connection_entity.dart';
import 'package:grc_module/features/messaging/m3_groups/domain/entities/group_entity.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/widgets/menus/message_menu_popup_button.dart';
import 'package:grc_module/core/custom/pickers/custom_image_picker.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:grc_module/core/custom/cards/stacked_avatars.dart';
import 'package:grc_module/core/theme/haptic_controller.dart'
    show HapticController;

class MessageMobileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final double height;
  const MessageMobileAppBar({super.key, this.height = kToolbarHeight});

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    bool isTablet = ContextExtension(context).isTablett;
    // DI via Bloc — provided by ChatMobileView's MultiBlocProvider (§3).
    final masterChatCubit = context.read<MasterChatCubit>();

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      bloc: masterChatCubit,
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            boxShadow: [
              BoxShadow(
                color: AppColors.grey.withValues(alpha: 0.2),
                blurRadius: 2.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: masterChatCubit is SingleChatCubit
              ? _buildSingleChatAppBar(context, isTablet, state)
              : masterChatCubit is GroupChatCubit
                  ? _buildGroupAppBar(context, isTablet, state)
                  : const SizedBox(),
        );
      },
    );
  }

  Widget _buildSingleChatAppBar(
      BuildContext context, bool isTablet, MasterChatState state) {
    if (state.otherConnectionSide == null) return const SizedBox();

    final singleConnection =
        state.otherConnectionSide as SingleConnectionEntity;

    return Container(
      color: AppColors.card,
      padding: EdgeInsetsDirectional.only(
        end: 0,
        top: 10.sp,
        bottom: 10.sp,
      ),
      child: Row(
        children: [
          _buildBackButton(context),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => HapticController.low(),
              onTap: () {
                //  Get.toNamed(Routes.singleChatProfile);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'profileChat',
                    child: Container(
                      height: 45.sp,
                      width: 45.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mediumGrey,
                        image: state.otherConnectionSide!.imageUri.isNotEmpty
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: state.otherConnectionSide!.imageUri
                                        .contains("http")
                                    ? NetworkImage(
                                        state.otherConnectionSide!.imageUri)
                                    : appImageProvider(
                                        state.otherConnectionSide!.imageUri),
                              )
                            : null,
                      ),
                      child: state.otherConnectionSide!.imageUri.isEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30.r),
                              child: CustomSvgImage(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                                width: 30.w,
                                height: 30.h,
                                fit: BoxFit.fill,
                              ),
                            )
                          : null,
                    ),
                  ),
                  horizontalSpace(5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8.sp,
                    children: [
                      Text(
                        singleConnection.name,
                        style: StyleText.fontSize14Weight500,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        singleConnection.subInfo,
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryBlack),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const MessageMenuPopupButton(isGroup: false),
          SizedBox(width: 8.sp),
        ],
      ),
    );
  }

  Widget _buildGroupAppBar(
      BuildContext context, bool isTablet, MasterChatState state) {
    if (state.otherConnectionSide == null) return const SizedBox();

    final groupEntity = state.otherConnectionSide as GroupEntity;

    return Container(
      color: AppColors.card,
      padding: EdgeInsetsDirectional.only(
        end: 0,
        top: 10.sp,
        bottom: 10.sp,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildBackButton(context),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      groupEntity.groupImage == null
                          ? Container(
                              height: 40.sp,
                              width: 40.sp,
                              padding: EdgeInsets.all(4.sp),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                color: AppColors.background,
                              ),
                              child: CustomSvgImage(
                                assetPath: AppAssets.message,
                                color: AppColors.text,
                                width: 20.sp,
                                height: 20.sp,
                              ),
                            )
                          : Hero(
                              tag: 'profileChat',
                              child: Container(
                                height: 40.sp,
                                width: 40.sp,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      state.otherConnectionSide!.imageUri,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      horizontalSpace(16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocalizedTextHelper.formatString(
                                secondaryLanguageText: state
                                    .otherConnectionSide!.secondaryLanguageName,
                                primaryLanguageText: state
                                    .otherConnectionSide!.primaryLanguageName,
                              ),
                              style: StyleText.fontSize14Weight500,
                              overflow: TextOverflow.ellipsis,
                            ),
                            verticalSpace(ContextExtension(context).isTablett
                                ? 4.sp
                                : 2.sp),
                            StackedAvatars(
                              height: 24.h,
                              avatarColor: AppColors.white,
                              avatarTextColor: AppColors.secondaryBlack,
                              width: 65.sp,
                              fontSize: 10.sp,
                              images: groupEntity.members
                                  .map((e) =>
                                      "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png")
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const MessageMenuPopupButton(),
            ],
          ),
        ],
      ),
    );
  }

  IconButton _buildBackButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      iconSize: 12.sp,
      onPressed: () {
        context.read<MasterChatCubit>().cancelChatMessagesSubscription();
        HapticFeedbackHelper.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact,
        );
        Get.back();
      },
      icon: CustomSvgImage(
        assetPath: Get.locale.toString().contains('en')
            ? AppAssets.mobileArrowBack
            : AppAssets.arrowForward,
        color: AppColors.text,
        width: ContextExtension(context).isTablett ? 24.w : 16.w,
        height: ContextExtension(context).isTablett ? 24.h : 16.h,
      ),
    );
  }
}
