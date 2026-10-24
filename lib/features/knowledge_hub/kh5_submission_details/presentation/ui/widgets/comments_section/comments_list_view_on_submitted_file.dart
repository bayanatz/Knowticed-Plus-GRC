/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/comments_section
/// ************************* FILE INFO *************************** ///
/// File Name: comments_list_view_on_submitted_file.dart
/// Description: Comments list view on submitted file — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_confirm_dialog.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/comments_section/comment_item_on_submitted_file.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Wrapper function for backwards compatibility
Widget commentsListViewOnSubmittedFile({
  required BuildContext context,
  required bool lightMode,
  required List<CreateNewCommentModel> comments,
  required SubmissionsCubit cubit,
  required String knowledgeId,
  String? currentUserEmail,
}) {
  return CommentsListViewOnSubmittedFile(
    parentContext: context,
    lightMode: lightMode,
    comments: comments,
    cubit: cubit,
    knowledgeId: knowledgeId,
    currentUserEmail: currentUserEmail,
  );
}

/// Enhanced Comments List View with CommentSection-style UI
class CommentsListViewOnSubmittedFile extends StatefulWidget {
  final BuildContext parentContext;
  final bool lightMode;
  final List<CreateNewCommentModel> comments;
  final SubmissionsCubit cubit;
  final String knowledgeId;
  final String? currentUserEmail;

  const CommentsListViewOnSubmittedFile({
    super.key,
    required this.parentContext,
    required this.lightMode,
    required this.comments,
    required this.cubit,
    required this.knowledgeId,
    this.currentUserEmail,
  });

  @override
  State<CommentsListViewOnSubmittedFile> createState() =>
      _CommentsListViewOnSubmittedFileState();
}

