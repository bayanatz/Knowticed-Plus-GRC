/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: universal_comment_section.dart
/// Description: Declares `UniversalCommentSection`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 23/8/2026 - The comment box is a `CustomTextField` (core/custom/2)
///          instead of a bare `TextField`, so it carries the same fill, radius
///          and type sizes as every other input in the app.
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/core/custom/cards/custom_card_styles.dart';
import 'package:grc_module/core/custom/cards/custom_person_chips.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/helper/format_title.dart';
import 'package:grc_module/core/custom/inputs/custom_textfield.dart';
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/helper/access/main_core_employee_controller.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/core/custom/feedback/circle_progress.dart';
import 'package:grc_module/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

part 'custom_comment_widget/comment_section_style.dart';
part 'custom_comment_widget/universal_comment_section_state.dart';
part 'custom_comment_widget/universal_comment_section_builders.dart';
part 'custom_comment_widget/universal_comment_section_logic.dart';

class UniversalCommentSection extends StatelessWidget {
  final String collectionPath;
  final Map<String, dynamic> filterFields;
  final String sortByField;
  final String currentUserId;
  final CommentSectionStyle? style;
  final Function(Map<String, dynamic> commentData)? onCommentAdded;
  final bool enableFileAttachment;
  final bool isExpandable;

  /// ✅ Height when expanded (full screen)
  final double? fixedHeight;

  /// ✅ Height when collapsed (default 400.h)
  final double? collapsedHeight;

  /// ✅ Callback fired whenever the section expands or collapses
  final Function(bool isExpanded)? onExpandChanged;

  final Future<void> Function({
    required String currentUserId,
    String? commentText,
    String? mediaPath,
  })? customAddComment;

  const UniversalCommentSection({
    super.key,
    required this.collectionPath,
    required this.filterFields,
    required this.currentUserId,
    this.sortByField = 'Comment_Date',
    this.style,
    this.onCommentAdded,
    this.enableFileAttachment = true,
    this.isExpandable = true,
    this.fixedHeight,
    this.collapsedHeight,
    this.onExpandChanged,
    this.customAddComment,
  });

  @override
  Widget build(BuildContext context) {
    return _UniversalCommentSectionState(
      collectionPath: collectionPath,
      filterFields: filterFields,
      sortByField: sortByField,
      currentUserId: currentUserId,
      style: style ?? CommentSectionStyle(),
      onCommentAdded: onCommentAdded,
      enableFileAttachment: enableFileAttachment,
      isExpandable: isExpandable,
      fixedHeight: fixedHeight,
      collapsedHeight: collapsedHeight,
      onExpandChanged: onExpandChanged,
      customAddComment: customAddComment,
    );
  }
}

