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
/// Updated: 22/10/2026 - Moataz: "this is the perfect model — apply it
///          everywhere". The box reads / writes through a [CommentSource], so
///          a module with its own comment store (Time Tracker, Inventory, …)
///          shows this exact box over its own data. No source = the flat
///          collection ([FirestoreCommentSource]), as before.
library;

import 'package:knowticed_plus/core/custom/pickers/custom_upload_document.dart'
    show fileTypeIconAsset;
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/cards/custom_person_chips.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

part 'custom_comment_widget/comment_source.dart';
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

  /// 21/10/2026 (Moataz): when true, Expand scrolls the page to its TOP (so a
  /// summary the page shows above the thread stays visible) and the thread
  /// then fills exactly the space left down to the bottom of the visible
  /// area — on the phone, the top of the tab bar — so the input never hides
  /// under it. False keeps the old "bring the section to the top" behaviour.
  final bool fitBelowPageTopWhenExpanded;

  final Future<void> Function({
    required String currentUserId,
    String? commentText,
    String? mediaPath,
  })? customAddComment;

  /// A module's own comment store; null = [collectionPath] + [filterFields].
  final CommentSource? source;

  const UniversalCommentSection({
    super.key,
    this.collectionPath = '',
    this.filterFields = const <String, dynamic>{},
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
    this.fitBelowPageTopWhenExpanded = false,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    final CommentSource effective = source ??
        FirestoreCommentSource(
          collectionPath: collectionPath,
          filterFields: filterFields,
          customAddComment: customAddComment,
          onCommentAdded: onCommentAdded,
        );
    return _UniversalCommentSectionState(
      source: effective,
      currentUserId: currentUserId,
      style: style ?? CommentSectionStyle(),
      enableFileAttachment: enableFileAttachment && effective.supportsFiles,
      isExpandable: isExpandable,
      fixedHeight: fixedHeight,
      collapsedHeight: collapsedHeight,
      onExpandChanged: onExpandChanged,
      fitBelowPageTopWhenExpanded: fitBelowPageTopWhenExpanded,
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

  /// 21/10/2026 (Moataz): inline edit, like Messages — the comment being
  /// edited (null = writing a new one) and its text before the edit, shown
  /// in the bar above the input.
  final FocusNode _commentFocus = FocusNode();
  CommentEntry? _editing;
  String? _editingOriginal;
  bool _isFullScreen = false;

  /// Measured expanded height (fitBelowPageTopWhenExpanded); null = estimate.
  double? _fittedHeight;

  /// After the page has scrolled to its top: the thread starts at this
  /// widget's top + header, and must end at the bottom of the visible area.
  void _fitExpandedHeight() {
    if (!mounted || !_isFullScreen) return;
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final MediaQueryData media = MediaQuery.of(context);
    final double top = box.localToGlobal(Offset.zero).dy;
    // Same reservation SideFrameBoundedBody makes for the phone tab bar.
    final double navBar = kpIsPhoneLayout(context) ? 125.sp : 0;
    final double bottom = media.size.height - media.padding.bottom - navBar;
    final double header = widget.isExpandable ? 40.sp + 5.h : 0;
    final double fitted =
        (bottom - top - header - 12.sp).clamp(200.0, double.infinity);
    if (_fittedHeight != fitted) setState(() => _fittedHeight = fitted);
  }

  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isUploading = false;

  /// Kept across rebuilds; re-subscribed only when the thread changes.
  late Stream<List<CommentEntry>> _thread = widget.source.watch();

  @override
  void didUpdateWidget(covariant _UniversalCommentSectionState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source.identity != widget.source.identity) {
      _thread = widget.source.watch();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  /// ✅ FIX: Use context-based locale instead of Get.locale
  bool _isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
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
    // Item 177 (21/10/2026, "when I downloaded it threw me out"): this used
    // to `Navigator.pop()` after the download — there was no loading dialog
    // to pop, so it popped the PAGE. The app's loader overlay shows instead,
    // and the page stays.
    setState(() => _isUploading = true);
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
      setState(() => _isUploading = false);
      _showDownloadSuccessDialog(filePath, fileName);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
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
    // 18/10/2026 (Moataz): expanded fills the VISIBLE area of the page (the
    // scroll viewport minus this section's own header row), not the whole
    // window height — so the expanded thread + input never need a scroll.
    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    final double viewport =
        (scrollable != null && scrollable.position.hasViewportDimension)
            ? scrollable.position.viewportDimension
            : MediaQuery.of(context).size.height;
    final double expandedHeight = widget.fixedHeight ??
        (viewport - (widget.isExpandable ? 40.sp + 5.h : 0))
            .clamp(200.0, double.infinity);
    final double collapsedH = widget.collapsedHeight ?? 400.h;
    final double height =
        _isFullScreen ? (_fittedHeight ?? expandedHeight) : collapsedH;

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
                // 22/10/2026: shrinks to fit a narrow phone (never "…"),
                // so the title never pushes Expand off the row. Expanded
                // (not Flexible + Spacer, which split the row in half and
                // left Expand in the middle) keeps Expand at the row's end.
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      S.of(context).inquiriesAndComments,
                      maxLines: 1,
                      style: StyleText.fontSize22Weight700.copyWith(
                        color: AppColors.text,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ),
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
                    // 18/10/2026 (Moataz: "too big"): 14/500, 1 rule.
                    final TextStyle expandStyle = StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.blue);

                    return InkWell(
                      borderRadius: BorderRadius.circular(6.r),
                      onTapDown: (_) => HapticController.low(),
                      onTap: () {
                        final newState = !_isFullScreen;
                        setState(() {
                          _isFullScreen = newState;
                          _fittedHeight = null;
                        });
                        widget.onExpandChanged?.call(newState);
                        if (newState && widget.fitBelowPageTopWhenExpanded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            // Every scroll view above us goes to its top —
                            // on the phone the frame wraps the page in a
                            // second one, so the nearest alone is not enough.
                            ScrollableState? scrollable =
                                Scrollable.maybeOf(this.context);
                            while (scrollable != null) {
                              final ScrollPosition position =
                                  scrollable.position;
                              position.jumpTo(position.minScrollExtent);
                              scrollable =
                                  Scrollable.maybeOf(scrollable.context);
                            }
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _fitExpandedHeight());
                          });
                        } else if (newState) {
                          // Expanded = exactly the visible page: bring the
                          // section to the top so nothing needs scrolling.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            Scrollable.ensureVisible(
                              this.context,
                              alignment: 0,
                              duration: const Duration(milliseconds: 250),
                            );
                          });
                        }
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
                            SizedBox(height: 1.h),
                            Container(
                              width: _getTextWidth(expandLabel, expandStyle),
                              height: 1,
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
                        child: StreamBuilder<List<CommentEntry>>(
                          stream: _thread,
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

                            final comments =
                                snapshot.data ?? const <CommentEntry>[];

                            // EDIT 25/9/2026: empty thread shows the same
                            // illustration as knowticed_admin instead of a blank box.
                            // D-222 (21/10/2026): an empty thread shows the
                            // shared empty state (as Time Tracker), not a
                            // blank box.
                            if (comments.isEmpty) {
                              // Owner 21/10/2026: the comments illustration (425:235), not the lottie — 200 wide on tablet/desktop, 160 on phone.
                              final double emptyW =
                                  kpIsPhoneLayout(context) ? 160 : 200;
                              return Center(
                                child: CustomEmptyState(
                                  // Fits the collapsed thread height.
                                  size: emptyW,
                                  height: emptyW * 235 / 425,
                                  verticalPadding: 12,
                                  svgPath:
                                      'assets/icons_assets/main_icons_assets/ic_empty_comments.svg',
                                  title: S.of(context).noCommentsYet,
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
                                return _buildCommentItem(comments[index]);
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
                if (widget.source.canWrite) ...[
                  SizedBox(height: 15.h),
                  _buildInputField(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteComment(CommentEntry comment) async {
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
      onConfirm: () => widget.source.delete(comment),
    );
  }

  Future<void> _replaceAttachment(CommentEntry comment) async {
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
      await widget.source.replaceFile(
        comment,
        url: url,
        name: file.name,
        size: _getFileSize(file.path!),
      );
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
        child: CustomSvgImage.natural(
          assetPath: 'assets/icons_assets/qiyas_assets/ic_file_attachment.svg',
          width: 20.sp,
          height: 20.sp,
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
