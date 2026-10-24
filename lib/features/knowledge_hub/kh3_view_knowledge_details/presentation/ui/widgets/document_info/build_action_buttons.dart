/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/build_action_buttons.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_action_buttons.dart
/// Description: Contains the action button to download/view files from knowledge hub.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
/// Updated: Added permission check for removing any document (not just owned ones)
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/ui/pages/creating_knowledge_hub.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/controller/knowledge_removal_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_file_operations.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_states.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ActionButtonsWidget extends StatelessWidget {
  final String knowledgeId;
  final String fileName;
  final String fileType;
  final String fileUrl;
  final String department;
  final String documentExtension;
  final String? createdBy; // ✅ Creator's email

  const ActionButtonsWidget({
    super.key,
    required this.knowledgeId,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.department,
    required this.documentExtension,
    this.createdBy,
    required String createdByEmail,
  });

  /// Whether the signed-in user may remove this document.
  ///
  /// KH-CREATE-13. This allowed the creator regardless of
  /// the role's "remove documents" switch. The correct rule already lived in
  /// [KnowledgeHubAccess.canRemove] (remove switched on, AND creator or
  /// allowed to remove anyone's) but nothing called it. It is now used for
  /// the button AND re-checked in the remove action itself.
  bool _canRemoveDocument(BuildContext context) {
    final String currentUserEmail =
        _currentUserEmail(context).toLowerCase().trim();
    final bool isCreator = createdBy != null &&
        currentUserEmail.isNotEmpty &&
        currentUserEmail == createdBy!.toLowerCase().trim();
    return KnowledgeHubAccess.canRemove(isCreator: isCreator);
  }

  /// KH large-screen report p.9 "Add Edit Button": the
  /// owner can edit their document from its details page, with the same
  /// [EditAccess] rule the Submissions details page uses.
  bool _canEditDocument(BuildContext context) {
    final String currentUserEmail =
        _currentUserEmail(context).toLowerCase().trim();
    final bool isCreator = createdBy != null &&
        currentUserEmail.isNotEmpty &&
        currentUserEmail == createdBy!.toLowerCase().trim();
    return isCreator && KnowledgeHubAccess.editAccess.canEdit;
  }

  void _handleEdit(BuildContext context) {
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

  /// The signed-in user's e-mail, or '' when the employee is not loaded.
  String _currentUserEmail(BuildContext context) =>
      context.read<CommentsCubit>().people.signedInEmail;

  /// The signed-in user's employee ID, or '' when the employee is not loaded.
  /// File actions are saved with it (KH-CREATE-14).
  String _currentEmployeeId(BuildContext context) =>
      context.read<CommentsCubit>().people.signedInEmployee?.id ?? '';

  bool _isCreator(String currentUserEmail) =>
      createdBy != null &&
      currentUserEmail.isNotEmpty &&
      currentUserEmail.toLowerCase().trim() == createdBy!.toLowerCase().trim();

  /// Downloads the file. A download by the author is not counted.
  Future<void> _handleDownload(BuildContext context) async {
    final String currentUserEmail = _currentUserEmail(context);
    showLoadingDialog(context, S.of(context).downloading);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!context.mounted) return;

    if (!_isCreator(currentUserEmail)) {
      await context.read<CommentsCubit>().recordFileAction(
            knowledgeId: knowledgeId,
            typeOfAction: 'download',
            employeeId: _currentEmployeeId(context),
          );
    }
    if (!context.mounted) return;

    final bool success = await downloadFile(
      context,
      fileUrl: fileUrl,
      fileName: fileName,
    );
    if (!context.mounted) return;

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    if (success) {
      showSuccessDialog(context, S.of(context).fileDownloadedSuccessfully);
    } else {
      showErrorDialog(context, S.of(context).downloadFailed);
    }
  }

  /// Opens the file in the viewer dialog. A view by the author is not
  /// counted.
  Future<void> _handleView(BuildContext context) async {
    final String currentUserEmail = _currentUserEmail(context);
    if (!_isCreator(currentUserEmail)) {
      await context.read<CommentsCubit>().recordFileAction(
            knowledgeId: knowledgeId,
            typeOfAction: 'view',
            employeeId: _currentEmployeeId(context),
          );
    }
    if (!context.mounted) return;
    _showFileViewerDialog(
      context,
      fileUrl: fileUrl,
      fileName: fileName,
      fileExtension: documentExtension,
      lightMode: Theme.of(context).brightness == Brightness.light,
    );
  }

  /// ✅ Handle remove action - Updates status to "removed" with dynamic company ID
  ///
  /// . The
  /// 22/9/2026 version asked "are you sure" AND collected the justification in
  /// ONE hand-built dialog, which matched nothing else in the app. It now runs
  /// the app's standard sequence, `CustomDialogManager.showDialogFlow` — the
  /// same one editing a document uses (confirm → "Reason Of Editing" →
  /// success): a Remove Knowledge confirmation, then a separate "Reason Of
  /// Removing" dialog, then the success dialog. The reason is still required
  /// and still stored through `removeKnowledgeWithReason`.
  ///
  /// The page pops with `true` after a removal so the list that opened it
  /// can refetch — see Knowledge Hub p.17, where the removed card stayed on
  /// the list until the user logged out and back in.
  Future<void> _handleRemove(BuildContext context) async {
    // KH-CREATE-13: enforce the rule in the action too, not only by hiding
    // the button.
    if (!_canRemoveDocument(context)) return;
    khLog(
      '🗑️ Remove initiated for: $fileName ($knowledgeId)',
      name: 'ViewKnowledgeRemove',
    );

    final TextEditingController reasonController = TextEditingController();
    bool removed = false;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_rejected.json',
      confirmTitle: S.of(context).removeKnowledge,
      confirmSubtitle: S.of(context).areYouSureDeleteKnowledge,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,

      // Reason step — required: the author is told why their document was
      // pulled, and a blank reason tells them nothing.
      comment: true,
      commentRequired: true,
      commentController: reasonController,
      customReasonTitle: S.of(context).reasonOfRemoving,
      commentSubmitText: S.of(context).submit,
      commentDiscardText: S.of(context).discard,
      onCommentSubmit: () async => true,

      // The removal itself. Returning false stops the flow before the success
      // dialog, so a failed removal cannot report success.
      onConfirm: () async {
        if (!context.mounted) return false;
        showLoadingDialog(context, S.of(context).Delete);
        // Read before the wait, so no context is used across the gap.
        final String currentUserEmail = _currentUserEmail(context);
        await Future.delayed(const Duration(milliseconds: 100));

        final KnowledgeRemovalCubit removal =
            KnowledgeHubDI.knowledgeRemovalCubit();
        await removal.remove(
          documentId: knowledgeId,
          currentUserEmail: currentUserEmail,
          justification: reasonController.text.trim(),
        );
        final KnowledgeRemovalState outcome = removal.state;
        await removal.close();

        // Close the loading dialog.
        if (context.mounted &&
            Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (!context.mounted) return false;

        if (outcome is KnowledgeRemovalFailure) {
          showErrorDialog(
            context,
            outcome.error == KnowledgeRemovalError.notFound
                ? S.of(context).khDocumentNotFound
                : S.of(context).khRemoveDocumentFailed,
          );
          return false;
        }
        if (outcome is! KnowledgeRemovalSuccess) return false;

        removed = true;
        return true;
      },

      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
      successTitle: S.of(context).successful,
      successSubtitle: S.of(context).knowledgeRemovedSuccessfully,
      onSuccessComplete: () {
        if (removed && context.mounted) Navigator.of(context).pop(true);
      },
    );

    reasonController.dispose();
  }

  /// ✅ Show file viewer dialog - LOADS FILE DIRECTLY
  void _showFileViewerDialog(
    BuildContext context, {
    required String fileUrl,
    required String fileName,
    required String fileExtension,
    required bool lightMode,
  }) {
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
                _buildViewerHeader(
                  dialogContext,
                  fileName: fileName,
                  lightMode: lightMode,
                ),
                Expanded(
                  child: _buildFileContent(
                    dialogContext,
                    fileUrl: fileUrl,
                    fileExtension: fileExtension,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// File name and close button at the top of the viewer dialog.
  Widget _buildViewerHeader(
    BuildContext dialogContext, {
    required String fileName,
    required bool lightMode,
  }) {
    return Container(
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
    );
  }

  /// ✅ Build file content - DIRECT LOADING FROM URL
  Widget _buildFileContent(
    BuildContext context, {
    required String fileUrl,
    required String fileExtension,
  }) {
    final extension = fileExtension.toLowerCase().replaceAll('.', '');
    if (extension == 'pdf') return _buildPdfViewer(fileUrl);
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return _buildImageViewer(context, fileUrl);
    }
    return _buildNoPreview(context, extension);
  }

  Widget _buildPdfViewer(String fileUrl) {
    // See the note in K5's _buildPDFViewer for why the url is logged.
    khLog('📄 [KH-VIEWER] pdf url: $fileUrl', name: 'ViewKnowledgeView');
    return Container(
      color: AppColors.background,
      // "every knowledge view the same file": `SfPdfViewer` keeps the loaded
      // document in its State and does NOT reload it when only the URL
      // changes. Keying on the URL makes a different document a different
      // element, so the right file loads; the same document reopened keeps
      // its cache.
      child: SfPdfViewer.network(
        key: ValueKey<String>(fileUrl),
        fileUrl,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
      ),
    );
  }

  /// Image files - LOAD DIRECTLY FROM URL
  Widget _buildImageViewer(BuildContext context, String fileUrl) {
    return Container(
      color: AppColors.background,
      child: PhotoView(
        // Keyed for the same reason as the pdf viewer above.
        key: ValueKey<String>(fileUrl),
        imageProvider: NetworkImage(fileUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        initialScale: PhotoViewComputedScale.contained,
        backgroundDecoration: BoxDecoration(color: AppColors.background),
        loadingBuilder: (context, event) => Center(
          child: CircleProgressMaster.inline(
            color: AppColors.primary,
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
          ),
        ),
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

  /// For other file types (Excel, Word, etc.)
  Widget _buildNoPreview(BuildContext context, String extension) {
    final S s = S.of(context);
    return Center(
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
            s.khPreviewNotAvailable,
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.blackButton,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            s.khFileType(extension),
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
              s.khDownloadToView,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Logs whether a view / download was recorded.
  void _onCommentsState(BuildContext context, CommentsState state) {
    if (state is RecordFileActionSuccess) {
      khLog(
        '${state.actionType == 'download' ? 'Download' : 'View'} recorded successfully',
        name: 'ViewKnowledgeActions',
      );
    } else if (state is RecordFileActionFailure) {
      khLog(
        'Failed to record action: ${state.error}',
        name: 'ViewKnowledgeActions',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Check if user can remove this document
    final bool canRemove = _canRemoveDocument(context);
    final bool canEdit = _canEditDocument(context);

    return BlocListener<CommentsCubit, CommentsState>(
      listener: _onCommentsState,
      child: BlocBuilder<CommentsCubit, CommentsState>(
        builder: (context, state) {
          final isLoading = state is RecordFileActionLoading;

          return Row(
            children: [
              if (KnowledgeHubAccess.has(
                section:
                    KnowledgeHubPermissionsSections.knowledgeHubPermissions,
                permission: KnowledgeHubPermissions.viewDocuments,
              ))
                // View Button
                _buildActionButton(
                  context,
                  assetPath:
                      "assets/icons_assets/knowledge_hub_assets/ic_action_view.svg",
                  functionName: S.of(context).view,
                  onTap: isLoading ? null : () => _handleView(context),
                ),
              SizedBox(width: 15.w),

              if (KnowledgeHubAccess.has(
                section:
                    KnowledgeHubPermissionsSections.knowledgeHubPermissions,
                permission: KnowledgeHubPermissions.downloadDocuments,
              ))
                // Download Button
                _buildActionButton(
                  context,
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_action_cloud_download.svg',
                  functionName: S.of(context).download,
                  onTap: isLoading ? null : () => _handleDownload(context),
                ),

              // Only add Spacer if showing edit/remove buttons
              if (canRemove || canEdit) Spacer(),

              if (canEdit)
                _buildActionButton(
                  context,
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_action_edit.svg',
                  functionName: S.of(context).edit,
                  onTap: isLoading ? null : () => _handleEdit(context),
                ),

              // Remove Button - Show if user is creator OR has permission
              if (canRemove) ...[
                SizedBox(width: 15.w),
                customButtonWithSvg(
                  // 14/10/2026 — KH mobile report p.12 "just the icon": on a
                  // phone Remove is an icon button like View and Download.
                  title: ContextExtension(context).isPhone
                      ? ''
                      : S.of(context).remove,
                  function: () => _handleRemove(context),
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.white,
                  ),
                  width: 135.sp,
                  height: 38.sp,
                  space: 8.sp,
                  radius: 8.r,
                  color: AppColors.red,
                  image:
                      "assets/icons_assets/knowledge_hub_assets/ic_action_trash_circle.svg",
                  svgColor: AppColors.colorWhite,
                  widthImage: 20.w,
                  heightImage: 20.h,
                  colorBorder: AppColors.transparent,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String assetPath,
    required String functionName,
    required VoidCallback? onTap,
    Color? buttonColor,
    Color? textColor,
  }) {
    final isMobile = ContextExtension(context).isPhone;
    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: Container(
        height: 38.h,
        width: isMobile ? 38.w : 135.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: buttonColor ?? AppColors.primary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgImage(
              assetPath: assetPath,
              width: 20.w,
              height: 20.h,
              fit: BoxFit.fill,
              color: AppColors.textButton,
            ),
            if (!isMobile) ...[
              SizedBox(width: 8.w),
              Text(
                functionName,
                style: StyleText.fontSize16Weight500.copyWith(
                  color: textColor ?? AppColors.textButton,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ✅ Helper function with createdBy parameter
Widget buildActionButtons({
  required String knowledgeId,
  required String fileName,
  required String fileType,
  required String fileUrl,
  required String department,
  required String createdByEmail,
  required String documentExtension,
  String? createdBy,
}) {
  return ActionButtonsWidget(
    knowledgeId: knowledgeId,
    fileName: fileName,
    fileType: fileType,
    fileUrl: fileUrl,
    department: department,
    createdByEmail: createdByEmail,
    documentExtension: documentExtension,
    createdBy: createdBy,
  );
}
