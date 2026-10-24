/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_document_card.dart
/// Description: Approvals document card — Approvals (S6) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';

Widget approvalsDocumentCard(
  BuildContext context, {
  required String status,
  required Color statusColor,
  required String fileExtension,
  String? fileImage,
  required String fileName,
  required String department,
  required String requestedBy,
  required String jobTitle,
  DateTime? uploadDate,
  DateTime? lastEditDate,
  VoidCallback? onApprove,
  VoidCallback? onReject,
}) {
  final S s = S.of(context);
  final Map<String, dynamic> statusInfo = _approvalStatusInfo(context, status);
  final String statusKey = status.toLowerCase();
  final bool isPending =
      statusKey == 'pending' ||
      statusKey == 'pending_approval' ||
      statusKey == 'scheduled';

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4.r),
      color: AppColors.card,
    ),
    padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardTitle(fileName, fileExtension, fileImage),
        SizedBox(height: 10.sp),
        _cardInfoRow(
          icon: 'assets/icons_assets/main_icons_assets/ic_user_profile.svg',
          label: s.requestedBy,
          value: requestedBy,
        ),
        SizedBox(height: 10.sp),
        _cardInfoRow(
          icon: 'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
          label: s.requestedDate,
          value: uploadDate == null
              ? '-'
              : DateFormat('dd MMM yyyy').format(uploadDate),
        ),
        SizedBox(height: 10.sp),
        _cardInfoRow(
          icon: 'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg',
          label: s.department,
          value: department,
        ),
        SizedBox(height: 10.sp),
        _cardInfoRow(
          icon: 'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg',
          label: FormatHelper.capitalize(s.jobTitle),
          value: FormatHelper.capitalize(jobTitle),
        ),
        SizedBox(height: 10.sp),
        _cardInfoRow(
          icon: 'assets/icons_assets/main_icons_assets/ic_status.svg',
          label: s.status,
          value: statusInfo['text'],
          valueColor: statusInfo['color'],
        ),
        SizedBox(height: 10.sp),
        if (KnowledgeHubAccess.approvalAccess.canApprove && isPending)
          _buildDecisionButtons(
            context,
            onApprove: onApprove,
            onReject: onReject,
          )
        else
          _buildStatusBadge(statusInfo),
      ],
    ),
  );
}

String _approvalFileIcon(String extension) {
  switch (extension.toLowerCase().trim()) {
    case 'pdf':
      return 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
    case 'ppt':
    case 'pptx':
      return 'assets/icons_assets/main_icons_assets/ic_file_powerpoint.svg';
    case 'doc':
      return 'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
    case 'docx':
      return 'assets/icons_assets/knowledge_hub_assets/ic_file_word.svg';
    case 'xls':
    case 'xlsx':
    case 'csv':
      return 'assets/icons_assets/main_icons_assets/ic_file_excel.svg';
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'bmp':
    case 'webp':
      return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
    default:
      return 'assets/icons_assets/knowledge_hub_assets/ic_action_view.svg';
  }
}

/// Status label, colour and icon. A published document shows "Approved".
Map<String, dynamic> _approvalStatusInfo(BuildContext context, String status) {
  Widget icon(String asset) => CustomSvgImage(
    assetPath: asset,
    height: 24.sp,
    width: 24.sp,
    fit: BoxFit.cover,
  );
  switch (status.toLowerCase().trim()) {
    case 'rejected':
      return {
        'text': S.of(context).rejected,
        'color': AppColors.red,
        'widget': icon(
          'assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg',
        ),
      };
    case 'published':
    case 'approved':
      return {
        'text': S.of(context).approved,
        'color': AppColors.lightGreen,
        'widget': icon(
          'assets/icons_assets/knowledge_hub_assets/ic_images_approve.svg',
        ),
      };
    case 'pending_approval':
    case 'pending':
    case 'scheduled':
      return {
        'text': S.of(context).pending,
        'color': AppColors.orange,
        'widget': icon(
          'assets/icons_assets/main_icons_assets/ic_status_pending.svg',
        ),
      };
    case 'removed':
      return {
        'text': S.of(context).removed,
        'color': AppColors.redCrimson,
        'widget': icon(
          'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg',
        ),
      };
    default:
      return {
        'text': status,
        'color': AppColors.primary,
        'widget': Icon(Icons.info, color: AppColors.primary, size: 24.sp),
      };
  }
}

/// File icon (or cover image) and file name.
Widget _buildCardTitle(
  String fileName,
  String fileExtension,
  String? fileImage,
) {
  final Widget fileIcon = CustomSvgImage(
    assetPath: _approvalFileIcon(fileExtension),
    height: 50.h,
    width: 50.w,
    fit: BoxFit.cover,
  );
  return Row(
    children: [
      fileImage == null
          ? fileIcon
          : ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                height: 50.h,
                width: 50.w,
                child: Image.network(
                  fileImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => fileIcon,
                ),
              ),
            ),
      SizedBox(width: 10.w),
      Expanded(
        child: Text(
          fileName,
          style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

/// One "icon  Label: value" line of the card.
Widget _cardInfoRow({
  required String icon,
  required String label,
  required String value,
  Color? valueColor,
}) {
  final Color labelColor = AppColors.secondaryText.withValues(alpha: .7);
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CustomSvgImage(
        assetPath: icon,
        height: 16.sp,
        width: 16.sp,
        fit: BoxFit.cover,
        color: labelColor,
      ),
      SizedBox(width: 3.w),
      Text(
        '$label: ',
        style: StyleText.fontSize14Weight400.copyWith(color: labelColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      Expanded(
        child: Text(
          value,
          style: StyleText.fontSize14Weight400.copyWith(
            color: valueColor ?? AppColors.blackButton,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

/// Reject / Approve buttons for a document waiting for a decision.
Widget _buildDecisionButtons(
  BuildContext context, {
  VoidCallback? onApprove,
  VoidCallback? onReject,
}) {
  Widget button({
    required String title,
    required VoidCallback? onTap,
    required Color color,
    required String image,
  }) => customButtonWithSvg(
    title: title,
    function: onTap ?? () {},
    textStyle: StyleText.fontSize16Weight500.copyWith(color: color),
    height: 36,
    space: 8.w,
    radius: 8.r,
    color: AppColors.card,
    image: image,
    widthImage: 24.w,
    heightImage: 24.h,
    colorBorder: color,
  );
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (KnowledgeHubAccess.approvalAccess.canReject) ...[
        Expanded(
          child: button(
            title: S.of(context).reject,
            onTap: onReject,
            color: AppColors.red,
            image: 'assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg',
          ),
        ),
        SizedBox(width: 10.w),
      ],
      Expanded(
        child: button(
          title: S.of(context).approve,
          onTap: onApprove,
          color: AppColors.lightGreen,
          image:
              'assets/icons_assets/knowledge_hub_assets/ic_images_approve.svg',
        ),
      ),
    ],
  );
}

/// ✅ Status badge for non-pending items
Widget _buildStatusBadge(Map<String, dynamic> statusInfo) {
  return Container(
    height: 36,
    decoration: BoxDecoration(
      color: AppColors.card,
      border: Border.all(color: statusInfo['color'], width: 2),
      borderRadius: BorderRadius.circular(8.r),
    ),
    padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 12.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(width: 24.sp, height: 24.sp, child: statusInfo['widget']),
        SizedBox(width: 8.w),
        Text(
          statusInfo['text'],
          style: StyleText.fontSize16Weight500.copyWith(
            color: statusInfo['color'],
          ),
        ),
      ],
    ),
  );
}
