/// Module: knowledge_hub/presentation/ui/widgets
///
/// ************************* FILE INFO *************************** ///
/// File Name: file_card.dart
/// Description: Contains all data of each knowledge file viewed in home page.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/layout/responsive_card_grid.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/shared_functions/format_date.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/file_card_widgets/card_date.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/file_card_widgets/card_values.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

Widget fileCard(
  BuildContext context, {
  required CreateKnowledgeModel knowledge,
  String? currentUserEmail,
}) {
  // Both callers pass the signed-in e-mail (rule 3: no lookups here).
  final String email = (currentUserEmail ?? '').toLowerCase().trim();
  final String creator = knowledge.currentCreatedByEmail.toLowerCase().trim();
  final bool userIsOwner =
      email.isNotEmpty && creator.isNotEmpty && creator == email;
  final String badgeText = userIsOwner
      ? S.of(context).owner
      : S.of(context).contributor;

  // The card is laid out inside a fixed-extent grid cell, so its content must
  // adapt to whatever height it is given instead of asserting its own. Text
  // scaling is clamped and the vertical gaps/padding collapse under pressure
  // so the card never overflows, at any window size or text scale.
  return MediaQuery.withClampedTextScaling(
    maxScaleFactor: 1.2,
    child: Stack(
      children: [
        // Fills the grid cell so every card keeps the same background size.
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) => _buildFileCardBody(
              context,
              knowledge: knowledge,
              constraints: constraints,
              badgeReserve: _badgeReserve(context, badgeText),
            ),
          ),
        ),
        // D-03 diagonal cut, 10 / 10 (17/10/2026), mirrored by direction.
        PositionedDirectional(
          top: CardStyles.cornerInset,
          end: CardStyles.cornerInset,
          child: _buildOwnerBadge(badgeText),
        ),
      ],
    ),
  );
}

String _fileTypeIcon(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
    case 'ppt':
    case 'pptx':
      return 'assets/icons_assets/main_icons_assets/ic_file_powerpoint.svg';
    case 'doc':
    case 'docx':
      return 'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
    case 'mp4':
    case 'avi':
    case 'mov':
    case 'wmv':
    case 'flv':
    case 'mkv':
    case 'webm':
      return 'assets/icons_assets/main_icons_assets/ic_file_video.svg';
    case 'xlsx':
    case 'xls':
    case 'xlsm':
    case 'csv':
      return 'assets/icons_assets/main_icons_assets/ic_file_excel_grid.svg';
    default: // png / jpg / jpeg and anything else
      return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
  }
}

/// The badge floats over the top-end corner, so a long name ran UNDER it.
/// Measures the badge, so the name line can stop short of it and end in "…".
double _badgeReserve(BuildContext context, String badgeText) {
  final TextPainter badgePainter = TextPainter(
    text: TextSpan(text: badgeText, style: StyleText.fontSize10Weight400),
    maxLines: 1,
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2),
  )..layout();
  // + 8.w breathing room so the "…" never touches the badge (KH vertical
  // report p.1).
  return (badgePainter.width + 12.w).clamp(0.0, 80.w) + 5.h + 6.w + 8.w;
}

/// Owner / Contributor badge. Sizes to its label, so it can never clip or
/// overflow whatever the locale or text scale is.
Widget _buildOwnerBadge(String badgeText) {
  return Container(
    constraints: BoxConstraints(maxWidth: 80.w),
    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(4.r),
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        badgeText,
        maxLines: 1,
        style: StyleText.fontSize10Weight400.copyWith(
          color: AppColors.textButton,
        ),
      ),
    ),
  );
}

