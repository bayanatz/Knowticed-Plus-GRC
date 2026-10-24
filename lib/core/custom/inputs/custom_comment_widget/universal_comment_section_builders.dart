/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: universal_comment_section_builders.dart
/// Description: UI builder methods of `_UniversalCommentSectionStateImpl` — split out of `36-custom_comment_widget.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_comment_widget.dart';

// Split from 36-custom_comment_widget.dart to keep every file under 700 lines.

extension _UniversalCommentSectionStateImplBuilders
    on _UniversalCommentSectionStateImpl {
  /// The app's own file-type icon (18/10/2026: Material icons were used here
  /// — "this is not our icon"). Same mapping as every upload card.
  Widget _buildFileIcon(String? fileName) {
    return CustomSvgImage.natural(
      assetPath: fileTypeIconAsset(fileName ?? 'file'),
      width: 28.sp,
      height: 28.sp,
      fit: BoxFit.contain,
    );
  }

  /// REWRITTEN 17/10/2026 — the best of both comment sections (owner:
  /// "Time Tracker version + Universal's attachment icon, long-press edit /
  /// delete and upload progress"). Time Tracker's layout: avatar (the real
  /// photo) + name + department, the text in a soft bubble, the date under
  /// EVERY comment (it used to show only under files). Universal's file card
  /// (type icon, name, type, download) and Edit / Delete menu stay — the menu
  /// now opens on LONG-PRESS of one's own comment, as in Time Tracker; a
  /// plain tap on a file downloads it.
  Widget _buildCommentItem(CommentEntry comment) {
    final String? commentText = comment.text;
    final String? fileName = comment.fileName;
    final String? fileUrl = comment.fileUrl;
    final String? commenterEmail = comment.commenterEmail;
    final DateTime? commentDate = comment.date;

    final String commenterName =
        comment.name ?? _getCommenterName(commenterEmail);
    final String commenterDepartment =
        comment.subtitle ?? _getCommenterDepartment(commenterEmail);
    final bool mine = commenterEmail == widget.currentUserId;
    // Edit / Delete: own comments, unless the source says read-only.
    final bool canModify = comment.canModify ?? mine;
    final CrossAxisAlignment side =
        mine ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    // 21/10/2026 (Moataz): the menu opens UNDER the bubble that was
    // pressed, lined up with its edge — not wherever the finger landed.
    final GlobalKey textBubbleKey = GlobalKey();
    final GlobalKey fileBubbleKey = GlobalKey();
    void openMenuFor(GlobalKey key, LongPressStartDetails d) =>
        _showOwnCommentMenu(
          TapDownDetails(globalPosition: d.globalPosition),
          comment,
          anchor: key.currentContext?.findRenderObject() as RenderBox?,
        );

    return Padding(
      // Test handle for one comment (22/10/2026).
      key: ValueKey<String>('comment_${comment.id}'),
      padding: EdgeInsetsDirectional.only(top: 10.h),
      child: Column(
        crossAxisAlignment: side,
        children: <Widget>[
          Row(
            mainAxisAlignment:
                mine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              CustomAvatar(
                  photo: comment.photo ?? _getCommenterPhoto(commenterEmail),
                  size: 30.r),
              SizedBox(width: 8.w),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      FormatHelper.capitalize(commenterName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.text),
                    ),
                    if (commenterDepartment.isNotEmpty)
                      Text(
                        commenterDepartment,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize10Weight400
                            .copyWith(color: AppColors.secondaryText),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (commentText != null && commentText.isNotEmpty) ...<Widget>[
            SizedBox(height: 6.h),
            GestureDetector(
              key: textBubbleKey,
              behavior: HitTestBehavior.opaque,
              onLongPressStart:
                  canModify ? (d) => openMenuFor(textBubbleKey, d) : null,
              child: Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: CardStyles.radius(),
                ),
                // 21/10/2026 (Moataz): shown exactly as typed — it used to
                // capitalise every word ("Test Comment From Claude").
                child: Text(
                  FormatHelper.sentence(commentText),
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.text),
                ),
              ),
            ),
          ],
          if (fileName != null) ...<Widget>[
            SizedBox(height: 6.h),
            GestureDetector(
              key: fileBubbleKey,
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => HapticController.low(),
              onTap: () => _downloadFile(fileUrl, fileName),
              onLongPressStart:
                  canModify ? (d) => openMenuFor(fileBubbleKey, d) : null,
              child: Container(
                // 21/10/2026 (Moataz, R-11): the same space on every side —
                // was a fixed 70 high with 10 at the sides, so the file sat
                // far from the top and bottom but close to the left edge.
                width: 270.w,
                // 12 at the sides, 8 top/bottom: the two text lines carry
                // ~4 of line space each, so the VISIBLE gap is 12 all round.
                padding:
                    EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
                decoration: widget.style.fileChipDecoration.copyWith(),
                child: Row(
                  children: <Widget>[
                    _buildFileIcon(fileName),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            fileName,
                            style: widget.style.fileNameStyle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _getFileType(fileName),
                            style: StyleText.fontSize10Weight400
                                .copyWith(color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    CustomSvgImage.natural(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_action_download.svg',
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (commentDate != null) ...<Widget>[
            SizedBox(height: 4.h),
            // 21/10/2026: "Edited" before the time, as in Messages.
            Text(
              comment.isEdited
                  ? '${S.of(context).edited} · ${_formatDate(commentDate)}'
                  : _formatDate(commentDate),
              style: StyleText.fontSize10Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField() {
    final bool isArabic = _isArabic(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 21/10/2026 (Moataz): the comment being edited, above the box —
        // the Messages edit bar; X cancels, send saves.
        if (_editing != null) ...[
          Container(
            key: const ValueKey<String>('commentEditBar'),
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _editingOriginal ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: AppColors.text),
                  ),
                ),
                SizedBox(width: 8.sp),
                InkWell(
                  onTapDown: (_) => HapticController.low(),
                  onTap: _cancelEdit,
                  child: CustomSvgImage.natural(
                    assetPath:
                        'assets/icons_assets/main_icons_assets/ic_action_cancel.svg',
                    width: 18.sp,
                    height: 18.sp,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.sp),
        ],
        if (_selectedFileName != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.card, width: 1),
            ),
            child: Row(
              children: [
                CustomSvgImage.natural(
                  assetPath:
                      'assets/icons_assets/qiyas_assets/ic_file_attachment.svg',
                  width: 18.sp,
                  height: 18.sp,
                  color: AppColors.text,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFileName!,
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      if (_selectedFilePath != null)
                        Text(
                          _getFileSize(_selectedFilePath!),
                          style: StyleText.fontSize12Weight500.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                if (!_isUploading)
                  InkWell(
                    onTapDown: (_) => HapticController.high(),
                    onTap: () {
                      rebuild(() {
                        _selectedFilePath = null;
                        _selectedFileName = null;
                      });
                    },
                    child: CustomSvgImage.natural(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_action_close.svg',
                      width: 20.sp,
                      height: 20.sp,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
        Row(
          children: [
            // The shared field (core/custom/2) rather than a bare TextField, so
            // the comment box inherits the app-wide fill, radius, hint size and
            // RTL handling instead of restating them here.
            //
            // Two behaviours of the raw field are carried over deliberately:
            // the attachment button still swaps between prefix and suffix so it
            // stays on the outer edge in Arabic, and `contentPadding` keeps the
            // original 14/10 so the box still lines up with the 46.h send
            // button beside it.
            //
            // `CustomTextField` draws no border in any state, so the focused
            // primary outline `style.inputFocusedBorder` used to give is gone —
            // that is the field's rule, not an oversight.
            Expanded(
              child: CustomTextField(
                key: const ValueKey<String>('commentInput'),
                controller: _commentController,
                focusNode: _commentFocus,
                maxLines: 1,

                enabled: !_isUploading,
                hint:
                    _isUploading ? 'Uploading file...' : S.of(context).textHere,
                hintStyle: widget.style.hintStyle,
                valueStyle: StyleText.fontSize16Weight400.copyWith(
                  color: AppColors.text,
                ),
                fillColor: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
                // 18/10/2026: same 38 as the send button, and the field's
                // own centred padding (a 12 vertical padding pushed the
                // hint off-centre).
                height: 38,
                // Measured 21/10/2026: the hint sat ~3.5 px below the box's
                // middle (the font draws low in its line box) — 3 at the
                // bottom lifts it to the middle by eye.
                contentPadding: EdgeInsets.fromLTRB(12.sp, 0, 12.sp, 3.sp),
                // ✅ FIX: Set text direction based on locale
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!_isUploading) _addComment();
                },
                // ✅ FIX: Attachment icon position — use suffixIcon for RTL
                // 23/10/2026 (Moataz): the field already follows the screen
                // direction, so the START edge is the right one in Arabic
                // (the old swap put the icon on the left there).
                prefixIcon:
                    widget.enableFileAttachment ? _buildAttachButton() : null,
              ),
            ),
            SizedBox(width: 10.w),
            // 21/10/2026 (Moataz): grey and faded (R-3) until there is text
            // or a file to send — it looked active on an empty box.
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _commentController,
              builder: (BuildContext context, TextEditingValue value, _) {
                // While editing: only once the text really differs (and is
                // not empty) — sending the same text saved nothing.
                final bool canSend = !_isUploading &&
                    (_editing != null
                        ? value.text.trim().isNotEmpty &&
                            value.text.trim() != (_editingOriginal ?? '').trim()
                        : value.text.trim().isNotEmpty ||
                            _selectedFilePath != null);
                return Opacity(
                  opacity: canSend ? 1.0 : 0.5,
                  child: IgnorePointer(
                    ignoring: !canSend,
                    child: InkWell(
                      key: const ValueKey<String>('commentSend'),
                      onTapDown: (_) => HapticController.medium(),
                      onTap: _addComment,
                      child: Container(
                        // 15/10/2026 — KH large-screen report "make it perfect
                        // square": was 38 × 36.
                        height: 38.sp,
                        width: 38.sp,
                        // 21/10/2026 (Moataz): the same corners as the
                        // "Text here" field beside it (8.r; was plain 8).
                        decoration: widget.style.sendButtonDecoration.copyWith(
                          borderRadius: BorderRadius.circular(8.r),
                          color: canSend
                              ? (widget.style.sendButtonDecoration.color ??
                                  AppColors.primary)
                              : AppColors.grey,
                        ),
                        child: CustomSvgImage(
                          color: AppColors.secondaryPrimaryText,
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_action_send_white.svg",
                          width: 20.w,
                          height: 20.h,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
