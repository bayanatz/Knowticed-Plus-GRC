/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: universal_comment_section_logic.dart
/// Description: Logic and event handlers of `_UniversalCommentSectionStateImpl` — split out of `36-custom_comment_widget.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_comment_widget.dart';

// Split from 36-custom_comment_widget.dart to keep every file under 700 lines.

extension _UniversalCommentSectionStateImplLogic
    on _UniversalCommentSectionStateImpl {
  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty && _selectedFilePath == null) {
      return;
    }

    if (_isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait, file is uploading...'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    try {
      rebuild(() => _isUploading = true);

      String? firebaseUrl;

      if (_selectedFilePath != null && _selectedFileName != null) {
        firebaseUrl = await _uploadFileToStorage(
          _selectedFilePath!,
          _selectedFileName!,
        );

        if (firebaseUrl == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload file'),
              backgroundColor: AppColors.red,
            ),
          );
          rebuild(() => _isUploading = false);
          return;
        }
      }

      if (widget.customAddComment != null) {
        await widget.customAddComment!(
          currentUserId: widget.currentUserId,
          commentText: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
          mediaPath: firebaseUrl,
        );
        _commentController.clear();
        rebuild(() {
          _selectedFilePath = null;
          _selectedFileName = null;
          _isUploading = false;
        });
        _scrollToBottom();
        return;
      }

      final commentData = {
        ...widget.filterFields,
        'Comment_Id':
            '${widget.currentUserId}_${DateTime.now().millisecondsSinceEpoch}',
        'Comment_Text': _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        'Commenter_Id': widget.currentUserId,
        'Comment_Date': Timestamp.now(),
        'Comment_Link': firebaseUrl,
        'File_Name': _selectedFileName,
        'File_Size':
            _selectedFilePath != null ? _getFileSize(_selectedFilePath!) : null,
      };

      await FirebaseFirestore.instance
          .collection(widget.collectionPath)
          .doc(commentData['Comment_Id'] as String)
          .set(commentData);

      widget.onCommentAdded?.call(commentData);

      _commentController.clear();
      rebuild(() {
        _selectedFilePath = null;
        _selectedFileName = null;
        _isUploading = false;
      });
      _scrollToBottom();
    } catch (e) {
      rebuild(() => _isUploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
    }
  }

  void _showDownloadSuccessDialog(String filePath, String fileName) {
    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Container(
          width: 411.w,
          padding: EdgeInsets.all(15.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 28.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    S.of(context).downloadComplete,
                    style: StyleText.fontSize16Weight400.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                '${S.of(context).file}: $fileName',
                style: StyleText.fontSize16Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                S.of(context).saveTo,
                style: StyleText.fontSize16Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.folder, size: 20.sp, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        filePath,
                        style: StyleText.fontSize16Weight400.copyWith(
                          color: AppColors.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  customButton(
                    title: S.of(context).ok,
                    function: () => Navigator.of(context).pop(),
                    width: 100.w,
                    height: 38.h,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // EDIT 25/9/2026: own comments (text or attachment) open an Edit /
  // Delete menu when tapped. Edit on an attachment replaces the file.
  // ─────────────────────────────────────────────────────────────────
  Future<void> _showOwnCommentMenu(
    TapDownDetails details,
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> comment,
  ) async {
    final bool hasFile = comment['File_Name'] != null;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final pos = details.globalPosition;
    final choice = await showMenu<String>(
      context: context,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(pos.dx, pos.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        // Bug report p.22: no "Edit" on an attachment — only text comments
        // are editable; a file is downloaded or deleted.
        if (!hasFile)
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18.sp, color: AppColors.text),
                SizedBox(width: 8.w),
                Text(
                  S.of(context).edit,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        if (hasFile)
          PopupMenuItem<String>(
            value: 'download',
            child: Row(
              children: [
                Icon(Icons.download, size: 18.sp, color: AppColors.text),
                SizedBox(width: 8.w),
                Text(
                  S.of(context).download,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18.sp, color: AppColors.red),
              SizedBox(width: 8.w),
              Text(
                S.of(context).delete,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'edit':
        if (hasFile) {
          await _replaceAttachment(ref);
        } else {
          await _editCommentText(ref, comment['Comment_Text'] as String?);
        }
        break;
      case 'download':
        _downloadFile(
          comment['Comment_Link'] as String?,
          comment['File_Name'] as String,
        );
        break;
      case 'delete':
        await _confirmDeleteComment(ref);
        break;
    }
  }

  Future<void> _editCommentText(
    DocumentReference<Map<String, dynamic>> ref,
    String? current,
  ) async {
    final controller = TextEditingController(text: current ?? '');
    final newText = await showAppDialog<String>(
      context: context,
      builder: (dCtx) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          width: 411.sp,
          padding: EdgeInsets.all(20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(dCtx).EditMessage,
                style: StyleText.fontSize18Weight500.copyWith(
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 15.h),
              CustomTextField(
                controller: controller,
                hint: S.of(dCtx).Edityourmessage,
                fillColor: AppColors.background,
                maxLines: null,
              ),
              SizedBox(height: 20.h),
              Row(
                textDirection: TextDirection
                    .ltr, // X-73: Cancel left, action right in both languages

                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customButton(
                    title: S.of(dCtx).cancel,
                    function: () => Navigator.pop(dCtx),
                    width: 135.sp,
                    height: 38.sp,
                    radius: 4.r,
                    color: AppColors.darkGrey,
                    textStyle: StyleText.fontSize15Weight400.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  customButton(
                    title: S.of(dCtx).Save,
                    function: () => Navigator.pop(dCtx, controller.text.trim()),
                    width: 135.sp,
                    height: 38.sp,
                    radius: 4.r,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize15Weight400.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (newText == null || newText.isEmpty || newText == current) return;
    try {
      await ref.update({'Comment_Text': newText});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.red),
      );
    }
  }
}
