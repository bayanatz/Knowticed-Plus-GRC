/// Module: messaging / chat / presentation/ui/widgets/poll_details_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/message_controller.dart';


import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import '../../../../../../core/extension/context_extensions.dart';
import 'package:grc_module/core/helper/main_helper/custom_app_bar.dart';
import '../../../data/models/message/poll_message_model.dart';
import 'package:grc_module/core/custom/46_custom_image_picker.dart';
import 'package:grc_module/generated/l10n.dart';

// By: Youssef Ashraf
// Last update: 8/9/2024
// Main poll Details screen
class PollDetailsView extends StatelessWidget {
  final PollMessageModel model;

  const PollDetailsView({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: S.of(context).pollDetails,
      ),
      body: SafeArea(
        child: BlocBuilder<MessageCubit, MessageState>(
          builder: (context, state) {
            final cubit = context.read<MessageCubit>();
            final chatModel = state is MessageLoaded
                ? state.chatModel
                : cubit.chatModel;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ContextExtension(context).isTablett ? 24.w : 16.w,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: ContextExtension(context).isTablett ? 12.h : 8.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            model.question,
                            style: ContextExtension(context).isTablett
                                ? AppTextStyles.font23MediumBlackCairo
                                : AppTextStyles.font19BlackRegularCairo,
                          ),
                          if (chatModel?.groupModel != null)
                            Column(
                              children: [
                                SizedBox(
                                  height: ContextExtension(context).isTablett ? 24.h : 16.h,
                                ),
                                Text(
                                  '${model.uniqueMembersVotes()} ${S.of(context).ofLabel} ${chatModel!.groupModel!.groupMembers.length} ${S.of(context).membersVoted}',
                                  style: ContextExtension(context).isTablett
                                      ? AppTextStyles
                                      .font16SecondaryBlackCairoMedium
                                      : AppTextStyles
                                      .font12SecondaryBlackCairoMedium,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Divider(
                      color: AppColors.black,
                      thickness: 1.w,
                      height: 1,
                    ),
                    SizedBox(
                      height: ContextExtension(context).isTablett ? 50.h : 40.h,
                    ),
                    ...List.generate(
                      model.options.length,
                          (optionIndex) {
                        return Container(
                          padding: EdgeInsets.only(
                            left: 8.w,
                            right: 8.w,
                            top: 12.h,
                          ),
                          margin: EdgeInsets.only(
                            bottom: 12.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: AppColors.field,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        model.options[optionIndex],
                                        style: ContextExtension(context).isTablett
                                            ? AppTextStyles.font20BlackCairoMedium
                                            : AppTextStyles
                                            .font16BlackRegularCairo,
                                      ),
                                    ),
                                    Text(
                                      model.votes[optionIndex].toString(),
                                      style: ContextExtension(context).isTablett
                                          ? AppTextStyles
                                          .font16SecondaryBlackCairoMedium
                                          : AppTextStyles
                                          .font12SecondaryBlackCairoMedium,
                                    ),
                                  ],
                                ),
                              ),
                              if (model
                                  .voters[model.options[optionIndex]]!.isNotEmpty)
                                Divider(
                                  thickness: 1.h,
                                  color: AppColors.secondaryBlack,
                                ),
                              ...List.generate(
                                model.voters[model.options[optionIndex]]!.length,
                                    (index) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 6.h),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: appImageProvider(
                                            model
                                                .voters[model
                                                .options[optionIndex]]![index]
                                                .avatarUrl,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        Text(
                                          model
                                              .voters[model
                                              .options[optionIndex]]![index]
                                              .firstName,
                                          style: ContextExtension(context).isTablett
                                              ? AppTextStyles
                                              .font16LightGreyMediumCairo
                                              : AppTextStyles
                                              .font12LightGreyBoldCairo,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ));

                      },
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}