class _UniversalCommentSectionStateImpl
    extends State<_UniversalCommentSectionState> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFullScreen = false;
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isUploading = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// ✅ FIX: Use context-based locale instead of Get.locale
  bool _isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      widget.collectionPath,
    );
    widget.filterFields.forEach((field, value) {
      query = query.where(field, isEqualTo: value);
    });
    return query;
  }

  Future<String?> _uploadFileToStorage(String filePath, String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileRef = storageRef.child(
        'comment_attachments/${timestamp}_$fileName',
      );
      final file = File(filePath);
      final uploadTask = await fileRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  String _getFileSize(String filePath) {
    try {
      final file = File(filePath);
      final bytes = file.lengthSync();
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(2)} MB';
    } catch (e) {
      return '0 MB';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getFileExtension(String fileName) {
    if (fileName.isEmpty) return '';
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  String _getFileType(String fileName) {
    final extension = _getFileExtension(fileName);
    switch (extension) {
      case 'pdf':
        return 'PDF Document';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'xls':
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'gif':
        return 'GIF Image';
      case 'txt':
        return 'Text File';
      case 'zip':
        return 'ZIP Archive';
      case 'mp3':
        return 'Audio File';
      case 'mp4':
        return 'Video File';
      default:
        return '${extension.toUpperCase()} File';
    }
  }

  String _getCommenterName(String? email) {
    if (email == null || email.isEmpty) return 'Unknown User';
    try {
      final employeeController = Get.find<MainCoreEmployeeController>();
      String name = employeeController.getEmployeeName(email);
      if (name == "no name" || name.isEmpty) return email;
      return name;
    } catch (e) {
      return email;
    }
  }


  /// The commenter's photo URL ('' = the default avatar).
  String _getCommenterPhoto(String? email) {
    if (email == null || email.isEmpty) return '';
    try {
      return Get.find<MainCoreEmployeeController>().getEmployeePhoto(email);
    } catch (e) {
      return '';
    }
  }

  String _getCommenterDepartment(String? email) {
    if (email == null || email.isEmpty) return '';
    try {
      final employeeController = Get.find<MainCoreEmployeeController>();
      String department = employeeController.getEmployeeDepartmentName(email);
      if (department == "no department" || department.isEmpty) return '';
      return department;
    } catch (e) {
      return '';
    }
  }

  Future<void> _downloadFile(String? fileUrl, String fileName) async {
    if (fileUrl == null || fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File URL not available'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid file URL: $fileUrl'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    try {
      final dio = Dio();
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }
      if (directory == null) {
        throw Exception('Could not find download directory');
      }
      final filePath = '${directory.path}/$fileName';
      await dio.download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {}
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      _showDownloadSuccessDialog(filePath, fileName);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: $e'),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  double _getTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      // ✅ FIX: Use correct text direction based on locale
      textDirection: _isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = _isArabic(context);
    final double expandedHeight =
        widget.fixedHeight ?? MediaQuery.of(context).size.height;
    final double collapsedH = widget.collapsedHeight ?? 400.h;
    final double height = _isFullScreen ? expandedHeight : collapsedH;

    return Directionality(
      // ✅ FIX: Wrap entire section with correct text direction
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header row with Expand / Collapse button
          if (widget.isExpandable)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  S.of(context).inquiriesAndComments,
                  style: StyleText.fontSize22Weight700.copyWith(
                    color: AppColors.text,
                    fontSize: 20.sp,
                  ),
                ),
                Spacer(),
                // EDIT 29/8/2026: Expand / Hide was a 14/400 label with a
                // hairline under it, sitting next to a 22pt section heading —
                // easy to miss, and a thin tap target since only the glyphs
                // themselves were hittable. It is now 18/500 with a 2 rule and
                // padding inside the InkWell, so the whole padded box responds.
                //
                // The rule is measured with the SAME style the label draws in.
                // It used to measure `widget.style.expandButtonStyle` while the
                // label rendered `fontSize14Weight400`, so the underline never
                // actually matched the width of the word above it.
                Builder(
                  builder: (context) {
                    final String expandLabel = _isFullScreen
                        ? S.of(context).hide
                        : S.of(context).expand;
                    final TextStyle expandStyle = StyleText.fontSize18Weight500
                        .copyWith(color: AppColors.blue);

                    return InkWell(
                      borderRadius: BorderRadius.circular(6.r),
                      onTapDown: (_) => HapticController.low(),
                      onTap: () {
                        final newState = !_isFullScreen;
                        setState(() => _isFullScreen = newState);
                        widget.onExpandChanged?.call(newState);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(expandLabel, style: expandStyle),
                            SizedBox(height: 2.h),
                            Container(
                              width: _getTextWidth(expandLabel, expandStyle),
                              height: 2.h,
                              color: AppColors.blue,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

          if (widget.isExpandable) SizedBox(height: 5.h),

          SizedBox(
            height: height,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: widget.style.containerPadding,
                        decoration: widget.style.containerDecoration,
                        child:
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _buildQuery().snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircleProgressMaster();
                            }

                            var comments = snapshot.data?.docs ?? [];
                            comments.sort((a, b) {
                              final aDate =
                                  a.data()['Comment_Date'] as Timestamp?;
                              final bDate =
                                  b.data()['Comment_Date'] as Timestamp?;
                              if (aDate == null) return 1;
                              if (bDate == null) return -1;
                              return aDate.compareTo(bDate);
                            });

                            // EDIT 25/9/2026: empty thread shows the same
                            // illustration as knowticed_admin instead of a blank box.
                            if (comments.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            _scrollToBottom();

                            return ListView.separated(
                              controller: _scrollController,
                              itemCount: comments.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 15.h),
                              itemBuilder: (context, index) {
                                final comment = comments[index].data();
                                return _buildCommentItem(
                                  comment,
                                  comments[index].reference,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // EDIT 25/9/2026: upload progress is shown once, in the
                      // middle of the comments area, with the app's loader —
                      // not as two small spinners in the input row.
                      if (_isUploading)
                        const Positioned.fill(child: CircleProgressMaster()),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                _buildInputField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteComment(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json',
      confirmTitle: S.of(context).deleteMessage,
      confirmSubtitle: S.of(context).AreYousureYouWanttoDeleteThisMessage,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      showSuccessDialog: false,
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
      successTitle: '',
      successSubtitle: '',
      onConfirm: () async {
        try {
          await ref.delete();
          return true;
        } catch (_) {
          return false;
        }
      },
    );
  }

  Future<void> _replaceAttachment(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    setState(() => _isUploading = true);
    try {
      final url = await _uploadFileToStorage(file.path!, file.name);
      if (url == null) throw Exception('Failed to upload file');
      await ref.update({
        'Comment_Link': url,
        'File_Name': file.name,
        'File_Size': _getFileSize(file.path!),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  /// ✅ Extracted attach button widget to reuse in prefix/suffix
  ///
  /// A sized `InkWell` rather than an `IconButton` (23/8/2026): `IconButton`
  /// enforces a 48x48 minimum tap target, and `CustomTextField` passes an
  /// unbounded `prefixIconConstraints`, so the icon alone would have made the
  /// comment box taller than the 46.h send button next to it.
  Widget _buildAttachButton() {
    return InkWell(
      onTapDown: _isUploading ? null : (_) => HapticController.medium(),
      onTap: _isUploading ? null : _pickFile,
      borderRadius: BorderRadius.circular(4.r),
      child: SizedBox(
        width: 24.sp,
        height: 24.sp,
        child: Icon(
          Icons.attach_file,
          size: 20.sp,
          color: widget.style.attachIconColor,
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        // EDIT 25/9/2026: no "File attached" snackbar — the chip above the
        // input already shows the selected file.
        setState(() {
          _selectedFilePath = file.path;
          _selectedFileName = file.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final isArabic = _isArabic(context);
    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return isArabic
          ? 'منذ ${diff.inDays} يوم'
          : '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return isArabic
          ? 'منذ ${diff.inHours} ساعة'
          : '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return isArabic
          ? 'منذ ${diff.inMinutes} دقيقة'
          : '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return isArabic ? 'الآن' : 'Now';
    }
  }
}
