import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/circle_progress.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:demo_app/core/custom/32-custom_svg.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import '../../generated/l10n.dart';

import 'package:demo_app/core/custom/circle_progress.dart';

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
    Key? key,
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
  }) : super(key: key);

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

class _UniversalCommentSectionState extends StatefulWidget {
  final String collectionPath;
  final Map<String, dynamic> filterFields;
  final String sortByField;
  final String currentUserId;
  final CommentSectionStyle style;
  final Function(Map<String, dynamic>)? onCommentAdded;
  final bool enableFileAttachment;
  final bool isExpandable;
  final double? fixedHeight;
  final double? collapsedHeight;
  final Function(bool isExpanded)? onExpandChanged;
  final Future<void> Function({
  required String currentUserId,
  String? commentText,
  String? mediaPath,
  })? customAddComment;

  const _UniversalCommentSectionState({
    required this.collectionPath,
    required this.filterFields,
    required this.sortByField,
    required this.currentUserId,
    required this.style,
    this.onCommentAdded,
    required this.enableFileAttachment,
    required this.isExpandable,
    this.fixedHeight,
    this.collapsedHeight,
    this.onExpandChanged,
    this.customAddComment,
  });

  @override
  State<_UniversalCommentSectionState> createState() =>
      _UniversalCommentSectionStateImpl();
}

