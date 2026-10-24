/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_attachments_grid.dart
/// Description: The "Attach Document" control under each box on the comments and
///          feedback form — the uploaded files as cards, plus the button that
///          adds another.
/// Author: Amr Mesbah
/// Created at: 1/9/2026
///
/// Figma: MESBAH 7628:7681. The design draws two 265-wide "Attach Document"
/// buttons side by side inside a 574-wide card, which is the two-column grid
/// this widget lays out. An uploaded file takes a cell; the add button is
/// always the LAST cell, so it moves along as files arrive instead of jumping
/// somewhere else on screen.
///
/// The file card deliberately mirrors `selectedDocumentWidget`
/// (knowledge_hub/main_controller) — icon, name, size, red remove badge — but
/// is written here rather than imported because that widget hardcodes
/// `width: 310.w` and would overflow a 265-wide cell.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart'
    show kFieldLabelGap;
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_display.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class FeedbackAttachmentsGrid extends StatelessWidget {
  const FeedbackAttachmentsGrid({
    super.key,
    required this.attachments,
    required this.onAdd,
    required this.onRemove,
    this.isUploading = false,
    this.isBlocked = false,
    this.columns = 2,
  });

  /// Files already in Storage for this box, in the order they were added.
  final List<FeedbackAttachment> attachments;

  /// Opens the picker. Ignored while [isUploading] or [isBlocked].
  final VoidCallback onAdd;

  /// Drops the file at [index] from the list. It is NOT deleted from the
  /// bucket — see the note at the call site in the screen.
  final ValueChanged<int> onRemove;

  /// This box's own upload is in flight: the add button shows a spinner.
  final bool isUploading;

  /// Another box is uploading. The button is dimmed and inert, because the
  /// screen allows only one upload at a time.
  final bool isBlocked;

  /// 2 on tablet and desktop (the Figma layout), 1 on phone.
  final int columns;

  @override
  Widget build(BuildContext context) {
    final bool disabled = isUploading || isBlocked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Deliberately the same label treatment CustomDropdown applies —
        // 14.sp/500 in AppColors.text, then [kFieldLabelGap]. This label and
        // the Priority dropdown's stand side by side in one Row, and a
        // different size or gap makes the two FIELDS start at different
        // heights, which reads as stepped rather than aligned. See the note on
        // kFieldLabelGap in 1-custom_dropdown.dart.
        // RichText, not Text (21/10/2026): CustomDropdown draws its label as a
        // RichText; a Text merges the ambient line height and sits a few px
        // lower, which put the Priority box out of line with this button.
        RichText(
          text: TextSpan(
            text: S.of(context).attach_document,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.text, fontSize: 14.sp),
          ),
        ),
        SizedBox(height: kFieldLabelGap.sp),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Owner 21/10/2026 (R-1): 16 between the two columns (was 15).
            const double gap = 16;
            final int columnCount = columns < 1 ? 1 : columns;
            // `constraints.maxWidth` is finite here — the grid is always given
            // a bounded width by the form's Column. Guarded anyway: an
            // unbounded parent would make every cell infinitely wide and throw
            // inside Wrap.
            final double available = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : ScreenUtil().screenWidth;
            final double cellWidth =
                (available - gap * (columnCount - 1)) / columnCount;

            return Wrap(
              spacing: gap,
              runSpacing: gap.h,
              children: <Widget>[
                for (int i = 0; i < attachments.length; i++)
                  SizedBox(
                    width: cellWidth,
                    child: _AttachmentCard(
                      attachment: attachments[i],
                      // Removing mid-upload would leave the in-flight file
                      // with nowhere to land.
                      onRemove: disabled ? null : () => onRemove(i),
                    ),
                  ),
                SizedBox(
                  width: cellWidth,
                  child: _AddButton(
                    onTap: disabled ? null : onAdd,
                    isUploading: isUploading,
                    isDimmed: disabled,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// One uploaded file. 60 tall to match the knowledge-hub document card.
class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({required this.attachment, required this.onRemove});

  final FeedbackAttachment attachment;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final String extension = attachment.extension;

    // D-146 (Moataz 20/10/2026): the red minus sits in the box's corner at
    // the same inset from the top and the end (diagonal cut), not centred in
    // the row.
    return Stack(
      children: <Widget>[
        Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: lightMode ? AppColors.white : AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
            border: lightMode
                ? Border.all(color: AppColors.borderGrey)
                : Border.all(color: Colors.transparent),
          ),
          padding: EdgeInsetsDirectional.only(
              start: 12.w, end: onRemove != null ? 30.w : 8.w),
          child: Row(
            children: <Widget>[
              CustomSvgImage(
                assetPath: FeedbackDisplay.fileIcon(extension),
                // Only the silhouette icons are tinted; a tinted PDF glyph would
                // lose the red that identifies it.
                color: FeedbackDisplay.iconNeedsTint(extension)
                    ? AppColors.text
                    : null,
                height: 30.sp,
                width: 30.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      attachment.name,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      FeedbackDisplay.readableSize(attachment.sizeInBytes),
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (onRemove != null)
          PositionedDirectional(
            top: 10,
            end: 10,
            child: GestureDetector(
              onTapDown: hapticDown(onRemove, HapticLevel.high),
              onTap: onRemove,
              child: Container(
                width: 16.sp,
                height: 16.sp,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.remove, size: 12.sp, color: AppColors.white),
              ),
            ),
          ),
      ],
    );
  }
}

/// The primary-coloured "Attach Document" button. 36 tall, per Figma.
class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.onTap,
    required this.isUploading,
    required this.isDimmed,
  });

  final VoidCallback? onTap;
  final bool isUploading;
  final bool isDimmed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDimmed ? 0.5 : 1.0,
      child: GestureDetector(
        onTapDown: hapticDown(onTap, HapticLevel.medium),
        onTap: onTap,
        child: Container(
          // 38.sp, not .h: CustomDropdown scales its `height: 38` by .sp, so
          // the same unit here is what keeps the two boxes level (21/10/2026).
          height: 38.sp, // same height as the Priority box (Moataz 20/10/2026)
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isUploading)
                SizedBox(
                  width: 16.sp,
                  height: 16.sp,
                  child: CircleProgressMaster.inline(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textButton,
                    ),
                  ),
                )
              else
                CustomSvgImage(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_action_upload.svg',
                  color: AppColors.textButton,
                  height: 16.sp,
                  width: 16.sp,
                ),
              SizedBox(width: 16.w),
              Flexible(
                child: Text(
                  S.of(context).attach_document,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
