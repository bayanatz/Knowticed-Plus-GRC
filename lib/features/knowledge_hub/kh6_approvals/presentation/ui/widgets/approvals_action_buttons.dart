/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_action_buttons.dart
/// Description: Contains the action button to download/view files from Approvals.
/// Author: Amr Mesbah
/// Created at: 26/10/2025
/// Updated: Full file viewer support WITHOUT WebView
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_file_operations.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/file_preview_loader.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_states.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_haptic.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part 'approvals_action_buttons.viewers.dart';

// ✅ Initialize HapticController

// ✅ Animated Action Button Wrapper
class _AnimatedActionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _AnimatedActionButton({required this.child, required this.onTap});

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInBack));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (widget.onTap == null) return;

    hapticController.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );

    await _controller.forward();
    widget.onTap!();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: hapticDown(_onTap, HapticLevel.low),
      onTap: _onTap,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
      ),
    );
  }
}

class ApprovalsActionButtonsWidget extends StatelessWidget
    with _ApprovalsFileViewers {
  final String knowledgeId;
  final String fileName;
  final String fileType;
  final String fileUrl;
  final String department;
  final String fileExtension;

  const ApprovalsActionButtonsWidget({
    super.key,
    required this.knowledgeId,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.department,
    required this.fileExtension,
  });

  /// KH-CREATE-14: file actions are saved with the employee ID.
  String _currentEmployeeId(BuildContext context) =>
      context.read<ApprovalsCubit>().people.signedInEmployee?.id ?? '';

  String? _currentUserEmail(BuildContext context) =>
      context.read<ApprovalsCubit>().people.signedInEmployee?.email;

  /// ✅ Handle download action
  Future<void> _handleDownload(BuildContext context) async {
    final String? userEmail = _currentUserEmail(context);
    if (userEmail == null || userEmail.isEmpty) {
      showErrorDialog(context, S.of(context).downloadFailed);
      return;
    }

    showLoadingDialog(context, S.of(context).downloading);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!context.mounted) return;

    // Both calls handle their own failures (the cubit emits an error state,
    // downloadFile returns false), so no try/catch is needed here.
    await context.read<ApprovalsCubit>().recordFileAction(
      knowledgeId: knowledgeId,
      typeOfAction: 'download',
      employeeId: _currentEmployeeId(context),
    );
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

  /// ✅ Handle view action
  Future<void> _handleView(BuildContext context) async {
    final String? userEmail = _currentUserEmail(context);
    if (userEmail != null && userEmail.isNotEmpty) {
      await context.read<ApprovalsCubit>().recordFileAction(
        knowledgeId: knowledgeId,
        typeOfAction: 'view',
        employeeId: _currentEmployeeId(context),
      );
    }
    if (!context.mounted) return;

    final lightMode = Theme.of(context).brightness == Brightness.light;
    _showFileViewerDialog(
      context,
      fileUrl: fileUrl,
      fileName: fileName,
      fileExtension: fileExtension,
      lightMode: lightMode,
    );
  }

  /// ✅ Show file viewer dialog
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
                // Header with close button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
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

                // File content viewer
                Expanded(
                  child: _buildFileContent(
                    dialogContext,
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

  /// ✅ Build file content based on extension
  Widget _buildFileContent(
    BuildContext context, {
    required String fileUrl,
    required String fileExtension,
    required bool lightMode,
  }) {
    final extension = fileExtension.toLowerCase();

    // PDF files
    if (extension == 'pdf') {
      return _buildPdfViewer(fileUrl, lightMode);
    }

    // Image files
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return _buildImageViewer(context, fileUrl);
    }

    // Video files
    if ([
      'mp4',
      'avi',
      'mov',
      'wmv',
      'flv',
      'mkv',
      'webm',
    ].contains(extension)) {
      return _buildVideoPlayer(fileUrl, lightMode);
    }

    // Excel/CSV files
    if (['xls', 'xlsx', 'xlsm', 'csv'].contains(extension)) {
      return _buildOfficeFileViewer(context, fileUrl, extension, lightMode);
    }

    // Word/PowerPoint files
    if (['doc', 'docx', 'ppt', 'pptx'].contains(extension)) {
      return _buildDocumentPlaceholder(context, extension);
    }

    // Unsupported file type
    return _buildUnsupportedFileView(context, extension);
  }

  /// ✅ PDF Viewer

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApprovalsCubit, ApprovalsStates>(
      listener: (context, state) {
        if (state is RecordFileActionSuccess) {
          khLog(
            '${state.typeOfAction == 'download' ? 'Download' : 'View'} recorded successfully',
            name: 'ApprovalsActions',
          );
        } else if (state is RecordFileActionFailure) {
          khLog(
            'Failed to record action: ${state.error}',
            name: 'ApprovalsActions',
          );
        }
      },
      child: BlocBuilder<ApprovalsCubit, ApprovalsStates>(
        builder: (context, state) {
          final isLoading = state is RecordFileActionLoading;

          final bool canDownload = KnowledgeHubAccess.canDownload;
          final bool canView = KnowledgeHubAccess.canView;

          return Row(
            children: [
              if (canDownload)
                _buildActionButton(
                  context,
                  assetPath: 'assets/icons_assets/main_icons_assets/ic_action_cloud_download.svg',
                  functionName: S.of(context).download,
                  onTap: isLoading ? null : () => _handleDownload(context),
                ),
              // Only when both are showing, so a single button is not left
              // sitting against a 15pt gap.
              if (canDownload && canView) SizedBox(width: 15.w),
              if (canView)
                _buildActionButton(
                  context,
                  assetPath: 'assets/icons_assets/knowledge_hub_assets/ic_action_view.svg',
                  functionName: S.of(context).view,
                  onTap: isLoading ? null : () => _handleView(context),
                ),
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
  }) {
    final isMobile = ContextExtension(context).isPhone;

    return _AnimatedActionButton(
      onTap: onTap,
      child: Container(
        height: 38.h,
        width: isMobile ? 38.w : 135.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.primary,
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
                  color: AppColors.textButton,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ✅ Video Player Widget
class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool lightMode;

  const _VideoPlayerWidget({required this.videoUrl, required this.lightMode});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final controller = await FilePreviewLoader.initVideo(widget.videoUrl);
    if (!mounted) {
      await controller?.dispose();
      return;
    }
    if (controller == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = S.of(context).error;
      });
      return;
    }
    _videoPlayerController = controller;
    {
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: AppColors.colorGrey,
          bufferedColor: AppColors.primary.withValues(alpha: 0.3),
        ),
        placeholder: Container(
          color: AppColors.background.withValues(alpha: 0.87),
          child: Center(
            child: CircleProgressMaster.inline(color: AppColors.primary),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
                SizedBox(height: 16.h),
                Text(
                  S.of(context).khVideoLoadFailed,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleProgressMaster.inline(color: AppColors.primary),
            SizedBox(height: 16.h),
            Text(
              S.of(context).khLoadingVideo,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
            SizedBox(height: 16.h),
            Text(
              S.of(context).khVideoLoadFailed,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: AppColors.background.withValues(alpha: 0.87),
      child: Center(
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : SizedBox.shrink(),
      ),
    );
  }
}

// Helper function
Widget buildApprovalsActionButtons({
  required String knowledgeId,
  required String fileName,
  required String fileType,
  required String fileUrl,
  required String department,
  String fileExtension = '',
}) {
  return ApprovalsActionButtonsWidget(
    knowledgeId: knowledgeId,
    fileName: fileName,
    fileType: fileType,
    fileUrl: fileUrl,
    department: department,
    fileExtension: fileExtension,
  );
}