class _UniversalCommentSectionStateImpl
    extends State<_UniversalCommentSectionState> {
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
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection(widget.collectionPath);
    widget.filterFields.forEach((field, value) {
      query = query.where(field, isEqualTo: value);
    });
    return query;
  }

  Future<String?> _uploadFileToStorage(
      String filePath, String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileRef =
      storageRef.child('comment_attachments/${timestamp}_$fileName');
      final file = File(filePath);
      final uploadTask = await fileRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("❌ Error uploading file to Firebase Storage: $e");
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
      setState(() => _isUploading = true);

      String? firebaseUrl;

      if (_selectedFilePath != null && _selectedFileName != null) {
        firebaseUrl = await _uploadFileToStorage(
          _selectedFilePath!,
          _selectedFileName!,
        );

        if (firebaseUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text('Failed to upload file'),
              backgroundColor: AppColors.red,
            ),
          );
          setState(() => _isUploading = false);
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
        setState(() {
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
        'File_Size': _selectedFilePath != null
            ? _getFileSize(_selectedFilePath!)
            : null,
      };

      await FirebaseFirestore.instance
          .collection(widget.collectionPath)
          .doc(commentData['Comment_Id'] as String)
          .set(commentData);

      widget.onCommentAdded?.call(commentData);

      _commentController.clear();
      setState(() {
        _selectedFilePath = null;
        _selectedFileName = null;
        _isUploading = false;
      });
      _scrollToBottom();
    } catch (e, stack) {
      print('❌ Error adding comment: $e');
      print('Stack trace: $stack');
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
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

  String _getCommenterInitial(String? email) {
    if (email == null || email.isEmpty) return 'U';
    try {
      final employeeController = Get.find<MainCoreEmployeeController>();
      String firstName =
      employeeController.getEmployeeNameFirstOrLast(email, true);
      if (firstName.isNotEmpty) return firstName.substring(0, 1).toUpperCase();
      return email.substring(0, 1).toUpperCase();
    } catch (e) {
      return email.substring(0, 1).toUpperCase();
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
            backgroundColor: AppColors.red),
      );
      return;
    }
    if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Invalid file URL: $fileUrl'),
            backgroundColor: AppColors.red),
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
      await dio.download(fileUrl, filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              print(
                  "Download progress: ${(received / total * 100).toStringAsFixed(0)}%");
            }
          });
      Navigator.of(context).pop();
      _showDownloadSuccessDialog(filePath, fileName);
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to download file: $e'),
            backgroundColor: AppColors.red,
            duration: const Duration(seconds: 3)),
      );
    }
  }

  void _showDownloadSuccessDialog(String filePath, String fileName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          width: 411.w,
          padding: EdgeInsets.all(15.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle,
                      color: AppColors.primary, size: 28.sp),
                  SizedBox(width: 8.w),
                  Text(S.of(context).downloadComplete,
                      style: StyleText.fontSize16Weight400
                          .copyWith(color: AppColors.text)),
                ],
              ),
              SizedBox(height: 12.h),
              Text('${S.of(context).file}: $fileName',
                  style: StyleText.fontSize16Weight400
                      .copyWith(color: AppColors.text)),
              SizedBox(height: 12.h),
              Text(S.of(context).saveTo,
                  style: StyleText.fontSize16Weight400
                      .copyWith(color: AppColors.secondaryText)),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(6.r)),
                child: Row(
                  children: [
                    Icon(Icons.folder,
                        size: 20.sp, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(filePath,
                          style: StyleText.fontSize16Weight400
                              .copyWith(color: AppColors.text),
                          overflow: TextOverflow.ellipsis),
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
                      color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      // ✅ FIX: Use correct text direction based on locale
      textDirection:
      _isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
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
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.text),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    final newState = !_isFullScreen;
                    setState(() => _isFullScreen = newState);
                    widget.onExpandChanged?.call(newState);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isFullScreen
                                ? S.of(context).collapse
                                : S.of(context).expand,
                            style: StyleText.fontSize12Weight400.copyWith(
                              color: AppColors.secondaryPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Container(
                            width: _getTextWidth(
                              _isFullScreen
                                  ? S.of(context).collapse
                                  : S.of(context).expand,
                              widget.style.expandButtonStyle,
                            ),
                            height: 1.h,
                            color: AppColors.secondaryPrimary,
                          ),
                        ],
                      ),
                      SizedBox(width: 4.w),
                    ],
                  ),
                ),
              ],
            ),

          if (widget.isExpandable) SizedBox(height: 5.h),

          SizedBox(
            height: height,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: widget.style.containerPadding,
                    decoration: widget.style.containerDecoration,
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _buildQuery().snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
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

                        if (comments.isEmpty) {
                          return Center(
                            child: CustomSvg(
                              assetPath:
                              "assets/icons_assets/calender_assets/no_comment.svg",
                              width: 150.w,
                              height: 150.h,
                              fit: BoxFit.fill,
                            ),
                          );
                        }

                        _scrollToBottom();

                        return ListView.separated(
                          controller: _scrollController,
                          itemCount: comments.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: 15.h),
                          itemBuilder: (context, index) {
                            final comment = comments[index].data();
                            return _buildCommentItem(comment);
                          },
                        );
                      },
                    ),
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

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final commentText = comment['Comment_Text'] as String?;
    final fileName = comment['File_Name'] as String?;
    final fileUrl = comment['Comment_Link'] as String?;
    final commenterEmail = comment['Commenter_Id'] as String?;
    final commentDate =
    (comment['Comment_Date'] as Timestamp?)?.toDate();

    final commenterName = _getCommenterName(commenterEmail);
    final commenterInitial = _getCommenterInitial(commenterEmail);
    final commenterDepartment = _getCommenterDepartment(commenterEmail);

    final bool isCurrentUser = commenterEmail == widget.currentUserId;
    final bool isArabic = _isArabic(context);

    // ✅ FIX: In RTL (Arabic), the Directionality wrapper already handles
    // the base direction. We just need to align current user's messages
    // to the "end" and other user's messages to the "start".
    // "start" in LTR = left, in RTL = right
    // "end" in LTR = right, in RTL = left

    return Container(
      padding: EdgeInsets.all(0.sp),
      margin: EdgeInsetsDirectional.only(
        // ✅ FIX: Use EdgeInsetsDirectional so it auto-flips in RTL
        start: isCurrentUser ? 40.w : 0,
        end: isCurrentUser ? 0 : 40.w,
      ),
      decoration: widget.style.commentItemDecoration,
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              // ✅ FIX: Avatar on the "start" side for other users
              if (!isCurrentUser)
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: CustomSvg(
                    assetPath: "assets/icons_assets/main_icons_assets/assets_male.svg",
                    width: 45.w,
                    height: 45.h,
                    fit: BoxFit.fill,
                  ),
                ),
              if (!isCurrentUser) SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.capitalize(commenterName),
                      style: widget.style.userNameStyle,
                    ),
                    SizedBox(height: 4.h),
                    if (commenterDepartment.isNotEmpty)
                      Text(
                        commenterDepartment,
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    SizedBox(height: 2.h),
                    if (commentText != null && commentText.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          FormatHelper.capitalize(commentText),
                          style: widget.style.commentTextStyle,
                          // ✅ FIX: Current user's text aligns to end,
                          // other user's text aligns to start.
                          // Directionality wrapper handles RTL/LTR automatically.
                          textAlign:
                          isCurrentUser ? TextAlign.end : TextAlign.start,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // ✅ FIX: Avatar on the "end" side for current user
              if (isCurrentUser) SizedBox(width: 8.w),
              if (isCurrentUser)
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: CustomSvg(
                    assetPath: "assets/icons_assets/main_icons_assets/assets_male.svg",
                    width: 45.w,
                    height: 45.h,
                    fit: BoxFit.fill,
                  ),
                ),
            ],
          ),
          if (fileName != null) ...[
            SizedBox(height: 8.h),
            Container(
              // ✅ FIX: Use AlignmentDirectional for auto RTL/LTR
              alignment: isCurrentUser
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: InkWell(
                onTap: () => _downloadFile(fileUrl, fileName),
                child: Container(
                  height: 70.h,
                  width: 270.w,
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 6.h),
                  decoration:
                  widget.style.fileChipDecoration?.copyWith() ??
                      BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.blue, width: 1),
                      ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFileIcon(fileName),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              fileName,
                              style:
                              widget.style.fileNameStyle?.copyWith(
                                decoration:
                                TextDecoration.underline,
                              ) ??
                                  StyleText.fontSize12Weight500.copyWith(
                                    color: AppColors.blue,
                                    decoration:
                                    TextDecoration.underline,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _getFileType(fileName),
                              style: StyleText.fontSize10Weight400.copyWith(
                                  color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.download,
                          size: 16.sp, color: AppColors.secondaryText),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            if (commentDate != null)
              Text(
                _formatDate(commentDate),
                style: StyleText.fontSize12Weight400
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
            padding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.card, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file,
                    size: 18.sp, color: AppColors.text),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFileName!,
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.text),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      if (_selectedFilePath != null)
                        Text(
                          _getFileSize(_selectedFilePath!),
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.secondaryText),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                if (!_isUploading)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilePath = null;
                        _selectedFileName = null;
                      });
                    },
                    child: Icon(Icons.close,
                        size: 20.sp, color: AppColors.primary),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                style: StyleText.fontSize16Weight400
                    .copyWith(color: AppColors.text),
                controller: _commentController,
                maxLines: 1,
                enabled: !_isUploading,
                // ✅ FIX: Set text direction based on locale
                textDirection:
                isArabic ? TextDirection.rtl : TextDirection.ltr,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  hintText: _isUploading
                      ? 'Uploading file...'
                      : S.of(context).textHere,
                  hintStyle: widget.style.hintStyle,
                  // ✅ FIX: Hint text direction
                  hintTextDirection:
                  isArabic ? TextDirection.rtl : TextDirection.ltr,
                  filled: true,
                  fillColor: widget.style.inputFillColor,
                  border: widget.style.inputBorder,
                  enabledBorder: widget.style.inputBorder,
                  focusedBorder: widget.style.inputFocusedBorder,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 10.h),
                  // ✅ FIX: Attachment icon position — use suffixIcon for RTL
                  prefixIcon: !isArabic && widget.enableFileAttachment
                      ? _buildAttachButton()
                      : null,
                  suffixIcon: isArabic && widget.enableFileAttachment
                      ? _buildAttachButton()
                      : null,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            InkWell(
              onTap: _isUploading ? null : _addComment,
              child: Container(
                height: 46.h,
                width: 46.h,
                decoration: widget.style.sendButtonDecoration.copyWith(
                  color: _isUploading
                      ? AppColors.grey
                      : (widget.style.sendButtonDecoration.color ??
                      AppColors.primary),
                ),
                child: _isUploading
                    ? SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
                    : CustomSvg(
                  color: AppColors.secondaryPrimaryText,
                  assetPath: "assets/icons_assets/main_icons_assets/send.svg",
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

  /// ✅ Extracted attach button widget to reuse in prefix/suffix
  Widget _buildAttachButton() {
    return IconButton(
      icon: _isUploading
          ? SizedBox(
        width: 20.sp,
        height: 20.sp,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.style.attachIconColor,
          ),
        ),
      )
          : Icon(Icons.attach_file, color: widget.style.attachIconColor),
      onPressed: _isUploading ? null : _pickFile,
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
        setState(() {
          _selectedFilePath = file.path;
          _selectedFileName = file.name;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File attached: ${file.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
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

/// Styling class for customization
class CommentSectionStyle {
  final BoxDecoration containerDecoration;
  final EdgeInsets containerPadding;
  final BoxDecoration commentItemDecoration;
  final TextStyle userNameStyle;
  final TextStyle dateStyle;
  final TextStyle commentTextStyle;
  final TextStyle hintStyle;
  final TextStyle emptyStateStyle;
  final TextStyle expandButtonStyle;
  final Color avatarColor;
  final TextStyle avatarTextStyle;
  final Color inputFillColor;
  final InputBorder inputBorder;
  final InputBorder inputFocusedBorder;
  final BoxDecoration sendButtonDecoration;
  final Color sendIconColor;
  final Color attachIconColor;
  final BoxDecoration fileChipDecoration;
  final Color fileIconColor;
  final TextStyle fileNameStyle;

  CommentSectionStyle({
    BoxDecoration? containerDecoration,
    EdgeInsets? containerPadding,
    BoxDecoration? commentItemDecoration,
    TextStyle? userNameStyle,
    TextStyle? dateStyle,
    TextStyle? commentTextStyle,
    TextStyle? hintStyle,
    TextStyle? emptyStateStyle,
    TextStyle? expandButtonStyle,
    Color? avatarColor,
    TextStyle? avatarTextStyle,
    Color? inputFillColor,
    InputBorder? inputBorder,
    InputBorder? inputFocusedBorder,
    BoxDecoration? sendButtonDecoration,
    Color? sendIconColor,
    Color? attachIconColor,
    BoxDecoration? fileChipDecoration,
    Color? fileIconColor,
    TextStyle? fileNameStyle,
  })  : containerDecoration = containerDecoration ??
      BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
        containerPadding = containerPadding ?? EdgeInsets.all(15),
        commentItemDecoration = commentItemDecoration ??
            BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey),
            ),
        userNameStyle = userNameStyle ??
            StyleText.fontSize14Weight700.copyWith(
              color: AppColors.text,
            ),
        dateStyle =
            dateStyle ?? StyleText.fontSize11Weight400.copyWith(color: AppColors.secondaryText),
        commentTextStyle = commentTextStyle ??
            StyleText.fontSize13Weight400.copyWith(color: AppColors.text),
        hintStyle =
            hintStyle ?? StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
        emptyStateStyle = emptyStateStyle ??
            StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText),
        expandButtonStyle = expandButtonStyle ??
            StyleText.fontSize12Weight400.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
        avatarColor = avatarColor ?? AppColors.blue,
        avatarTextStyle = avatarTextStyle ??
            StyleText.fontSize14Weight700.copyWith(
                color: AppColors.white),
        inputFillColor = inputFillColor ?? AppColors.card,
        inputBorder = inputBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.card),
            ),
        inputFocusedBorder = inputFocusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
              BorderSide(color: AppColors.primary, width: 1.5),
            ),
        sendButtonDecoration = sendButtonDecoration ??
            BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
        sendIconColor = sendIconColor ?? AppColors.white,
        attachIconColor = attachIconColor ?? AppColors.secondaryText,
        fileChipDecoration = fileChipDecoration ??
            BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
        fileIconColor = fileIconColor ?? AppColors.blue,
        fileNameStyle = fileNameStyle ??
            StyleText.fontSize12Weight500.copyWith(
              color: AppColors.blue,
            );
}