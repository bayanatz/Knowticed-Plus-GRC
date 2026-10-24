/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/view_knowledge_details.dart
/// ************************* FILE INFO *************************** ///
/// File Name: view_knowledge_details.dart
/// Description: Contains the file info and comments section with conditional tabs for owners.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
/// Updated: Added Analytics & Statistics tabs for document owners
library;

import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/kh_comment_source.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_document_type.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/ui/widgets/document_info/document_details_section.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab/analytics_tab.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab/statistics_tab.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

part 'view_knowledge_details.sections.dart';
part '../widgets/view_knowledge_details.sections/view_knowledge_details_sections_builders.dart';

class ViewKnowledgeDetails extends StatefulWidget {
  final String documentName;
  final String documentNameAr;
  final String documentType;
  final String owningDepartment;
  final String documentEnglishDescription;
  final String documentEnglishDescriptionAr;
  final String publishDate;
  final String knowledgeId;
  final String fileUrl;
  final String fileType;
  final String documentExtension;
  final String emailUser; // ✅ Creator's email

  const ViewKnowledgeDetails({
    super.key,
    required this.documentName,
    required this.documentNameAr,
    required this.publishDate,
    required this.documentType,
    required this.owningDepartment,
    required this.documentEnglishDescription,
    required this.documentEnglishDescriptionAr,
    required this.knowledgeId,
    required this.fileType,
    required this.fileUrl,
    required this.emailUser,
    required this.documentExtension,
  });

  @override
  State<ViewKnowledgeDetails> createState() => _ViewKnowledgeDetailsState();
}

class _ViewKnowledgeDetailsState extends State<ViewKnowledgeDetails>
    with
        SingleTickerProviderStateMixin,
        _ViewKnowledgeDetailsSections,
        _ViewKnowledgeDetailsSectionsBuilders {
  @override
  void initState() {
    super.initState();

    // ✅ Determine if current user is the owner
    isOwner = _checkIfOwner();

    khLog(
      '═══════════════════════════════════════',
      name: 'ViewKnowledgeDetails',
    );
    khLog('📄 Document: ${widget.documentName}', name: 'ViewKnowledgeDetails');
    khLog(
      '👤 Creator Email: ${widget.emailUser}',
      name: 'ViewKnowledgeDetails',
    );
    khLog('✓ Is Owner: $isOwner', name: 'ViewKnowledgeDetails');
    khLog(
      '═══════════════════════════════════════',
      name: 'ViewKnowledgeDetails',
    );

    // ✅ Initialize TabController ONLY for owners (3 tabs)
    if (isOwner) {
      _tabController = TabController(length: 3, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchStatisticsController.dispose();
    _disposeCommentControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    // ✅ Get localized document name
    final localizedDocumentName = KhLocale.pick(
      context,
      en: widget.documentName,
      ar: widget.documentNameAr,
    );

    // ✅ Get localized description
    final localizedDescription = KhLocale.pick(
      context,
      en: widget.documentEnglishDescription,
      ar: widget.documentEnglishDescriptionAr,
    );

    // ✅ Get localized document type
    final localizedDocumentType = KhDocumentType.label(
      context,
      widget.documentType,
    );

    final String localizedDepartment = KhLocale.department(
      context,
      widget.owningDepartment,
    );

    return MultiBlocProvider(
      providers: [
        // ✅ CommentsCubit - Always needed
        BlocProvider(
          create: (context) =>
              KnowledgeHubDI.commentsCubit()..fetchComments(widget.knowledgeId),
        ),
        // ✅ AnalyticsCubit - Only for owners
        if (isOwner)
          BlocProvider(
            create: (context) => KnowledgeHubDI.analyticsCubit()
              ..fetchAnalytics(widget.knowledgeId),
          ),
      ],
      child: Scaffold(
        body: BlocListener<CommentsCubit, CommentsState>(
          listener: (context, state) {
            if (state is CreateCommentSuccess) {
              khLog('Comment added successfully', name: 'ViewKnowledgeDetails');
            } else if (state is CreateCommentFailure) {
              _showErrorDialog(context, state.error);
            }
          },
          child: SideFrameMasterServices(
            titleText: S.of(context).knowledge_hub,
            onFirstTap: () => Navigator.of(context).pop(),
            secondTitle: localizedDocumentName,
            // "when I try to scroll it doesn't scroll".
            // This was a SingleChildScrollView with AlwaysScrollable physics
            // INSIDE the frame's own scroll view. On the phone layout it had
            // nothing to scroll (unbounded height) but, being "always
            // scrollable", it still grabbed every drag — so the page never
            // moved. SideFrameScrollableBody scrolls only where the frame
            // doesn't, so exactly one scroll view handles the gesture.
            child: SideFrameScrollableBody(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // ✅ Document Info Section - Always visible at top
                  buildDocumentDetailsSection(
                    context,
                    documentName: localizedDocumentName,
                    documentType: localizedDocumentType,
                    owningDepartment: localizedDepartment,
                    documentDescription: localizedDescription,
                    publishDate: widget.publishDate,
                    fileType: widget.fileType,
                    fileUrl: widget.fileUrl,
                    knowledgeId: widget.knowledgeId,
                    documentExtension: widget.documentExtension,
                    createdByEmail: widget.emailUser,
                    people: KnowledgeHubDI.people,
                  ),

                  SizedBox(height: 15.h),

                  // ✅ CONDITIONAL RENDERING: Tabs for Owner, Simple Comments for Contributors
                  if (isOwner)
                    _buildOwnerTabsView(context, lightMode)
                  else
                    _buildContributorCommentsView(context, lightMode),
                  SizedBox(height: 20.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
