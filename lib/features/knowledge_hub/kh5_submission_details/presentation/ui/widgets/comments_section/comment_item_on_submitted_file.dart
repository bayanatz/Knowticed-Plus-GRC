/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/comments_section
/// ************************* FILE INFO *************************** ///
/// File Name: comment_item_on_submitted_file.dart
/// Description: Comment item on submitted file — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

Widget commentItemOnSubmittedFile({
  required BuildContext context,
  required bool isMyComment,
  String? createdByPhoto,
  required String createdByName,
  required String createdByRole,
  required String commentText,
  String? attachmentExtension,
  int? attachmentSize,
  required DateTime createdAt,
  required bool lightMode,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  return Container(
    height: 180.h,
    decoration: BoxDecoration(color: AppColors.card),
    child: Padding(
      padding: EdgeInsets.only(
        bottom: 15.h,
        left: 15.w,
        right: 15.w,
        top: 15.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentAuthorRow(
            photo: createdByPhoto,
            name: createdByName,
            role: createdByRole,
          ),
          SizedBox(height: 10.h),
          // Long-press opens Edit / Delete on your own comment.
          GestureDetector(
            onLongPress: isMyComment
                ? () => _showCustomMenu(
                    context,
                    lightMode: lightMode,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  )
                : null,
            child: _buildCommentBubble(
              context,
              commentText: commentText,
              attachmentExtension: attachmentExtension,
              attachmentSize: attachmentSize,
              lightMode: lightMode,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            KhLocale.formatDate(context, createdAt, 'd MMM yyyy, h:mm a'),
            style: StyleText.fontSize10Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Avatar, name and role of the comment's author.
Widget _buildCommentAuthorRow({
  required String? photo,
  required String name,
  required String role,
}) {
  final Widget placeholder = CustomSvgImage.natural(
    assetPath: "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
    width: 35.sp,
    height: 35.sp,
    fit: BoxFit.cover,
  );
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        backgroundColor: AppColors.chatBackground,
        radius: 17.5.r,
        child: photo != null && photo.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  photo,
                  width: 35.r,
                  height: 35.r,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => placeholder,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    final int? total = loadingProgress.expectedTotalBytes;
                    return Center(
                      child: CircleProgressMaster.inline(
                        value: total != null
                            ? loadingProgress.cumulativeBytesLoaded / total
                            : null,
                      ),
                    );
                  },
                ),
              )
            : placeholder,
      ),
      SizedBox(width: 10.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),
            SizedBox(height: 5.sp),
            if (role.isNotEmpty)
              Text(
                role,
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

/// The comment text and its attachment, if any.
Widget _buildCommentBubble(
  BuildContext context, {
  required String commentText,
  required String? attachmentExtension,
  required int? attachmentSize,
  required bool lightMode,
}) {
  final String extension = attachmentExtension ?? '';
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (commentText.isNotEmpty)
          Text(
            commentText,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.blackButton,
            ),
          ),
        if (extension.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: commentText.isNotEmpty ? 8.h : 0),
            child: _buildAttachmentPreview(
              context,
              extension,
              attachmentSize ?? 0,
              lightMode,
            ),
          ),
      ],
    ),
  );
}

// Attachment Preview Widget
Widget _buildAttachmentPreview(
  BuildContext context,
  String extension,
  int size,
  bool lightMode,
) {
  final isImage = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ].any((ext) => extension.toLowerCase().contains(ext));
  extension.toLowerCase().contains('pdf');

  return Row(
    children: [
      CustomSvgImage.natural(
        assetPath: isImage
            ? 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg'
            : 'assets/icons_assets/main_icons_assets/ic_pdf.svg',
        width: 35.sp,
        height: 35.sp,
        fit: BoxFit.scaleDown,
      ),
      SizedBox(width: 8.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isImage
                  ? S.of(context).khImageAttachment
                  : S.of(context).khDocumentAttachment,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.blue,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (size > 0)
              Text(
                _formatFileSize(size),
                style: StyleText.fontSize10Weight400.copyWith(
                  color: lightMode
                      ? AppColors.colorBlack.withValues(alpha: 0.54)
                      : AppColors.colorWhite.withValues(alpha: 0.54),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

// Format file size
String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

// Custom Menu for Edit/Delete
void _showCustomMenu(
  BuildContext context, {
  required bool lightMode,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  String? selectedItem;

  showAppDialog(
    context: context,
    barrierColor: AppColors.colorBlack.withValues(alpha: 0.26),
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTapDown: (_) => HapticController.high(),
            onTap: () => Navigator.pop(dialogContext),
            child: Material(
              color: AppColors.transparent,
              child: Center(
                child: Container(
                  width: 150.w,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.colorBlack.withValues(alpha: 0.26),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOptionItem(
                        label: S.of(dialogContext).edit,
                        iconPath: "assets/icons_assets/main_icons_assets/ic_nav_back_curved.svg",
                        isSelected: selectedItem == 'edit',
                        lightMode: lightMode,
                        onTap: () {
                          setState(() => selectedItem = 'edit');
                          Future.delayed(Duration(milliseconds: 150), () {
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            onEdit();
                          });
                        },
                      ),
                      _buildOptionItem(
                        label: S.of(dialogContext).delete,
                        iconPath: "assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg",
                        isSelected: selectedItem == 'delete',
                        lightMode: lightMode,
                        onTap: () {
                          setState(() => selectedItem = 'delete');
                          Future.delayed(Duration(milliseconds: 150), () {
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            onDelete();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildOptionItem({
  required String label,
  required String iconPath,
  required bool isSelected,
  required bool lightMode,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: withHaptic(onTap, HapticLevel.low),
    child: Container(
      width: 280.sp,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          CustomSvgImage.natural(
            assetPath: iconPath,
            fit: BoxFit.scaleDown,
            color: isSelected ? AppColors.white : AppColors.secondaryText,
            width: 14.sp,
            height: 14.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            label,
            style: StyleText.fontSize13Weight500
                .copyWith(color: AppColors.secondaryBlack)
                .copyWith(
                  color: isSelected ? AppColors.white : AppColors.secondaryText,
                ),
          ),
        ],
      ),
    ),
  );
}
