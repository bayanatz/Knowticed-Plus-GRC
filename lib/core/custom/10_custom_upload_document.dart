// ─────────────────────────────────────────────
//  UPLOAD / ATTACHMENT DIALOG  (Figma-matched)
// ─────────────────────────────────────────────
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:demo_app/core/custom/32-custom_svg.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/local_widgets/services_management/custom_textformfield.dart';

///
/// Usage:
/// ```dart
/// showUploadDialog(
///   context: context,
///   onSubmit: (file, title) { /* handle upload */ },
/// );
/// ```
Future<void> showUploadDialog({
  required BuildContext context,
  String dialogTitle = 'Adding Attachment',
  String titleFieldLabel = 'Title Name',
  String titleFieldHint = 'Text here',
  String submitLabel = 'Submit',
  String discardLabel = 'Discard',
  String browseLabel = 'Browse Files',
  TextDirection textDirection = TextDirection.ltr,
  String? headerIconAsset,
  List<String>? allowedExtensions,
  void Function(PlatformFile file, String titleName)? onSubmit,
}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withOpacity(0.4),
    builder: (_) => _UploadDialog(
      dialogTitle: dialogTitle,
      titleFieldLabel: titleFieldLabel,
      titleFieldHint: titleFieldHint,
      submitLabel: submitLabel,
      discardLabel: discardLabel,
      browseLabel: browseLabel,
      textDirection: textDirection,
      headerIconAsset: headerIconAsset,
      allowedExtensions: allowedExtensions,
      onSubmit: onSubmit,
    ),
  );
}

// ─────────────────────────────────────────────
//  Helper — file-type icon path
// ─────────────────────────────────────────────
String getFileIcon(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg';
    case 'ppt':
    case 'pptx':
      return 'assets/icons_assets/main_icons_assets/ppt_attachment_icon.svg';
    case 'doc':
    case 'docx':
      return 'assets/icons_assets/main_icons_assets/doc_icon.svg';
    case 'png':
      return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
    default:
      return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
  }
}

// ─────────────────────────────────────────────
//  _DialogShell — rounded dialog wrapper (no border)
// ─────────────────────────────────────────────
class _DialogShell extends StatelessWidget {
  final Widget child;
  final double width;

  const _DialogShell({required this.child, required this.width});

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      backgroundColor: lightMode ? AppColors.card : AppColors.background,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        width: width,
        padding: EdgeInsets.all(20.r),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Dialog states
// ─────────────────────────────────────────────
enum _UploadState {
  empty,   // State 1: no file — drop zone + Discard/Browse buttons (NO title field)
  picked,  // State 2: file picked — file card + Title + Discard/Submit
  removed, // State 3: file removed — Upload button + Title + Discard/Submit
}

// ─────────────────────────────────────────────
//  _UploadDialog — StatefulWidget
// ─────────────────────────────────────────────
class _UploadDialog extends StatefulWidget {
  final String dialogTitle;
  final String titleFieldLabel;
  final String titleFieldHint;
  final String submitLabel;
  final String discardLabel;
  final String browseLabel;
  final TextDirection textDirection;
  final String? headerIconAsset;
  final List<String>? allowedExtensions;
  final void Function(PlatformFile, String)? onSubmit;

