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
    if (_editing != null) {
      await _saveEdit();
      return;
    }
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
      // 21/10/2026 (Moataz): the spinner is for a FILE upload only — a text
      // comment sends without one.
      if (_selectedFilePath != null) rebuild(() => _isUploading = true);

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

      await widget.source.add(
        currentUserId: widget.currentUserId,
        text: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        fileUrl: firebaseUrl,
        fileName: _selectedFileName,
        fileSize:
            _selectedFilePath != null ? _getFileSize(_selectedFilePath!) : null,
      );

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

  /// X-129 (20/10/2026): the shared core Download Complete dialog — the
  /// page-local version (OK button, raw path) is gone; the user stays here.
  void _showDownloadSuccessDialog(String filePath, String fileName) {
    CustomDialogManager.showDownloadComplete(
      context: context,
      fileName: fileName,
      filePath: filePath,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // EDIT 25/9/2026: own comments (text or attachment) open an Edit /
  // Delete menu when tapped. Edit on an attachment replaces the file.
  // ─────────────────────────────────────────────────────────────────
  Future<void> _showOwnCommentMenu(
    TapDownDetails details,
    CommentEntry comment, {
    RenderBox? anchor,
  }) async {
    final bool hasFile = comment.fileName != null;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final pos = details.globalPosition;
    // Under the pressed bubble, flush with its far edge: showMenu right-
    // aligns when the space on the left is the larger one (own comments sit
    // on the right). Falls back to the finger when the bubble is unknown.
    final Rect bubble = anchor != null && anchor.hasSize
        ? (anchor.localToGlobal(Offset.zero, ancestor: overlay) & anchor.size)
        : Rect.fromLTWH(pos.dx, pos.dy, 0, 0);
    final choice = await showMenu<String>(
      context: context,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      position: RelativeRect.fromLTRB(
        bubble.left,
        bubble.bottom + 4.sp,
        overlay.size.width - bubble.right,
        overlay.size.height - bubble.bottom,
      ),
      items: [
        // Bug report p.22: no "Edit" on an attachment — only text comments
        // are editable; a file is downloaded or deleted.
        if (!hasFile && widget.source.supportsEdit)
          PopupMenuItem<String>(
            key: const ValueKey<String>('commentEdit'),
            value: 'edit',
            child: Row(
              children: [
                // 21/10/2026: our pencil, as in the Messages menu.
                CustomSvgImage.natural(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_action_edit.svg',
                  width: 18.sp,
                  height: 18.sp,
                  color: AppColors.text,
                ),
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
                CustomSvgImage.natural(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_action_download.svg',
                  width: 18.sp,
                  height: 18.sp,
                  color: AppColors.text,
                ),
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
          key: const ValueKey<String>('commentDelete'),
          value: 'delete',
          child: Row(
            children: [
              // 21/10/2026: our red trash, as in the Messages menu.
              CustomSvgImage.natural(
                assetPath:
                    'assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg',
                width: 18.sp,
                height: 18.sp,
              ),
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
          await _replaceAttachment(comment);
        } else {
          await _editCommentText(comment);
        }
        break;
      case 'download':
        _downloadFile(comment.fileUrl, comment.fileName!);
        break;
      case 'delete':
        await _confirmDeleteComment(comment);
        break;
    }
  }

  /// 21/10/2026 (Moataz): inline edit, as in Messages — the text goes back
  /// into the comment box with a bar above it (X cancels) and the send
  /// button saves. Was a dialog.
  Future<void> _editCommentText(CommentEntry comment) async {
    final String? current = comment.text;
    rebuild(() {
      _editing = comment;
      _editingOriginal = current ?? '';
      _selectedFilePath = null;
      _selectedFileName = null;
    });
    _commentController.text = current ?? '';
    _commentController.selection = TextSelection.collapsed(
      offset: _commentController.text.length,
    );
    _commentFocus.requestFocus();
  }

  void _cancelEdit() {
    rebuild(() {
      _editing = null;
      _editingOriginal = null;
    });
    _commentController.clear();
  }

  /// Saves the inline edit. An unchanged or emptied text just closes edit
  /// mode; a real change is written with `Is_Edited` so the comment shows
  /// "Edited".
  Future<void> _saveEdit() async {
    final CommentEntry? editing = _editing;
    final String text = _commentController.text.trim();
    if (editing == null) return;
    if (text.isEmpty || text == (_editingOriginal ?? '').trim()) {
      _cancelEdit();
      return;
    }
    try {
      await widget.source.edit(editing, text);
      if (!mounted) return;
      _cancelEdit();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.red),
      );
    }
  }
}
