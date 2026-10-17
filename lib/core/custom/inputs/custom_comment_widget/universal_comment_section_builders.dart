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
  Widget _buildFileIcon(String? fileName) {
    if (fileName == null) return Icon(Icons.insert_drive_file, size: 24.sp);
    final extension = _getFileExtension(fileName);
    IconData iconData;
    Color iconColor;
    switch (extension) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = AppColors.red;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = AppColors.blue;
        break;
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart;
        iconColor = AppColors.green;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        iconData = Icons.image;
        iconColor = AppColors.secondaryPrimary;
        break;
      case 'txt':
        iconData = Icons.text_snippet;
        iconColor = AppColors.grey;
        break;
      case 'zip':
      case 'rar':
      case '7z':
        iconData = Icons.folder_zip;
        iconColor = AppColors.orange;
        break;
      case 'mp3':
      case 'wav':
      case 'aac':
        iconData = Icons.audiotrack;
        iconColor = AppColors.red;
        break;
      case 'mp4':
      case 'avi':
      case 'mov':
        iconData = Icons.videocam;
        iconColor = AppColors.blue;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = AppColors.secondaryText;
    }
    return Icon(iconData, size: 28.sp, color: iconColor);
  }

  /// REWRITTEN 17/10/2026 — the best of both comment sections (owner:
  /// "Time Tracker version + Universal's attachment icon, long-press edit /
  /// delete and upload progress"). Time Tracker's layout: avatar (the real
  /// photo) + name + department, the text in a soft bubble, the date under
  /// EVERY comment (it used to show only under files). Universal's file card
  /// (type icon, name, type, download) and Edit / Delete menu stay — the menu
  /// now opens on LONG-PRESS of one's own comment, as in Time Tracker; a
  /// plain tap on a file downloads it.
  Widget _buildCommentItem(
    Map<String, dynamic> comment,
    DocumentReference<Map<String, dynamic>> ref,
  ) {
    final String? commentText = comment['Comment_Text'] as String?;
    final String? fileName = comment['File_Name'] as String?;
    final String? fileUrl = comment['Comment_Link'] as String?;
    final String? commenterEmail = comment['Commenter_Id'] as String?;
    final DateTime? commentDate =
        (comment['Comment_Date'] as Timestamp?)?.toDate();

    final String commenterName = _getCommenterName(commenterEmail);
    final String commenterDepartment = _getCommenterDepartment(commenterEmail);
    final bool mine = commenterEmail == widget.currentUserId;
    final CrossAxisAlignment side =
        mine ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    void openMenu(LongPressStartDetails d) => _showOwnCommentMenu(
          TapDownDetails(globalPosition: d.globalPosition),
          ref,
          comment,
        );

    return Padding(
      padding: EdgeInsetsDirectional.only(top: 10.h),
      child: Column(
        crossAxisAlignment: side,
        children: <Widget>[
          Row(
            mainAxisAlignment:
                mine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              CustomAvatar(
                  photo: _getCommenterPhoto(commenterEmail), size: 30.r),
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
              behavior: HitTestBehavior.opaque,
              onLongPressStart: mine ? openMenu : null,
              child: Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: CardStyles.radius(),
                ),
                child: Text(
                  FormatHelper.capitalize(commentText),
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.text),
                ),
              ),
            ),
          ],
          if (fileName != null) ...<Widget>[
            SizedBox(height: 6.h),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => HapticController.low(),
              onTap: () => _downloadFile(fileUrl, fileName),
              onLongPressStart: mine ? openMenu : null,
              child: Container(
                height: 70.h,
                width: 270.w,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
                            style: widget.style.fileNameStyle.copyWith(
                              decoration: TextDecoration.underline,
                            ),
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
                    Icon(
                      Icons.download,
                      size: 16.sp,
                      color: AppColors.secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (commentDate != null) ...<Widget>[
            SizedBox(height: 4.h),
            Text(
              _formatDate(commentDate),
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
                Icon(Icons.attach_file, size: 18.sp, color: AppColors.text),
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
                    child: Icon(
                      Icons.close,
                      size: 20.sp,
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
                controller: _commentController,
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
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.sp,
                ),
                // ✅ FIX: Set text direction based on locale
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!_isUploading) _addComment();
                },
                // ✅ FIX: Attachment icon position — use suffixIcon for RTL
                prefixIcon: !isArabic && widget.enableFileAttachment
                    ? _buildAttachButton()
                    : null,
                suffixIcon: isArabic && widget.enableFileAttachment
                    ? _buildAttachButton()
                    : null,
              ),
            ),
            SizedBox(width: 10.w),
            InkWell(
              onTapDown: _isUploading ? null : (_) => HapticController.medium(),
              onTap: _isUploading ? null : _addComment,
              child: Container(
                // 15/10/2026 — KH large-screen report "make it perfect
                // square": was 38 × 36.
                height: 38.sp,
                width: 38.sp,
                decoration: widget.style.sendButtonDecoration.copyWith(
                  color: (widget.style.sendButtonDecoration.color ??
                          AppColors.primary)
                      .withValues(alpha: _isUploading ? 0.5 : 1),
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
          ],
        ),
      ],
    );
  }
}
