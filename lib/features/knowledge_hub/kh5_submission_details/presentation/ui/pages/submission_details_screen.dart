/// Module: knowledge_hub/kh5_submission_details/presentation/ui/pages
/// ************************* FILE INFO *************************** ///
/// File Name: submission_details_screen.dart
/// Description: Submission details screen — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/submission_details_contents/published_content.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/submission_date_formatter.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_cubit.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class SubmissionDetailsScreen extends StatefulWidget {
  final String documentName;
  final String documentNameAr;
  final String documentType;
  final String documentEnglishDescriptionAr;
  final String owningDepartment;
  final String documentEnglishDescription;
  final String submissionDate;
  final String fileType;
  final String fileUrl;
  final String knowledgeId;
  final String documentExtension;
  final String currentStatus;
  final List<String>? limitedDepartments;
  final dynamic startDate;
  final dynamic endDate;
  final dynamic startTime;
  final dynamic endTime;
  final List<String>? statusHistory;
  final String createdBy;

  const SubmissionDetailsScreen({
    super.key,
    required this.documentName,
    required this.documentNameAr,
    required this.documentType,
    required this.documentEnglishDescriptionAr,
    required this.owningDepartment,
    required this.documentEnglishDescription,
    required this.submissionDate,
    required this.fileType,
    required this.fileUrl,
    required this.knowledgeId,
    required this.documentExtension,
    required this.currentStatus,
    this.limitedDepartments,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.statusHistory,
    required this.createdBy,
  });

  @override
  State<SubmissionDetailsScreen> createState() =>
      _SubmissionDetailsScreenState();
}

class _SubmissionDetailsScreenState extends State<SubmissionDetailsScreen> {
  final TextEditingController _searchStatisticsController =
      TextEditingController();

  static const String _publishedStatus = 'published';

  @override
  void initState() {
    super.initState();
    if (widget.currentStatus != _publishedStatus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SubmissionsCubit>().fetchCommentsByKnowledgeId(
          widget.knowledgeId,
        );
      });
    }
  }

  @override
  void dispose() {
    _searchStatisticsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    // Format the dates and times
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final formattedStartDate = SubmissionDateFormatter.formatDateTime(
      widget.startDate,
      locale: locale,
    );
    final formattedEndDate = SubmissionDateFormatter.formatDateTime(
      widget.endDate,
      locale: locale,
    );
    final formattedStartTime = SubmissionDateFormatter.formatTime(
      widget.startTime,
      locale: locale,
    );
    final formattedEndTime = SubmissionDateFormatter.formatTime(
      widget.endTime,
      locale: locale,
    );

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).knowledge_hub,
        secondTitle: S.of(context).submissions,
        thirdTitle: KhLocale.pick(
          context,
          en: widget.documentName,
          ar: widget.documentNameAr,
        ),
        onFirstTap: () => Navigator.of(context).pop(),
        onSecondTap: () => Navigator.of(context).pop(),
        // KH vertical report p.16: keep "Knowledge Hub" in the path.
        verticalTabletCrumbs: 3,
        child: buildPublishedContent(
          context,
          createdBy: widget.createdBy,
          documentNameAr: widget.documentNameAr,
          documentName: widget.documentName,
          documentDescriptionAr: widget.documentEnglishDescriptionAr,
          documentType: widget.documentType,
          owningDepartment: widget.owningDepartment,
          documentDescription: widget.documentEnglishDescription,
          publishDate: widget.submissionDate,
          fileType: widget.fileType,
          fileUrl: widget.fileUrl,
          knowledgeId: widget.knowledgeId,
          documentExtension: widget.documentExtension,
          isMobile: isMobile,
          currentStatus: widget.currentStatus,
          limitedDepartments: widget.limitedDepartments,
          lightMode: lightMode,
          searchStatisticsController: _searchStatisticsController,
          startDate: formattedStartDate,
          endDate: formattedEndDate,
          startTime: formattedStartTime,
          endTime: formattedEndTime,
          statusHistory: widget.statusHistory ?? [],
        ),
      ),
    );
  }
}
