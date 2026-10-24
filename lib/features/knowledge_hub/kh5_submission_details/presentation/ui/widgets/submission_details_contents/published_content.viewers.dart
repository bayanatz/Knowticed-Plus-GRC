/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/submission_details_contents
///
///*************************** FILE INFO ****************************///
/// File Name: published_content.viewers.dart
/// Description: `_showFileViewerDialog()`, `_buildFileContent()`, `_buildImageViewer()` and 7 more — split out of `published_content.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'published_content.dart';

/// File viewers, action buttons + approval/removal reason helpers (split from published_content.dart, §7).

Future<void> _showFileViewerDialog(
  BuildContext context, {
  required String fileUrl,
  required String fileName,
  required String fileExtension,
  required bool lightMode,
}) async {
  showAppDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: AppColors.transparent,
        insetPadding: EdgeInsets.all(10.w),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: lightMode ? AppColors.white : AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: lightMode
                          ? AppColors.secondaryText.withValues(alpha: 0.2)
                          : AppColors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fileName,
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.blackButton),
                      onPressed: withHaptic(
                        () => Navigator.of(dialogContext).pop(),
                        HapticLevel.high,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildFileContent(
                  fileUrl: fileUrl,
                  fileExtension: fileExtension,
                  lightMode: lightMode,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildFileContent({
  required String fileUrl,
  required String fileExtension,
  required bool lightMode,
}) {
  final extension = fileExtension.toLowerCase();

  if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
    return _buildImageViewer(fileUrl, lightMode);
  } else if (extension == 'pdf') {
    return _buildPDFViewer(fileUrl, lightMode);
  } else {
    return _buildUnsupportedFileView(fileExtension, lightMode);
  }
}

Widget _buildImageViewer(String imageUrl, bool lightMode) {
  return Container(
    color: AppColors.background.withValues(alpha: 0.87),
    child: PhotoView(
      // Keyed for the same reason as the pdf viewer below.
      key: ValueKey<String>(imageUrl),
      imageProvider: NetworkImage(imageUrl),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3,
      initialScale: PhotoViewComputedScale.contained,
      backgroundDecoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.87),
      ),
      loadingBuilder: (context, event) => Center(child: CircleProgressMaster()),
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
            SizedBox(height: 16.h),
            Text(
              S.of(context).khFailedToLoadImage,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPDFViewer(String pdfUrl, bool lightMode) {
  // Logged so "it opened the wrong document" can be settled in one run:
  // if two documents print the SAME url here, the problem is the stored
  // documentUrl, not the viewer.
  khLog('📄 [KH-VIEWER] pdf url: $pdfUrl');
  return Container(
    color: AppColors.background.withValues(alpha: 0.87),
    // "every knowledge view the same file".
    //
    // `SfPdfViewer` holds the loaded document in its State and does NOT
    // reload it when only the `network` URL changes. With no key, Flutter
    // matches the new widget to the existing element by position and type
    // and calls `didUpdateWidget` instead of building fresh State, so the
    // FIRST pdf opened in this viewer kept rendering for every document
    // opened afterwards — the breadcrumb said one document, the pages were
    // another's.
    //
    // Keying on the URL makes a different document a different element, so
    // the State is rebuilt and the right file loads. Same document reopened
    // = same key = the existing cache is reused, which is the behaviour that
    // made this worth having in the first place.
    child: SfPdfViewer.network(
      key: ValueKey<String>(pdfUrl),
      pdfUrl,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      enableDoubleTapZooming: true,
      enableTextSelection: true,
    ),
  );
}

Widget _buildUnsupportedFileView(String fileExtension, bool lightMode) {
  return Builder(
    builder: (context) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvgImage(
            assetPath:
                'assets/icons_assets/knowledge_hub_assets/ic_file_type.svg',
            height: 64.sp,
            width: 64.sp,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 24.h),
          Text(
            S.of(context).khPreviewNotAvailable,
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.blackButton,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            S.of(context).khFileType(fileExtension),
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              S.of(context).khDownloadToView,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ============= ACTION BUTTONS SECTION =============

Widget _buildActionButtonsSection(
  BuildContext context, {
  required String currentStatus,
  required String knowledgeId,
  required String fileUrl,
  required String documentFileName,
  required String documentExtension,
  required bool isMobile,
  required bool lightMode,
  required String createdBy,
}) {
  // KH large-screen report p.10 / p.17: Edit and Remove show for every status
  // the owner can still act on; the permission checks still decide whether
  // the user may.
  final bool showEditButton = _editableStatuses.contains(currentStatus);
  final bool showRemoveButton = _removableStatuses.contains(currentStatus);
  final String currentUserEmail = context
      .read<SubmissionsCubit>()
      .people
      .signedInEmail;
  final bool isCreator =
      currentUserEmail.toLowerCase().trim() == createdBy.toLowerCase().trim();

  // Download is gated on its own permission (2/9/2026); Edit on
  // [EditAccess] — both permissions off means no Edit button.
  final EditAccess editAccess = KnowledgeHubAccess.editAccess;
  final bool canEdit = showEditButton && editAccess.canEdit;
  final bool canRemove =
      showRemoveButton &&
      KnowledgeHubAccess.has(
        section: KnowledgeHubPermissionsSections.submissions,
        permission: SubmissionsPermissions.removeDocuments,
      );
  final _SubmissionFile file = _SubmissionFile(
    knowledgeId: knowledgeId,
    fileUrl: fileUrl,
    fileName: documentFileName,
    extension: documentExtension,
    countAction: !isCreator,
  );

  return Row(
    children: [
      if (KnowledgeHubAccess.canDownload)
        _buildActionButton(
          context,
          svgHeight: 20.h,
          svgWidth: 20.w,
          assetPath: 'assets/icons_assets/main_icons_assets/ic_action_cloud_download.svg',
          functionName: S.of(context).download,
          color: AppColors.primary,
          isMobile: isMobile,
          onTap: () => _downloadSubmissionFile(context, file),
        ),
      SizedBox(width: 15.w),
      if (KnowledgeHubAccess.has(
        section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
        permission: KnowledgeHubPermissions.viewDocuments,
      ))
        _buildActionButton(
          context,
          svgHeight: 20.h,
          svgWidth: 20.w,
          assetPath:
              'assets/icons_assets/knowledge_hub_assets/ic_action_view.svg',
          color: AppColors.primary,
          functionName: S.of(context).view,
          isMobile: isMobile,
          onTap: () => _viewSubmissionFile(context, file, lightMode: lightMode),
        ),
      const Spacer(),
      if (canEdit)
        _buildActionButton(
          context,
          assetPath: 'assets/icons_assets/main_icons_assets/ic_action_edit.svg',
          functionName: S.of(context).edit,
          color: AppColors.primary,
          isMobile: isMobile,
          onTap: () => _openEditScreen(context, knowledgeId),
        ),
      if (canEdit && canRemove) SizedBox(width: 15.w),
      if (canRemove)
        _buildRemoveButton(
          context,
          knowledgeId: knowledgeId,
          currentUserEmail: currentUserEmail,
          isMobile: isMobile,
          lightMode: lightMode,
        ),
    ],
  );
}

/// Statuses whose document the owner may still edit / remove.
const Set<String> _editableStatuses = {
  'rejected',
  'archived',
  'published',
  'approved',
  'pending_approval',
  'scheduled',
};
const Set<String> _removableStatuses = {
  'pending_approval',
  'scheduled',
  'published',
  'approved',
};

/// The red Remove button. 14/10/2026 — KH report p.17: the same red as the
/// Remove button on the document-details screen.
Widget _buildRemoveButton(
  BuildContext context, {
  required String knowledgeId,
  required String currentUserEmail,
  required bool isMobile,
  required bool lightMode,
}) {
  return _buildActionButton(
    context,
    assetPath:
        'assets/icons_assets/knowledge_hub_assets/ic_action_trash_circle.svg',
    functionName: S.of(context).remove,
    functionNameColor: AppColors.white,
    isMobile: isMobile,
    svgColor: AppColors.colorWhite,
    color: AppColors.red,
    onTap: () => _confirmRemoveDocument(
      context,
      knowledgeId: knowledgeId,
      currentUserEmail: currentUserEmail,
      isMobile: isMobile,
      lightMode: lightMode,
    ),
  );
}

/// The file of a submission and whether opening it counts as a view /
/// download (the author's own actions are not counted).
class _SubmissionFile {
  const _SubmissionFile({
    required this.knowledgeId,
    required this.fileUrl,
    required this.fileName,
    required this.extension,
    required this.countAction,
  });

  final String knowledgeId;
  final String fileUrl;
  final String fileName;
  final String extension;
  final bool countAction;
}

/// Records a view / download of [file] unless it is the author's own.
Future<void> _recordSubmissionAction(
  BuildContext context,
  _SubmissionFile file,
  String typeOfAction,
) async {
  if (!file.countAction) return;
  final SubmissionsCubit cubit = context.read<SubmissionsCubit>();
  await cubit.recordFileAction(
    knowledgeId: file.knowledgeId,
    typeOfAction: typeOfAction,
    employeeId: cubit.people.signedInEmployee?.id ?? '',
  );
}

/// Saves the file to the platform's Downloads location ("download here work
/// like view": it used to open the viewer and count a view).
Future<void> _downloadSubmissionFile(
  BuildContext context,
  _SubmissionFile file,
) async {
  showLoadingDialog(context, S.of(context).downloading);
  // Let the dialog paint before the transfer starts.
  await Future.delayed(const Duration(milliseconds: 100));
  if (!context.mounted) return;
  await _recordSubmissionAction(context, file, 'download');
  if (!context.mounted) return;
  final bool success = await downloadFile(
    context,
    fileUrl: file.fileUrl,
    fileName: file.fileName,
  );
  if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop();
  }
  if (!context.mounted) return;
  if (success) {
    showSuccessDialog(context, S.of(context).fileDownloadedSuccessfully);
  } else {
    showErrorDialog(context, S.of(context).downloadFailed);
  }
}

/// Opens the in-app viewer.
Future<void> _viewSubmissionFile(
  BuildContext context,
  _SubmissionFile file, {
  required bool lightMode,
}) async {
  await _recordSubmissionAction(context, file, 'view');
  if (!context.mounted) return;
  await _showFileViewerDialog(
    context,
    fileUrl: file.fileUrl,
    fileName: file.fileName,
    fileExtension: file.extension,
    lightMode: lightMode,
  );
}

void _openEditScreen(BuildContext context, String knowledgeId) {
  khLog('📝 Opening edit screen for: $knowledgeId', name: 'EditButton');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => KnowledgeHubDI.createKnowledgeCubit(),
        child: CreatingKnowledgeHub(knowledgeId: knowledgeId),
      ),
    ),
  );
}

/// "Remove this document?" — on Yes, asks for the reason, then refreshes the
/// submissions and goes back.
void _confirmRemoveDocument(
  BuildContext context, {
  required String knowledgeId,
  required String currentUserEmail,
  required bool isMobile,
  required bool lightMode,
}) {
  khLog('🔍 Remove button clicked: $knowledgeId', name: 'RemoveAction');
  showAppDialog(
    destructive: true,
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => _buildRemoveConfirmDialog(
      context,
      isMobile: isMobile,
      lightMode: lightMode,
      onNo: () => Navigator.pop(dialogContext),
      onYes: () async {
        Navigator.of(dialogContext).pop();
        final result = await showAppDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (ctx) => ReasonForRemovingDialog(
            documentId: knowledgeId,
            currentUserEmail: currentUserEmail,
          ),
        );
        if (result != true || !context.mounted) return;
        // Refresh the submissions list (the cubit handles errors).
        await context.read<SubmissionsCubit>().fetchMySubmissions();
        if (!context.mounted) return;
        Navigator.of(context).pop(); // back to the submissions screen
      },
    ),
  );
}

Widget _buildRemoveConfirmDialog(
  BuildContext context, {
  required bool isMobile,
  required bool lightMode,
  required VoidCallback onNo,
  required VoidCallback onYes,
}) {
  return Center(
    child: Material(
      color: AppColors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 411.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: lightMode ? AppColors.white : AppColors.background,
        ),
        padding: EdgeInsets.all(20.r),
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie_assets/main_lottie_assets/lot_status_rejected.json',
              height: 70.h,
              width: 70.w,
            ),
            SizedBox(height: 20.h),
            Text(
              S.of(context).removingDocument,
              style: StyleText.fontSize20Weight500,
            ),
            SizedBox(height: 18.h),
            Text(
              S.of(context).areYouSureYouWantToRemoveDocument,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: customButton(
                    title: S.of(context).no,
                    height: 38.h,
                    width: 135.w,
                    // 14/10/2026 — KH report p.16 / mobile p.20: the
                    // standard light-grey secondary button.
                    color: AppColors.secondaryAction,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.onSecondaryAction,
                    ),
                    function: onNo,
                  ),
                ),
                SizedBox(width: 45.w),
                Expanded(
                  child: customButton(
                    height: 38.h,
                    width: 135.w,
                    title: S.of(context).yes,
                    function: onYes,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildActionButton(
  BuildContext context, {
  required String assetPath,
  required String functionName,
  required VoidCallback? onTap,
  required bool isMobile,
  Color? color,
  Color? functionNameColor,
  Color? svgColor,
  double? svgWidth,
  double? svgHeight,
}) {
  return _AnimatedActionButton(
    onTap: onTap,
    child: Container(
      height: 38.h,
      width: isMobile ? 38.w : 135.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: color ?? AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CustomSvgImage(
              assetPath: assetPath,
              width: svgWidth ?? 20.w,
              height: svgHeight ?? 20.h,
              color: svgColor ?? AppColors.textButton,
              fit: BoxFit.cover,
            ),
          ),
          if (!isMobile) ...[
            SizedBox(width: 8.w),
            Text(
              functionName,
              style: StyleText.fontSize16Weight500.copyWith(
                color: functionNameColor ?? AppColors.textButton,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
