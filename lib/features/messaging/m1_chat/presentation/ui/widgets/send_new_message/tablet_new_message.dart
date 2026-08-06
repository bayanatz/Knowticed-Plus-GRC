/// Module: messaging / chat / presentation/ui/widgets/send_new_message/tablet_new_message.dart
// Date: 6/8/2024
// By: Youssef Ashraf, Nada Mohammed
// Last update: 27/4/2026
// Objectives: This file is responsible for providing a widget that represents the new message input in the direct messaging screen.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';


import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/constants/message_module/app_assets.dart';
import 'package:grc_module/core/enums/message_module/message_types.dart';
import 'package:grc_module/core/helper/main_helper/haptic_feedback_helper.dart';
import 'package:grc_module/core/helper/main_helper/spacing_helper.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import '../../../../../../../core/helper/message_module/interface/controller/messaging_init_controller.dart';
import '../cards/edit_card.dart';
import '../../../../../m3_groups/domain/entities/group_entity.dart';
import '../../../../../../../core/helper/message_module/main_helper/message_action_types.dart';
import '../../../controller/main_controllers/group_chat_cubit.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import '../../../controller/message_types_controllers/record_and_audio_cubit.dart';
import '../../pages/chat_mobile_view.dart';
import '../mention_card.dart';
import '../menus/menu_attachment_message.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class NewMessageTablet extends StatelessWidget {
  const NewMessageTablet({super.key});

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isArabic = Get.locale?.toString().contains('ar') ?? false;

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      builder: (context, state) {
        final cubit = context.read<MasterChatCubit>();

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // ── Reply preview ──────────────────────────────────────
            if (state.messageActionType == MessageActionTypes.replyMessage)
              Stack(
                alignment: AlignmentDirectional.topEnd,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: ReplyContent(
                      padding: EdgeInsets.only(left: 40.w, right: 90.w),
                      model: state.selectedMessage!,
                      constraints:
                      BoxConstraints(maxHeight: 65.h, minHeight: 45.h),
                      color: AppColors.background,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        cubit.replyMessageCubit.cancelReply(context),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                          end: 95.w, top: 5.h),
                      child: Icon(Icons.close,
                          color: AppColors.secondaryBlack, size: 24.sp),
                    ),
                  ),
                ],
              ),

            // ── Edit preview ───────────────────────────────────────
            if (state.messageActionType == MessageActionTypes.editMessage)
              Stack(
                alignment: AlignmentDirectional.topEnd,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 90.w, left: 40.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: EditCard(
                          content: state.selectedMessage?.messageContent),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        cubit.editAndDeleteMessageCubit.cancelEdit(context),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: 92.w),
                      child: Icon(Icons.close,
                          color: AppColors.secondaryBlack, size: 20.sp),
                    ),
                  ),
                ],
              ),

            Column(
              children: [
                // ── Mention card ───────────────────────────────────
                if (state is GroupChatState && state.showMentionCard)
                  Row(
                    children: [
                      SizedBox(width: 24.sp + 10.w),
                      Expanded(child: MentionCard()),
                      SizedBox(width: 10.w + 78.w),
                      if (!Platform.isMacOS && !Platform.isWindows)
                        SizedBox(width: 24.sp + 10.w),
                    ],
                  ),

                // ✅ Multi-file preview row (scrollable)
                if (state.hasSelectedFiles)
                  Padding(
                    padding: EdgeInsets.only(
                        right: 40.w, left: 40.w, bottom: 8.h, top: 4.h),
                    child: SizedBox(
                      height: 80.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.selectedMediaPaths.length +
                            state.selectedDocPaths.length,
                        separatorBuilder: (_, __) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          final isMedia =
                              index < state.selectedMediaPaths.length;

                          if (isMedia) {
                            // ── Image/Video thumbnail ──
                            final path = state.selectedMediaPaths[index];
                            return _FilePreviewItem(
                              onRemove: () =>
                                  cubit.removeSelectedMedia(index),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.file(
                                  File(path),
                                  width: 80.w,
                                  height: 80.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 80.w,
                                    height: 80.h,
                                    color: AppColors.background,
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: AppColors.secondaryBlack,
                                      size: 28.sp,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // ── Document icon ──
                            final docIndex =
                                index - state.selectedMediaPaths.length;
                            final path = state.selectedDocPaths[docIndex];
                            final fileName = path.split('/').last;
                            final ext = fileName.contains('.')
                                ? fileName.split('.').last.toUpperCase()
                                : 'DOC';

                            return _FilePreviewItem(
                              onRemove: () =>
                                  cubit.removeSelectedDoc(docIndex),
                              child: Container(
                                width: 80.w,
                                height: 80.h,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.insert_drive_file_outlined,
                                      color: AppColors.primary,
                                      size: 28.sp,
                                    ),
                                    SizedBox(height: 2.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.w),
                                      child: Text(
                                        ext,
                                        style: AppTextStyles
                                            .font12SecondaryBlackCairoRegular,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                // ── Input row ──────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Attachment button
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        HapticFeedbackHelper.triggerHapticFeedback(
                          vibration: VibrateType.mediumImpact,
                          hapticFeedback: HapticFeedback.mediumImpact,
                        );
                        final masterChatCubit =
                        context.read<MasterChatCubit>();
                        Get.defaultDialog(
                          contentPadding: EdgeInsets.zero,
                          titlePadding: EdgeInsets.zero,
                          backgroundColor: AppColors.card,
                          title: '',
                          content: MenuAttachmentMessage(
                            masterChatCubit: masterChatCubit,
                          ),
                        );
                      },
                      child: Container(
                        width: 28.sp,
                        height: 28.sp,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.sp),
                          color: AppColors.primary,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppAssets.add,
                            color: AppColors.icon,
                            width: 16.w,
                            height: 16.h,
                          ),
                        ),
                      ),
                    ),

                    horizontalSpace(10),

                    // Text input
                    Expanded(
                      child: BlocBuilder<RecordAndAudioCubit,
                          RecordAndAudioState>(
                        builder: (context, audioState) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: audioState.isRecording
                                ? const RecordingCard()
                                : Padding(
                              padding: EdgeInsets.only(top: 0.h),
                              child: CustomTextField(
                                hint: S.of(context).typeYourMessage,
                                controller: cubit
                                    .textMessageEditingController,
                                height: 36,
                                textAlign: isArabic
                                    ? TextAlign.right
                                    : TextAlign.left,
                                maxLines: 1,
                                showCharCount: false,
                                fillColor: AppColors.background,
                                textDirection: isArabic
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                onChanged: cubit.setCurrentMessage,
                                // ✅ NEW: Send message on Enter key press (laptop/desktop)
                                onSubmitted: (_) {
                                  final hasContent = cubit
                                      .textMessageEditingController
                                      .text
                                      .isNotEmpty ||
                                      state.hasSelectedFiles;
                                  if (!hasContent) return;
                                  HapticFeedbackHelper
                                      .triggerHapticFeedback(
                                    vibration:
                                    VibrateType.mediumImpact,
                                    hapticFeedback:
                                    HapticFeedback.mediumImpact,
                                  );
                                  cubit.applySelectedMessageAction(
                                      context);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Camera button
                    if (!Platform.isMacOS && !Platform.isWindows)
                      horizontalSpace(10),
                    if (!Platform.isMacOS && !Platform.isWindows)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (Get.find<MessagingInitController>()
                              .messagingConfigurations
                              .photo)
                            GestureDetector(
                              onTap: () {
                                HapticFeedbackHelper.triggerHapticFeedback(
                                  vibration: VibrateType.mediumImpact,
                                  hapticFeedback:
                                  HapticFeedback.mediumImpact,
                                );
                                cubit.selectMessageToMakeAction(
                                  message: null,
                                  actionType: MessageActionTypes.newMessage,
                                  newMessageType: MessageTypes.cameraImage,
                                  context: context,
                                );
                              },
                              child: SvgPicture.asset(
                                AppAssets.camera,
                                color: AppColors.text,
                                width: 24.sp,
                                height: 24.sp,
                              ),
                            ),
                        ],
                      ),
                    horizontalSpace(10),

                    // ✅ Send button — spinner while uploading
                    state.isSending
                        ? SizedBox(
                      width: isPortrait ? 36.h : 78.w,
                      height: 36.h,
                      child: Center(
                        child: SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                        : Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child:
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable:
                        cubit.textMessageEditingController,
                        builder: (context, textValue, child) {
                          final hasContent =
                              textValue.text.isNotEmpty ||
                                  state.hasSelectedFiles;
                          return GestureDetector(
                            onTap: () {
                              if (!hasContent) return;
                              HapticFeedbackHelper
                                  .triggerHapticFeedback(
                                vibration: VibrateType.mediumImpact,
                                hapticFeedback:
                                HapticFeedback.mediumImpact,
                              );
                              cubit.applySelectedMessageAction(
                                  context);
                            },
                            child: Container(
                              width: isPortrait ? 36.h : 78.w,
                              height: 27.h,
                              decoration: BoxDecoration(
                                color: hasContent
                                    ? AppColors.primary
                                    : AppColors.primary
                                    .withOpacity(0.4),
                                borderRadius:
                                BorderRadius.circular(5.91.r),
                              ),
                              alignment: Alignment.center,
                              child: isPortrait
                                  ? Transform.rotate(
                                angle: context.isArabic
                                    ? 3.14
                                    : 0,
                                child: SvgPicture.asset(
                                  AppAssets.send,
                                  width: 20.sp,
                                  height: 20.sp,
                                  color:
                                  AppColors.textButton,
                                ),
                              )
                                  : Text(S.of(context).send,
                                  style: AppTextStyles
                                      .font16ButtonMediumCairo),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ✅ Reusable file preview item with X remove button
// ─────────────────────────────────────────────────────────────────────────────

class _FilePreviewItem extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;

  const _FilePreviewItem({
    required this.child,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top: -4.h,
          end: -4.w,
          child: GestureDetector(
            onTap: onRemove,
            child: CircleAvatar(
              radius: 10.r,
              backgroundColor: AppColors.secondaryBlack,
              child: Icon(Icons.close, size: 12.sp, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }
}