  const _UploadDialog({
    required this.dialogTitle,
    required this.titleFieldLabel,
    required this.titleFieldHint,
    required this.submitLabel,
    required this.discardLabel,
    required this.browseLabel,
    required this.textDirection,
    this.headerIconAsset,
    this.allowedExtensions,
    this.onSubmit,
  });

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

// ─────────────────────────────────────────────
//  _UploadDialogState
// ─────────────────────────────────────────────
class _UploadDialogState extends State<_UploadDialog> {
  PlatformFile? _pickedFile;
  _UploadState _uploadState = _UploadState.empty;
  final TextEditingController _titleCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  // ── File picker ──
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedExtensions,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _uploadState = _UploadState.picked;
      });
    }
  }

  // ── Remove file ──
  void _removeFile() {
    setState(() {
      _pickedFile = null;
      _uploadState = _UploadState.removed;
    });
  }

  // ── Submit handler ──
  void _handleSubmit() {
    setState(() => _submitted = true);
    if (_pickedFile == null) return;
    if (_titleCtrl.text.trim().isEmpty) return;
    Navigator.of(context).pop();
    widget.onSubmit?.call(_pickedFile!, _titleCtrl.text.trim());
  }

  // ── Helpers ──
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Extract extension from file name
  String _getExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last : '';
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 430.w, // ✅ Fixed width = 430.w
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          _buildHeader(),
          SizedBox(height: 20.h),

          // ── State 1: Drop zone ONLY — NO title field ──
          if (_uploadState == _UploadState.empty) ...[
            _buildDropZone(),
            SizedBox(height: 20.h),
            _buildState1Buttons(),

            // ── State 2 & 3: File section + title + submit buttons ──
          ] else ...[
            Text(
              'File',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 8.h),

            // State 2 → file card | State 3 → upload button
            if (_uploadState == _UploadState.picked)
              _buildFileCard()
            else
              _buildUploadButton(),

            SizedBox(height: 16.h),

            // Title Name field
            Text(
              widget.titleFieldLabel,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.text),
            ),
            SizedBox(height: 6.h),
            CustomTextField(
              hint: widget.titleFieldHint,
              controller: _titleCtrl,
              required: _submitted,
              textDirection: widget.textDirection,
              onChanged: (_) => setState(() {}),
            ),

            SizedBox(height: 20.h),
            _buildState2And3Buttons(),
          ],

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Header
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child:
                 SvgPicture.asset(
              "assets/icons_assets/main_icons_assets/Upload Minimalistic.svg",
              width: 18.r,
              height: 18.r,
            )
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          widget.dialogTitle,
          style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  State 1 — Drop zone (no border, light grey bg)
  // ─────────────────────────────────────────────
  Widget _buildDropZone() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvg(assetPath: "assets/icons_assets/main_icons_assets/first_upload.svg",width: 100.sp,height: 100.sp,fit: BoxFit.fill,),
          SizedBox(height: 12.h),
          Text(
            'Drag & Drop files here',
            style: StyleText.fontSize16Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 6.h),
          Text(
            'Or',
            style: StyleText.fontSize13Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  State 1 buttons — Discard (left) | Browse Files (right)
  // ─────────────────────────────────────────────
  Widget _buildState1Buttons() {
    return Row(
      children: [
        Expanded(
          child: _secondaryBtn(
            label: widget.discardLabel,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _primaryBtn(
            label: widget.browseLabel,
            onTap: _pickFile,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  State 2 — File card with SVG icon (NO background box)
  // ─────────────────────────────────────────────
  Widget _buildFileCard() {
    final file = _pickedFile;
    if (file == null) return _buildUploadButton();
    final now = DateTime.now();
    final ext = _getExtension(file.name);
    final iconPath = getFileIcon(ext);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // ✅ SVG icon directly — NO white background box
          SvgPicture.asset(
            iconPath,
            width: 40.r,
            height: 40.r,
          ),
          SizedBox(width: 12.w),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: StyleText.fontSize13Weight400
                      .copyWith(color: AppColors.text),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      _formatBytes(file.size),
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.secondaryText),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Date: ${_formatDate(now)}',
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Red circle minus button
          GestureDetector(
            onTap: _removeFile,
            child: Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove, size: 14.r, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  State 3 — Full-width Upload button (no border)
  // ─────────────────────────────────────────────
  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        height: 46.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_rounded, size: 18.r, color: AppColors.textButton),
            SizedBox(width: 8.w),
            Text(
              'Upload',
              style: StyleText.fontSize14Weight600
                  .copyWith(color: AppColors.textButton),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  States 2 & 3 buttons — Discard | Submit
  // ─────────────────────────────────────────────
  Widget _buildState2And3Buttons() {
    return Row(
      children: [
        Expanded(
          child: _secondaryBtn(
            label: widget.discardLabel,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _primaryBtn(
            label: widget.submitLabel,
            onTap: _handleSubmit,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Button helpers (no border anywhere)
  // ─────────────────────────────────────────────

  Widget _secondaryBtn({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36.sp,
        decoration: BoxDecoration(
          color: AppColors.greyDark,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.text),
        ),
      ),
    );
  }

  Widget _primaryBtn({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36.sp,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: StyleText.fontSize14Weight600
              .copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }
}
