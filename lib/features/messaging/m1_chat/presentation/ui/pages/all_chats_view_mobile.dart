/// Module: messaging / chat / presentation/ui/pages/all_chats_view_mobile.dart
// Date: 18/9/2024
// By: Mohamed Ashraf
// Last update: 18/9/2024
// Objectives: This file is responsible for providing the all chats view.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/messaging/m2_connections/presentation/controller/community_controller.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/chat/chat_model.dart';

import 'package:grc_module/core/constants/message_module/app_assets.dart';
import 'package:grc_module/core/helper/main_helper/spacing_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import '../../../../../../core/extension/context_extensions.dart';
import 'package:grc_module/core/helper/main_helper/custom_app_bar.dart';
import '../../../data/models/message/message_model.dart';
import '../widgets/all_chats_tile.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class AllChatsViewMobile extends StatelessWidget {
  final List<MessageModel> message;

  const AllChatsViewMobile({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablett;

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          context.read<CommunityCubit>().resetSelectedChats();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<CommunityCubit, CommunityState>(
            builder: (context, state) {
              final cubit = context.read<CommunityCubit>();

              // Extract state values
              final frequentlyContacted = state is CommunityLoaded
                  ? state.frequentlyContacted
                  : <ChatModel>[];
              final allChats = state is CommunityLoaded
                  ? state.allChats
                  : <ChatModel>[];
              final isSelectedChat = state is CommunityLoaded
                  ? state.isSelectedChat
                  : false;

              return Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomAppBar(
                        title: S.of(context).forwardTo,
                        centerTitle: false,
                        actionWidget: Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: 16.w,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (isSelectedChat) {
                                cubit.forwardMessage(message, context);
                                Navigator.of(context).pop();
                              }
                            },
                            child: SvgPicture.asset(
                              AppAssets.forward,
                              width: 24.w,
                              height: 24.h,
                              color: isSelectedChat
                                  ? AppColors.secondaryPrimary
                                  : AppColors.darkGrey,
                            ),
                          ),
                        ),
                      ),
                      verticalSpace(24),
                      CustomTextField(
                        hint: S.of(context).search,
                        hintStyle: ContextExtension(context).isTablett
                            ? AppTextStyles.font23LightGreyMediumCairo
                            : AppTextStyles.font16LightGreyMediumCairo,
                        controller: cubit.searchController,
                        prefixIcon: SvgPicture.asset(
                          AppAssets.search,
                        ),),
                      verticalSpace(24),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          S.of(context).frequentlyContacted,
                          style: ContextExtension(context).isTablett
                              ? AppTextStyles.font14BlackCairoMedium
                              : AppTextStyles.font14BlackCairoMedium,
                        ),
                      ),
                      verticalSpace(8.h),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.isDark ?? false
                              ? AppColors.field
                              : AppColors.background,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: frequentlyContacted.length,
                          itemBuilder: (context, index) {
                            return AllChatsTile(
                              chat: frequentlyContacted[index],
                            );
                          },
                        ),
                      ),
                      verticalSpace(isTablet ? 24 : 16),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          S.of(context).recentlyContacted,
                          style: ContextExtension(context).isTablett
                              ? AppTextStyles.font14BlackCairoMedium
                              : AppTextStyles.font14BlackCairoMedium,
                        ),
                      ),
                      verticalSpace(8.h),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.isDark ?? false
                              ? AppColors.field
                              : AppColors.background,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: allChats.length,
                          itemBuilder: (context, index) {
                            return AllChatsTile(
                              chat: allChats[index],
                            );
                          },
                        ),
                      ),
                      verticalSpace(24),
                      // BLoC version of the commented button code:
                      // AppDefaultButton(
                      //   width: double.infinity,
                      //   textColor: isSelectedChat
                      //       ? AppColors.base
                      //       : AppColors.darkGrey,
                      //   color: isSelectedChat
                      //       ? AppColors.primary
                      //       : AppColors.moreLightGrey,
                      //   text: 'Send'.tr,
                      //   style: AppTextStyles.font18BlackCairoMedium,
                      //   onPressed: () {
                      //     if (isSelectedChat) {
                      //       cubit.forwardMessage(message, context);
                      //       Navigator.of(context).pop();
                      //     }
                      //   },
                      // ,)
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}