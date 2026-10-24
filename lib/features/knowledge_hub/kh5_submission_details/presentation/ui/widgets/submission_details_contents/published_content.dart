/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/submission_details_contents
/// ************************* FILE INFO *************************** ///
/// File Name: published_content.dart
/// Description: Build published content — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/kh_comment_source.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_system_log.dart';
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/submissions_permissions_enum.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_file_operations.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/ui/pages/creating_knowledge_hub.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/custom_validated_text_field.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_section.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/submission_date.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/submitted_document_header.dart';
import 'package:flutter/services.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_haptic.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart'
    show SideFrameScrollableBody;
// The Download and Edit permission checks in the .viewers
// part file below.
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/controller/knowledge_removal_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_document_type.dart';

part 'published_content.viewers.dart';
part 'published_content.info_card.dart';
part 'published_content.dialog.dart';
part 'published_content.info_card/status_button.dart';

// CREATE: Animated Action Button Wrapper
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

    await Future.delayed(const Duration(milliseconds: 100));
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

Widget buildPublishedContent(
  BuildContext context, {
  required bool isMobile,
  required bool lightMode,
  required String documentName,
  required String documentNameAr,
  required String documentType,
  required String owningDepartment,
  required String documentDescription,
  required String documentDescriptionAr,
  required String publishDate,
  required String fileType,
  required String fileUrl,
  required String knowledgeId,
  required String documentExtension,
  required String currentStatus,
  required List<String>? limitedDepartments,
  required TextEditingController searchStatisticsController,
  required List<String>? statusHistory,
  String? startDate,
  String? endDate,
  String? startTime,
  String? endTime,
  required String createdBy,
}) {
  final bool hasBeenPublished =
      statusHistory?.any((status) => status.toLowerCase() == 'published') ??
          false;
  final String localizedName = KhLocale.pick(
    context,
    en: documentName,
    ar: documentNameAr,
  );

  // "when I try to scroll it doesn't scroll": SideFrameScrollableBody scrolls
  // ONLY where the frame doesn't, and the analytics section takes its
  // natural height so the page scrolls through all of it.
  return SideFrameScrollableBody(
    physics: const ClampingScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionButtonsSection(
          context,
          currentStatus: currentStatus,
          knowledgeId: knowledgeId,
          fileUrl: fileUrl,
          documentFileName: localizedName,
          documentExtension: documentExtension,
          isMobile: isMobile,
          lightMode: lightMode,
          createdBy: createdBy,
        ),
        SizedBox(height: 15.h),
        _buildDocumentInfoCard(
          context,
          publishDate: publishDate,
          documentName: localizedName,
          documentNameAr: documentNameAr,
          documentType: KhDocumentType.label(context, documentType),
          owningDepartment: KhLocale.department(context, owningDepartment),
          documentDescription: KhLocale.pick(
            context,
            en: documentDescription,
            ar: documentDescriptionAr,
          ),
          documentExtension: documentExtension,
          isMobile: isMobile,
          currentStatus: currentStatus,
          statusHistory: statusHistory,
          limitedDepartments: limitedDepartments,
          lightMode: lightMode,
          knowledgeId: knowledgeId,
          startDate: startDate,
          endDate: endDate,
          startTime: startTime,
          endTime: endTime,
          createdBy: createdBy,
        ),
        // 14/10/2026 — KH report p.17 "equalize padding": the card's 20.h is
        // the gap above the tabs, matching the 20.h under them.
        SizedBox(height: 20.h),
        if (hasBeenPublished)
          buildAnalyticsSection(
            context,
            lightMode: lightMode,
            knowledgeId: knowledgeId,
            searchStatisticsController: searchStatisticsController,
          )
        else
          _buildSubmissionComments(context, knowledgeId),
        // 20.sp breathing room at the bottom (bug report 11/10/2026).
        SizedBox(height: 20.sp),
      ],
    ),
  );
}

/// The shared comment box (UniversalCommentSection) of a document that was
/// never published.
Widget _buildSubmissionComments(BuildContext context, String knowledgeId) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 20.h),
      UniversalCommentSection(
        // 22/10/2026: old- and new-format comments (KhCommentSource).
        source: KhCommentSource(knowledgeId: knowledgeId),
        currentUserId: context.read<SubmissionsCubit>().people.signedInEmail,
        onCommentAdded: (_) =>
            khSystemLog(KhLogAction.submitInquiryComment), // System Logs §3
        isExpandable: true,
        fixedHeight: MediaQuery.of(context).size.height,
        style: _submissionCommentStyle(),
      ),
    ],
  );
}

CommentSectionStyle _submissionCommentStyle() {
  final BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(8.r),
  );
  return CommentSectionStyle(
    hintStyle: StyleText.fontSize16Weight400.copyWith(
      color: AppColors.secondaryText.withValues(alpha: .5),
    ),
    commentTextStyle: StyleText.fontSize18Weight500.copyWith(
      color: AppColors.text,
    ),
    fileChipDecoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(8.r),
    ),
    fileIconColor: AppColors.text,
    fileNameStyle: StyleText.fontSize12Weight400.copyWith(
      color: AppColors.text,
    ),
    avatarColor: AppColors.background,
    inputFillColor: AppColors.card,
    containerDecoration: cardDecoration,
    commentItemDecoration: BoxDecoration(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(8.r),
    ),
    userNameStyle: StyleText.fontSize16Weight400.copyWith(
      color: AppColors.text,
    ),
    sendButtonDecoration: BoxDecoration(
      color: AppColors.secondaryPrimary,
      borderRadius: BorderRadius.circular(8.r),
    ),
    sendIconColor: AppColors.secondaryPrimaryText,
  );
}
