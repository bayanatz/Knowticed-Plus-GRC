/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/comments_section/build_comments_text_field.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_comments_text_field.dart
/// Description: Contains the text field to add new comment on file in knowledge hub.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
/// Updated: Refactored to use simplified comment model (only stores userId and email)
library;

import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_states.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CommentInputWidget extends StatefulWidget {
  final String knowledgeId;

  const CommentInputWidget({super.key, required this.knowledgeId});

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _commentController = TextEditingController();
  File? _selectedFile;
  String? _selectedFileName;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Picks a file and uploads it at once. A failed pick is treated as
  /// "nothing picked".
  Future<void> _pickFile() async {
    // The picker is injected at the route (view_knowledge_hub.dart).
    final picked = await context
        .read<MediaPickerService>()
        .pickDocument(
          extensions: const [
            'jpg',
            'jpeg',
            'png',
            'pdf',
            'doc',
            'docx',
            'xls',
            'xlsx',
          ],
        )
        .catchError((Object _) => null);
    if (picked?.path == null || !mounted) return;
    setState(() {
      _selectedFile = File(picked!.path!);
      _selectedFileName = picked.name;
    });
    context.read<CommentsCubit>().uploadAttachment(_selectedFile!);
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
    });
    context.read<CommentsCubit>().clearAttachment();
  }

  Future<void> _submitComment() async {
    final commentText = _commentController.text.trim();

    if (commentText.isEmpty && _selectedFile == null) {
      khLog('You can not add empty comment');
      return;
    }

    final employeeEntity = context
        .read<CommentsCubit>()
        .people
        .signedInEmployee!;
    khLog(employeeEntity.email ?? 'No email found', name: 'Employee email');

    // ✅ Only need userId and email - other user details fetched when displaying comments
    final String currentUserId = employeeEntity.id!;
    final String currentUserEmail = employeeEntity.email!;

    // Submit comment with simplified parameters
    await context.read<CommentsCubit>().createComment(
      knowledgeId: widget.knowledgeId,
      commentText: commentText,
      createdById: currentUserId,
      createdByEmail: currentUserEmail,
    );

    // Clear text field and file after submission
    _commentController.clear();
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentsCubit, CommentsState>(
      listener: (context, state) {
        if (state is UploadAttachmentSuccess) {
          Fluttertoast.showToast(
            msg: S.of(context).khFileUploaded,
            backgroundColor: AppColors.primary,
            textColor: AppColors.colorBlack,
          );
        } else if (state is UploadAttachmentFailure) {
          _removeFile();
          Fluttertoast.showToast(
            msg: S.of(context).khFileUploadFailed,
            backgroundColor: AppColors.red,
            textColor: AppColors.colorWhite,
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show selected file if exists
          if (_selectedFileName != null)
            Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.colorWhite,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file, size: 16.w, color: AppColors.primary),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      _selectedFileName!,
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18.w),
                    onPressed: withHaptic(_removeFile, HapticLevel.high),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          // Comment input
          Container(
            constraints: BoxConstraints(minHeight: 38.h, maxHeight: 120.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTextField(context),
                SizedBox(width: 10.w),
                _buildSendButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.card,
        ),
        height: 38.sp,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocBuilder<CommentsCubit, CommentsState>(
              builder: (context, state) {
                if (state is UploadAttachmentLoading) {
                  return CustomSvgImage(
                    assetPath: 'assets/icons_assets/main_icons_assets/ic_media_attach_square.svg',
                    height: 22.sp,
                    width: 22.sp,
                  );
                }
                return GestureDetector(
                  onTapDown: hapticDown(_pickFile, HapticLevel.medium),
                  onTap: _pickFile,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 10.w),
                    child: CustomSvgImage(
                      // 14/10/2026 — KH mobile report p.18 "increase icon
                      // size": 16 was hard to see and to hit on a phone.
                      assetPath: 'assets/icons_assets/main_icons_assets/ic_media_attach_square.svg',
                      height: 22.sp,
                      width: 22.sp,
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CustomTextField(
                controller: _commentController,
                maxLines: null,
                hint: S.of(context).write_a_comment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        final isLoading = state is CreateCommentLoading;

        return GestureDetector(
          onTapDown: isLoading ? null : (_) => HapticController.medium(),
          onTap: isLoading ? null : _submitComment,
          child: Container(
            width: 38.sp,
            height: 38.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.secondaryPrimary,
            ),
            alignment: Alignment.center,
            child: CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_comms_send.svg',
              height: 20.h,
              width: 20.w,
            ),
          ),
        );
      },
    );
  }
}

// Helper function to use in other files
Widget buildCommentInput(BuildContext context, {required String knowledgeId}) {
  return CommentInputWidget(knowledgeId: knowledgeId);
}
