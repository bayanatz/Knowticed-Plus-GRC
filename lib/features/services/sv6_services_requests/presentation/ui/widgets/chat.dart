/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: chat.dart
/// Purpose: Comment and attachment thread of one service request. All
///          reads, writes and file picking go through ChatCubit; this widget
///          only calls the cubit and shows its state.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/foundation.dart';

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/services/data/repository/chat_repository_impl.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/chat_cubit.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/chat_state.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/chat_message_tile.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/core/helper/current_user_context.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/chat_repository.dart';

class ChatCommentSectionRequest extends StatefulWidget {
  const ChatCommentSectionRequest({super.key, required this.modelId});

  final String modelId;

  @override
  State<ChatCommentSectionRequest> createState() =>
      _ChatCommentSectionRequestState();
}

class _ChatCommentSectionRequestState extends State<ChatCommentSectionRequest> {
  bool isExpanded = false;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _commentSectionKey = GlobalKey();

  /// Date and time of a message in the reader's language.
  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).add_jm().format(timestamp);
  }

  void _scrollToCommentSection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          _commentSectionKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final scrollController = Scrollable.of(context);
        scrollController.position.ensureVisible(
          renderBox,
          alignment: 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _sendMessage(ChatCubit cubit) async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    await cubit.sendTextMessage(text);
  }

  void _editMessage(ChatCubit cubit, ChatMessageData message) {
    if (message.text == null) return;

    final TextEditingController editController = TextEditingController(
      text: message.text,
    );

    showAppDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(dialogContext).EditMessage),
        content: CustomTextField(
          controller: editController,
          hint: S.of(dialogContext).Edityourmessage,
          maxLines: null,
        ),
        actions: [
          customButton(
            title: S.of(dialogContext).Cancel,
            function: () => Navigator.pop(dialogContext),
            width: 90.sp,
            height: 36.sp,
            color: AppColors.card,
            textColor: AppColors.text,
          ),
          customButton(
            title: S.of(dialogContext).Save,
            width: 90.sp,
            height: 36.sp,
            color: AppColors.primary,
            textColor: AppColors.textButton,
            function: () async {
              await cubit.editMessage(
                docId: message.docId,
                newText: editController.text,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
          ),
        ],
      ),
    ).whenComplete(editController.dispose);
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildMediaPreview(BuildContext context, ChatMessageData msg) {
    final imageUrl = msg.imagePath!;
    final isImage = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
    ].any((ext) => imageUrl.toLowerCase().contains(ext));
    final isPDF = imageUrl.toLowerCase().contains('.pdf');

    final iconAsset = isImage
        ? 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg'
        : 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
    final fallbackLabel = isImage
        ? S.of(context).image
        : isPDF
            ? S.of(context).svcChatAttachmentPdf
            : S.of(context).document;

    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () => _launchExternal(imageUrl),
      child: Row(
        children: [
          CustomSvgImage.natural(
            assetPath: iconAsset,
            width: 35.sp,
            height: 35.sp,
            fit: BoxFit.scaleDown,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              msg.text ?? fallbackLabel,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.blue,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomMenu(
    BuildContext context,
    ChatCubit cubit,
    Offset position,
    ChatMessageData message,
  ) {
    showAppDialog(
      context: context,
      barrierColor: AppColors.transparent,
      builder: (BuildContext dialogContext) {
        String? selectedItem;

        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return Stack(
              children: [
                Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: Material(
                    color: AppColors.transparent,
                    child: Container(
                      width: 150.w,
                      padding: EdgeInsets.symmetric(vertical: 8.sp),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildOptionItem(
                            dialogContext,
                            label: S.of(context).edit,
                            iconPath:
                                "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
                            isSelected: selectedItem == 'edit',
                            onTap: () {
                              setState(() => selectedItem = 'edit');
                              Future.delayed(Duration(milliseconds: 150), () {
                                if (!dialogContext.mounted) return;
                                Navigator.pop(dialogContext);
                                _editMessage(cubit, message);
                              });
                            },
                            selectedColor: AppColors.red,
                            selectedBackground: AppColors.primary,
                          ),
                          _buildOptionItem(
                            dialogContext,
                            label: S.of(context).delete,
                            iconPath:
                                "assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg",
                            isSelected: selectedItem == 'delete',
                            onTap: () {
                              setState(() => selectedItem = 'delete');
                              Future.delayed(Duration(milliseconds: 150), () {
                                if (!dialogContext.mounted) return;
                                Navigator.pop(dialogContext);
                                _confirmDelete(context, cubit, message);
                              });
                            },
                            selectedColor: AppColors.red,
                            selectedBackground: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// deleting a message asks first (it used to delete at once).
  Future<void> _confirmDelete(
    BuildContext context,
    ChatCubit cubit,
    ChatMessageData message,
  ) {
    return CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      confirmLottie: ServicesLottie.rejected,
      confirmTitle: S.of(context).deleteMessage,
      confirmSubtitle: S.of(context).AreYousureYouWanttoDeleteThisMessage,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () => cubit.deleteMessage(message.docId),
      showSuccessDialog: false,
      successLottie: ServicesLottie.approved,
      successTitle: S.of(context).deleteMessage,
      successSubtitle: S.of(context).youDeletedThisMessage,
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required String label,
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedColor,
    Color? selectedBackground,
  }) {
    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: Container(
        width: 280.sp,
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: isSelected ? selectedBackground : AppColors.card,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            CustomSvgImage.natural(
              assetPath: iconPath,
              fit: BoxFit.scaleDown,
              color: isSelected ? selectedColor : AppColors.secondaryText,
              width: 14.sp,
              height: 14.sp,
            ),
            SizedBox(width: 10.sp),
            Text(
              label,
              style: StyleText.fontSize13Weight500
                  .copyWith(color: AppColors.secondaryBlack)
                  .copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the source-selection dialog, then routes to the cubit — no
  /// file_picker/image_picker calls happen in this widget ().
  Future<void> _pickMedia(ChatCubit cubit) async {
    final isDesktop =
        !kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows);

    final choice = await showAppDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => SimpleDialog(
        title: Text(S.of(dialogContext).selectFileSource),
        children: [
          if (!isDesktop)
            _buildMediaOption(
              dialogContext,
              S.of(dialogContext).camera,
              'camera',
            ),
          _buildMediaOption(
            dialogContext,
            S.of(dialogContext).gallery,
            'gallery',
          ),
          _buildMediaOption(
            dialogContext,
            S.of(dialogContext).document,
            'document',
          ),
          _buildMediaOption(dialogContext, S.of(dialogContext).cancel, null),
        ],
      ),
    );

    if (choice == null) return;

    if (choice == 'camera' || choice == 'gallery') {
      await cubit.sendImageMessage(fromCamera: choice == 'camera');
    } else if (choice == 'document') {
      await cubit.sendDocumentMessage();
    }

    if (!mounted) return;
    final state = cubit.state;
    if (state is ChatError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S.of(context).uploadFailed)));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S.of(context).uploadSuccess)));
    }
  }

  Widget _buildMediaOption(
    BuildContext context,
    String title,
    String? returnVal,
  ) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SimpleDialogOption(
            onPressed: () => Navigator.pop(context, returnVal),
            child: Text(
              title,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.textButton,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        modelId: widget.modelId,
        repository: context.read<ChatRepository>(),
        mediaPicker: context.read<MediaPickerService>(),
        currentUserEmail: CurrentUserContext.email ?? '',
      )..loadComments(),
      child: BlocListener<ChatCubit, ChatState>(
        listenWhen: (_, current) =>
            current is ChatError && current.type != ChatErrorType.upload,
        listener: (context, state) {
          if (state is! ChatError) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_errorText(context, state.type))),
          );
        },
        child: Builder(
          builder: (context) {
            final cubit = context.read<ChatCubit>();
            var isMobile = ContextExtension(context).isPhone;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.sp),
              child: Column(
                key: _commentSectionKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).InquiriesAndComments,
                        style: isMobile
                            ? StyleText.fontSize16Weight500.copyWith(
                                color: AppColors.blackButton,
                              )
                            : StyleText.fontSize22Weight600.copyWith(
                                color: AppColors.blackButton,
                              ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTapDown: (_) => HapticController.low(),
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                          if (isExpanded) {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                _scrollToCommentSection();
                              },
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              isExpanded
                                  ? S.of(context).Hide
                                  : S.of(context).Expand,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: AppColors.blue,
                                decoration: TextDecoration.underline,
                                decorationThickness: 1.2,
                                decorationColor: AppColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.sp),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    child: isExpanded
                        ? AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeIn,
                            child: Container(
                              padding: EdgeInsets.only(bottom: 15.sp),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: BlocBuilder<ChatCubit, ChatState>(
                                builder: (context, state) {
                                  final messages = state is ChatLoaded
                                      ? state.messages
                                      : const <ChatMessageData>[];
                                  final isBusy =
                                      state is ChatLoaded && state.isBusy;

                                  return Column(
                                    children: [
                                      if (state is ChatLoading)
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 20.sp,
                                          ),
                                          child: Center(
                                            child:
                                                CircleProgressMaster.inline(),
                                          ),
                                        ),
                                      if (messages.isNotEmpty)
                                        ListView.builder(
                                          itemCount: messages.length,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final msg = messages[index];
                                            return TweenAnimationBuilder<
                                                double>(
                                              duration: Duration(
                                                milliseconds:
                                                    300 + (index * 50),
                                              ),
                                              curve: Curves.easeOutCubic,
                                              tween: Tween(
                                                begin: 0.0,
                                                end: 1.0,
                                              ),
                                              builder: (context, value, child) {
                                                return Transform.translate(
                                                  offset: Offset(
                                                    0,
                                                    20 * (1 - value),
                                                  ),
                                                  child: Opacity(
                                                    opacity: value,
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 15.sp,
                                                  left: 15.sp,
                                                  right: 15.sp,
                                                  top: index == 0 ? 15.sp : 0,
                                                ),
                                                child: ServicesChatMessageTile(
                                                  message: msg,
                                                  timeText: _formatTimestamp(
                                                    context,
                                                    msg.timestamp,
                                                  ),
                                                  // Edit / delete only on your own messages.
                                                  onLongPressStart:
                                                      cubit.canModify(msg)
                                                          ? (
                                                              details,
                                                            ) =>
                                                              _showCustomMenu(
                                                                context,
                                                                cubit,
                                                                details
                                                                    .globalPosition,
                                                                msg,
                                                              )
                                                          : null,
                                                  content: msg.imagePath != null
                                                      ? _buildMediaPreview(
                                                          context,
                                                          msg,
                                                        )
                                                      : Text(
                                                          msg.text ?? '',
                                                          style: StyleText
                                                              .fontSize12Weight400,
                                                        ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      SizedBox(height: 15.sp),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(width: 15.sp),
                                          Expanded(
                                            child: Container(
                                              height: 38.sp,
                                              decoration: BoxDecoration(
                                                color: AppColors.chatBackground,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 38.sp,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          8.r,
                                                        ),
                                                        color: Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.light
                                                            ? AppColors.white
                                                            : AppColors
                                                                .chatBackground,
                                                      ),
                                                      child: CustomTextField(
                                                        controller: _controller,
                                                        hint: S
                                                            .of(context)
                                                            .WriteaComment,
                                                        fillColor: AppColors
                                                            .background,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          8.r,
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                          vertical: 0,
                                                          horizontal: 8.w,
                                                        ),
                                                        valueStyle: StyleText
                                                            .fontSize14Weight500
                                                            .copyWith(
                                                          height: 1.4,
                                                        ),
                                                        hintStyle: StyleText
                                                            .fontSize14Weight500
                                                            .copyWith(
                                                          color: Theme.of(
                                                                    context,
                                                                  )
                                                                      .brightness ==
                                                                  Brightness
                                                                      .light
                                                              ? AppColors
                                                                  .secondaryText
                                                              : AppColors.grey,
                                                        ),
                                                        prefixIcon: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                            10.sp,
                                                          ),
                                                          child:
                                                              GestureDetector(
                                                            onTapDown: isBusy
                                                                ? null
                                                                : (_) =>
                                                                    HapticController
                                                                        .low(),
                                                            onTap: isBusy
                                                                ? null
                                                                : () =>
                                                                    _pickMedia(
                                                                      cubit,
                                                                    ),
                                                            child:
                                                                CustomSvgImage
                                                                    .natural(
                                                              assetPath:
                                                                  "assets/icons_assets/main_icons_assets/ic_media_camera_teal.svg",
                                                              width: 16.sp,
                                                              height: 16.sp,
                                                              color: Theme.of(
                                                                        context,
                                                                      )
                                                                          .brightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? AppColors
                                                                      .secondaryText
                                                                  : AppColors
                                                                      .whiteShadow,
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 15.sp),
                                          GestureDetector(
                                            onTapDown: (_) =>
                                                HapticController.medium(),
                                            onTap: () async =>
                                                await _sendMessage(cubit),
                                            child: Container(
                                              width: 35.sp,
                                              height: 35.sp,
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColors.secondaryPrimary,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: CustomSvgImage.natural(
                                                assetPath:
                                                    "assets/icons_assets/main_icons_assets/ic_action_send_white.svg",
                                                width: 20.sp,
                                                height: 20.sp,
                                                fit: BoxFit.scaleDown,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 15.sp),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _errorText(BuildContext context, ChatErrorType type) {
    final s = S.of(context);
    switch (type) {
      case ChatErrorType.load:
        return s.svcChatLoadFailed;
      case ChatErrorType.send:
        return s.svcChatSendFailed;
      case ChatErrorType.upload:
        return s.svcChatUploadFailed;
      case ChatErrorType.edit:
        return s.svcChatEditFailed;
      case ChatErrorType.delete:
        return s.svcChatDeleteFailed;
      case ChatErrorType.notAuthor:
        return s.svcChatNotAuthor;
    }
  }
}
