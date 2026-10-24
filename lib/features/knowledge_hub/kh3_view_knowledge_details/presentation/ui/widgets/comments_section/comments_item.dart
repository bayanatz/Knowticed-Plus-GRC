/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/comments_section/comments_item.dart
/// ************************* FILE INFO *************************** ///
/// File Name: comments_item.dart
/// Description: Contains the comment created on specific file in knowledge hub.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
/// Updated: Refactored to fetch user data from cubit cache
library;

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_cubit.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

Widget commentItem(
  BuildContext context, {
  required CreateNewCommentModel comment,
  required bool isMyComment,
  required CommentsCubit cubit, // ✅ Required to access user data cache
}) {
  final EmployeeData? userData = cubit.usersCache[comment.currentCreatedById];
  final DateTime? createdAt = KhLocale.parseStoredTime(
    comment.currentTimestamp,
  );
  final CrossAxisAlignment side = isMyComment
      ? CrossAxisAlignment.end
      : CrossAxisAlignment.start;

  return Align(
    alignment: isMyComment
        ? AlignmentDirectional.centerEnd
        : AlignmentDirectional.centerStart,
    child: Container(
      constraints: BoxConstraints(
        maxWidth: 0.75.sw, // Limit width to 75% of screen width
      ),
      child: Column(
        crossAxisAlignment: side,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCommentAuthor(
            context,
            userData: userData,
            isMyComment: isMyComment,
          ),
          SizedBox(height: 8.h),
          _buildCommentContent(
            context,
            comment: comment,
            isMyComment: isMyComment,
          ),
          SizedBox(height: 8.h),
          Text(
            KhLocale.formatDateNow(
              createdAt ?? DateTime.now(),
              'dd MMM yyyy, hh:mm a',
            ),
            style: StyleText.fontSize12Weight600.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Avatar, name and role — the avatar on the outer side of the bubble.
Widget _buildCommentAuthor(
  BuildContext context, {
  required EmployeeData? userData,
  required bool isMyComment,
}) {
  final String photo = userData?.currentemployeePhoto ?? '';
  final Widget avatar = CircleAvatar(
    backgroundColor: AppColors.background,
    radius: 17.5.r,
    backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
    child: photo.isEmpty ? Icon(Icons.person, color: AppColors.primary) : null,
  );
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: isMyComment
        ? MainAxisAlignment.end
        : MainAxisAlignment.start,
    children: [
      if (!isMyComment) ...[avatar, SizedBox(width: 5.w)],
      Column(
        crossAxisAlignment: isMyComment
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            userData?.currentemployeeName ?? S.of(context).khUnknownUser,
            style: StyleText.fontSize14Weight500,
          ),
          Text(
            userData?.currentemployeeRole ?? '',
            style: StyleText.fontSize12Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
      if (isMyComment) ...[SizedBox(width: 5.w), avatar],
    ],
  );
}

/// The comment text and its attachment.
Widget _buildCommentContent(
  BuildContext context, {
  required CreateNewCommentModel comment,
  required bool isMyComment,
}) {
  final bool attachmentOnly =
      comment.currentAttachmentExtension.isNotEmpty &&
      comment.currentCommentText.isEmpty;
  return Container(
    decoration: BoxDecoration(
      color: attachmentOnly || isMyComment
          ? AppColors.transparent
          : AppColors.background,
      borderRadius: BorderRadius.circular(8.r),
    ),
    padding: EdgeInsetsDirectional.only(
      top: 8.h,
      bottom: 8.h,
      start: 14.w,
      end: 21.w,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isMyComment
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (comment.currentCommentText.isNotEmpty)
          Text(
            comment.currentCommentText,
            style: StyleText.fontSize14Weight500,
          ),
        if (comment.currentAttachmentExtension.isNotEmpty)
          _buildAttachment(context, comment),
      ],
    ),
  );
}

Widget _buildAttachment(BuildContext context, CreateNewCommentModel comment) {
  // KH-CREATE-05: the attachment now opens. Older comments saved before the
  // fix have no link; they still show the chip, just not tappable.
  return GestureDetector(
    onTapDown: comment.hasAttachment ? (_) => HapticController.medium() : null,
    onTap: comment.hasAttachment
        ? () => launchUrl(
            Uri.parse(comment.currentAttachmentUrl),
            mode: LaunchMode.externalApplication,
          )
        : null,
    child: Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.background),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvgImage(
            assetPath: _getFileIcon(comment.currentAttachmentExtension),
            height: 50.sp,
            width: 45.sp,
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              comment.currentAttachmentName.isNotEmpty
                  ? comment.currentAttachmentName
                  : S.of(context).khAttachment,
              style: StyleText.fontSize12Weight500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (comment.currentAttachmentSize > 0)
            Text(
              ' (${_formatFileSize(comment.currentAttachmentSize)})',
              style: StyleText.fontSize10Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
        ],
      ),
    ),
  );
}

String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _getFileIcon(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
    case 'doc':
    case 'docx':
      return 'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
    case 'xls':
    case 'xlsx':
      return 'assets/icons_assets/main_icons_assets/ic_file_excel.svg';
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
    default:
      return 'assets/icons_assets/knowledge_hub_assets/ic_file_word.svg';
  }
}
