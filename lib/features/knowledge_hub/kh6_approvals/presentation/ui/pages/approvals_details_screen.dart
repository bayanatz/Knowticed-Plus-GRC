/// Module: knowledge_hub/kh6_approvals/presentation/ui/pages
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_details_screen.dart
/// Description: Approvals details screen — Approvals Details (S7) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/kh_comment_source.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_approve_reject_buttons.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_system_log.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/approvals_action_buttons.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/reason_for_justifications_dialog.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/reason_for_approval_removing_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/submission_date_formatter.dart';

import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_states.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

part 'approvals_details_screen.sections.dart';
part '../widgets/approvals_details_screen.sections/approvals_details_sections_builders.dart';
part '../widgets/approvals_details_screen.sections/approvals_details_build_parts.dart';

/// The approvals details screen.
///
/// Key Features:
/// - ✅ Real-time status updates (approved/rejected)
/// - ✅ Arabic/English localization for title, description
/// - ✅ Formatted phone numbers with country code
/// - ✅ Proper SVG icons and colors for all statuses
/// - ✅ BlocListener for state management
/// - ✅ Dynamic action buttons based on status
/// - ✅ Start/End dates and times display

class ApprovalsDetailsScreen extends StatefulWidget {
  final String documentName;
  final String knowledgeId;
  final String fileName;
  final String fileType;
  final String fileUrl;
  final String department;
  final String documentDesc;
  final String createdByEmail;
  final int? createdTimestamp;
  final String status;
  final String fileExtension;
  final dynamic startDate;
  final dynamic endDate;
  final dynamic startTime;
  final dynamic endTime;

  const ApprovalsDetailsScreen({
    super.key,
    required this.documentName,
    required this.knowledgeId,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.department,
    required this.documentDesc,
    required this.createdByEmail,
    this.createdTimestamp,
    required this.status,
    required this.fileExtension,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  });

  @override
  State<ApprovalsDetailsScreen> createState() => _ApprovalsDetailsScreenState();
}

class _ApprovalsDetailsScreenState extends State<ApprovalsDetailsScreen>
    with
        _ApprovalsDetailsSections,
        _ApprovalsDetailsSectionsBuilders,
        _ApprovalsDetailsBuildParts {
  // ---- fields & helpers moved to _ApprovalsDetailsSections (approvals_details_screen.sections.dart) ----

  @override
  void initState() {
    super.initState();
    currentStatus = widget.status;
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final statusInfo = _getStatusInfo(currentStatus);
    final String status = currentStatus.toLowerCase();
    final bool awaitingDecision = status == 'pending' ||
        status == 'pending_approval' ||
        status == 'scheduled';

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).knowledge_hub,
        secondTitle: S.of(context).approvals,
        thirdTitle: _getLocalizedDocumentName(),
        onFirstTap: () => Navigator.of(context).pop(),
        onSecondTap: () => Navigator.of(context).pop(),
        child: BlocListener<ApprovalsCubit, ApprovalsStates>(
          listener: _onApprovalsState,
          child: isLoading
              ? Center(child: CircleProgressMaster())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDetailsHeader(isMobile),
                      SizedBox(height: 8.h),
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.all(15.sp),
                            child: Column(
                              children: [
                                _buildDocumentTitleRow(isMobile, lightMode),
                                if (isMobile) SizedBox(height: 10.sp),
                                if (isMobile) ..._buildMobileDescription(),
                                SizedBox(height: isMobile ? 20.h : 25.h),
                                ..._buildCreatorInfoRows(isMobile, lightMode),
                                ..._buildContactAndScheduleRows(
                                  isMobile,
                                  lightMode,
                                ),
                                if (status == 'removed')
                                  _buildRemovalReason(isMobile),
                                SizedBox(height: 24.h),
                                if (awaitingDecision)
                                  _buildApprovalButtons(isMobile, lightMode)
                                else
                                  _buildStatusBadge(
                                    isMobile,
                                    lightMode,
                                    statusInfo,
                                  ),
                              ],
                            ),
                          ),
                          if (!isMobile) _buildRequestedDateCorner(),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      ..._buildCommentsSection(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