class _CommentsListViewOnSubmittedFileState
    extends State<CommentsListViewOnSubmittedFile> {
  final TextEditingController commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Injected at the route (submitted_documents_view_builders.dart).
  MediaPickerService get _mediaPicker => context.read<MediaPickerService>();
  bool isFullScreen = false;

  @override
  void dispose() {
    commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============= MEDIA UPLOAD =============
  Future<void> _pickMedia() async {
    final isDesktop =
        !kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows);
    final controller = widget.cubit.people.employees;

    final choice = await showAppDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SimpleDialog(
        backgroundColor: AppColors.card,
        title: Text(
          S.of(context).selectFileSource,
          style: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        children: [
          if (!isDesktop) _buildMediaOption(S.of(context).camera, 'camera'),
          _buildMediaOption(S.of(context).gallery, 'gallery'),
          _buildMediaOption(S.of(context).document, 'document'),
          _buildMediaOption(S.of(context).cancel, null),
        ],
      ),
    );

    if (choice == null || !mounted) return;

    String? filePath;
    String? fileName;
    String? fileExtension;
    int? fileSize;

    // Handle Camera or Gallery
    if (choice == 'camera' || choice == 'gallery') {
      final picked = await _mediaPicker.pickImage(
        fromCamera: choice == 'camera',
      );
      if (picked?.path == null) return;

      filePath = picked!.path;
      fileName = picked.name;
      fileExtension = fileName.split('.').last;
      fileSize = picked.bytes.length;
    }
    // Handle Document
    else if (choice == 'document') {
      final picked = await _mediaPicker.pickDocument(
        extensions: const ['pdf', 'doc', 'docx'],
      );
      if (picked?.path == null) return;

      filePath = picked!.path;
      fileName = picked.name;
      fileExtension = fileName.split('.').last;
      fileSize = picked.bytes.length;
    }

    if (filePath == null || fileName == null) return;

    final employeeEntity = controller.employeeEntity;
    if (employeeEntity == null ||
        employeeEntity.id == null ||
        employeeEntity.email == null) {
      if (!mounted) return;
      _showErrorSnackbar(S.of(context).error);
      return;
    }

    if (!mounted) return;
    _showLoadingDialog(S.of(context).uploading);
    // The cubit uploads the file and saves the comment with its link; it
    // never throws.
    final bool sent = await widget.cubit.addAttachmentComment(
      knowledgeId: widget.knowledgeId,
      file: File(filePath),
      fileName: fileName,
      attachmentExtension: fileExtension,
      attachmentSize: fileSize,
      createdById: employeeEntity.id!,
      createdByEmail: employeeEntity.email!,
    );
    if (!mounted) return;
    Navigator.of(context).pop(); // Hide loading

    if (sent) {
      _showSuccessSnackbar(S.of(context).uploadSuccess);
      _scrollToBottom();
    } else {
      _showErrorSnackbar(S.of(context).uploadFailed);
    }
  }

  Widget _buildMediaOption(String title, String? returnVal) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Container(
        decoration: BoxDecoration(
          color: returnVal == null ? AppColors.darkGrey : AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SimpleDialogOption(
            onPressed: () => Navigator.pop(context, returnVal),
            child: Text(
              title,
              style: StyleText.fontSize14Weight400.copyWith(
                color: returnVal == null
                    ? AppColors.text
                    : AppColors.textButton,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============= COMMENT ACTIONS =============
  Future<void> _sendMessage() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final controller = widget.cubit.people.employees;
    final employeeEntity = controller.employeeEntity;

    if (employeeEntity == null ||
        employeeEntity.id == null ||
        employeeEntity.email == null) {
      _showErrorSnackbar(S.of(context).error);
      return;
    }

    FocusScope.of(context).unfocus();

    await widget.cubit.addComment(
      knowledgeId: widget.knowledgeId,
      commentText: text,
      createdById: employeeEntity.id!,
      createdByEmail: employeeEntity.email!,
    );
    if (!mounted) return;
    if (widget.cubit.state is AddingCommentErrorState) {
      _showErrorSnackbar(S.of(context).failedToAddComment);
      return;
    }
    commentController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _editComment(CreateNewCommentModel comment, int index) {
    final editController = TextEditingController(
      text: comment.currentCommentText,
    );

    CustomDialogManager.showInput(
      context: context,
      controller: editController,
      title: S.of(context).EditMessage,
      hint: S.of(context).Edityourmessage,
      maxLines: 3,
      cancelText: S.of(context).Cancel,
      confirmText: S.of(context).Save,
      onConfirm: () async {
        final newText = editController.text.trim();
        if (newText.isNotEmpty) {
          // KH-SUBMIT-01 (critical): this closed the
          // dialog and said "saved" without writing anything. It now
          // calls the cubit and reports what really happened.
          await widget.cubit.updateComment(
            knowledgeId: widget.knowledgeId,
            commentId: comment.currentCommentId,
            newText: newText,
          );
          if (!mounted) return;
          final st = widget.cubit.state;
          if (st is UpdatingCommentErrorState) {
            _showErrorSnackbar(S.of(context).error);
          } else {
            _showSuccessSnackbar(S.of(context).Save);
          }
        }
      },
    );
  }

  void _deleteComment(CreateNewCommentModel comment) {
    showConfirmDialog(
      context: context,
      title: S.of(context).delete,
      subtitle: S.of(context).areYouSureYouWantToRemoveDocument,
      cancelLabel: S.of(context).no,
      confirmLabel: S.of(context).yes,
      lottieAsset:
          'assets/lottie_assets/main_lottie_assets/lot_action_delete.json',
      destructive: true,
      onConfirm: () async {
        // KH-SUBMIT-01 (critical): said "deleted"
        // without deleting. Now calls the cubit and reports the result.
        await widget.cubit.deleteComment(
          knowledgeId: widget.knowledgeId,
          commentId: comment.currentCommentId,
        );
        if (!mounted) return;
        final st = widget.cubit.state;
        if (st is DeletingCommentErrorState) {
          _showErrorSnackbar(S.of(context).error);
        } else {
          _showSuccessSnackbar(S.of(context).khCommentDeleted);
        }
      },
    );
  }

  // ============= UI HELPERS =============
  void _showLoadingDialog(String message) {
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: AppColors.card,
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleProgressMaster.inline(color: AppColors.primary),
                SizedBox(height: 16.h),
                Text(message, style: StyleText.fontSize14Weight500),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.lightGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ============= MAIN UI =============
  @override
  Widget build(BuildContext context) {
    final controller = widget.cubit.people.employees;
    final String? userEmail =
        widget.currentUserEmail ?? controller.employeeEntity?.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content container
        SizedBox(
          height: isFullScreen ? 570.h : 300.h,
          child: Column(
            children: [
              // Comments content area
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15.sp),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        // Comments list
                        ...List.generate(
                          widget.comments.length,
                          (index) => _buildCommentRow(
                            widget.comments[index],
                            index,
                            userEmail,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Input Field
              _buildInputRow(),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }

  /// One comment, with edit / delete on the signed-in user's own comments.
  Widget _buildCommentRow(
    CreateNewCommentModel comment,
    int index,
    String? userEmail,
  ) {
    final userId = comment.currentCreatedById;
    final userData = widget.cubit.usersCache[userId];

    bool isMyComment = false;
    if (userEmail != null) {
      isMyComment =
          comment.currentCreatedByEmail.toLowerCase().trim() ==
          userEmail.toLowerCase().trim();
    }

    // tryParse cannot throw, so no try/catch.
    final String timestampStr = comment.currentTimestamp;
    final int? millis = int.tryParse(timestampStr);
    final DateTime? createdAt =
        DateTime.tryParse(timestampStr) ??
        (millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis));

    return Padding(
      padding: EdgeInsets.only(bottom: 30.sp),
      child: commentItemOnSubmittedFile(
        context: context,
        commentText: comment.currentCommentText,
        attachmentExtension: comment.currentAttachmentExtension,
        attachmentSize: comment.currentAttachmentSize,
        createdAt: createdAt ?? DateTime.now(),
        createdByName:
            userData?.currentemployeeName ?? S.of(context).khUnknownUser,
        createdByRole: userData?.currentemployeeRole ?? '',
        createdByPhoto: userData?.currentemployeePhoto.isNotEmpty == true
            ? userData!.currentemployeePhoto
            : null,
        isMyComment: isMyComment,
        lightMode: widget.lightMode,
        onEdit: () => _editComment(comment, index),
        onDelete: () => _deleteComment(comment),
      ),
    );
  }

  /// The comment box with the attach and send buttons.
  Widget _buildInputRow() {
    return Row(
      children: [
        // Input Field with Upload Button
        Expanded(
          child: Container(
            height: 38.h,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: CustomTextField(
              controller: commentController,
              prefixIcon: Padding(
                padding: EdgeInsets.all(10.sp),
                child: GestureDetector(
                  onTapDown: hapticDown(_pickMedia, HapticLevel.medium),
                  onTap: _pickMedia,
                  child: CustomSvgImage.natural(
                    assetPath: "assets/icons_assets/main_icons_assets/ic_media_attach_square.svg",
                    width: 16.sp,
                    height: 16.sp,
                    color: widget.lightMode
                        ? AppColors.blackButton
                        : AppColors.whiteShadow,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
              hint: S.of(context).WriteaComment,
              fillColor: AppColors.card,
            ),
          ),
        ),

        SizedBox(width: 15.w),

        // Send Button
        GestureDetector(
          onTapDown: hapticDown(_sendMessage, HapticLevel.medium),
          onTap: _sendMessage,
          child: Container(
            width: 35.sp,
            height: 35.sp,
            decoration: BoxDecoration(
              color: AppColors.secondaryPrimary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: CustomSvgImage.natural(
              assetPath: "assets/icons_assets/main_icons_assets/ic_action_send_white.svg",
              width: 20.sp,
              height: 20.sp,
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
      ],
    );
  }
}