/// Preview and texts, padded to fit the grid cell.
Widget _buildFileCardBody(
  BuildContext context, {
  required CreateKnowledgeModel knowledge,
  required BoxConstraints constraints,
  required double badgeReserve,
}) {
  final bool lightMode = Theme.of(context).brightness == Brightness.light;
  // Padding shrinks on short cells rather than squeezing the text.
  final double vPadding = constraints.hasBoundedHeight
      ? (constraints.maxHeight * 0.12).clamp(2.0, 10.0)
      : 10.0;
  final String? imageUrl = _getImageUrl(knowledge);
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4.r),
      color: lightMode ? AppColors.white : AppColors.chatBackground,
    ),
    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: vPadding),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildFilePreview(
          imageUrl: imageUrl,
          fileIcon: imageUrl == null
              ? _fileTypeIcon(knowledge.currentDocumentExtension)
              : null,
          fileExtension: knowledge.currentDocumentExtension,
          getFileIcon: _fileTypeIcon,
          lightMode: lightMode,
          maxHeight: constraints.hasBoundedHeight
              ? (constraints.maxHeight - vPadding * 2).clamp(
                  0.0,
                  double.infinity,
                )
              : double.infinity,
        ),
        SizedBox(width: 10.h),
        // Laid out at its natural size, then uniformly scaled down if the
        // cell is shorter than the content needs (overflow-proof).
        Expanded(
          child: ResponsiveCardContent(
            alignment: AlignmentDirectional.centerStart.resolve(
              Directionality.of(context),
            ),
            child: _buildFileCardTexts(
              context,
              knowledge: knowledge,
              badgeReserve: badgeReserve,
              lightMode: lightMode,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Name (stopping short of the badge), owning department and dates.
Widget _buildFileCardTexts(
  BuildContext context, {
  required CreateKnowledgeModel knowledge,
  required double badgeReserve,
  required bool lightMode,
}) {
  final String? lastStamp = knowledge.timeStamp.lastOrNull;
  final String uploadDate = KhLocale.digits(
    context,
    formatDate(lastStamp != null ? DateTime.tryParse(lastStamp) : null),
  );
  final String lastEditDate = KhLocale.digits(
    context,
    _getLastEditDate(knowledge),
  );
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: EdgeInsetsDirectional.only(end: badgeReserve),
        child: Text(
          FormatHelper.capitalize(
            KhLocale.pick(
              context,
              en: knowledge.currentNameEnglish,
              ar: knowledge.currentNameArabic,
            ),
          ),
          style: StyleText.fontSize12Weight500.copyWith(
            color: lightMode ? AppColors.blackButton : AppColors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
      SizedBox(height: 6.sp),
      buildInfoRow(
        context,
        label: "${S.of(context).owning_department}: ",
        // capitalize() leaves Arabic text as it is.
        value: FormatHelper.capitalize(
          KhLocale.department(context, knowledge.currentOwningDepartment),
        ),
        lightMode: lightMode,
      ),
      SizedBox(height: 6.sp),
      Row(
        children: [
          buildDateInfo(
            context,
            "${S.of(context).publish_date}: ",
            uploadDate,
            lightMode,
          ),
          Spacer(),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: buildDateInfo(
              context,
              '${S.of(context).last_edit}: ',
              lastEditDate,
              lightMode,
            ),
          ),
        ],
      ),
    ],
  );
}

String? _getImageUrl(CreateKnowledgeModel knowledge) {
  if (knowledge.imageUrl!.isNotEmpty) {
    final url = knowledge.imageUrl!.first;
    if (url.isNotEmpty && url.startsWith('http')) {
      return url;
    }
  }
  return null;
}

Widget _buildFilePreview({
  required String? imageUrl,
  required String? fileIcon,
  required String fileExtension,
  required String Function(String) getFileIcon,
  required bool lightMode,
  double maxHeight = double.infinity,
}) {
  // The preview never exceeds the height the cell actually offers, so a short
  // grid cell shrinks the thumbnail instead of overflowing the row.
  final double previewHeight = maxHeight.isFinite
      ? (45.h).clamp(0.0, maxHeight)
      : 45.h;
  final double previewWidth = previewHeight <= 0
      ? 0.0
      : 40.w * (previewHeight / (45.h));

  if (imageUrl != null) {
    // Display actual image with loading and error handling
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: Image.network(
        imageUrl,
        width: previewWidth,
        height: previewHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to icon if image fails to load
          return CustomSvgImage(
            assetPath: getFileIcon(fileExtension),
            height: previewHeight,
            width: previewWidth,
            fit: BoxFit.contain,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          // Show loading indicator while image is loading
          return Container(
            width: previewWidth,
            height: previewHeight,
            decoration: BoxDecoration(
              color: AppColors.greyBack,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircleProgressMaster.inline(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.border),
                ),
              ),
            ),
          );
        },
      ),
    );
  } else {
    // Display file type icon when no image is available
    return SizedBox(
      width: previewWidth,
      height: previewHeight,
      child: CustomSvgImage(
        assetPath: fileIcon ?? getFileIcon(fileExtension),
        width: previewWidth,
        height: previewHeight,
        fit: BoxFit.contain,
      ),
    );
  }
}

String _getLastEditDate(CreateKnowledgeModel knowledge) {
  if (knowledge.timestamps.isEmpty) return '-';
  final lastTimestamp = knowledge.timestamps.last;
  final lastEditDateTime = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
  return formatDate(lastEditDateTime);
}
